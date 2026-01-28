import 'dart:convert';
import 'package:exness_clone/view/account/buy_sell_trade/model/ws_equity_data.dart';
import 'package:flutter/cupertino.dart';
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
    if (isConnected) {
      debugPrint('Socket already connected');
      return;
    }

    debugPrint('Connecting to WebSocket...');

    _socket = io.io(
      'https://api.capyngen.us',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setAuth({'token': jwt})
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('Socket connected successfully');
      _socket!.emit('subscribe', userId);
      debugPrint('Subscribed user: $userId');

      _socket!.emit('equity:value');
      debugPrint('Started equity streaming');
    });

    _socket!.on('equity:value', (data) {
      _prettyPrint(data, prefix: "📊 equity:value → ");
      try {
        if (data is Map<String, dynamic>) {
          final equity = EquitySnapshot.fromJson(data);
          onEquity(equity);
          onLiveData?.call(equity.liveProfit);
        }
      } catch (e) {
        debugPrint('Error parsing equity:value: $e');
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

      debugPrint('Socket error: $errorMsg');
      onError?.call(errorMsg);

      if (errorMsg.contains('handshakeFailed') ||
          errorMsg.contains('invalid Token')) {
        debugPrint('Authentication failed - disconnecting');
        _socket?.disconnect();
      }
    });

    _socket!.onConnectError((data) {
      debugPrint('Connection error: $data');
      onError?.call('Connection failed: $data');
    });

    _socket!.onDisconnect((reason) {
      debugPrint('Socket disconnected: $reason');
    });
  }

  void disconnect() {
    if (_socket != null) {
      debugPrint('Disconnecting socket...');
      _socket!.disconnect();
    }
  }

  void dispose() {
    disconnect();
    _socket?.dispose();
    _socket = null;
  }
}

void _prettyPrint(dynamic data, {String prefix = ""}) {
  try {
    final encoder = const JsonEncoder.withIndent("  ");
    final pretty = encoder.convert(data);
    debugPrint("$prefix$pretty");
  } catch (_) {
    debugPrint("$prefix$data");
  }
}
