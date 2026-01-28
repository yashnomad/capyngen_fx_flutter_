/*
import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/utils/bottom_nav_helper.dart';
import 'package:exness_clone/view/account/buy_sell_trade/model/create_trade_response.dart';
import 'package:exness_clone/view/account/buy_sell_trade/provider/orders_provider.dart';
import 'package:exness_clone/view/account/buy_sell_trade/widget/trade_bottom_sheets.dart';
import 'package:exness_clone/widget/button/premium_app_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constant/trade_data.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrdersProvider>(
      builder: (context, p, _) {
        final hasTrades = p.trades.isNotEmpty;

        return Scaffold(
          appBar: AppBar(
            flexibleSpace: Container(
              color: context.backgroundColor,
            ),
            title: const Text(
              'Open Orders',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            centerTitle: true,
            elevation: 1,
            bottom: p.equity != null
                ? PreferredSize(
                    preferredSize: const Size.fromHeight(50),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceVariant
                          .withOpacity(0.3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // _statChip('Balance', double.tryParse(p.equity!.balance) ?? 0.0),
                          _statChip(
                              'Funds', double.tryParse(p.equity!.userAssets.fund) ?? 0.0),
                          _statChip('Equity',
                              double.tryParse(p.equity!.equity) ?? 0.0),
                          _statChip('Free',
                              double.tryParse(p.equity!.freeMargin) ?? 0.0),
                          _statChip( 
                              'PNL', double.tryParse(p.equity!.pnl) ?? 0.0,
                              color: (double.tryParse(p.equity!.pnl) ?? 0) >= 0
                                  ? Colors.green
                                  : Colors.red),
                        ],
                      ),
                    ),
                  )
                : null,
          ),
          body: hasTrades
              ? ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: p.trades.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final t = p.trades[i];
                    final isBuy = t.side == TradeSide.buy;
                    return Container(
                      decoration: BoxDecoration(
                        color: context.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isBuy
                                    ? Colors.green.withOpacity(0.15)
                                    : Colors.red.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isBuy ? 'BUY' : 'SELL',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isBuy ? Colors.green : Colors.red,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.symbol,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Lot: ${t.lot} • TP: ${t.tp ?? '-'} • SL: ${t.sl ?? '-'}',
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 13),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Avg Price: ${t.avg.toString()}',
                                    // 'Avg Price: ${t.avg.toStringAsFixed(2)}',
                                    style: TextStyle(
                                        color: Colors.grey[500], fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  t.profit.toString(),
                                  // t.profit.toStringAsFixed(2),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: t.profit >= 0
                                        ? AppColor.greenColor
                                        : AppColor.redColor,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                        icon: Icon(Icons.edit,
                                            size: 20,
                                            color: AppColor.greyColor),
                                        onPressed: () {
                                          isBuy
                                              ? showBuyTradeBottomSheet(
                                                  context,
                                                  symbol: t.symbol,
                                                  sector:
                                                      TradeData.stockCategory,
                                                  currentPrice: t.avg,
                                                )
                                              : showSellTradeBottomSheet(
                                                  context,
                                                  symbol: t.symbol,
                                                  sector:
                                                      TradeData.stockCategory,
                                                  currentPrice: t.avg,
                                                );
                                        }),
                                    IconButton(
                                      icon: Icon(Icons.close,
                                          size: 20, color: AppColor.greyColor),
                                      onPressed: () => p.closeTrade(t.id),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : _EmptyPlaceholder(onPlaceOrder: () => BottomNavHelper.goTo(0)
                  //     showBuyTradeBottomSheet(
                  //   context,
                  //   symbol: "C:GBPUSD",
                  //   sector: AppData.stockCategory,
                  //   currentPrice: 10.0,
                  // ),
                  ),
          // floatingActionButton: PremiumAppButton(
          //   text: 'Place Order',
          //   onPressed: () => showBuyTradeBottomSheet(
          //     context,
          //     symbol: "C:GBPUSD",
          //     sector: AppData.stockCategory,
          //     currentPrice: 10.0,
          //   ),
          //   showIcon: true,
          //   icon: Icons.add,
          //   width: MediaQuery.of(context).size.width * 0.5,
          // ),
        );
      },
    );
  }

  */
/* static Widget _statChip(String label, double value, {Color? color}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(
          value.toStringAsFixed(2),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color ,
          ),
        ),
      ],
    );
  }*//*

  static Widget _statChip(String label, double value, {Color? color}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(
          value.toString(),
          // value.toStringAsFixed(2),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black,
          ),
        ),
      ],
    );
  }
}

class _EmptyPlaceholder extends StatelessWidget {
  final VoidCallback onPlaceOrder;
  const _EmptyPlaceholder({required this.onPlaceOrder});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.10),
                    theme.colorScheme.primary.withOpacity(0.02),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 48,
                color: AppFlavorColor.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Open Orders',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'When you place an order, it will appear here with real-time updates.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            PremiumAppButton(
              text: 'Place Your First Order',
              onPressed: onPlaceOrder,
              showIcon: true,
              icon: Icons.add,
              width: MediaQuery.of(context).size.width * 0.7,
            ),
          ],
        ),
      ),
    );
  }
}
*/
