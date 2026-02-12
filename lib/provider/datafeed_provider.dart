import 'package:flutter/foundation.dart';
import '../network/api_service.dart';
import '../services/data_feed_ws.dart';
import '../services/storage_service.dart';

class DataFeedProvider extends ChangeNotifier {
  final DataFeedWS _socket = DataFeedWS();

  final Map<String, LiveProfit> _liveData = {};

  final Set<String> _subscribedSymbols = {};

  bool _isConnected = false;

  Map<String, LiveProfit> get liveData => _liveData;

  void connect(String jwt, String tradeUserId) {
    if (tradeUserId.isEmpty) {
      debugPrint("⚠️ Cannot connect socket: Trade User ID is empty");
      return;
    }

    _socket.connect(
        jwt: jwt,
        tradeUserId: tradeUserId,
        onConnected: () {
          _isConnected = true;
          debugPrint("🔄 Socket connected for user: $tradeUserId $jwt");

          resubscribeAll();
        },
        onLiveData: (profits) {
          for (var p in profits) {
            _liveData[p.symbol] = p;
          }
          notifyListeners();
        },
        onError: (err) {
          _isConnected = false;
          debugPrint("❌ LiveData Socket Error: $err");
        });
  }

  void switchAccount(String jwt, String newTradeUserId) {
    debugPrint("🔀 Switching Socket Account to: $newTradeUserId");

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
    if (_subscribedSymbols.contains(symbol)) return;

    _subscribedSymbols.add(symbol);

    if (_isConnected) {
      _socket.subscribeSymbol(symbol);
    }
  }

  void resubscribeAll() {
    if (_subscribedSymbols.isEmpty) return;
    for (var symbol in _subscribedSymbols) {
      _socket.subscribeSymbol(symbol);
    }
  }
  //
  // Future<List<Map<String, dynamic>>> fetchHistoricalBars({
  //   required String symbol,
  //   required String tradeUserId,
  //   required String interval,
  //   required int fromSeconds,
  //   required int toSeconds,
  // }) async {
  //   try {
  //     int timeframe = interval == 'D' ? 1440 : (int.tryParse(interval) ?? 60);
  //
  //     // 3. Call your ApiService
  //     final response = await ApiService.getHistoricalData(
  //       symbol: symbol,
  //       timeframe: timeframe,
  //       fromMs: fromSeconds * 1000, // Convert to MS
  //       toMs: toSeconds * 1000, // Convert to MS
  //       tradeUserId: tradeUserId,
  //     );
  //
  //     if (response.success && response.data != null) {
  //       // Access the 'results' list inside the response body
  //       final List rawList = response.data?['results'] ?? [];
  //
  //       // Map to TradingView format
  //       return rawList
  //           .map((item) => {
  //                 'time': item['time'],
  //                 'open': item['open'].toDouble(),
  //                 'high': item['high'].toDouble(),
  //                 'low': item['low'].toDouble(),
  //                 'close': item['close'].toDouble(),
  //                 'volume': item['volume']?.toDouble() ?? 0.0,
  //               })
  //           .toList();
  //     }
  //   } catch (e) {
  //     debugPrint("❌ Error fetching historical data: $e");
  //   }
  //   return [];
  // }

  Future<List<Map<String, dynamic>>> fetchHistoricalBars({
    required String symbol,
    required String tradeUserId,
    required String interval,
    required int fromSeconds,
    required int toSeconds,
  }) async {
    try {
      // --- interval → timeframe (KEEP AS IS) ---
      final int timeframe = interval == 'D'
          ? 1440
          : interval == 'W'
              ? 10080
              : int.tryParse(interval) ?? 60;

      // --- debug log (KEEP) ---
      debugPrint(
        '📊 [HIST] symbol=$symbol interval=$interval timeframe=$timeframe '
        'from=${fromSeconds * 1000} to=${toSeconds * 1000}',
      );

      // --- REST API CALL (NO CHANGE) ---
      final response = await ApiService.getHistoricalData(
        symbol: symbol,
        timeframe: timeframe,
        fromMs: fromSeconds * 1000,
        toMs: toSeconds * 1000,
        tradeUserId: tradeUserId,
      );

      if (response.success && response.data != null) {
        final List rawList = response.data?['results'] ?? [];

        debugPrint('📊 [HIST] candles=${rawList.length}');

        // --- map API → TradingView format ---
        return rawList.map<Map<String, dynamic>>((item) {
          return {
            'time': item['time'], // ✅ API already milliseconds de rahi hai
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
    _socket.disconnect();
    super.dispose();
  }

  void reset() {
    _socket.disconnect();
    _isConnected = false;
    _liveData.clear();
    _subscribedSymbols.clear();
    notifyListeners();
  }
}
