/*
For first time i made change in this file to fix the decimal issue upto 5 decimal places. 2/2/2026
 */

import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/provider/datafeed_provider.dart';
import 'package:exness_clone/services/balance_masked.dart';
import 'package:exness_clone/services/switch_account_service.dart';
import 'package:exness_clone/services/trading_view_service.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/utils/bottom_sheets.dart';
import 'package:exness_clone/utils/snack_bar.dart';
import 'package:exness_clone/view/trade/model/trade_account.dart';
import 'package:exness_clone/widget/account_bottom_sheet.dart';
import 'package:exness_clone/widget/simple_appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../constant/trade_data.dart';
import '../../../constant/app_vector.dart';
import '../../../services/data_feed_ws.dart';
import '../../../services/reactive_data_service.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/common_utils.dart';
import '../../../widget/slidepage_navigate.dart';
import '../trade_screen/new_order_screen.dart';
import '../btc_setting/btc_setting_screen.dart';
import '../buy_sell_trade/widget/trade_bottom_sheets.dart';
import '../calculator_screen.dart';
import '../detail_screen.dart';
import '../price_alert_screen.dart';
import '../widget/tab_selector.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BTCChartScreenUpdated extends StatefulWidget {
  final String symbolName;
  final String id;
  final String tradeUserId;

  const BTCChartScreenUpdated({
    super.key,
    required this.symbolName,
    required this.id,
    required this.tradeUserId,
  });

  @override
  State<BTCChartScreenUpdated> createState() => _BTCChartScreenUpdatedState();
}

class _BTCChartScreenUpdatedState extends State<BTCChartScreenUpdated> {
  // late final WebViewController _controller;
  WebViewController? _controller;

  final TradingViewService _chartService = TradingViewService();

  final notifier = TradingViewService().getPriceNotifier('GBPUSD');

  // Current interval
  String _selectedInterval = '1';
  bool _isChartReady = false;

  // late String _symbolName;

  int sellPercentage = 51;
  int buyPercentage = 49;

  // Interval options
  final Map<String, String> _intervals = {
    '1': '1m',
    '5': '5m',
    '30': '30m',
    '60': '1h',
    '240': '4h',
    'D': '1D',
    'W': '1W',
  };

  void _changeInterval(String interval) {
    setState(() {
      _selectedInterval = interval;
    });

    // ✨ Call the service to update the resolution in JS
    _chartService.changeInterval(widget.symbolName, interval);
  }

  String _formatPrice(double? value,
      {int minDecimals = 2, int maxDecimals = 5}) {
    if (value == null) return '--';

    // Start with maxDecimals, then trim trailing zeros but keep at least minDecimals
    String s = value.toStringAsFixed(maxDecimals); // e.g. "4751.440"
    int dotIndex = s.indexOf('.');
    if (dotIndex == -1) return s; // no decimal point

    int end = s.length;
    // Trim trailing zeros but keep at least minDecimals decimals
    while (end > dotIndex + 1 &&
        end - (dotIndex + 1) > minDecimals &&
        s[end - 1] == '0') {
      end--;
    }

    // If last char is '.', remove it
    if (s[end - 1] == '.') {
      end--;
    }

    return s.substring(0, end);
  }

  // @override
  // void initState() {
  //   super.initState();
  //   debugPrint("--- Chart Widget initState ---");
  //
  //   // _controller = _chartService.getController(
  //   //   widget.symbolName,
  //   //   interval: _selectedInterval,
  //   // );
  //   _controller = _chartService.getController(
  //     widget.symbolName,
  //     interval: _selectedInterval,
  //     tradeUserId: widget.tradeUserId,
  //     context: context,
  //   );
  // }

  @override
  void initState() {
    super.initState();

    _controller = _chartService.getController(
      widget.symbolName,
      interval: _selectedInterval,
      tradeUserId: widget.tradeUserId,
      context: context,
    );
  }

  @override
  void dispose() {
    debugPrint("--- Chart Widget disposed for ${widget.symbolName} ---");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      appBar: SimpleAppbar(title: 'Live Chart'),
      bottomNavigationBar: buildPadding(context),
      // body: SafeArea(
      //   child: Selector<DataFeedProvider, LiveProfit?>(
      //     selector: (_, provider) {
      //       var data = provider.liveData[widget.symbolName];
      //
      //       data ??= provider.liveData[widget.symbolName.toUpperCase()];
      //
      //       data ??= provider.liveData[widget.symbolName.toLowerCase()];
      //
      //       return data;
      //     },
      //     builder: (context, liveProfit, _) {
      //       if (liveProfit != null) {
      //         _chartService.updateLiveData(
      //           symbol: widget.symbolName,
      //           bid: liveProfit.bid,
      //           ask: liveProfit.ask,
      //           timestamp: liveProfit.timestamp,
      //         );
      //       }
      //
      //       return RepaintBoundary(
      //         child: WebViewWidget(
      //           controller: _controller,
      //         ),
      //       );
      //     },
      //   ),
      // ),
      body: SafeArea(
        child: Selector<DataFeedProvider, LiveProfit?>(
          selector: (_, provider) {
            var data = provider.liveData[widget.symbolName];
            data ??= provider.liveData[widget.symbolName.toUpperCase()];
            data ??= provider.liveData[widget.symbolName.toLowerCase()];
            return data;
          },
          shouldRebuild: (prev, next) => prev?.timestamp != next?.timestamp,
          builder: (context, liveProfit, _) {
            if (liveProfit != null) {
              _chartService.updateLiveData(
                symbol: widget.symbolName,
                bid: liveProfit.bid,
                ask: liveProfit.ask,
                timestamp: liveProfit.timestamp,
              );
            }

            return RepaintBoundary(
              child: WebViewWidget(
                controller: _controller!,
              ),
            );
          },
        ),
      ),
    );
  }

  Padding buildPadding(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: ReactiveDataService(
                      symbolName: widget.symbolName,
                      builder: (context, liveData, calculations) {
                        return CupertinoButton(
                          color: AppColor.redColor,
                          padding: EdgeInsets.symmetric(vertical: 10),
                          onPressed: () => _goToOrder(
                            context: context,
                            price: calculations.askValue,
                            side: 'Sell',
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Sell',
                                style: TextStyle(
                                  color: AppColor.whiteColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                _formatPrice(calculations.askValue),
                                style: TextStyle(
                                  color: AppColor.whiteColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: ReactiveDataService(
                      symbolName: widget.symbolName,
                      builder: (context, liveData, calculations) {
                        return CupertinoButton(
                          color: AppColor.blueColor,
                          padding: EdgeInsets.symmetric(vertical: 10),
                          onPressed: () => _goToOrder(
                            context: context,
                            price: calculations.bidValue,
                            side: 'Buy',
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Buy',
                                style: TextStyle(
                                  color: AppColor.whiteColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                _formatPrice(calculations.bidValue),
                                style: TextStyle(
                                  color: AppColor.whiteColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _goToOrder({
    required BuildContext context,
    required double? price,
    required String side,
  }) {
    if (price == null || price == 0) {
      SnackBarService.showInfo('Price not available');
      return;
    }

    Navigator.push(
      context,
      SlidePageRoute(
        page: NewOrderScreen(
          side: side,
          symbol: widget.symbolName,
          id: widget.id,
          sector: TradeData.stockCategory,
        ),
      ),
    );
  }
}

/*
import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/services/balance_masked.dart';
import 'package:exness_clone/services/switch_account_service.dart';
import 'package:exness_clone/services/trading_view_service.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/utils/bottom_sheets.dart';
import 'package:exness_clone/view/trade/model/trade_account.dart';
import 'package:exness_clone/widget/account_bottom_sheet.dart';
import 'package:exness_clone/widget/simple_appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../constant/trade_data.dart';
import '../../../constant/app_vector.dart';
import '../../../services/reactive_data_service.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/common_utils.dart';
import '../../../widget/slidepage_navigate.dart';
import '../trade_screen/new_order_screen.dart';
import '../btc_setting/btc_setting_screen.dart';
import '../buy_sell_trade/widget/trade_bottom_sheets.dart';
import '../calculator_screen.dart';
import '../detail_screen.dart';
import '../price_alert_screen.dart';
import '../widget/tab_selector.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BTCChartScreenUpdated extends StatefulWidget {
  final String symbolName;
  final String id;

  const BTCChartScreenUpdated({
    super.key,
    required this.symbolName,
    required this.id,
  });

  @override
  State<BTCChartScreenUpdated> createState() => _BTCChartScreenUpdatedState();
}

class _BTCChartScreenUpdatedState extends State<BTCChartScreenUpdated> {
  late final WebViewController _controller;
  final TradingViewService _chartService = TradingViewService();

  final notifier = TradingViewService().getPriceNotifier('GBPUSD');

  // Current interval
  String _selectedInterval = '60';
  // late String _symbolName;

  int sellPercentage = 51;
  int buyPercentage = 49;

  // Interval options
  final Map<String, String> _intervals = {
    '1': '1m',
    '5': '5m',
    '15': '15m',
    '30': '30m',
    '60': '1h',
    '240': '4h',
    'D': '1D',
    'W': '1W',
  };

  @override
  void initState() {
    super.initState();
    debugPrint("--- Chart Widget initState ---");

    // Get preloaded controller or create new one
    // _symbolName = widget.symbolName;
    _controller = _chartService.getController(
      widget.symbolName,
      interval: _selectedInterval,
    );
  }

  @override
  void dispose() {
    debugPrint("--- Chart Widget disposed for ${widget.symbolName} ---");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      appBar: SimpleAppbar(title: 'Live Chart'),
      bottomNavigationBar: buildPadding(context),
      body: SafeArea(
        child: Column(
          children: [
            // Interval Selector
            _buildIntervalSelector(),

            // Chart WebView
            Expanded(
              child: RepaintBoundary(
                child: WebViewWidget(
                  controller: _controller!,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntervalSelector() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _intervals.length,
        itemBuilder: (context, index) {
          final intervalKey = _intervals.keys.elementAt(index);
          final intervalLabel = _intervals.values.elementAt(index);
          final isSelected = _selectedInterval == intervalKey;

          return GestureDetector(
            onTap: () => _changeInterval(intervalKey),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppColor.blueColor : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? AppColor.blueColor : Colors.grey.shade300,
                ),
              ),
              child: Text(
                intervalLabel,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Padding buildPadding(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: CupertinoButton(
                      color: AppColor.redColor,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      onPressed: () {
                        Navigator.push(
                            context,
                            SlidePageRoute(
                                page: NewOrderScreen(
                                    side: 'Sell',
                                    symbol: widget.symbolName,
                                    id: widget.id,
                                    sector: TradeData.stockCategory)));
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Sell',
                              style: TextStyle(
                                  color: AppColor.whiteColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                          ReactiveDataService(
                              symbolName: widget.symbolName,
                              builder: (context, liveData, calculations) {
                                return Text(
                                  calculations.askValue.toString(),
                                  style: TextStyle(
                                      color: AppColor.whiteColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                );
                              }),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: CupertinoButton(
                      color: AppColor.blueColor,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      onPressed: () {
                        Navigator.push(
                            context,
                            SlidePageRoute(
                                page: NewOrderScreen(
                              side: 'Buy',
                              symbol: widget.symbolName,
                              id: widget.id,
                              sector: TradeData.stockCategory,
                            )));
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Buy',
                              style: TextStyle(
                                  color: AppColor.whiteColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                          ReactiveDataService(
                            builder: (context, liveData, calculations) {
                              return Text(
                                calculations.bidValue.toString(),
                                style: TextStyle(
                                    color: AppColor.whiteColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                              );
                            },
                            symbolName: widget.symbolName,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              ReactiveDataService(
                builder: (context, liveData, calculations) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      calculations.askValue.toString(),
                      style:
                          TextStyle(fontSize: 10, color: AppColor.blackColor),
                    ),
                  );
                },
                symbolName: widget.symbolName,
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            spacing: 15,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(height: 3, color: AppColor.lightGrey),
                        FractionallySizedBox(
                          widthFactor: sellPercentage / 100,
                          child: Container(height: 3, color: AppColor.redColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$sellPercentage%',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColor.redColor,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(height: 3, color: AppColor.lightGrey),
                        FractionallySizedBox(
                          widthFactor: buyPercentage / 100,
                          child:
                              Container(height: 3, color: AppColor.blueColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$buyPercentage%',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColor.blueColor,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
*/

/*
************************** Working webview code *********************


import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/services/balance_masked.dart';
import 'package:exness_clone/services/switch_account_service.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/utils/bottom_sheets.dart';
import 'package:exness_clone/view/trade/model/trade_account.dart';
import 'package:exness_clone/widget/account_bottom_sheet.dart';
import 'package:exness_clone/widget/simple_appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../constant/trade_data.dart';
import '../../../constant/app_vector.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/common_utils.dart';
import '../../../widget/slidepage_navigate.dart';
import '../trade_screen/new_order_screen.dart';
import '../btc_setting/btc_setting_screen.dart';
import '../buy_sell_trade/widget/trade_bottom_sheets.dart';
import '../calculator_screen.dart';
import '../detail_screen.dart';
import '../price_alert_screen.dart';
import '../widget/tab_selector.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BTCChartScreenUpdated extends StatefulWidget {
  final String symbolName;
  final IconData icon;
  final double price;

  const BTCChartScreenUpdated(
      {super.key,
      required this.symbolName,
      required this.icon,
      required this.price});

  @override
  State<BTCChartScreenUpdated> createState() => _BTCChartScreenUpdatedState();
}

class _BTCChartScreenUpdatedState extends State<BTCChartScreenUpdated> {
  late final WebViewController _controller;

  int sellPercentage = 51;
  int buyPercentage = 49;

  Color getLabelColor(String type) {
    switch (type) {
      case 'Intraday':
        return AppColor.blueColor;
      case 'Short term':
        return AppColor.blueColor;
      case 'Medium term':
        return AppColor.blueColor;
      default:
        return AppColor.greyColor;
    }
  }

  String _getTradingViewSymbol(String dirtySymbol) {
    debugPrint("Original symbol received: $dirtySymbol");

    String cleanSymbol = dirtySymbol;

    if (dirtySymbol.contains(':')) {
      cleanSymbol = dirtySymbol.split(':').last;
      debugPrint("Cleaned symbol to: $cleanSymbol");
    }

    const symbolsToAppendUsd = {'BTC', 'ETH', 'XAU'};

    if (symbolsToAppendUsd.contains(cleanSymbol)) {
      debugPrint("Converted to: ${cleanSymbol}USD");
      return '${cleanSymbol}USD';
    }

    debugPrint("Using symbol as-is: $cleanSymbol");
    return cleanSymbol;
  }

  String _buildChartHtml(String symbol) {
    return '''
    <!DOCTYPE html>
    <html style="background-color: #131722;">
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <style>
          body, html {
            margin: 0;
            padding: 0;
            width: 100%;
            height: 100%;
            overflow: hidden;
            background-color: #131722;
          }
          .tradingview-widget-container {
            width: 100% !important;
            height: 100% !important;
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
          }
          .tradingview-widget-container__widget {
            width: 100% !important;
            height: 100% !important;
          }
          #tradingview_chart_widget {
            width: 100% !important;
            height: 100% !important;
          }
        </style>
        <script type="text/javascript" src="https://s3.tradingview.com/tv.js"></script>
      </head>
      <body>
        <div class="tradingview-widget-container">
          <div id="tradingview_chart_widget"></div>
          <script type="text/javascript">
            console.log("Creating TradingView widget for: ${symbol.replaceAll('"', r'\"')}");

            new TradingView.widget({
              "autosize": true,
              "symbol": "${symbol.replaceAll('"', r'\"')}",
              "interval": "60",
              "timezone": "Etc/UTC",
              "theme": "light",
              "style": "1",
              "locale": "en",
              "toolbar_bg": "#131722",
              "enable_publishing": false,
              "hide_side_toolbar": false,
              "allow_symbol_change": true,
              "container_id": "tradingview_chart_widget",
              "width": "100%",
              "height": "100%"
            });

            console.log("Widget initialized");
          </script>
        </div>
      </body>
    </html>
    ''';
  }

  @override
  void initState() {
    super.initState();

    debugPrint("--- Chart Widget initState ---");

    final String tradingViewSymbol = _getTradingViewSymbol(widget.symbolName);
    debugPrint("Symbol: ${widget.symbolName} -> $tradingViewSymbol");

    final String htmlContent = _buildChartHtml(tradingViewSymbol);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF131722))
      // Reduce console logging to minimize buffer issues
      ..setOnConsoleMessage((JavaScriptConsoleMessage message) {
        // Only log warnings and errors, not all messages
        final level = message.level.toString();
        if (level.contains('warning') || level.contains('error')) {
          debugPrint("[WebView]: ${message.message}");
        }
      })
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Only log at key milestones to reduce logs
            if (progress == 100) {
              debugPrint('WebView loaded: 100%');
            }
          },
          onPageStarted: (String url) {
            debugPrint('Page loading started');
          },
          onPageFinished: (String url) {
            debugPrint('Page loaded successfully');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView Error: ${error.description}');
          },
        ),
      )
      ..loadHtmlString(htmlContent, baseUrl: 'https://www.tradingview.com');

    debugPrint("WebViewController configured");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      appBar: SimpleAppbar(title: 'Live Chart'),
      bottomNavigationBar: buildPadding(context),
      body: SafeArea(
        // Remove the Column and make WebView take full available space
        child: WebViewWidget(
          controller: _controller,
        ),
      ),
    );
  }

  Padding buildPadding(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: CupertinoButton(
                      color: AppColor.redColor,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      onPressed: () {
                        Navigator.push(
                            context,
                            SlidePageRoute(
                                page: NewOrderScreen(
                                    side: 'Sell',
                                    symbol: widget.symbolName,
                                    sector: TradeData.stockCategory,
                                    currentPrice: widget.price)));
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Sell',
                              style: TextStyle(
                                  color: AppColor.whiteColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                          Text(
                            widget.price.toString(),
                            style: TextStyle(
                                color: AppColor.whiteColor,
                                fontSize: 13,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: CupertinoButton(
                      color: AppColor.blueColor,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      onPressed: () {
                        Navigator.push(
                            context,
                            SlidePageRoute(
                                page: NewOrderScreen(
                                    side: 'Buy',
                                    symbol: widget.symbolName,
                                    sector: TradeData.stockCategory,
                                    currentPrice: widget.price)));
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Buy',
                              style: TextStyle(
                                  color: AppColor.whiteColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                          Text(
                            widget.price.toString(),
                            style: TextStyle(
                                color: AppColor.whiteColor,
                                fontSize: 13,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.price.toString(),
                  style: TextStyle(fontSize: 10, color: AppColor.blackColor),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            spacing: 15,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(height: 3, color: AppColor.lightGrey),
                        FractionallySizedBox(
                          widthFactor: sellPercentage / 100,
                          child: Container(height: 3, color: AppColor.redColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$sellPercentage%',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColor.redColor,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(height: 3, color: AppColor.lightGrey),
                        FractionallySizedBox(
                          widthFactor: buyPercentage / 100,
                          child:
                              Container(height: 3, color: AppColor.blueColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$buyPercentage%',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColor.blueColor,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
*/

/*
import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/services/balance_masked.dart';
import 'package:exness_clone/services/switch_account_service.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/utils/bottom_sheets.dart';
import 'package:exness_clone/view/trade/model/trade_account.dart';
import 'package:exness_clone/widget/account_bottom_sheet.dart';
import 'package:exness_clone/widget/simple_appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../constant/trade_data.dart';
import '../../../constant/app_vector.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/common_utils.dart';
import '../../../widget/slidepage_navigate.dart';
import '../trade_screen/new_order_screen.dart';
import '../btc_setting/btc_setting_screen.dart';
import '../buy_sell_trade/widget/trade_bottom_sheets.dart';
import '../calculator_screen.dart';
import '../detail_screen.dart';
import '../price_alert_screen.dart';
import '../widget/tab_selector.dart';

class BTCChartScreenUpdated extends StatefulWidget {
  final String symbolName;
  final IconData icon;
  final double price;

  const BTCChartScreenUpdated(
      {super.key,
      required this.symbolName,
      required this.icon,
      required this.price});

  @override
  State<BTCChartScreenUpdated> createState() => _BTCChartScreenUpdatedState();
}

class _BTCChartScreenUpdatedState extends State<BTCChartScreenUpdated> {
  List<String> tabTitle = ['Chart', 'Analytics', 'Specifications'];

  int sellPercentage = 51;
  int buyPercentage = 49;

  final List<Map<String, String>> tradingSignals = const [
    {
      'type': 'Intraday',
      'title':
          'Bitcoin / Dollar intraday: as long as 107890 is support look for 112330',
      'time': '3 hours ago',
    },
    {
      'type': 'Short term',
      'title':
          'Bitcoin / Dollar ST: as long as 101790 is support look for 127050',
      'time': '2 hours ago',
    },
    {
      'type': 'Medium term',
      'title': 'MT: bullish bias above 53000.',
      'time': '29 Oct 2024',
    },
  ];

  final List<Map<String, String>> events = const [
    {
      'title': 'Redbook YoY',
      'time': '18:25',
      'countdown': 'In 29 minutes',
    },
    {
      'title': '52-Week Bill Auction',
      'time': '21:00',
      'countdown': 'In 3 hours',
    },
    {
      'title': '3-Year Note Auction',
      'time': '22:30',
      'countdown': 'In 4 hours',
    },
  ];

  final List<Map<String, String>> newsItems = const [
    {
      'image': AppVector.bull,
      'title':
          "Bitcoin spikes above \$110K after account of Paraguay's president claims BTC legal t...",
      'coin': 'BTC',
      'change': '-0.70%',
      'time': '9 hours ago',
    },
    {
      'image': AppVector.crypto,
      'title':
          'Crypto products mark \$224 million of inflows after strong performance in IBIT an...',
      'coin': 'BTC',
      'change': '-0.70%',
      'time': '14 hours ago',
    },
    {
      'image': AppVector.bull,
      'title':
          'Why the US should care about GENIUS Act as stablecoin market hits new record in 20...',
      'coin': 'BTC',
      'change': '-0.70%',
      'time': '14 hours ago',
    },
  ];

  Color getLabelColor(String type) {
    switch (type) {
      case 'Intraday':
        return AppColor.blueColor;
      case 'Short term':
        return AppColor.blueColor;
      case 'Medium term':
        return AppColor.blueColor;
      default:
        return AppColor.greyColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      {'label': 'Hour', 'value': '+0.24%', 'color': AppColor.blueColor},
      {'label': 'Today', 'value': '-0.72%', 'color': AppColor.redColor},
      {'label': 'Week', 'value': '+4.19%', 'color': AppColor.blueColor},
      {'label': 'Month', 'value': '+5.51%', 'color': AppColor.blueColor},
      {'label': 'Year', 'value': '+87.45%', 'color': AppColor.blueColor},
    ];

    return DefaultTabController(
      length: tabTitle.length,
      child: Scaffold(
        backgroundColor: context.scaffoldBackgroundColor,
        appBar: SimpleAppbar(title: 'Live Chart'),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Row(
                    spacing: 10,
                    children: [
                      Expanded(
                        child: CupertinoButton(
                          color: AppColor.redColor,
                          padding: EdgeInsets.symmetric(vertical: 10),
                          onPressed: () {
                            Navigator.push(
                                context,
                                SlidePageRoute(
                                    page: NewOrderScreen(
                                        side: 'Sell',
                                        symbol: widget.symbolName,
                                        sector: TradeData.stockCategory,
                                        currentPrice: widget.price)));
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Sell',
                                  style: TextStyle(
                                      color: AppColor.whiteColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500)),
                              Text(
                                widget.price.toString(),
                                style: TextStyle(
                                    color: AppColor.whiteColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: CupertinoButton(
                          color: AppColor.blueColor,
                          padding: EdgeInsets.symmetric(vertical: 10),
                          onPressed: () {
                            Navigator.push(
                                context,
                                SlidePageRoute(
                                    page: NewOrderScreen(
                                        side: 'Buy',
                                        symbol: widget.symbolName,
                                        sector: TradeData.stockCategory,
                                        currentPrice: widget.price)));
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Buy',
                                  style: TextStyle(
                                      color: AppColor.whiteColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500)),
                              Text(
                                widget.price.toString(),
                                style: TextStyle(
                                    color: AppColor.whiteColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.price.toString(),
                      style:
                          TextStyle(fontSize: 10, color: AppColor.blackColor),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                spacing: 15,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(height: 3, color: AppColor.lightGrey),
                            FractionallySizedBox(
                              widthFactor: sellPercentage / 100,
                              child: Container(
                                  height: 3, color: AppColor.redColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$sellPercentage%',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColor.redColor,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(height: 3, color: AppColor.lightGrey),
                            FractionallySizedBox(
                              widthFactor: buyPercentage / 100,
                              child: Container(
                                  height: 3, color: AppColor.blueColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$buyPercentage%',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColor.blueColor,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Top Balance and Menu

              ChangeAccountService(accountBuilder: (context, account) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: buildTradeAccountCard(context, account),
                );
              }),

              Container(
                color: context.backgroundColor,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            // backgroundColor: AppColor.orangeColor,
                            backgroundColor: AppColor.lightGrey,
                            radius: 16,
                            child: Icon(
                              widget.icon,
                              color: AppColor.blueColor,
                              // color: AppColor.whiteColor,
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(widget.symbolName,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                          Icon(Icons.keyboard_arrow_down_rounded),
                        ],
                      ),
                      Spacer(),
                      IconButton(
                          style: IconButton.styleFrom(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            Navigator.push(context,
                                SlidePageRoute(page: PriceAlertScreen()));
                          },
                          icon: Icon(
                            Icons.access_alarm_rounded,
                            size: 22,
                          )),
                      IconButton(
                          style: IconButton.styleFrom(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            Navigator.push(context,
                                SlidePageRoute(page: CalculatorScreen()));
                          },
                          icon: Icon(
                            CupertinoIcons.square_list,
                            size: 22,
                          )),
                      IconButton(
                          style: IconButton.styleFrom(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            Navigator.push(context,
                                SlidePageRoute(page: BTCSettingsScreen()));
                          },
                          icon: Icon(
                            CupertinoIcons.gear,
                            size: 22,
                          )),
                    ],
                  ),
                ),
              ),
              // Tabs
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    TabSelector(title: 'Open', count: 0),
                    SizedBox(width: 8),
                    TabSelector(title: 'Pending', count: 0),
                  ],
                ),
              ),
              TabBar(
                dividerColor: AppColor.transparent,
                labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.4),
                labelColor: context.tabLabelColor,
                unselectedLabelColor: AppColor.greyColor,
                indicatorColor: context.tabLabelColor,
                indicatorWeight: 2,
                tabs: tabTitle.map((tab) => Tab(text: tab)).toList(),
              ), // Chart

              Expanded(
                child: TabBarView(children: [
                  Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Image.asset(
                            AppVector.trading,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            _buildButton(
                              child: const Icon(
                                Icons.show_chart,
                                size: 16,
                              ),
                              decoration: BoxDecoration(
                                color: context
                                    .boxDecorationColor, // light gray background
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildButton(
                              child: const Text(
                                '5 m',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: context
                                    .boxDecorationColor, // light gray background
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildButton(
                              child: const Icon(
                                Icons.insert_chart_outlined,
                                size: 16,
                              ),
                              decoration: BoxDecoration(
                                color: context
                                    .boxDecorationColor, // light gray background
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColor.mediumGrey),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: items.map((item) {
                                final isSelected =
                                    item['label'] == 'Hour'; // Highlight 'Hour'
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: isSelected
                                      ? BoxDecoration(
                                          color: context.boxDecorationColor,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        )
                                      : null,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${item['label']}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${item['value']}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: item['color'] as Color,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        Image.asset(
                          AppVector.trading,
                          height: 150,
                          fit: BoxFit.fill,
                          width: double.infinity,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'UPCOMING HMR PERIODS',
                                style: TextStyle(
                                    color: AppColor.greyColor,
                                    fontSize: 12,
                                    letterSpacing: 1.5),
                              ),
                              Icon(
                                CupertinoIcons.info,
                                size: 24,
                              )
                            ],
                          ),
                        ),
                        Divider(
                          color: AppColor.mediumGrey,
                        ),
                        Column(
                          children: List.generate(3, (index) {
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15, right: 15),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    dense: true,
                                    title: Text(
                                      '21:15 - 21:31',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15),
                                    ),
                                    subtitle: Text(
                                      'Leverage 1:200',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: AppColor.greyColor,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    trailing: Icon(CupertinoIcons.bell),
                                  ),
                                ),
                                Divider(
                                  color: AppColor.mediumGrey,
                                  thickness: 0.6,
                                  height: 10,
                                ),
                              ],
                            );
                          }),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                foregroundColor: AppColor.blackColor,
                                backgroundColor: AppColor.lightGrey,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text(
                                "Show More",
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                        Divider(
                          color: AppColor.mediumGrey,
                          thickness: 0.6,
                          height: 10,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            'TRADING SIGNALS',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: AppColor.greyColor,
                                fontSize: 12,
                                letterSpacing: 1.5),
                          ),
                        ),
                        Divider(
                          color: AppColor.mediumGrey,
                          height: 15,
                        ),
                        Column(
                          spacing: 15,
                          children:
                              List.generate(tradingSignals.length, (index) {
                            final signal = tradingSignals[index];

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: getLabelColor(signal['type']!),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '↑ ${signal['type']}',
                                          style: TextStyle(
                                              color: AppColor.whiteColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        signal['title']!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 6,
                                      ),
                                      Text(
                                        signal['time']!,
                                        style: TextStyle(
                                          color: AppColor.greyColor,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),
                                Divider(
                                  thickness: 0.5,
                                  color: AppColor.mediumGrey,
                                  height: 0,
                                )
                              ],
                            );
                          }),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                foregroundColor: AppColor.blackColor,
                                backgroundColor: AppColor.lightGrey,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text(
                                "Show More",
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            'UPCOMING EVENTS',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: AppColor.greyColor,
                                fontSize: 12,
                                letterSpacing: 1.5),
                          ),
                        ),
                        Divider(
                          color: AppColor.mediumGrey,
                          height: 15,
                        ),
                        Column(
                          spacing: 15,
                          children:
                              List.generate(tradingSignals.length, (index) {
                            final event = events[index];

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 10),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const CircleAvatar(
                                        radius: 18,
                                        backgroundColor: Colors.transparent,
                                        backgroundImage: AssetImage(AppVector
                                            .usFlag), // Replace with correct path
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              event['title']!,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Text("US",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                                const SizedBox(width: 6),
                                                Container(
                                                  width: 4,
                                                  height: 16,
                                                  decoration: BoxDecoration(
                                                    color: AppColor.amberColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            2),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  "${event['time']} – ${event['countdown']}",
                                                  style: TextStyle(
                                                      color: AppColor.greyColor,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),
                                Divider(
                                  thickness: 0.5,
                                  color: AppColor.mediumGrey,
                                  height: 0,
                                )
                              ],
                            );
                          }),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                foregroundColor: AppColor.blackColor,
                                backgroundColor: AppColor.lightGrey,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text(
                                "Show More",
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                        Divider(
                            color: AppColor.mediumGrey,
                            thickness: 0.6,
                            height: 10),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            'LATEST NEWS',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: AppColor.greyColor,
                                fontSize: 12,
                                letterSpacing: 1.5),
                          ),
                        ),
                        Divider(
                          color: AppColor.mediumGrey,
                          height: 15,
                        ),
                        Column(
                          spacing: 15,
                          children:
                              List.generate(tradingSignals.length, (index) {
                            final news = newsItems[index];

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 10),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Thumbnail Image
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: Image.asset(
                                          news['image']!,
                                          width: 70,
                                          height: 70,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      // Text Content
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              news['title']!,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Text(
                                                  news['coin']!,
                                                  style: TextStyle(
                                                      color: AppColor.greyColor,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  '↓ ${news['change']}',
                                                  style: TextStyle(
                                                    color: AppColor.redColor,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  news['time']!,
                                                  style: TextStyle(
                                                    color: AppColor.greyColor,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),
                                Divider(
                                  thickness: 0.5,
                                  color: AppColor.mediumGrey,
                                  height: 0,
                                )
                              ],
                            );
                          }),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                foregroundColor: AppColor.blackColor,
                                backgroundColor: AppColor.lightGrey,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text(
                                "Show More",
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                        Divider(
                            color: AppColor.mediumGrey,
                            thickness: 0.6,
                            height: 10),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Text('TRADING HOURS',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.greyColor,
                                  letterSpacing: 0.8)),
                          const SizedBox(height: 8),
                          Row(
                            children: const [
                              Icon(
                                Icons.access_time,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text("Market is open",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 18,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Info Section
                          Text('INFO',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.greyColor,
                                  letterSpacing: 0.8)),
                          const SizedBox(height: 12),
                          _infoRow(
                            'Minimum volume, lots',
                            '0.01',
                          ),
                          _infoRow(
                            'Maximum volume, lots',
                            '100',
                          ),
                          _infoRow(
                            'Step',
                            '0.01',
                          ),
                          _infoRow(
                            'Contract size',
                            '1',
                          ),
                          _infoRow(
                            'Spread units',
                            'USD',
                          ),
                          _infoRow(
                            'Stop level, pips',
                            '0.0',
                          ),
                          _infoRow(
                            'Swap long, pips',
                            '-225.2',
                          ),
                          _infoRow(
                            'Swap short, pips',
                            '0.0',
                          ),
                        ],
                      ),
                    ),
                  )
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Text(
            label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          )),
          const SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColor.greyColor),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
      {required Widget child, required BoxDecoration decoration}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: decoration,
      child: child,
    );
  }

  Widget buildTradeAccountCard(BuildContext context, Account account) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppFlavorColor.primary,
            AppFlavorColor.darkPrimary
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppFlavorColor.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              UIBottomSheets.accountBottomSheet<String>(
                  context, AccountsTabSheet());
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: AppColor.whiteColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColor.whiteColor.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: AppColor.whiteColor,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Account",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColor.whiteColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColor.whiteColor,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColor.whiteColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            account.group?.groupName ?? 'Standard',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColor.whiteColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColor.whiteColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            CommonUtils.capitalizeFirst(account.accountType) ??
                                '',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColor.whiteColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "# ${account.accountId}",
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColor.whiteColor.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              BalanceMasked(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Balance",
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColor.whiteColor.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          CommonUtils.formatBalance(
                              account.balance?.toDouble() ?? 0),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColor.whiteColor,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColor.whiteColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "USD",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColor.whiteColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
*/
