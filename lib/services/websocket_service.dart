import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class WebSocketService with ChangeNotifier {
  // Socket instance
  IO.Socket? _socket;

  // Connection states
  bool _isConnected = false;
  bool _isConnecting = false;
  String? _error;
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 5;

  // User data
  String? _userId;
  Set<String> _activeSubscriptions = {};

  // Data state
  Map<String, dynamic>? _equityData;
  DateTime? _lastUpdate;

  // Getters
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String? get error => _error;
  Map<String, dynamic>? get equityData => _equityData;
  DateTime? get lastUpdate => _lastUpdate;

  // Connect to WebSocket server
  Future<void> connect(String token) async {
    if (_isConnected || _isConnecting) {
      debugPrint('WebSocket already connected or connecting');
      return;
    }

    _isConnecting = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('Initializing Socket.IO connection with token');

      // Clean up existing socket if any
      if (_socket != null) {
        _socket!.disconnect();
        _socket = null;
      }

      // Create new socket connection
      _socket = IO.io(
          'https://api.capyngen.us',
          IO.OptionBuilder()
              .setTransports(['websocket', 'polling'])
              .setAuth({'token': token})
              .enableAutoConnect()
              .setReconnectionAttempts(double.infinity)
              .setReconnectionDelay(1000)
              .setTimeout(10000)
              .build());

      // Set up event handlers
      _setupEventHandlers();

      debugPrint('Socket.IO connection initialized');
    } catch (e) {
      debugPrint('Error initializing WebSocket: $e');
      _isConnecting = false;
      _error = 'Failed to initialize socket: $e';
      notifyListeners();
    }
  }

  // Set up event handlers
  void _setupEventHandlers() {
    // Connection successful
    _socket!.on('connect', (_) {
      debugPrint('✅ WebSocket connected successfully with ID: ${_socket!.id}');
      _isConnected = true;
      _isConnecting = false;
      _reconnectAttempts = 0;
      _error = null;
      notifyListeners();

      // Auto-subscribe to active subscriptions
      if (_activeSubscriptions.isNotEmpty) {
        for (final userId in _activeSubscriptions) {
          _socket!.emit('subscribe', userId);
          debugPrint('Auto-subscribed to user: $userId');
        }

        // Request equity updates
        Future.delayed(Duration(milliseconds: 500), () {
          requestEquityUpdates();
        });
      }
    });

    // Connection error
    _socket!.on('connect_error', (error) {
      debugPrint('⚠️ WebSocket connection error: $error');
      _reconnectAttempts++;

      _isConnecting = _reconnectAttempts < _maxReconnectAttempts;
      _isConnected = false;
      _error = 'Connection error: $error';

      if (_reconnectAttempts >= _maxReconnectAttempts) {
        debugPrint('Failed to connect after $_maxReconnectAttempts attempts');
        _error = 'Failed to connect after $_maxReconnectAttempts attempts';
      }

      notifyListeners();
    });

    // Disconnection
    _socket!.on('disconnect', (reason) {
      debugPrint('❌ WebSocket disconnected, reason: $reason');
      _isConnected = false;

      // If server-side disconnect, try to reconnect
      if (reason == 'io server disconnect' || reason == 'transport close') {
        debugPrint('Attempting to reconnect...');
        _socket!.connect();
      }

      notifyListeners();
    });

    // Server error
    _socket!.on('error', (error) {
      debugPrint('⚠️ WebSocket server error: $error');
      _error = 'Server error: $error';
      notifyListeners();
    });

    // Equity value updates
    _socket!.on('equity:value', (data) {
      debugPrint('📊 Received equity data');
      if (data != null) {
        _equityData = data;
        _lastUpdate = DateTime.now();
        notifyListeners();

        // Process live profit data for position updates
        if (data['liveprofit'] != null || data['trades'] != null) {
          final liveTrades = data['liveprofit'] ?? data['trades'] ?? [];
          if (liveTrades.isNotEmpty) {
            _processLiveProfitUpdate(liveTrades);
          }
        }
      }
    });

    // Trade updates
    _socket!.on('trade:update', (data) {
      debugPrint('🔄 Received trade update: $data');
      if (data != null && data['action'] != null && data['data'] != null) {
        _processTradeUpdate(data['action'], data['data']);
      }
    });

    // Live data updates (GBPUSD real-time stream)
    _socket!.on('live-data', (data) {
      debugPrint('📡 Received live-data: $data');
      if (data != null) {
        _equityData = data; // reuse your equityData Map
        _lastUpdate = DateTime.now();
        notifyListeners();
      }
    });

    // Catch-all for unhandled events
    _socket!.onAny((event, data) {
      if (!['connect', 'disconnect', 'equity:value', 'trade:update', 'error']
          .contains(event)) {
        debugPrint('📩 Received unhandled event "$event"');
      }
    });
  }

  // Process live profit updates - to be overridden in subclasses
  void _processLiveProfitUpdate(List<dynamic> liveTrades) {
    // Base implementation does nothing
    // Subclasses will implement this to update positions
  }

  // Process trade updates - to be overridden in subclasses
  void _processTradeUpdate(String action, dynamic data) {
    // Base implementation does nothing
    // Subclasses will implement this to handle trade events
  }

  // Subscribe to user updates
  void subscribeToUser(String userId) {
    if (!_isConnected) {
      debugPrint('Cannot subscribe: Socket not connected');
      _error = 'Cannot subscribe: Socket not connected';
      notifyListeners();
      return;
    }

    if (_activeSubscriptions.contains(userId)) {
      debugPrint('Already subscribed to user: $userId');
      return;
    }

    debugPrint('Subscribing to user: $userId');
    _socket!.emit('subscribe', userId);
    _userId = userId;
    _activeSubscriptions.add(userId);

    // Request equity updates after subscription
    Future.delayed(Duration(milliseconds: 500), () {
      if (_isConnected) {
        requestEquityUpdates();
      }
    });

    notifyListeners();
  }

  // Unsubscribe from user updates
  void unsubscribeFromUser(String userId) {
    if (!_isConnected) {
      debugPrint('Cannot unsubscribe: Socket not connected');
      return;
    }

    if (!_activeSubscriptions.contains(userId)) {
      debugPrint('Not subscribed to user: $userId');
      return;
    }

    debugPrint('Unsubscribing from user: $userId');
    _socket!.emit('unsubscribe', userId);
    _activeSubscriptions.remove(userId);

    notifyListeners();
  }

  // Request equity updates
  void requestEquityUpdates() {
    if (_isConnected) {
      _socket!.emit('equity:value');
    } else {
      debugPrint('Cannot request updates: Socket not connected');
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Set user ID
  void setUserId(String userId) {
    _userId = userId;
    notifyListeners();
  }

  // Reset connection
  void resetConnection() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket = null;
    }

    _isConnected = false;
    _isConnecting = false;
    _error = null;
    _reconnectAttempts = 0;
    _equityData = null;
    _lastUpdate = null;
    _activeSubscriptions = {};

    notifyListeners();
  }

  // Disconnect
  void disconnect() {
    if (_socket != null) {
      debugPrint('Disconnecting WebSocket...');
      _socket!.disconnect();
      _socket = null;
    }

    _isConnected = false;
    _isConnecting = false;
    _activeSubscriptions = {};

    notifyListeners();
  }
}
