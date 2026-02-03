import 'dart:convert';
import 'package:exness_clone/view/account/buy_sell_trade/model/ws_equity_data.dart';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class PlaceOrderWS {
  PlaceOrderWS._();
  static final PlaceOrderWS _instance = PlaceOrderWS._();
  factory PlaceOrderWS() => _instance;

  io.Socket? _socket;
  bool get isConnected => _socket?.connected ?? false;

  void connect({
    required String jwt,
    required String userId,
    required void Function(EquitySnapshot) onEquity,
    void Function(Map<String, dynamic>)? onTradeUpdate,
    void Function(Map<String, dynamic>)? onNewTrade,
    void Function(List<LiveProfit>)? onLiveData,
    void Function(String)? onError,
  }) {
    if (_socket != null) {
      _socket!.off('equity:value');
      _socket!.off('trade:update');
      _socket!.off('trade:new');
      _socket!.off('error');
    }

    if (_socket == null || !_socket!.connected) {
      _socket = io.io(
        'https://api.capyngen.us',
        io.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .setAuth({'token': jwt})
            .build(),
      );

      _socket!.onConnect((_) {
        _subscribeToEvents(userId);
      });
    } else {
      _subscribeToEvents(userId);
    }

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
      debugPrint('Socket Disconnected: $reason');
    });
  }

  void _subscribeToEvents(String userId) {
    if (_socket == null) return;
    _socket!.emit('subscribe', userId);
    _socket!.emit('equity:value');
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
  }
}
