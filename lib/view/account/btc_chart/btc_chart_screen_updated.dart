import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/provider/datafeed_provider.dart';
import 'package:exness_clone/services/data_feed_ws.dart';
import 'package:exness_clone/services/reactive_data_service.dart';
import 'package:exness_clone/services/trading_view_service.dart';
import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/utils/snack_bar.dart';
import 'package:exness_clone/view/account/trade_screen/new_order_screen.dart';
import 'package:exness_clone/widget/simple_appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constant/trade_data.dart';
import '../../../widget/slidepage_navigate.dart';
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
  late String _uniqueCacheKey;

  @override
  void initState() {
    super.initState();
    _uniqueCacheKey =
        '${widget.symbolName}_detail_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _isInit = true;
      final isDark = Theme.of(context).brightness == Brightness.dark;

      context
          .read<DataFeedProvider>()
          .subscribeToSymbols([widget.symbolName.toUpperCase()]);

      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) {
          setState(() {
            _controller = _chartService.getController(
              widget.symbolName,
              interval: _selectedInterval,
              tradeUserId: widget.tradeUserId,
              context: context,
              isDarkMode: isDark,
              cacheKey: _uniqueCacheKey,
            );
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _chartService.removeController(_uniqueCacheKey);
    super.dispose();
  }

  String _formatPrice(double? value,
      {int minDecimals = 2, int maxDecimals = 5}) {
    if (value == null) return '--';
    String s = value.toStringAsFixed(maxDecimals);
    int dotIndex = s.indexOf('.');
    if (dotIndex == -1) return s;

    int end = s.length;
    while (end > dotIndex + 1 &&
        end - (dotIndex + 1) > minDecimals &&
        s[end - 1] == '0') {
      end--;
    }
    if (s[end - 1] == '.') end--;
    return s.substring(0, end);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF161A1E) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: SimpleAppbar(title: widget.symbolName),
      bottomNavigationBar: buildPadding(context, isDark),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _controller == null
                  ? const Center(child: CupertinoActivityIndicator())
                  : Selector<DataFeedProvider, LiveProfit?>(
                      selector: (_, provider) {
                        return provider.liveData[widget.symbolName] ??
                            provider.liveData[widget.symbolName.toUpperCase()];
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
                            child: WebViewWidget(controller: _controller!));
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPadding(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2329) : Colors.white,
        border: Border(
            top: BorderSide(
                color: isDark ? Colors.white10 : Colors.black12, width: 0.5)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ReactiveDataService(
                  symbolName: widget.symbolName,
                  builder: (context, liveData, calculations) {
                    return GestureDetector(
                      onTap: () => _goToOrder(
                          context: context,
                          price: calculations.askValue,
                          side: 'Sell'),
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                            color: const Color(0xFFF6465D),
                            borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Sell / Short',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold)),
                            Text(_formatPrice(calculations.askValue),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    );
                  }),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ReactiveDataService(
                  symbolName: widget.symbolName,
                  builder: (context, liveData, calculations) {
                    return GestureDetector(
                      onTap: () => _goToOrder(
                          context: context,
                          price: calculations.bidValue,
                          side: 'Buy'),
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                            color: const Color(0xFF0ECB81),
                            borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Buy / Long',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold)),
                            Text(_formatPrice(calculations.bidValue),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }

  void _goToOrder(
      {required BuildContext context,
      required double? price,
      required String side}) {
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
                sector: TradeData.stockCategory)));
  }
}
