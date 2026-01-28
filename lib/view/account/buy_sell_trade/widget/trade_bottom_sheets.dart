/*
import 'package:exness_clone/services/switch_account_service.dart';
import 'package:exness_clone/services/storage_service.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/view/account/buy_sell_trade/model/trade_payload.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../config/flavor_config.dart';
import '../../../../constant/trade_data.dart';
import '../../../../theme/app_colors.dart';
import '../../../../utils/snack_bar.dart';
import '../provider/orders_provider.dart';

Future<void> showBuyTradeBottomSheet(
  BuildContext context, {
  required String symbol,
  required double currentPrice,
  required String sector,
}) async =>
    _showTradeSheet(context,
        side: 'Buy',
        symbol: symbol,
        sector: sector,
        currentPrice: currentPrice);

Future<void> showSellTradeBottomSheet(
  BuildContext context, {
  required String symbol,
  required double currentPrice,
  required String sector,
}) async =>
    _showTradeSheet(context,
        side: 'Sell',
        symbol: symbol,
        sector: sector,
        currentPrice: currentPrice);

Future<void> _showTradeSheet(
  BuildContext context, {
  required String side,
  required String symbol,
  required String sector,
  required double currentPrice,
}) async {
  final lotCtrl = TextEditingController(text: '1.0');
  final tpCtrl = TextEditingController();
  final slCtrl = TextEditingController();
  final priceCtrl =
      TextEditingController(text: currentPrice.toStringAsFixed(2));

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 12,
        ),
        child: SwitchAccountService(accountBuilder: (context, account) {
          return Consumer<OrdersProvider>(
            builder: (ctx, p, _) {
              final jwt = StorageService.getToken();
              final userId = StorageService.getUser();
              debugPrint("User Id ${userId?.id ?? ''}");

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text('$symbol  •  $side',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Text('Price ${currentPrice..toString()}',
                          style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: lotCtrl,
                          enabled: !p.isPlacingOrder,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(labelText: 'Lot'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: priceCtrl,
                          enabled: !p.isPlacingOrder,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration:
                              const InputDecoration(labelText: 'Entry (avg)'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: tpCtrl,
                          enabled: !p.isPlacingOrder,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration:
                              const InputDecoration(labelText: 'TP (target)'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: slCtrl,
                          enabled: !p.isPlacingOrder,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration:
                              const InputDecoration(labelText: 'SL (exit)'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: p.isPlacingOrder
                              ? null
                              : () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: side == 'Sell'
                                ? AppColor.redColor
                                : AppFlavorColor.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: p.isPlacingOrder
                              ? null
                              : () async {
                                  final lot =
                                      double.tryParse(lotCtrl.text.trim()) ??
                                          1.0;
                                  final avg =
                                      double.tryParse(priceCtrl.text.trim()) ??
                                          currentPrice;
                                  final tp = tpCtrl.text.trim().isEmpty
                                      ? null
                                      : double.tryParse(tpCtrl.text.trim());
                                  final sl = slCtrl.text.trim().isEmpty
                                      ? null
                                      : double.tryParse(slCtrl.text.trim());

                                  // final res = await p.createTrade(
                                  //     tradeAccountId: account.id ?? '',
                                  //     userId: userId?.id ?? '',
                                  //     symbol: symbol,
                                  //     lot: lot,
                                  //     side: side,
                                  //     avg: avg,
                                  //     sector: TradeData.stockCategory,
                                  //     target: tp,
                                  //     exit: sl,
                                  //     jwt: jwt ?? '');
                                  // final res = await p.createTrade(
                                  //   payload: TradePayload(
                                  //     tradeAccountId: account.id ?? '',
                                  //     symbol: symbol,
                                  //     lot: lot,
                                  //     bs: side,
                                  //     avg: avg,
                                  //     sector: TradeData.stockCategory,
                                  //     target: tp,
                                  //     exit: sl,
                                  //   ),
                                  //   jwt: jwt ?? '',
                                  //   userId: userId?.id ?? '',
                                  // );

                                  // if (ctx.mounted) {
                                  //   Navigator.pop(ctx);
                                  //   SnackBarService.showInfo(
                                  //       res ?? 'Unknown response');
                                  // }
                                },
                          child: p.isPlacingOrder
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColor.whiteColor),
                                  ),
                                )
                              : Text(
                                  side,
                                  style: TextStyle(color: AppColor.whiteColor),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        }),
      );
    },
  );
}

*/
/*
import 'package:exness_clone/services/switch_account_service.dart';
import 'package:exness_clone/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../utils/snack_bar.dart';
import '../provider/orders_provider.dart';

Future<void> showBuyTradeBottomSheet(
  BuildContext context, {
  required String symbol,
  required double currentPrice,
}) {
  return _showTradeSheet(context,
      side: 'Buy', symbol: symbol, currentPrice: currentPrice);
}

Future<void> showSellTradeBottomSheet(
  BuildContext context, {
  required String symbol,
  required double currentPrice,
}) {
  return _showTradeSheet(context,
      side: 'Sell', symbol: symbol, currentPrice: currentPrice);
}

Future<void> _showTradeSheet(
  BuildContext context, {
  required String side,
  required String symbol,
  required double currentPrice,
}) async {
  final lotCtrl = TextEditingController(text: '1.0');
  final tpCtrl = TextEditingController();
  final slCtrl = TextEditingController();
  final priceCtrl =
      TextEditingController(text: currentPrice.toStringAsFixed(2));

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 12,
        ),
        child: ChangeAccountService(accountBuilder: (context, account) {
          return Consumer<OrdersProvider>(
            builder: (ctx, p, _) {
              final jwt = StorageService.getToken();
              final userId = StorageService.getUser();
              debugPrint("User Id ${userId?.id ?? ''}");
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text('$symbol  •  $side',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Text('Price ${currentPrice.toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: lotCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(labelText: 'Lot'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: priceCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration:
                              const InputDecoration(labelText: 'Entry (avg)'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: tpCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration:
                              const InputDecoration(labelText: 'TP (target)'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: slCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration:
                              const InputDecoration(labelText: 'SL (exit)'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(8), // same radius
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                side == 'Sell' ? Colors.red : Colors.blue,
                            // padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            final lot =
                                double.tryParse(lotCtrl.text.trim()) ?? 1.0;
                            final avg =
                                double.tryParse(priceCtrl.text.trim()) ??
                                    currentPrice;
                            final tp = tpCtrl.text.trim().isEmpty
                                ? null
                                : double.tryParse(tpCtrl.text.trim());
                            final sl = slCtrl.text.trim().isEmpty
                                ? null
                                : double.tryParse(slCtrl.text.trim());

                            // Supply your tradeAccountId and market accordingly
                            final tradeId = await p.createTrade(
                                tradeAccountId: account.id ?? '',
                                userId: userId?.id ?? '',
                                symbol: symbol,
                                lot: lot,
                                side: side,
                                avg: avg,
                                target: tp,
                                exit: sl,
                                jwt: jwt ?? '');

                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              if (tradeId == null) {
                                SnackBarService.showError('Order failed');
                              } else {
                                SnackBarService.showSuccess('Order placed');
                              }
                            }
                          },
                          child: Text(
                            side,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        }),
      );
    },
  );
}
*/

