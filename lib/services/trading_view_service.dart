import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../provider/datafeed_provider.dart';

/// ------------------------------------------------------------
/// TradingView Config
/// ------------------------------------------------------------
class TradingViewConfig {
  static const String chartingLibraryUrl =
      'https://aksbyte-trading-view.netlify.app/';
}

/// ------------------------------------------------------------
/// TradingView Service (Singleton) - Fixed for Perfect Chart Sync
/// ------------------------------------------------------------
class TradingViewService {
  static final TradingViewService _instance = TradingViewService._internal();

  factory TradingViewService() => _instance;

  TradingViewService._internal();

  final Map<String, WebViewController> _controllerCache = {};
  final Map<String, ValueNotifier<PriceData>> _priceNotifiers = {};

  /// Get or create Price Notifier
  ValueNotifier<PriceData> getPriceNotifier(String symbol) {
    return _priceNotifiers.putIfAbsent(
      symbol,
      () => ValueNotifier(
        PriceData(
          symbol: symbol,
          currentPrice: 0,
          changePercent: 0,
          isPositive: true,
        ),
      ),
    );
  }

  /// Live Data Update sent to WebView (Always use BID for chart)
  void updateLiveData({
    required String symbol,
    required double bid,
    required double ask,
    required int timestamp,
  }) {
    // Chart is purely built on BID price to match standard exchange logic
    final chartPrice = bid;

    // Optional UI Notifier
    final notifier = getPriceNotifier(symbol);
    notifier.value = PriceData(
      symbol: symbol,
      currentPrice: chartPrice,
      changePercent: 0,
      isPositive: true,
    );

    if (!_controllerCache.containsKey(symbol)) return;

    final priceData = {
      'time': timestamp,
      'price': chartPrice,
      'volume': 1,
    };

    _controllerCache[symbol]!.runJavaScript(
      'if (window.updateLiveData) { window.updateLiveData(${jsonEncode(priceData)}); }',
    );
  }

  /// ------------------------------------------------------------
  /// WebView Controller (MAIN ENTRY POINT)
  /// ------------------------------------------------------------
  WebViewController getController(
    String symbol, {
    String interval = '60',
    required String tradeUserId,
    required BuildContext context,
    required bool isDarkMode,
  }) {
    // Always clear cache to force a fresh chart when opening/changing timeframes if needed
    // But since it's a singleton, we only build once per symbol.
    if (_controllerCache.containsKey(symbol)) {
      return _controllerCache[symbol]!;
    }

    final cleanSymbol = symbol.toUpperCase().trim();
    final html = _buildChartingLibraryHtml(cleanSymbol, interval, isDarkMode);

    final bgColor =
        isDarkMode ? const Color(0xFF131722) : const Color(0xFFffffff);

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(bgColor)
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (JavaScriptMessage message) async {
          try {
            final data = jsonDecode(message.message);

            if (data is! Map || data['type'] != 'getHistory') return;

            final provider =
                Provider.of<DataFeedProvider>(context, listen: false);

            final bars = await provider.fetchHistoricalBars(
              symbol: data['symbol'],
              tradeUserId: tradeUserId,
              interval: data['interval'],
              fromSeconds: data['from'],
              toSeconds: data['to'],
            );

            if (_controllerCache.containsKey(symbol)) {
              _controllerCache[symbol]!.runJavaScript(
                'if (window.onHistoryReady) { window.onHistoryReady(${jsonEncode(bars)}); }',
              );
            }
          } catch (e) {
            debugPrint('❌ TradingView Bridge Error: $e');
          }
        },
      )
      ..loadHtmlString(
        html,
        baseUrl: TradingViewConfig.chartingLibraryUrl,
      );

    _controllerCache[symbol] = controller;
    return controller;
  }

  /// ------------------------------------------------------------
  /// HTML + TradingView JS (PERFECT TIMEFRAME SYNC)
  /// ------------------------------------------------------------
  String _buildChartingLibraryHtml(
      String symbol, String interval, bool isDarkMode) {
    final String bgColor = isDarkMode ? '#131722' : '#ffffff';
    final String themeMode = isDarkMode ? 'dark' : 'light';
    final String gridColor = isDarkMode ? '#2B3139' : '#E6E8EA';

    return '''
<!DOCTYPE html>
<html style="background-color: $bgColor;">
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <style>
    body, html {
      margin: 0;
      padding: 0;
      width: 100%;
      height: 100%;
      overflow: hidden;
      background-color: $bgColor;
    }
    #tv_chart_container {
      width: 100% !important;
      height: 100% !important;
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
    }
  </style>
</head>
<body>
  <div id="tv_chart_container"></div>

  <script src="${TradingViewConfig.chartingLibraryUrl}charting_library.standalone.js"></script>

  <script>
    let lastBar = null;
    let subscribers = {};
    let onHistoryCallback = null;

    // 🔥 LIVE DATA UPDATE FUNCTION - FIXED FOR SEAMLESS MERGING 🔥
    window.updateLiveData = function(data) {
      if (!lastBar) return;

      // Extract precise resolution in minutes
      let resolutionStr = window.tvWidget ? window.tvWidget.chart().resolution() : '$interval';
      let resolutionMinutes = 1;
      
      if (resolutionStr === 'D' || resolutionStr === '1D') resolutionMinutes = 1440;
      else if (resolutionStr === 'W' || resolutionStr === '1W') resolutionMinutes = 10080;
      else resolutionMinutes = parseInt(resolutionStr);

      const barDurationMs = resolutionMinutes * 60 * 1000;
      
      // Calculate current bar's start time boundary
      const barTime = Math.floor(data.time / barDurationMs) * barDurationMs;

      // 🟢 NEW CANDLE
      if (barTime > lastBar.time) {
        lastBar = {
          time: barTime,
          open: lastBar.close,
          high: data.price,
          low: data.price,
          close: data.price,
          volume: data.volume || 1
        };
        Object.values(subscribers).forEach(cb => cb(lastBar));
      } 
      // 🔵 UPDATE CURRENT CANDLE
      else if (barTime === lastBar.time) {
        lastBar.high = Math.max(lastBar.high, data.price);
        lastBar.low = Math.min(lastBar.low, data.price);
        lastBar.close = data.price;
        lastBar.volume += (data.volume || 0);
        Object.values(subscribers).forEach(cb => cb(lastBar));
      }
    };

    // HISTORY CALLBACK FROM FLUTTER
    window.onHistoryReady = function(bars) {
      if (bars && bars.length > 0) {
        lastBar = bars[bars.length - 1]; // Set last historical bar as the starting point for live ticks
        if (onHistoryCallback) onHistoryCallback(bars, { noData: false });
      } else {
        if (onHistoryCallback) onHistoryCallback([], { noData: true });
      }
    };

    const Datafeed = {
      onReady: cb => setTimeout(() => cb({ supported_resolutions: ['1','5','15','30','60','240','D','W'] }), 0),

      resolveSymbol: (name, cb) => setTimeout(() => cb({
        name: name,
        ticker: name,
        type: 'crypto', // Keeps 24/7 formatting active
        session: '24x7',
        timezone: 'Etc/UTC',
        pricescale: 100000, // 5 Decimals precision
        minmov: 1,           
        has_intraday: true,
        supported_resolutions: ['1','5','15','30','60','240','D','W'],
        data_status: 'streaming'
      }), 0),

      getBars: function(symbolInfo, resolution, periodParams, historyCb, errorCb) {
        onHistoryCallback = historyCb;
        if (window.FlutterChannel) {
          FlutterChannel.postMessage(JSON.stringify({
            type: 'getHistory',
            symbol: symbolInfo.name,
            interval: resolution,
            from: periodParams.from,
            to: periodParams.to
          }));
        }
      },

      subscribeBars: (symbolInfo, res, onTick, uid) => {
        subscribers[uid] = onTick;
      },

      unsubscribeBars: uid => {
        delete subscribers[uid];
      }
    };

    // WIDGET INITIALIZATION
    try {
      window.tvWidget = new TradingView.widget({
        symbol: '$symbol',
        interval: '$interval',
        container: 'tv_chart_container',
        datafeed: Datafeed,
        library_path: '${TradingViewConfig.chartingLibraryUrl}',
        autosize: true,
        theme: '$themeMode',
        
        // UI Fixes
        preset: 'mobile',              
        hide_side_toolbar: true,       
        allow_symbol_change: false,
        enable_publishing: false,
        disabled_features: [
          'header_symbol_search', 
          'header_compare',
          'compare_symbol',
          'left_toolbar',          
          'volume_force_overlay'
        ],
        overrides: {
          "paneProperties.background": "$bgColor",
          "paneProperties.backgroundType": "solid",
          "paneProperties.vertGridProperties.color": "$gridColor",
          "paneProperties.horzGridProperties.color": "$gridColor",
        }
      });
    } catch (error) {
      console.error('Widget Error:', error);
    }
  </script>
</body>
</html>
''';
  }

  void dispose() {
    _controllerCache.clear();
    for (final n in _priceNotifiers.values) {
      n.dispose();
    }
    _priceNotifiers.clear();
  }
}

class PriceData {
  final String symbol;
  final double currentPrice;
  final double changePercent;
  final bool isPositive;

  PriceData({
    required this.symbol,
    required this.currentPrice,
    required this.changePercent,
    required this.isPositive,
  });

  String get formattedPrice => currentPrice.toStringAsFixed(5);

  String get formattedChange =>
      '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%';
}
