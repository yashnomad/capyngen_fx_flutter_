import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../network/api_service.dart';
import '../services/data_feed_ws.dart';
import '../services/storage_service.dart';

enum SocketStatus { connecting, connected, disconnected }

class DataFeedProvider extends ChangeNotifier with WidgetsBindingObserver {
  final DataFeedWS _socket = DataFeedWS();

  final Map<String, LiveProfit> _liveData = {};
  final Set<String> _subscribedSymbols = {};

  SocketStatus _socketStatus = SocketStatus.disconnected;
  bool _isConnected = false;

  String? _lastJwt;
  String? _lastTradeUserId;

  bool _isReconnecting = false;
  bool _isAppInForeground = true;

  // ✅ Track last data time to detect stale connection
  DateTime? _lastDataReceivedAt;

  Map<String, LiveProfit> get liveData => _liveData;
  SocketStatus get socketStatus => _socketStatus;

  DataFeedProvider() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    debugPrint('📱 [Lifecycle] State: $state');

    switch (state) {
      case AppLifecycleState.resumed:
        _isAppInForeground = true;
        _handleAppResumed();
        break;

      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _isAppInForeground = false;
        break;

      case AppLifecycleState.detached:
        _isAppInForeground = false;
        _socket.disconnect();
        _isConnected = false;
        _socketStatus = SocketStatus.disconnected;
        notifyListeners();
        break;

      default:
        break;
    }
  }

  void _handleAppResumed() {
    debugPrint('📱 [Resume] _isConnected: $_isConnected');
    debugPrint('📱 [Resume] socket.isConnected: ${_socket.isConnected}');

    if (_isReconnecting) {
      debugPrint('⏳ [Resume] Already reconnecting');
      return;
    }

    if (!_hasCredentials()) {
      debugPrint('⚠️ [Resume] No credentials');
      return;
    }

    // ✅ SMART CHECK: Wait briefly, then verify if socket is REALLY alive
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _verifyAndReconnectIfNeeded();
    });
  }

  // ✅ Check if connection is truly alive
  void _verifyAndReconnectIfNeeded() {
    debugPrint('🔍 [Verify] Checking real connection status...');
    debugPrint('🔍 [Verify] _isConnected: $_isConnected');
    debugPrint('🔍 [Verify] socket.isConnected: ${_socket.isConnected}');
    debugPrint('🔍 [Verify] lastDataAt: $_lastDataReceivedAt');

    // Case 1: Socket already knows it's disconnected
    if (!_isConnected || !_socket.isConnected) {
      debugPrint('🔄 [Verify] Socket is disconnected → reconnecting');
      _scheduleReconnect();
      return;
    }

    // Case 2: Socket says connected but no data received recently (stale)
    if (_lastDataReceivedAt != null) {
      final staleDuration = DateTime.now().difference(_lastDataReceivedAt!);
      if (staleDuration.inSeconds > 10) {
        debugPrint(
            '🔄 [Verify] Connection stale (${staleDuration.inSeconds}s) → reconnecting');
        _scheduleReconnect();
        return;
      }
    }

    // Case 3: Truly connected and receiving data
    debugPrint('✅ [Verify] Connection is alive, resubscribing symbols');
    resubscribeAll();
  }

  // ✅ Getter to check if provider is still active
  bool get mounted => _isAppInForeground;

  void _handleUnexpectedDisconnect() {
    if (!_isAppInForeground) {
      debugPrint('📱 [Disconnect] App in background, skip');
      return;
    }

    if (_isReconnecting) {
      debugPrint('⏳ [Disconnect] Already reconnecting');
      return;
    }

    if (!_hasCredentials()) {
      debugPrint('⚠️ [Disconnect] No credentials');
      return;
    }

    debugPrint('🔄 [Disconnect] Auto-reconnecting...');
    _scheduleReconnect();
  }

  bool _hasCredentials() {
    if (_lastJwt != null &&
        _lastTradeUserId != null &&
        _lastTradeUserId!.isNotEmpty) {
      return true;
    }

    final token = StorageService.getToken();
    if (token != null &&
        _lastTradeUserId != null &&
        _lastTradeUserId!.isNotEmpty) {
      _lastJwt = token;
      return true;
    }

    return false;
  }

  void _scheduleReconnect() {
    if (_isReconnecting) return;

    _isReconnecting = true;
    _socketStatus = SocketStatus.connecting;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!_isReconnecting) return;
      _reconnect();
    });
  }

  void _reconnect() {
    debugPrint('🔄 [Reconnect] Starting...');

    // ✅ DON'T clear _liveData - keep showing old prices until new ones arrive
    // ✅ DON'T clear _subscribedSymbols - need them for resubscription
    _socket.disconnect();
    _isConnected = false;

    _connectInternal(_lastJwt!, _lastTradeUserId!);
  }

  void connect(String jwt, String tradeUserId) {
    if (tradeUserId.isEmpty) {
      debugPrint("⚠️ Cannot connect: empty userId");
      return;
    }

    _lastJwt = jwt;
    _lastTradeUserId = tradeUserId;

    _connectInternal(jwt, tradeUserId);
  }

  void _connectInternal(String jwt, String tradeUserId) {
    debugPrint('🔧 [Provider] Connecting userId: $tradeUserId');

    _socket.connect(
      jwt: jwt,
      tradeUserId: tradeUserId,
      onConnecting: () {
        _socketStatus = SocketStatus.connecting;
        notifyListeners();
      },
      onConnected: () {
        debugPrint('✅ [Provider] Connected!');
        _isConnected = true;
        _isReconnecting = false;
        _socketStatus = SocketStatus.connected;
        _lastDataReceivedAt = DateTime.now();

        resubscribeAll();
        notifyListeners();
      },
      onLiveData: (profits) {
        // ✅ Track last data time
        _lastDataReceivedAt = DateTime.now();

        for (var p in profits) {
          _liveData[p.symbol] = p;
        }
        notifyListeners();
      },
      onDisconnect: () {
        debugPrint('🔌 [Provider] Disconnected');

        final wasConnected = _isConnected;
        _isConnected = false;
        _socketStatus = SocketStatus.disconnected;
        notifyListeners();

        // ✅ Only auto-reconnect if we WERE connected (not manual disconnect)
        if (wasConnected) {
          _handleUnexpectedDisconnect();
        }
      },
      onError: (err) {
        debugPrint('❌ [Provider] Error: $err');
        _isConnected = false;
        _isReconnecting = false;
        _socketStatus = SocketStatus.disconnected;
        notifyListeners();
      },
    );
  }

  void switchAccount(String jwt, String newTradeUserId) {
    debugPrint("🔀 Switching to: $newTradeUserId");

    _isReconnecting = false;

    // ✅ For switch account, we DO clear data
    _socket.disconnect();
    _isConnected = false;
    _liveData.clear();
    _subscribedSymbols.clear();
    notifyListeners();

    connect(jwt, newTradeUserId);
  }

  void subscribeToSymbols(List<String> symbols) {
    for (var s in symbols) {
      subscribeToSymbol(s);
    }
  }

  void subscribeToSymbol(String symbol) {
    final normalized = symbol.toUpperCase().trim();
    if (_subscribedSymbols.contains(normalized)) return;

    _subscribedSymbols.add(normalized);

    if (_isConnected) {
      _socket.subscribeSymbol(normalized);
    }
  }

  void resubscribeAll() {
    if (_subscribedSymbols.isEmpty) {
      debugPrint('⚠️ No symbols to resubscribe');
      return;
    }
    debugPrint('🔄 Resubscribing ${_subscribedSymbols.length} symbols');
    for (var symbol in _subscribedSymbols) {
      _socket.subscribeSymbol(symbol);
    }
  }

  Future<List<Map<String, dynamic>>> fetchHistoricalBars({
    required String symbol,
    required String tradeUserId,
    required String interval,
    required int fromSeconds,
    required int toSeconds,
  }) async {
    try {
      final int timeframe = interval == 'D'
          ? 1440
          : interval == 'W'
              ? 10080
              : int.tryParse(interval) ?? 60;

      final response = await ApiService.getHistoricalData(
        symbol: symbol,
        timeframe: timeframe,
        fromMs: fromSeconds * 1000,
        toMs: toSeconds * 1000,
        tradeUserId: tradeUserId,
      );

      if (response.success && response.data != null) {
        final List rawList = response.data?['results'] ?? [];

        return rawList.map<Map<String, dynamic>>((item) {
          return {
            'time': item['time'],
            'open': (item['open'] as num).toDouble(),
            'high': (item['high'] as num).toDouble(),
            'low': (item['low'] as num).toDouble(),
            'close': (item['close'] as num).toDouble(),
            'volume': (item['volume'] as num?)?.toDouble() ?? 0.0,
          };
        }).toList();
      }
    } catch (e, st) {
      debugPrint('❌ [HIST] Error: $e');
      debugPrint(st.toString());
    }

    return [];
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _socket.disconnect();
    super.dispose();
  }

  void reset() {
    _isReconnecting = false;
    _socket.disconnect();
    _isConnected = false;
    _lastJwt = null;
    _lastTradeUserId = null;
    _lastDataReceivedAt = null;
    _liveData.clear();
    _subscribedSymbols.clear();
    notifyListeners();
  }
}
