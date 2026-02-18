import 'package:exness_clone/view/account/buy_sell_trade/model/ws_equity_data.dart';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class PlaceOrderWS {
  PlaceOrderWS._();

  static final PlaceOrderWS _instance = PlaceOrderWS._();

  static PlaceOrderWS get instance => _instance;

  factory PlaceOrderWS() => _instance;

  io.Socket? _socket;

  bool get isConnected => _socket?.connected ?? false;

  String? _currentUserId;

  void Function(EquitySnapshot)? _onEquity;
  void Function(Map<String, dynamic>)? _onTradeUpdate;
  void Function(Map<String, dynamic>)? _onNewTrade;
  void Function(List<LiveProfit>)? _onLiveData;
  void Function(String)? _onError;
  void Function()? _onDisconnect;

  void connect({
    required String jwt,
    required String userId,
    required void Function(EquitySnapshot) onEquity,
    void Function(Map<String, dynamic>)? onTradeUpdate,
    void Function(Map<String, dynamic>)? onNewTrade,
    void Function(List<LiveProfit>)? onLiveData,
    void Function(String)? onError,
    void Function()? onDisconnect,
  }) {
    if (_socket != null && _socket!.connected && _currentUserId == userId) {
      debugPrint('♻️ [PlaceOrderWS] Already connected, resubscribing...');
      _updateCallbacks(onEquity, onTradeUpdate, onNewTrade, onLiveData, onError,
          onDisconnect);
      _subscribeToEvents(userId);
      return;
    }

    _currentUserId = userId;
    _updateCallbacks(
        onEquity, onTradeUpdate, onNewTrade, onLiveData, onError, onDisconnect);

    if (_socket != null) {
      _socket!.clearListeners();
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }

    _socket = io.io(
      'https://api.capyngen.us',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .enableForceNew()
          .setAuth({'token': jwt})
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('✅ [PlaceOrderWS] Socket Connected');
      _subscribeToEvents(userId);
    });

    _socket!.on('equity:value', (data) {
      try {
        if (data is Map<String, dynamic>) {
          final equity = EquitySnapshot.fromJson(data);
          _onEquity?.call(equity);
          _onLiveData?.call(equity.liveProfit);
        }
      } catch (e) {
        debugPrint('❌ [PlaceOrderWS] Parse Error: $e');
      }
    });

    _socket!.on('trade:update', (data) {
      if (data is Map<String, dynamic>) _onTradeUpdate?.call(data);
    });

    _socket!.on('trade:new', (data) {
      if (data is Map<String, dynamic>) _onNewTrade?.call(data);
    });

    _socket!.on('error', (data) {
      String errorMsg = 'Unknown error';
      if (data is Map<String, dynamic> && data['message'] != null) {
        errorMsg = data['message'].toString();
      } else if (data is String) {
        errorMsg = data;
      }
      _onError?.call(errorMsg);
      if (errorMsg.contains('handshakeFailed') ||
          errorMsg.contains('invalid Token')) {
        _socket?.disconnect();
      }
    });

    _socket!.onReconnect((_) {
      debugPrint('🔄 [PlaceOrderWS] Auto-reconnected, resubscribing...');
      if (_currentUserId != null) {
        _subscribeToEvents(_currentUserId!);
      }
    });

    _socket!.onDisconnect((reason) {
      debugPrint('❌ [PlaceOrderWS] Socket Disconnected: $reason');
      _onDisconnect?.call();
    });
  }

  void _updateCallbacks(
    void Function(EquitySnapshot)? onEquity,
    void Function(Map<String, dynamic>)? onTradeUpdate,
    void Function(Map<String, dynamic>)? onNewTrade,
    void Function(List<LiveProfit>)? onLiveData,
    void Function(String)? onError,
    void Function()? onDisconnect,
  ) {
    _onEquity = onEquity;
    _onTradeUpdate = onTradeUpdate;
    _onNewTrade = onNewTrade;
    _onLiveData = onLiveData;
    _onError = onError;
    _onDisconnect = onDisconnect;
  }

  void ensureConnected({
    required String jwt,
    required String userId,
    required void Function(EquitySnapshot) onEquity,
    void Function(Map<String, dynamic>)? onTradeUpdate,
    void Function(Map<String, dynamic>)? onNewTrade,
    void Function(List<LiveProfit>)? onLiveData,
    void Function(String)? onError,
    void Function()? onDisconnect,
  }) {
    if (_socket != null && _socket!.connected && _currentUserId == userId) {
      debugPrint('♻️ [PlaceOrderWS] Still alive, resubscribing only');
      _updateCallbacks(onEquity, onTradeUpdate, onNewTrade, onLiveData, onError,
          onDisconnect);
      _subscribeToEvents(userId);
      return;
    }

    debugPrint(
        '🔄 [PlaceOrderWS] Socket dead or user changed, full reconnect...');
    connect(
      jwt: jwt,
      userId: userId,
      onEquity: onEquity,
      onTradeUpdate: onTradeUpdate,
      onNewTrade: onNewTrade,
      onLiveData: onLiveData,
      onError: onError,
      onDisconnect: onDisconnect,
    );
  }

  void _subscribeToEvents(String userId) {
    if (_socket == null || !_socket!.connected) {
      debugPrint('⚠️ [PlaceOrderWS] Cannot subscribe — socket not connected');
      return;
    }
    _socket!.emit('subscribe', userId);
    _socket!.emit('equity:value', userId);
    debugPrint('📡 [PlaceOrderWS] Subscribed to: $userId');
  }

  void reSubscribe() {
    if (_currentUserId != null && _socket != null && _socket!.connected) {
      debugPrint('🔄 Re-subscribing... $_currentUserId');
      _subscribeToEvents(_currentUserId!);
    }
  }

  void disconnect() {
    _socket?.disconnect();
  }

  void dispose() {
    _socket?.clearListeners();
    disconnect();
    _socket?.dispose();
    _socket = null;
    _currentUserId = null;
    _onEquity = null;
    _onTradeUpdate = null;
    _onNewTrade = null;
    _onLiveData = null;
    _onError = null;
    _onDisconnect = null;
  }
}
