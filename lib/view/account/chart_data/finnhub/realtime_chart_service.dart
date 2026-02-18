import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'candle_data.dart';

class RealtimeChartService {
  static const String _apiKey = 'd1uk45pr01qpci1d0jm0d1uk45pr01qpci1d0jmg';
  static const String _baseUrl = 'https://finnhub.io/api/v1';
  static const String _wsUrl = 'wss://ws.finnhub.io?token=$_apiKey';

  final Dio _dio = Dio();
  WebSocketChannel? _channel;

  // Streams for real-time data
  final StreamController<double> _priceController =
      StreamController<double>.broadcast();
  final StreamController<List<CandleData>> _candleController =
      StreamController<List<CandleData>>.broadcast();

  Stream<double> get priceStream => _priceController.stream;
  Stream<List<CandleData>> get candleStream => _candleController.stream;

  String? _currentSymbol;
  List<CandleData> _candleData = [];
  Timer? _candleTimer;

  RealtimeChartService() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.queryParameters = {'token': _apiKey};
  }

  // Connect to WebSocket for real-time price updates
  Future<void> connectWebSocket(String symbol) async {
    _currentSymbol = symbol;

    try {
      _channel?.sink.close();
      _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));

      // Subscribe to the symbol
      _channel!.sink.add(json.encode({
        'type': 'subscribe',
        'symbol': symbol,
      }));

      _channel!.stream.listen(
        (data) => _handleWebSocketMessage(data),
        onError: (error) => print('WebSocket error: $error'),
        onDone: () => _reconnectWebSocket(),
      );

      // Load initial candle data
      await _loadInitialCandleData(symbol);

      // Start candle update timer (simulate real-time candles)
      _startCandleTimer();
    } catch (e) {
      print('Failed to connect WebSocket: $e');
    }
  }

  void _handleWebSocketMessage(dynamic data) {
    try {
      final Map<String, dynamic> message = json.decode(data);

      if (message['type'] == 'trade') {
        final List<dynamic> trades = message['data'] ?? [];

        for (var trade in trades) {
          if (trade['s'] == _currentSymbol) {
            final price = (trade['p'] ?? 0.0).toDouble();
            _priceController.add(price);

            // Update current candle with new price
            _updateCurrentCandle(price);
          }
        }
      }
    } catch (e) {
      print('Error parsing WebSocket message: $e');
    }
  }

  // Load initial historical candle data
  Future<void> _loadInitialCandleData(String symbol) async {
    try {
      final now = DateTime.now();
      final from = now.subtract(const Duration(hours: 24));

      final response = await _dio.get('/stock/candle', queryParameters: {
        'symbol': symbol,
        'resolution': '5', // 5-minute candles
        'from': from.millisecondsSinceEpoch ~/ 1000,
        'to': now.millisecondsSinceEpoch ~/ 1000,
      });

      if (response.statusCode == 200 && response.data['s'] == 'ok') {
        final data = response.data;
        _candleData.clear();

        for (int i = 0; i < data['t'].length; i++) {
          _candleData.add(CandleData(
            time: DateTime.fromMillisecondsSinceEpoch(data['t'][i] * 1000),
            open: data['o'][i].toDouble(),
            high: data['h'][i].toDouble(),
            low: data['l'][i].toDouble(),
            close: data['c'][i].toDouble(),
            volume: data['v'][i].toDouble(),
          ));
        }

        _candleController.add(List.from(_candleData));
      }
    } catch (e) {
      print('Error loading candle data: $e');
      // Generate sample data if API fails
      _generateSampleCandleData();
    }
  }

  // Generate sample candle data for demonstration
  void _generateSampleCandleData() {
    _candleData.clear();
    final now = DateTime.now();
    double basePrice = 150.0; // Starting price
    final random = Random();

    for (int i = 50; i >= 0; i--) {
      final time = now.subtract(Duration(minutes: i * 5));
      final open = basePrice;
      final change = (random.nextDouble() - 0.5) * 10; // ±5 price change
      final close = open + change;
      final high = max(open, close) + random.nextDouble() * 3;
      final low = min(open, close) - random.nextDouble() * 3;

      _candleData.add(CandleData(
        time: time,
        open: open,
        high: high,
        low: low,
        close: close,
        volume: random.nextDouble() * 1000000,
      ));

      basePrice = close;
    }

    _candleController.add(List.from(_candleData));
  }

  // Update the current (latest) candle with new price
  void _updateCurrentCandle(double newPrice) {
    if (_candleData.isNotEmpty) {
      final lastCandle = _candleData.last;
      final updatedCandle = CandleData(
        time: lastCandle.time,
        open: lastCandle.open,
        high: max(lastCandle.high, newPrice),
        low: min(lastCandle.low, newPrice),
        close: newPrice,
        volume: lastCandle.volume,
      );

      _candleData[_candleData.length - 1] = updatedCandle;
      _candleController.add(List.from(_candleData));
    }
  }

  // Timer to create new candles periodically (5-minute intervals)
  void _startCandleTimer() {
    _candleTimer?.cancel();
    _candleTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _createNewCandle();
    });
  }

  void _createNewCandle() {
    if (_candleData.isNotEmpty) {
      final lastCandle = _candleData.last;
      final now = DateTime.now();
      final random = Random();

      // Create new candle starting from last close price
      final open = lastCandle.close;
      final change = (random.nextDouble() - 0.5) * 5; // ±2.5 price change
      final close = open + change;
      final high = max(open, close) + random.nextDouble() * 2;
      final low = min(open, close) - random.nextDouble() * 2;

      final newCandle = CandleData(
        time: now,
        open: open,
        high: high,
        low: low,
        close: close,
        volume: random.nextDouble() * 1000000,
      );

      _candleData.add(newCandle);

      // Keep only last 100 candles
      if (_candleData.length > 100) {
        _candleData.removeAt(0);
      }

      _candleController.add(List.from(_candleData));
      _priceController.add(close);
    }
  }

  void _reconnectWebSocket() {
    if (_currentSymbol != null) {
      Timer(const Duration(seconds: 1), () {
        connectWebSocket(_currentSymbol!);
      });
    }
  }

  void dispose() {
    _candleTimer?.cancel();
    _channel?.sink.close();
    _priceController.close();
    _candleController.close();
    _dio.close();
  }
}
