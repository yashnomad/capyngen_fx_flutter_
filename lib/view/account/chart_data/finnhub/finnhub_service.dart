import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:exness_clone/view/account/chart_data/finnhub/stock_data.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class FinnhubService {
  // theaksbyte
  static const String _apiKey = 'd1ukl81r01qpci1d39k0d1ukl81r01qpci1d39kg';
  static const String _baseUrl = 'https://finnhub.io/api/v1';
  static const String _wsUrl = 'wss://ws.finnhub.io?token=$_apiKey';

  final Dio _dio = Dio();
  WebSocketChannel? _channel;
  StreamController<StockData>? _stockController;
  final Map<String, StockData> _stocksData = {};
  final Map<String, List<double>> _chartDataHistory = {};
  bool _isDisposed = false;
  Timer? _reconnectTimer;

  Stream<StockData> get stockStream {
    _stockController ??= StreamController<StockData>.broadcast();
    return _stockController!.stream;
  }

  Map<String, StockData> get currentStocks => Map.from(_stocksData);

  FinnhubService() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.queryParameters = {'token': _apiKey};
    _stockController = StreamController<StockData>.broadcast();
  }

  Future<void> connectWebSocket() async {
    if (_isDisposed) return;

    try {
      // Close previous connection if any
      _closeWebSocket();

      _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));

      _channel!.stream.listen(
            (data) {
          if (!_isDisposed) {
            _handleWebSocketMessage(data);
          }
        },
        onError: (error) {
          print('WebSocket error: $error');
          if (!_isDisposed) {
            // Check for "not upgraded to websocket" error
            if (error.toString().contains('was not upgraded to websocket')) {
              print('Closing WebSocket due to upgrade failure');
              _closeWebSocket();
            } else {
              _scheduleReconnect();
            }
          }
        },
        onDone: () {
          print('WebSocket connection closed');
          if (!_isDisposed) {
            _scheduleReconnect();
          }
        },
        cancelOnError: true,
      );
    } catch (e) {
      print('Failed to connect WebSocket: $e');
      if (!_isDisposed) {
        if (e.toString().contains('was not upgraded to websocket')) {
          _closeWebSocket();
        } else {
          _scheduleReconnect();
        }
      }
    }
  }

  void _handleWebSocketMessage(dynamic data) {
    if (_isDisposed || _stockController == null || _stockController!.isClosed) {
      return;
    }

    try {
      final Map<String, dynamic> message = json.decode(data);

      if (message['type'] == 'trade') {
        final List<dynamic> trades = message['data'] ?? [];

        for (var trade in trades) {
          if (_isDisposed || _stockController!.isClosed) break;

          final symbol = trade['s'];
          final price = (trade['p'] ?? 0.0).toDouble();

          if (!_chartDataHistory.containsKey(symbol)) {
            _chartDataHistory[symbol] = [];
          }

          _chartDataHistory[symbol]!.add(price);

          if (_chartDataHistory[symbol]!.length > 20) {
            _chartDataHistory[symbol]!.removeAt(0);
          }

          double change = 0.0;
          double changePercent = 0.0;

          if (_chartDataHistory[symbol]!.length > 1) {
            final firstPrice = _chartDataHistory[symbol]!.first;
            change = price - firstPrice;
            changePercent = (change / firstPrice) * 100;
          }

          final stockData = StockData(
            symbol: symbol,
            price: price,
            change: change,
            changePercent: changePercent,
            chartData: List.from(_chartDataHistory[symbol]!),
            timestamp: trade['t'] ?? DateTime.now().millisecondsSinceEpoch,
          );

          _stocksData[symbol] = stockData;

          // Only add to controller if it's not closed
          if (!_stockController!.isClosed) {
            _stockController!.add(stockData);
          }
        }
      }
    } catch (e) {
      print('Error parsing WebSocket message: $e');
    }
  }

  void subscribeToSymbol(String symbol) {
    if (_channel != null && !_isDisposed) {
      final subscribeMessage = json.encode({
        'type': 'subscribe',
        'symbol': symbol,
      });
      _channel!.sink.add(subscribeMessage);
    }
  }

  void unsubscribeFromSymbol(String symbol) {
    if (_channel != null && !_isDisposed) {
      final unsubscribeMessage = json.encode({
        'type': 'unsubscribe',
        'symbol': symbol,
      });
      _channel!.sink.add(unsubscribeMessage);
    }
  }

  Future<StockData?> getStockQuote(String symbol) async {
    if (_isDisposed) return null;

    try {
      final response = await _dio.get(
          '/quote', queryParameters: {'symbol': symbol});

      if (response.statusCode == 200) {
        final data = response.data;

        if (!_chartDataHistory.containsKey(symbol)) {
          _chartDataHistory[symbol] = [data['c'].toDouble()];
        }

        return StockData(
          symbol: symbol,
          price: data['c'].toDouble(),
          change: data['d'].toDouble(),
          changePercent: data['dp'].toDouble(),
          chartData: List.from(_chartDataHistory[symbol]!),
          timestamp: DateTime.now().millisecondsSinceEpoch,
        );
      }
    } catch (e) {
      print('Error fetching stock quote: $e');
    }
    return null;
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (!_isDisposed) {
        connectWebSocket();
      }
    });
  }

  void _closeWebSocket() {
    _channel?.sink.close(status.goingAway);
    _channel = null;
  }

  void dispose() {
    print('Disposing FinnhubService');
    _isDisposed = true;

    // Cancel reconnect timer
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    // Close WebSocket
    _closeWebSocket();

    // Close StreamController
    if (_stockController != null && !_stockController!.isClosed) {
      _stockController!.close();
    }
    _stockController = null;

    // Close Dio
    _dio.close();
  }
}