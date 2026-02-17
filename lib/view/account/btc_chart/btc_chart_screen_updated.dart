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
  WebViewController? _controller;
  final TradingViewService _chartService = TradingViewService();

  String _selectedInterval = '1';
  bool _isInit = false;

  int sellPercentage = 51;
  int buyPercentage = 49;

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

  void _changeInterval(String interval) {
    setState(() {
      _selectedInterval = interval;
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;

      _controller = _chartService.getController(
        widget.symbolName,
        interval: _selectedInterval,
        tradeUserId: widget.tradeUserId,
        context: context,
        isDarkMode: isDarkMode,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;

      _controller = _chartService.getController(
        widget.symbolName,
        interval: _selectedInterval,
        tradeUserId: widget.tradeUserId,
        context: context,
        isDarkMode: isDarkMode,
      );
      _isInit = true;
    }
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
        child: _controller == null
            ? const Center(child: CupertinoActivityIndicator())
            : Selector<DataFeedProvider, LiveProfit?>(
                selector: (_, provider) {
                  var data = provider.liveData[widget.symbolName];
                  data ??= provider.liveData[widget.symbolName.toUpperCase()];
                  data ??= provider.liveData[widget.symbolName.toLowerCase()];
                  return data;
                },
                shouldRebuild: (prev, next) =>
                    prev?.timestamp != next?.timestamp,
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
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            onPressed: () => _goToOrder(
                              context: context,
                              price: calculations.askValue,
                              side: 'Sell',
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Sell',
                                    style: TextStyle(
                                        color: AppColor.whiteColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500)),
                                Text(
                                  calculations.askValue.toString(),
                                  style: TextStyle(
                                      color: AppColor.whiteColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        }),
                  ),
                  Expanded(
                    child: ReactiveDataService(
                      builder: (context, liveData, calculations) {
                        return CupertinoButton(
                          color: AppColor.blueColor,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          onPressed: () => _goToOrder(
                            context: context,
                            price: calculations.bidValue,
                            side: 'Buy',
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Buy',
                                  style: TextStyle(
                                      color: AppColor.whiteColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500)),
                              Text(
                                calculations.bidValue.toString(),
                                style: TextStyle(
                                    color: AppColor.whiteColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        );
                      },
                      symbolName: widget.symbolName,
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
