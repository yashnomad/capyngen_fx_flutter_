import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../model/market_data.dart';
import 'market_data_state.dart';

class MarketDataCubit extends Cubit<MarketDataState> {
  MarketDataCubit() : super(MarketDataInitial());

  final Dio _dio = Dio();

  // Multiple API keys for rotation
  static const List<String> _apiKeys = [
    'ce5ff06e4f574e1884e315c45942053e', // API Key 1
    'd0d1822d9cfd414a89075a14cd08845b', // API Key 2
    'c415cf02958d4880b84fca36c47a639a', // API Key 3
    '07a4949327a245e8b45943a77b548868', // API Key 4
  ];

  int _currentApiKeyIndex = 0;
  String get _currentApiKey => _apiKeys[_currentApiKeyIndex];

  Timer? _timer;
  bool _isAutoUpdating = false;
  int _currentInterval = 15;

  final List<String> _symbols = [
    "BTC/USD",
    "ETH/USD",
    "XRP/USD",
    "ADA/USD",
    "DOGE/USD",
    "LTC/USD",
    "SOL/USD",
    "AVAX/USD",
  ];

  // Getters for UI
  bool get isAutoUpdating => _isAutoUpdating;
  int get currentInterval => _currentInterval;
  int get currentApiKeyIndex => _currentApiKeyIndex + 1; // 1-indexed for UI
  int get totalApiKeys => _apiKeys.length;

  // Rotate to next API key
  void _rotateApiKey() {
    _currentApiKeyIndex = (_currentApiKeyIndex + 1) % _apiKeys.length;
    debugPrint("🔄 Switched to API Key ${_currentApiKeyIndex + 1}/${_apiKeys.length}");

    // Update UI with new API key info
    final currentState = state;
    if (currentState is MarketDataLoaded) {
      emit(currentState.copyWith(
        warning: "Switched to API Key ${_currentApiKeyIndex + 1}/${_apiKeys.length}. Retrying...",
      ));
    }
  }

  // Manually switch to specific API key
  void switchToApiKey(int index) {
    if (index >= 0 && index < _apiKeys.length) {
      _currentApiKeyIndex = index;
      debugPrint("🔄 Manually switched to API Key ${index + 1}/${_apiKeys.length}");

      // Refresh data with new API key
      fetchMarketData();
    }
  }

  // Start fetching data with periodic updates
  void startFetching({int intervalSeconds = 15}) {
    _currentInterval = intervalSeconds;
    _isAutoUpdating = true;

    // Initial fetch
    fetchMarketData();

    // Setup periodic updates
    _timer?.cancel();
    _timer = Timer.periodic(
      Duration(seconds: intervalSeconds),
          (_) => fetchMarketData(isPeriodicUpdate: true),
    );

    // Emit state to update UI
    final currentState = state;
    if (currentState is MarketDataLoaded) {
      emit(currentState.copyWith(
        warning: "Auto-updating every ${intervalSeconds}s • API Key ${_currentApiKeyIndex + 1}/${_apiKeys.length}",
      ));
    }
  }

  // Stop periodic updates
  void stopFetching() {
    _timer?.cancel();
    _isAutoUpdating = false;

    // Emit state to update UI
    final currentState = state;
    if (currentState is MarketDataLoaded) {
      emit(currentState.copyWith(
        warning: "Auto-update stopped • API Key ${_currentApiKeyIndex + 1}/${_apiKeys.length}",
      ));
    }
  }

  // Toggle auto-updating with 10-second intervals
  void toggleAutoUpdate() {
    if (_isAutoUpdating) {
      stopFetching();
      debugPrint("🔴 Auto-update stopped");
    } else {
      startFetching(intervalSeconds: 10);
      debugPrint("🟢 Auto-update started (10s intervals)");
    }
  }

  // Check if error is API limit related
  bool _isApiLimitError(String errorMessage) {
    return errorMessage.contains('run out of API credits') ||
        errorMessage.contains('daily limits') ||
        errorMessage.contains('rate limit') ||
        errorMessage.contains('exceeded');
  }

  // Extract API limit info from error message
  String _getApiLimitMessage(String errorMessage) {
    if (errorMessage.contains('run out of API credits for the day')) {
      return "Daily API limit reached (800 calls/day). Switching to next API key...";
    } else if (errorMessage.contains('run out of API credits for the current minute')) {
      return "Rate limit reached (8 calls/minute). Switching to next API key...";
    } else if (errorMessage.contains('run out of API credits')) {
      return "API limit reached. Switching to next API key...";
    }
    return errorMessage;
  }

  // Fetch market data with API key rotation
  Future<void> fetchMarketData({bool isPeriodicUpdate = false}) async {
    try {
      // Show loading only on initial fetch, not during updates
      if (state is MarketDataInitial) {
        emit(MarketDataLoading());
      } else if (state is MarketDataLoaded && isPeriodicUpdate) {
        // Show updating state while keeping existing data
        emit((state as MarketDataLoaded).copyWith(isUpdating: true));
      }

      List<MarketData> tempList = [];
      List<String> failedSymbols = [];
      String? apiLimitError;
      bool shouldRotateKey = false;

      for (String symbol in _symbols) {
        try {
          final response = await _dio.get(
            'https://api.twelvedata.com/time_series',
            queryParameters: {
              'symbol': symbol,
              'interval': '1min',
              'outputsize': '30',
              'apikey': _currentApiKey,
            },
          );

          final data = response.data;

          if (data['status'] == 'error') {
            final errorMessage = data['message'] ?? 'Unknown error';

            // Check if it's an API limit error
            if (_isApiLimitError(errorMessage)) {
              apiLimitError = _getApiLimitMessage(errorMessage);
              debugPrint("🚫 API Limit Error for $symbol (Key ${_currentApiKeyIndex + 1}): $errorMessage");

              shouldRotateKey = true;
              break; // Stop trying other symbols with this key
            }

            failedSymbols.add(symbol);
            debugPrint("❌ API Error for $symbol: $errorMessage");
            continue;
          }

          final values = List<Map<String, dynamic>>.from(data['values']);
          if (values.isEmpty) {
            failedSymbols.add(symbol);
            continue;
          }

          final latestPrice = double.parse(values.first['close']);
          final oldestPrice = double.parse(values.last['close']);
          final percentChange = ((latestPrice - oldestPrice) / oldestPrice) * 100;
          final chartData = values.reversed.map((e) => double.parse(e['close'])).toList();

          tempList.add(MarketData(
            symbol: symbol,
            price: latestPrice,
            percentChange: percentChange,
            chartData: chartData,
          ));
        } catch (e) {
          failedSymbols.add(symbol);
          debugPrint("❌ Error fetching $symbol: $e");
          continue;
        }
      }

      // Handle API key rotation if needed
      if (shouldRotateKey && apiLimitError != null) {
        _rotateApiKey();

        // Retry with new API key after a short delay
        await Future.delayed(const Duration(seconds: 2));
        return fetchMarketData(isPeriodicUpdate: isPeriodicUpdate);
      }

      // Handle the results
      if (tempList.isNotEmpty) {
        String? warning;

        if (apiLimitError != null) {
          warning = apiLimitError;
        } else if (failedSymbols.isNotEmpty) {
          warning = "Some symbols failed • API Key ${_currentApiKeyIndex + 1}/${_apiKeys.length}";
        } else if (_isAutoUpdating) {
          warning = "Auto-updating every ${_currentInterval}s • API Key ${_currentApiKeyIndex + 1}/${_apiKeys.length}";
        } else {
          warning = "Using API Key ${_currentApiKeyIndex + 1}/${_apiKeys.length}";
        }

        emit(MarketDataLoaded(
          marketData: tempList,
          isUpdating: false,
          warning: warning,
          lastUpdateTime: DateTime.now(),
        ));
      } else {
        // No new data received
        final currentState = state;
        if (currentState is MarketDataLoaded) {
          // Keep existing data but show appropriate warning
          String warningMessage = "Failed to update data. Showing last successful update.";
          if (apiLimitError != null) {
            warningMessage = apiLimitError;
          }

          emit(currentState.copyWith(
            isUpdating: false,
            warning: warningMessage,
          ));
        } else {
          // No previous data, show error with API limit info
          String errorMessage = "Failed to fetch initial data. Please check your connection.";
          if (apiLimitError != null) {
            errorMessage = apiLimitError;
          }

          emit(MarketDataError(
            message: errorMessage,
          ));
        }
      }
    } catch (e) {
      debugPrint("❌ General error in fetchMarketData: $e");

      final currentState = state;
      if (currentState is MarketDataLoaded) {
        // Keep existing data but show error
        emit(currentState.copyWith(
          isUpdating: false,
          warning: "Connection error. Showing last successful update.",
        ));
      } else {
        emit(MarketDataError(
          message: "Network error: ${e.toString()}",
        ));
      }
    }
  }

  // Manually refresh data
  void refreshData() {
    fetchMarketData();
  }

  // Reset all API keys (for demo purposes)
  void resetApiKeys() {
    _currentApiKeyIndex = 0;
    debugPrint("🔄 Reset to API Key 1");

    final currentState = state;
    if (currentState is MarketDataLoaded) {
      emit(currentState.copyWith(
        warning: "Reset to API Key 1/${_apiKeys.length}",
      ));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}