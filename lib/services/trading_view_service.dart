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
    required int timestamp,
  }) {
    final price = bid;

    final int normalizedTime =
        timestamp < 10000000000 ? timestamp * 1000 : timestamp;

    final notifier = getPriceNotifier(symbol);
    notifier.value = PriceData(
      symbol: symbol,
      currentPrice: price,
      changePercent: 0,
      isPositive: true,
    );

    final priceData = {
      'time': normalizedTime,
      'price': price,
      'volume': 1,
    };

    final js =
        'if (window.updateLiveData) { window.updateLiveData(${jsonEncode(priceData)}); }';

    for (final key in _controllerCache.keys) {
      if (key == symbol || key.startsWith('${symbol}_')) {
        _controllerCache[key]!.runJavaScript(js).catchError((_) {});
      }
    }
  }

  WebViewController getController(
    String symbol, {
    String interval = '1',
    required String tradeUserId,
    required BuildContext context,
    required bool isDarkMode,
    String? cacheKey,
  }) {
    final key = cacheKey ?? symbol.toUpperCase().trim();

    if (_controllerCache.containsKey(key)) {
      return _controllerCache[key]!;
    }

    final cleanSymbol = symbol.toUpperCase().trim();
    final html = _buildChartingLibraryHtml(cleanSymbol, interval, isDarkMode);

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(
          isDarkMode ? const Color(0xFF161A1E) : const Color(0xFFFFFFFF))
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

            final reqId = data['reqId'] ?? '';

            if (_controllerCache.containsKey(key)) {
              _controllerCache[key]!.runJavaScript(
                'if (window.onHistoryReady) { window.onHistoryReady(${jsonEncode(bars)}, "${data['interval']}", "$reqId"); }',
              );
            }
          } catch (e) {
            debugPrint('❌ TradingView Bridge Error: $e');
          }
        },
      )
      ..loadHtmlString(html, baseUrl: TradingViewConfig.chartingLibraryUrl);

    _controllerCache[key] = controller;
    return controller;
  }

  Future<void> changeInterval(String cacheKey, String interval) async {
    if (_controllerCache.containsKey(cacheKey)) {
      await _controllerCache[cacheKey]!.runJavaScript('''
        if (window.tvWidget) {
           window.tvWidget.chart().setResolution('$interval');
        }
      ''');
    }
  }

  void removeController(String cacheKey) {
    _controllerCache.remove(cacheKey);
  }

  String _buildChartingLibraryHtml(
      String symbol, String interval, bool isDarkMode) {
    final String bgColor = isDarkMode ? '#161A1E' : '#FFFFFF';
    final String themeMode = isDarkMode ? 'dark' : 'light';
    final String gridColor = isDarkMode ? '#2B3139' : '#E6E8EA';

    return '''
<!DOCTYPE html>
<html style="background-color: $bgColor;">
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    html, body, #tv_chart_container { margin: 0; padding: 0; width: 100%; height: 100%; background: $bgColor; overflow: hidden; }
  </style>
</head>
<body>
  <div id="tv_chart_container"></div>
  <script src="${TradingViewConfig.chartingLibraryUrl}charting_library.standalone.js"></script>

  <script>
    let lastBarsCache = {}; 
    let subscribers = {};
    
    // FIX: Freeze Issue Resolution -> Use a Map for callbacks
    let historyCallbacks = {};
    let reqCounter = 0;

    function getResolutionInMs(res) {
      const resolutionMap = {
        "1": 60 * 1000,
        "3": 3 * 60 * 1000,
        "5": 5 * 60 * 1000,
        "15": 15 * 60 * 1000,
        "30": 30 * 60 * 1000,
        "45": 45 * 60 * 1000,
        "60": 60 * 60 * 1000,
        "120": 2 * 60 * 60 * 1000,
        "180": 3 * 60 * 60 * 1000,
        "240": 4 * 60 * 60 * 1000,
        "1D": 24 * 60 * 60 * 1000,
        "D": 24 * 60 * 60 * 1000,
        "1W": 7 * 24 * 60 * 60 * 1000,
        "W": 7 * 24 * 60 * 60 * 1000,
        "1M": 30 * 24 * 60 * 60 * 1000,
        "M": 30 * 24 * 60 * 60 * 1000
      };
      return resolutionMap[res] || 60 * 1000;
    }

    function isSameBar(timestamp1, timestamp2, res) {
      const intervalMs = getResolutionInMs(res);
      return Math.floor(timestamp1 / intervalMs) === Math.floor(timestamp2 / intervalMs);
    }

    function getBarTime(timestamp, res) {
      const intervalMs = getResolutionInMs(res);
      return Math.floor(timestamp / intervalMs) * intervalMs;
    }

    window.updateLiveData = function(data) {
      if (!data || data.price <= 0) return;
      
      try {
        const tickTime = data.time;
        const currentPrice = data.price;
        const tickVolume = data.volume || 1;

        Object.keys(subscribers).forEach(uid => {
          let sub = subscribers[uid];
          let lastBar = sub.lastBar;
          
          if (!lastBar) return; 

          const barTime = getBarTime(tickTime, sub.resolution);
          let newBar;

          if (isSameBar(tickTime, lastBar.time, sub.resolution)) {
            newBar = {
              time: lastBar.time,
              open: lastBar.open,
              high: Math.max(lastBar.high, currentPrice),
              low: Math.min(lastBar.low, currentPrice),
              close: currentPrice,
              volume: (lastBar.volume || 0) + tickVolume
            };
          } else {
            const lastClosedClose = lastBar.close;
            newBar = {
              time: barTime,
              open: lastClosedClose,
              high: Math.max(lastClosedClose, currentPrice),
              low: Math.min(lastClosedClose, currentPrice),
              close: currentPrice,
              volume: tickVolume
            };
          }

          sub.lastBar = newBar;
          lastBarsCache[sub.resolution] = newBar; 
          sub.handler({ ...newBar }); 
        });
      } catch (e) {
         console.error("LiveData Error: ", e);
      }
    };

    window.onHistoryReady = function(bars, resolution, reqId) {
      let cb = historyCallbacks[reqId];

      if (bars && bars.length > 0) {
        bars.sort((a, b) => a.time - b.time);
        let latestBar = bars[bars.length - 1];
        
        // Ensure we only store the most recent bar from multiple overlapping history requests
        if (!lastBarsCache[resolution] || latestBar.time >= lastBarsCache[resolution].time) {
            lastBarsCache[resolution] = latestBar;
        }
        
        Object.keys(subscribers).forEach(uid => {
           if (subscribers[uid].resolution === resolution) {
               subscribers[uid].lastBar = lastBarsCache[resolution];
           }
        });

        if (cb) cb(bars, { noData: false });
      } else {
        if (cb) cb([], { noData: true });
      }
      
      if (cb) delete historyCallbacks[reqId]; // Callback run ho gaya, memory free karo
    };

    const Datafeed = {
      onReady: cb => setTimeout(() => cb({ supported_resolutions: ['1','3','5','15','30','45','60','120','180','240','1D','1W','1M'] }), 0),

      resolveSymbol: (name, cb) => {
        let scale = 100000;
        if(name.includes("BTC") || name.includes("ETH") || name.includes("XAU")) scale = 100; 

        setTimeout(() => cb({
          name: name,
          ticker: name,
          type: 'crypto',
          session: '24x7',
          timezone: 'Etc/UTC',
          pricescale: scale,
          minmov: 1,
          has_intraday: true,
          has_no_volume: true, 
          data_status: 'streaming', 
          supported_resolutions: ['1','3','5','15','30','45','60','120','180','240','1D','1W','1M']
        }), 0);
      },

      getBars: function(symbolInfo, resolution, periodParams, historyCb) {
        // Har getBars call ko ek unique ID milegi
        let reqId = "req_" + (++reqCounter);
        historyCallbacks[reqId] = historyCb;

        if (window.FlutterChannel) {
           FlutterChannel.postMessage(JSON.stringify({
             type: 'getHistory',
             symbol: symbolInfo.name,
             interval: resolution,
             from: periodParams.from,
             to: periodParams.to,
             reqId: reqId // ID backend me bheji gayi
           }));
        }
      },

      subscribeBars: (symbolInfo, res, onTick, uid) => {
        let cachedBar = lastBarsCache[res] || null;
        subscribers[uid] = { handler: onTick, resolution: res, lastBar: cachedBar };
        
        if (cachedBar) {
           setTimeout(() => onTick(cachedBar), 100);
        }
      },

      unsubscribeBars: uid => {
        delete subscribers[uid];
      }
    };

    window.tvWidget = new TradingView.widget({
      symbol: '$symbol',
      interval: '$interval',
      container: 'tv_chart_container',
      datafeed: Datafeed,
      library_path: '${TradingViewConfig.chartingLibraryUrl}',
      autosize: true,
      theme: '$themeMode',
      preset: 'mobile',
      disabled_features: ['header_symbol_search', 'header_compare', 'left_toolbar', 'volume_force_overlay'],
      overrides: {
        "paneProperties.background": "$bgColor",
        "paneProperties.backgroundType": "solid",
        "paneProperties.vertGridProperties.color": "$gridColor",
        "paneProperties.horzGridProperties.color": "$gridColor"
      }
    });
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
}
