import 'dart:convert';
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

  void connect({
    required String jwt,
    required String userId,
    required void Function(EquitySnapshot) onEquity,
    void Function(Map<String, dynamic>)? onTradeUpdate,
    void Function(Map<String, dynamic>)? onNewTrade,
    void Function(List<LiveProfit>)? onLiveData,
    void Function(String)? onError,
  }) {
    _currentUserId = userId;

    // 🔥 FIX: Completely wipe out old connection on restart to avoid Ghost/Zombie sockets
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }

    _socket = io.io(
      'https://api.capyngen.us',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setAuth({'token': jwt})
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('✅ [PlaceOrderWS] Socket Connected Freshly');
      _subscribeToEvents(userId);
    });

    _socket!.on('equity:value', (data) {
      try {
        if (data is Map<String, dynamic>) {
          final equity = EquitySnapshot.fromJson(data);
          onEquity(equity);
          onLiveData?.call(equity.liveProfit);
        }
      } catch (e) {
        debugPrint('Parse Error: $e');
      }
    });

    _socket!.on('trade:update', (data) {
      if (data is Map<String, dynamic>) onTradeUpdate?.call(data);
    });

    _socket!.on('trade:new', (data) {
      if (data is Map<String, dynamic>) onNewTrade?.call(data);
    });

    _socket!.on('error', (data) {
      String errorMsg = 'Unknown error';
      if (data is Map<String, dynamic> && data['message'] != null) {
        errorMsg = data['message'].toString();
      } else if (data is String) {
        errorMsg = data;
      }
      onError?.call(errorMsg);

      if (errorMsg.contains('handshakeFailed') ||
          errorMsg.contains('invalid Token')) {
        _socket?.disconnect();
      }
    });

    _socket!.onDisconnect((reason) {
      debugPrint('❌ [PlaceOrderWS] Socket Disconnected: $reason');
    });
  }

  void _subscribeToEvents(String userId) {
    if (_socket == null) return;
    _socket!.emit('subscribe', userId);
    _socket!.emit('equity:value', userId);
  }

  void reSubscribe() {
    if (_currentUserId != null && _socket != null && _socket!.connected) {
      debugPrint('🔄 Re-subscribing... $_currentUserId');
      _subscribeToEvents(_currentUserId!);
    }
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
    }
  }

  void dispose() {
    disconnect();
    _socket?.dispose();
    _socket = null;
    _currentUserId = null;
  }
}
