import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class AppSocket {
  AppSocket._();
  static final AppSocket _instance = AppSocket._();
  factory AppSocket() => _instance;

  io.Socket? _socket;
  bool get isConnected => _socket?.connected ?? false;
  io.Socket get socket => _socket!;

  void connect({
    required String jwt,
    required String tradeUserId,
    VoidCallback? onConnected,
  }) {
    if (isConnected) {
      onConnected?.call();
      return;
    }

    _socket = io.io(
      'https://api.capyngen.us',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': jwt})
          .enableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('✅ [AppSocket] Connected');
      _socket!.emit('subscribe', tradeUserId);
      _socket!.emit('equity:value', tradeUserId);
      onConnected?.call();
    });

    _socket!.onDisconnect((_) {
      debugPrint('🔌 [AppSocket] Disconnected');
    });
  }

  /// ONLY on logout / app kill
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
