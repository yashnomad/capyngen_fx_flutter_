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
/// TradingView Service (Singleton)
/// ------------------------------------------------------------
class TradingViewService {
  static final TradingViewService _instance = TradingViewService._internal();

  factory TradingViewService() => _instance;

  TradingViewService._internal();

  final Map<String, WebViewController> _controllerCache = {};
  final Map<String, ValueNotifier<PriceData>> _priceNotifiers = {};

  /// ------------------------------------------------------------
  /// Price Notifier (optional – used by UI if needed)
  /// ------------------------------------------------------------
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

  void updateLiveData({
    required String symbol,
    required double bid,
    required double ask,
    required int timestamp, // ✅ ADD THIS
  }) {
    final avgPrice = (bid + ask) / 2;

    // notifier update (optional UI)
    final notifier = getPriceNotifier(symbol);
    notifier.value = PriceData(
      symbol: symbol,
      currentPrice: avgPrice,
      changePercent: 0,
      isPositive: true,
    );

    if (!_controllerCache.containsKey(symbol)) return;

    final priceData = {
      'time': timestamp,
      'price': avgPrice,
      'volume': 1,
    };

    _controllerCache[symbol]!.runJavaScript(
      'window.updateLiveData && window.updateLiveData(${jsonEncode(priceData)});',
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
  }) {
    if (_controllerCache.containsKey(symbol)) {
      return _controllerCache[symbol]!;
    }

    final cleanSymbol = symbol.toUpperCase().trim();
    final html = _buildChartingLibraryHtml(cleanSymbol, interval);

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF131722))
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (JavaScriptMessage message) async {
          try {
            final data = jsonDecode(message.message);

            if (data is! Map || data['type'] != 'getHistory') return;

            debugPrint('📩 JS → Flutter getHistory: $data');

            final provider =
                Provider.of<DataFeedProvider>(context, listen: false);

            final bars = await provider.fetchHistoricalBars(
              // symbol: 'AUDCAD',
              symbol: data['symbol'],
              tradeUserId: tradeUserId,
              interval: data['interval'],
              fromSeconds: data['from'],
              toSeconds: data['to'],
            );

            if (_controllerCache.containsKey(symbol)) {
              _controllerCache[symbol]!.runJavaScript(
                'window.onHistoryReady && window.onHistoryReady(${jsonEncode(bars)});',
              );
            }
          } catch (e, st) {
            debugPrint('❌ TradingView Bridge Error: $e');
            debugPrint(st.toString());
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
  /// HTML + TradingView JS
  /// ------------------------------------------------------------
  String _buildChartingLibraryHtml(String symbol, String interval) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    html, body, #tv_chart_container {
      margin: 0;
      padding: 0;
      width: 100%;
      height: 100%;
      background: #131722;
      overflow: hidden;
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

   window.updateLiveData = function(data) {
  const resolution = '$interval' === 'D'
    ? 1440
    : ('$interval' === 'W' ? 10080 : parseInt('$interval'));

  const barDuration = resolution * 60 * 1000;
  const barTime = Math.floor(data.time / barDuration) * barDuration;

  // 🟡 FIRST TICK
  if (!lastBar) {
    lastBar = {
      time: barTime,
      open: data.price,
      high: data.price,
      low: data.price,
      close: data.price,
      volume: data.volume
    };
    Object.values(subscribers).forEach(cb => cb(lastBar));
    return;
  }

  // 🟢 NEW CANDLE
  if (barTime > lastBar.time) {
    lastBar = {
      time: barTime,
      open: lastBar.close,   // ✅ correct
      high: data.price,      // ✅ reset
      low: data.price,       // ✅ reset
      close: data.price,
      volume: data.volume
    };
    Object.values(subscribers).forEach(cb => cb(lastBar));
    return;
  }

  // 🔵 UPDATE CURRENT CANDLE
  if (barTime === lastBar.time) {
    lastBar.high = Math.max(lastBar.high, data.price);
    lastBar.low = Math.min(lastBar.low, data.price);
    lastBar.close = data.price;
    lastBar.volume += data.volume;
    Object.values(subscribers).forEach(cb => cb(lastBar));
  }
};



    window.onHistoryReady = function(bars) {
      if (bars && bars.length) {
        lastBar = bars[bars.length - 1];
        onHistoryCallback(bars, { noData: false });
      } else {
        onHistoryCallback([], { noData: true });
      }
    };

    const Datafeed = {
      onReady: cb => cb({ supported_resolutions: ['1','5','15','30','60','240','D','W'] }),

     resolveSymbol: (name, cb) => cb({
  name: name,
  ticker: name,
  type: 'crypto',      // ETHUSD ke liye better
  session: '24x7',
  timezone: 'Etc/UTC',
  pricescale: 100,     // ✅ REQUIRED
  minmov: 1,           // ✅ REQUIRED (warning fix)
  has_intraday: true,
  supported_resolutions: ['1','5','15','30','60','240','D','W']
}),


      getBars: function(symbolInfo, resolution, periodParams, historyCb) {
        onHistoryCallback = historyCb;
        FlutterChannel.postMessage(JSON.stringify({
          type: 'getHistory',
          symbol: symbolInfo.name,
          interval: resolution,
          from: periodParams.from,
          to: periodParams.to
        }));
      },

      subscribeBars: (symbolInfo, res, onTick, uid) => {
        subscribers[uid] = onTick;
      },

      unsubscribeBars: uid => {
        delete subscribers[uid];
      }
    };

    new TradingView.widget({
      symbol: '$symbol',
      interval: '$interval',
      container: 'tv_chart_container',
      datafeed: Datafeed,
      library_path: '${TradingViewConfig.chartingLibraryUrl}',
      autosize: true,
      theme: 'light',
      disabled_features: ['header_symbol_search', 'header_compare']
    });
  </script>
</body>
</html>
''';
  }

  /// ------------------------------------------------------------
  /// Dispose
  /// ------------------------------------------------------------
  void dispose() {
    _controllerCache.clear();
    for (final n in _priceNotifiers.values) {
      n.dispose();
    }
    _priceNotifiers.clear();
  }
}

/// ------------------------------------------------------------
/// Price Data Model
/// ------------------------------------------------------------
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
}

/*
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../provider/datafeed_provider.dart';

class TradingViewConfig {
  static const String chartingLibraryUrl =
      'https://aksbyte-trading-view.netlify.app/';
}

class TradingViewService {
  static final TradingViewService _instance = TradingViewService._internal();
  factory TradingViewService() => _instance;
  TradingViewService._internal();

  final Map<String, WebViewController> _controllerCache = {};
  final Map<String, ValueNotifier<PriceData>> _priceNotifiers = {};

  ValueNotifier<PriceData> getPriceNotifier(String symbol) {
    return _priceNotifiers.putIfAbsent(
        symbol,
        () => ValueNotifier(PriceData(
            symbol: symbol,
            currentPrice: 0.0,
            changePercent: 0.0,
            isPositive: true)));
  }

  void updateLiveData(
      {required String symbol, required double bid, required double ask}) {
    final avgPrice = (bid + ask) / 2;

    final notifier = getPriceNotifier(symbol);
    notifier.value = PriceData(
        symbol: symbol,
        currentPrice: avgPrice,
        changePercent: 0,
        isPositive: true);

    if (_controllerCache.containsKey(symbol)) {
      final priceData = {
        'time': DateTime.now().millisecondsSinceEpoch,
        'open': avgPrice,
        'high': ask,
        'low': bid,
        'close': avgPrice,
        'volume': 1, // Changed from 0
      };

      _controllerCache[symbol]!.runJavaScript(
          'if (window.updateLiveData) { window.updateLiveData(${jsonEncode(priceData)}); }');
    }
  }

  WebViewController getController(String symbol,
      {String interval = '60',
      required String tradeUserId,
      required BuildContext context}) {
    if (_controllerCache.containsKey(symbol)) return _controllerCache[symbol]!;

    final cleanSymbol = symbol.toUpperCase().trim();
    final htmlContent = _buildChartingLibraryHtml(cleanSymbol, interval);

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF131722))
      ..addJavaScriptChannel('FlutterChannel',
          onMessageReceived: (JavaScriptMessage message) async {
        try {
          final Map<String, dynamic> data = jsonDecode(message.message);
          if (data['type'] == 'getHistory') {
            final provider =
                Provider.of<DataFeedProvider>(context, listen: false);
            final bars = await provider.fetchHistoricalBars(
              symbol: data['symbol'],
              tradeUserId: tradeUserId,
              interval: data['interval'],
              fromSeconds: data['from'],
              toSeconds: data['to'],
            );
            _controllerCache[symbol]?.runJavaScript(
                'if(window.onHistoryReady) { window.onHistoryReady(${jsonEncode(bars)}); }');
          }
        } catch (e) {
          debugPrint('Bridge Error: \$e');
        }
      })
      ..loadHtmlString(htmlContent,
          baseUrl: TradingViewConfig.chartingLibraryUrl);

    _controllerCache[symbol] = controller;
    return controller;
  }

  String _buildChartingLibraryHtml(String symbol, String interval) {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <style>body,html,#tv_chart_container{margin:0;padding:0;width:100%;height:100%;overflow:hidden;background:#ffffff;}</style>
</head>
<body>
    <div id="tv_chart_container"></div>
    <script src="${TradingViewConfig.chartingLibraryUrl}charting_library.standalone.js"></script>

    <script type="text/javascript">
      let lastBar = null;
      let subscribers = {};

  window.updateLiveData = function(data) {
  if (!lastBar) return;

  const resolution = parseInt('$interval') || 60;
  const barDuration = resolution === 'D' ? 86400000 : resolution * 60000;
  const barTime = Math.floor(data.time / barDuration) * barDuration;

  // NEW CANDLE - create and notify
  if (barTime > lastBar.time) {
    lastBar = {
      time: barTime,
      open: data.open,
      high: data.high,
      low: data.low,
      close: data.close,
      volume: data.volume
    };
    Object.values(subscribers).forEach(cb => cb(lastBar));
  }
  // UPDATE EXISTING CANDLE
  else if (barTime === lastBar.time) {
    lastBar.high = Math.max(lastBar.high, data.high);
    lastBar.low = Math.min(lastBar.low, data.low);
    lastBar.close = data.close;
    lastBar.volume += data.volume;
    Object.values(subscribers).forEach(cb => cb(lastBar));
  }
};

      window.onHistoryReady = function(bars) {
        if (bars && bars.length > 0) {
          lastBar = bars[bars.length - 1];
          window.onHistoryCallback(bars, { noData: false });
        } else {
          window.onHistoryCallback([], { noData: true });
        }
      };

      const Datafeed = {
        onReady: cb => setTimeout(() => cb({supported_resolutions: ['1','5','15','30','60','240','D','W']}), 0),
        resolveSymbol: (name, cb) => setTimeout(() => cb({
          name: name, ticker: name, type: 'forex', session: '24x7', timezone: 'Etc/UTC',
          pricescale: 100000, has_intraday: true, supported_resolutions: ['1','5','15','30','60','240','D','W']
        }), 0),
        getBars: function(symbolInfo, resolution, periodParams, onHistoryCallback) {
          window.onHistoryCallback = onHistoryCallback;
          FlutterChannel.postMessage(JSON.stringify({
            type: 'getHistory', symbol: symbolInfo.name, interval: resolution,
            from: periodParams.from, to: periodParams.to
          }));
        },
        subscribeBars: (symbolInfo, res, onTick, uid) => { subscribers[uid] = onTick; },
        unsubscribeBars: (uid) => { delete subscribers[uid]; }
      };

      new TradingView.widget({
        symbol: '$symbol', interval: '$interval', container: 'tv_chart_container',
        datafeed: Datafeed, library_path: '${TradingViewConfig.chartingLibraryUrl}',
        theme: 'light', autosize: true, disabled_features: ["header_symbol_search", "header_compare"]
      });
    </script>
</body>
</html>
    ''';
  }

  void dispose() {
    _controllerCache.clear();
    _priceNotifiers.forEach((k, v) => v.dispose());
    _priceNotifiers.clear();
  }
}

class PriceData {
  final String symbol;
  final double currentPrice;
  final double changePercent;
  final bool isPositive;
  PriceData(
      {required this.symbol,
      required this.currentPrice,
      required this.changePercent,
      required this.isPositive});
}
*/

/*
// ============================================
// lib/services/tradingview_chart_manager.dart
// Complete TradingView Service with Live Data Integration
// ============================================

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Configuration for TradingView
class TradingViewConfig {
  static const String chartingLibraryUrl =
      'https://aksbyte-trading-view.netlify.app/';
  static const bool useChartingLibrary = true;
}

/// Singleton service to manage TradingView charts with live data feed
class TradingViewService {
  static final TradingViewService _instance = TradingViewService._internal();
  factory TradingViewService() => _instance;
  TradingViewService._internal();

  // Cache for preloaded controllers
  final Map<String, WebViewController> _controllerCache = {};

  // ValueNotifier for real-time price updates
  final Map<String, ValueNotifier<PriceData>> _priceNotifiers = {};

  // Current interval for each symbol
  final Map<String, String> _currentIntervals = {};

  // Stream controllers for live data updates (Flutter → WebView)
  final Map<String, StreamController<Map<String, dynamic>>> _dataStreams = {};

  /// Get or create a price notifier for a symbol
  ValueNotifier<PriceData> getPriceNotifier(String symbol) {
    if (!_priceNotifiers.containsKey(symbol)) {
      _priceNotifiers[symbol] = ValueNotifier(PriceData(
        symbol: symbol,
        currentPrice: 0.0,
        changePercent: 0.0,
        isPositive: true,
      ));
    }
    return _priceNotifiers[symbol]!;
  }

  /// Update live price data from DataFeedProvider
  void updateLiveData({
    required String symbol,
    required double bid,
    required double ask,
  }) {
    final avgPrice = (bid + ask) / 2;

    // Update price notifier
    final notifier = getPriceNotifier(symbol);
    final oldPrice = notifier.value.currentPrice;

    if (oldPrice > 0) {
      final change = ((avgPrice - oldPrice) / oldPrice) * 100;
      notifier.value = PriceData(
        symbol: symbol,
        currentPrice: avgPrice,
        changePercent: change,
        isPositive: change >= 0,
      );
    } else {
      notifier.value = PriceData(
        symbol: symbol,
        currentPrice: avgPrice,
        changePercent: 0,
        isPositive: true,
      );
    }

    // Send data to WebView if controller exists
    if (_controllerCache.containsKey(symbol)) {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Create OHLC from bid/ask
      final priceData = {
        'time': timestamp,
        'open': avgPrice,
        'high': ask,
        'low': bid,
        'close': avgPrice,
        'volume': 0,
      };

      // Send to WebView via JavaScript
      _controllerCache[symbol]!.runJavaScript('''
        if (window.updateLiveData) {
          window.updateLiveData(${jsonEncode(priceData)});
        }
      ''').catchError((e) {
        debugPrint('Error sending data to WebView: $e');
      });
    }
  }

  /// Preload chart for a symbol (call before navigation)
  Future<void> preloadChart(String symbol, {String interval = '60'}) async {
    if (_controllerCache.containsKey(symbol)) {
      debugPrint("Chart already preloaded for: $symbol");
      return;
    }

    debugPrint("Preloading chart for: $symbol");
    final cleanSymbol = _getTradingViewSymbol(symbol);
    final htmlContent = _buildChartingLibraryHtml(cleanSymbol, interval);

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF))
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (JavaScriptMessage message) {
          _handleWebViewMessage(symbol, message.message);
        },
      )
      ..setOnConsoleMessage((message) {
        debugPrint("[WebView $symbol]: ${message.message}");
      })
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (progress == 100) {
              debugPrint('Chart preloaded: $symbol ($progress%)');
            }
          },
          onPageStarted: (url) {
            debugPrint('Preloading $symbol...');
          },
          onPageFinished: (url) {
            debugPrint('Chart ready: $symbol');
          },
          onWebResourceError: (error) {
            debugPrint('Preload error for $symbol: ${error.description}');
          },
        ),
      );

    await controller.loadHtmlString(
      htmlContent,
      baseUrl: TradingViewConfig.chartingLibraryUrl,
    );

    _controllerCache[symbol] = controller;
    _currentIntervals[symbol] = interval;
  }

  /// Get preloaded controller or create new one
  WebViewController getController(String symbol, {String interval = '60'}) {
    if (_controllerCache.containsKey(symbol)) {
      debugPrint("Using preloaded controller for: $symbol");
      return _controllerCache[symbol]!;
    }

    debugPrint("Creating new controller for: $symbol");
    final cleanSymbol = _getTradingViewSymbol(symbol);
    final htmlContent = _buildChartingLibraryHtml(cleanSymbol, interval);

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF131722))
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (JavaScriptMessage message) {
          _handleWebViewMessage(symbol, message.message);
        },
      )
      ..setOnConsoleMessage((message) {
        debugPrint("[WebView]: ${message.message}");
      })
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (progress == 100) {
              debugPrint('WebView loaded: 100%');
            }
          },
          onPageStarted: (url) {
            debugPrint('Page loading started');
          },
          onPageFinished: (url) {
            debugPrint('Page loaded successfully');
          },
          onWebResourceError: (error) {
            debugPrint('WebView Error: ${error.description}');
          },
        ),
      )
      ..loadHtmlString(htmlContent,
          baseUrl: TradingViewConfig.chartingLibraryUrl);

    _controllerCache[symbol] = controller;
    _currentIntervals[symbol] = interval;
    return controller;
  }

  /// Change interval for a symbol
  Future<void> changeInterval(String symbol, String newInterval) async {
    if (_controllerCache.containsKey(symbol)) {
      debugPrint("Changing interval for $symbol to $newInterval");

      await _controllerCache[symbol]!.runJavaScript('''
        if (window.tvWidget) {
          window.tvWidget.chart().setResolution("$newInterval");
        }
      ''');

      _currentIntervals[symbol] = newInterval;
    }
  }

  /// Handle messages from WebView
  void _handleWebViewMessage(String symbol, String message) {
    try {
      debugPrint('Received from WebView ($symbol): $message');

      if (message.startsWith('ready:')) {
        debugPrint('Chart is ready for $symbol');
      } else if (message.startsWith('error:')) {
        debugPrint('Chart error for $symbol: $message');
      }
    } catch (e) {
      debugPrint('Error handling WebView message: $e');
    }
  }

  String _getTradingViewSymbol(String dirtySymbol) {
    String cleanSymbol = dirtySymbol.toUpperCase().trim();
    if (dirtySymbol.contains(':')) {
      cleanSymbol = dirtySymbol.split(':').last;
    }
    return cleanSymbol;
  }

  /// Build HTML for TradingView Charting Library with live data feed
  String _buildChartingLibraryHtml(String symbol, String interval) {
    return '''
<!DOCTYPE html>
<html style="background-color: #ffffff;">
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <style>
      body, html {
        margin: 0;
        padding: 0;
        width: 100%;
        height: 100%;
        overflow: hidden;
          background-color: #ffffff;
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

    <!-- Load TradingView from Netlify -->
    <script src="${TradingViewConfig.chartingLibraryUrl}charting_library.standalone.js"
            onerror="console.error('Failed to load charting library')"></script>

    <script type="text/javascript">
      // Check if TradingView loaded
      if (typeof TradingView === 'undefined') {
        console.error('❌ TradingView library failed to load!');
        document.body.innerHTML = '<div style="color:white;padding:20px;text-align:center;">Failed to load TradingView library. Check network connection.</div>';
      } else {
        console.log('✅ TradingView library loaded successfully');
      }

      console.log("Initializing TradingView for: $symbol");

      // Store for live data bars
      let historicalBars = [];
      let lastBar = null;
      let subscribers = {};


      // Function to receive live data from Flutter
      window.updateLiveData = function(data) {
        console.log('📊 Received live data:', data);

        const bar = {
          time: data.time,
          open: data.open,
          high: data.high,
          low: data.low,
          close: data.close,
          volume: data.volume || 0
        };

        const resolution = parseInt('$interval') || 60;
        const barDuration = resolution === 'D' ? 86400000 : resolution * 60000;

        if (!lastBar) {
          // First bar - create it
          lastBar = bar;
          historicalBars.push(bar);
          console.log('✅ Created first bar');

          // Force chart to reload with new data
          Object.keys(subscribers).forEach(listenerGuid => {
            if (subscribers[listenerGuid]) {
              subscribers[listenerGuid](bar);
            }
          });
        } else {
          const timeDiff = bar.time - lastBar.time;

          if (timeDiff < barDuration) {
            // Update current bar
            lastBar.high = Math.max(lastBar.high, bar.high);
            lastBar.low = Math.min(lastBar.low, bar.low);
            lastBar.close = bar.close;
            lastBar.volume += bar.volume;

            console.log('📈 Updated current bar:', lastBar);

            // Notify subscribers with updated bar
            Object.keys(subscribers).forEach(listenerGuid => {
              if (subscribers[listenerGuid]) {
                subscribers[listenerGuid](lastBar);
              }
            });
          } else {
            // New bar - time period changed
            historicalBars.push(lastBar);
            lastBar = bar;

            console.log('🆕 Created new bar, total bars:', historicalBars.length + 1);

            // Notify subscribers with new bar
            Object.keys(subscribers).forEach(listenerGuid => {
              if (subscribers[listenerGuid]) {
                subscribers[listenerGuid](bar);
              }
            });
          }
        }
      };

      // Custom datafeed for live data
      const Datafeed = {
        onReady: function(callback) {
          console.log('[onReady]: Method call');
          setTimeout(() => {
            callback({
              supported_resolutions: ['1', '5', '15', '30', '60', '240', 'D', 'W'],
              supports_marks: false,
              supports_timescale_marks: false,
              supports_time: true,
            });
          }, 0);
        },

        searchSymbols: function(userInput, exchange, symbolType, onResultReadyCallback) {
          console.log('[searchSymbols]: Method call');
          onResultReadyCallback([]);
        },

        resolveSymbol: function(symbolName, onSymbolResolvedCallback, onResolveErrorCallback) {
          console.log('[resolveSymbol]: Method call', symbolName);

          const symbolInfo = {
            ticker: symbolName,
            name: symbolName,
            description: symbolName,
            type: 'forex',
            session: '24x7',
            timezone: 'Etc/UTC',
            exchange: '',
            minmov: 1,
            pricescale: 100000,
            has_intraday: true,
            has_no_volume: true,
            has_weekly_and_monthly: false,
            supported_resolutions: ['1', '5', '15', '30', '60', '240', 'D', 'W'],
            volume_precision: 0,
            data_status: 'streaming',
          };

          setTimeout(() => onSymbolResolvedCallback(symbolInfo), 0);
        },

        getBars: function(symbolInfo, resolution, periodParams, onHistoryCallback, onErrorCallback) {
          console.log('[getBars]: Method call', symbolInfo.name, resolution);
          console.log('[getBars]: Available bars:', historicalBars.length);
          console.log('[getBars]: Last bar:', lastBar);

          // If we have at least one bar (including lastBar), return it
          if (historicalBars.length === 0 && !lastBar) {
            console.log('[getBars]: No data yet, waiting for live feed');
            onHistoryCallback([], { noData: true });
            return;
          }

          // Combine historical bars + current bar
          const allBars = [...historicalBars];
          if (lastBar) {
            allBars.push(lastBar);
          }

          console.log('[getBars]: Returning', allBars.length, 'bars');
          onHistoryCallback(allBars, { noData: false });
        },

        subscribeBars: function(symbolInfo, resolution, onRealtimeCallback, subscriberUID, onResetCacheNeededCallback) {
          console.log('[subscribeBars]: Subscribed for', symbolInfo.name);
          subscribers[subscriberUID] = onRealtimeCallback;

          // If we already have a bar, send it immediately
          if (lastBar) {
            console.log('[subscribeBars]: Sending existing bar immediately');
            onRealtimeCallback(lastBar);
          }

          // Notify Flutter that chart is ready
          if (FlutterChannel) {
            FlutterChannel.postMessage('ready:' + symbolInfo.name);
          }
        },

        unsubscribeBars: function(subscriberUID) {
          console.log('[unsubscribeBars]: Unsubscribed', subscriberUID);
          delete subscribers[subscriberUID];
        }
      };

      // Create TradingView widget
      try {
        window.tvWidget = new TradingView.widget({
          symbol: '$symbol',
          interval: '$interval',
          container: 'tv_chart_container',
          datafeed: Datafeed,
          library_path: '${TradingViewConfig.chartingLibraryUrl}',
          locale: 'en',
          timezone: 'Etc/UTC',
          theme: 'light',
          style: '1',
          toolbar_bg: '#ffffff',
          enable_publishing: false,
          hide_side_toolbar: false,
          allow_symbol_change: false,
          save_image: false,
          fullscreen: false,
          autosize: true,
          studies_overrides: {},
          overrides: {
            "paneProperties.background": "#ffffff",
            "paneProperties.backgroundType": "solid",
            "mainSeriesProperties.candleStyle.upColor": "#26a69a",
            "mainSeriesProperties.candleStyle.downColor": "#ef5350",
            "mainSeriesProperties.candleStyle.borderUpColor": "#26a69a",
            "mainSeriesProperties.candleStyle.borderDownColor": "#ef5350",
            "mainSeriesProperties.candleStyle.wickUpColor": "#26a69a",
            "mainSeriesProperties.candleStyle.wickDownColor": "#ef5350"
          },
          disabled_features: [
            "use_localstorage_for_settings",
            "header_symbol_search",
            "header_compare",
            "compare_symbol"
          ],
          enabled_features: [],
         loading_screen: {
          backgroundColor: "#ffffff",
          foregroundColor: "#000000"
            }

        });

        window.tvWidget.onChartReady(() => {
          console.log('✅ Chart is ready!');
          if (FlutterChannel) {
            FlutterChannel.postMessage('ready:$symbol');
          }
        });

        console.log('✅ Widget initialized successfully');
      } catch (error) {
        console.error('❌ Error initializing widget:', error);
        if (FlutterChannel) {
          FlutterChannel.postMessage('error:' + error.message);
        }
      }
    </script>
  </body>
</html>
    ''';
  }

  /// Clear all cached controllers
  void dispose() {
    _controllerCache.clear();
    for (var notifier in _priceNotifiers.values) {
      notifier.dispose();
    }
    _priceNotifiers.clear();
    _currentIntervals.clear();

    for (var stream in _dataStreams.values) {
      stream.close();
    }
    _dataStreams.clear();
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


*/
