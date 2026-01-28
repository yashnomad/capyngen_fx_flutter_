import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/view/account/buy_sell_trade/model/trade_model.dart';
import 'package:exness_clone/view/account/buy_sell_trade/model/ws_equity_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderProgressCard extends StatefulWidget {
  final TradeModel trade;
  final LiveProfit liveProfit;
  final Future<void> Function() onDelete;
  final Future<void> Function()? onModify;
  final bool isHistory;

  const OrderProgressCard({
    super.key,
    required this.onDelete,
    this.onModify,
    required this.liveProfit,
    required this.trade,
    this.isHistory = false,
  });

  @override
  State<OrderProgressCard> createState() => _OrderProgressCardState();
}

class _OrderProgressCardState extends State<OrderProgressCard> {
  @override
  Widget build(BuildContext context) {
    final t = widget.trade;
    final lp = widget.liveProfit;

    // --- 1. Determine Values ---
    final isBuy = (t.bs ?? 'Buy').toLowerCase() == 'buy';

    // PnL
    final displayProfit =
        widget.isHistory ? (t.profitLossAmount ?? 0.0) : lp.profit;

    // Prices
    final entryPriceVal = t.avg ?? 0.0;

    // Current Price Logic
    final double currentPriceVal;
    if (widget.isHistory) {
      currentPriceVal = t.exit ?? 0.0;
    } else {
      if (lp.price != null && lp.price! > 0) {
        currentPriceVal = lp.price!;
      } else {
        currentPriceVal = entryPriceVal;
      }
    }

    // --- 2. Format Strings ---
    final entryPriceStr = entryPriceVal.toStringAsFixed(5);
    final currentPriceStr = currentPriceVal.toStringAsFixed(5);

    // S/L and T/P formatting (show '-' if null or 0)
    final slStr = (t.sl != null && t.sl! > 0) ? t.sl!.toStringAsFixed(5) : '-';
    final tpStr = (t.target != null && t.target! > 0)
        ? t.target!.toStringAsFixed(5)
        : '-';

    final pnlColor =
        displayProfit >= 0 ? AppFlavorColor.success : AppFlavorColor.error;

    return Container(
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.greyColor.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Top Row: Symbol, Type, PnL ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          t.symbol ?? "Unknown",
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 1),
                          decoration: BoxDecoration(
                            color: isBuy
                                ? AppFlavorColor.success.withValues(alpha: 0.2)
                                : AppFlavorColor.error.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isBuy ? "BUY" : "SELL",
                            style: TextStyle(
                                color: isBuy
                                    ? AppFlavorColor.success
                                    : AppFlavorColor.error,
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'PnL ',
                          style: TextStyle(
                              fontSize: 13,
                              color: AppColor.textColor,
                              fontWeight: FontWeight.w600),
                        ),
                        Text(
                          displayProfit.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: pnlColor,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    )
                  ],
                ),

                const SizedBox(height: 12),

                // --- Middle Row 1: Prices & Vol ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(entryPriceStr,
                            style: TextStyle(
                                fontSize: 13,
                                color: AppColor.greyColor,
                                fontWeight: FontWeight.w500)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(Icons.arrow_right_alt_rounded,
                              size: 14,
                              color: AppColor.greyColor.withOpacity(0.5)),
                        ),
                        Text(currentPriceStr,
                            style: TextStyle(
                                fontSize: 13,
                                color: AppColor.textColor,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                    Row(
                      children: [
                        Text('Vol:',
                            style: TextStyle(
                                fontSize: 13,
                                color: AppColor.greyColor,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(width: 4),
                        Text(
                          (t.lot ?? 0.0).toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppColor.textColor,
                          ),
                        ),
                      ],
                    )
                  ],
                ),

                const SizedBox(height: 8),

                // --- Middle Row 2: S/L & T/P (New Section) ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Stop Loss
                    Row(
                      children: [
                        Text('S/L:',
                            style: TextStyle(
                                fontSize: 13,
                                color: AppColor
                                    .greyColor, // Or use Colors.red.withOpacity(0.7)
                                fontWeight: FontWeight.w500)),
                        const SizedBox(width: 4),
                        Text(
                          slStr,
                          style: TextStyle(
                            fontWeight: FontWeight
                                .w500, // Slightly less bold than prices
                            fontSize: 13,
                            color: AppColor.textColor,
                          ),
                        ),
                      ],
                    ),
                    // Take Profit
                    Row(
                      children: [
                        Text('T/P:',
                            style: TextStyle(
                                fontSize: 13,
                                color: AppColor
                                    .greyColor, // Or use Colors.green.withOpacity(0.7)
                                fontWeight: FontWeight.w500)),
                        const SizedBox(width: 4),
                        Text(
                          tpStr,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            color: AppColor.textColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // --- Bottom Actions ---
                if (!widget.isHistory) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, thickness: 0.5),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCompactButton(
                          label: 'Modify',
                          icon: Icons.edit_outlined,
                          color: AppFlavorColor.primary,
                          bgColor: Colors.transparent,
                          onTap: () async {
                            if (widget.onModify != null) {
                              await widget.onModify!();
                            }
                          },
                        ),
                      ),
                      Container(
                          width: 1,
                          height: 16,
                          color: AppColor.greyColor.withOpacity(0.2)),
                      Expanded(
                        child: _buildCompactButton(
                          label: 'Close',
                          icon: Icons.close,
                          color: AppFlavorColor.error,
                          bgColor: Colors.transparent,
                          onTap: () async => widget.onDelete(),
                        ),
                      ),
                    ],
                  )
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactButton({
    required String label,
    required IconData icon,
    required Color color,
    required Color bgColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*
import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/view/account/buy_sell_trade/model/trade_model.dart';
import 'package:exness_clone/view/account/buy_sell_trade/model/ws_equity_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderProgressCard extends StatefulWidget {
  final TradeModel trade;
  final LiveProfit liveProfit;
  final Future<void> Function() onDelete;
  final Future<void> Function()? onModify;
  final bool isHistory;

  const OrderProgressCard({
    super.key,
    required this.onDelete,
     this.onModify,
    required this.liveProfit,
    required this.trade,
    this.isHistory = false,
  });

  @override
  State<OrderProgressCard> createState() => _OrderProgressCardState();
}

class _OrderProgressCardState extends State<OrderProgressCard> {
  @override
  Widget build(BuildContext context) {
    final t = widget.trade;
    final lp = widget.liveProfit;

    // --- 1. Determine Values ---
    final isBuy = (t.bs ?? 'Buy').toLowerCase() == 'buy';

    // PnL: Live from socket OR static history
    final displayProfit =
    widget.isHistory ? (t.profitLossAmount ?? 0.0) : lp.profit;

    // Entry Price
    final entryPriceVal = t.avg ?? 0.0;

    // Current Price Logic:
    // 1. History -> Use Exit Price (t.exit)
    // 2. Active -> Use Live Socket Price (lp.price)
    // 3. Fallback -> Use Entry Price (t.avg) if socket data isn't in yet
    final double currentPriceVal;
    if (widget.isHistory) {
      currentPriceVal = t.exit ?? 0.0;
    } else {
      // If we have a valid live price, use it. Otherwise, show entry price.
      if (lp.price != null && lp.price! > 0) {
        currentPriceVal = lp.price!;
      } else {
        currentPriceVal = entryPriceVal;
      }
    }

    // --- 2. Format Strings ---
    final entryPriceStr = entryPriceVal.toStringAsFixed(5);
    final currentPriceStr = currentPriceVal.toStringAsFixed(5);

    final pnlColor =
    displayProfit >= 0 ? AppFlavorColor.success : AppFlavorColor.error;

    final dateStr = t.openedAt != null
        ? DateFormat('dd MMM HH:mm')
        .format(DateTime.parse(t.openedAt!).toLocal())
        : DateFormat('dd MMM HH:mm').format(DateTime.now());

    return Container(
      // margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.greyColor.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Top Row: Symbol, Type, PnL ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          t.symbol ?? "Unknown",
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 1),
                          decoration: BoxDecoration(
                            color: isBuy
                                ? AppFlavorColor.success.withValues(alpha: 0.2)
                                : AppFlavorColor.error.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isBuy ? "BUY" : "SELL",
                            style: TextStyle(
                                color: isBuy
                                    ? AppFlavorColor.success
                                    : AppFlavorColor.error,
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'PnL ',
                          style: TextStyle(
                              fontSize: 13,
                              color: AppColor.textColor,
                              fontWeight: FontWeight.w600),
                        ),
                        Text(
                          displayProfit.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: pnlColor,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    )
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(entryPriceStr,
                            style: TextStyle(
                                fontSize: 13,
                                color: AppColor.greyColor,
                                fontWeight: FontWeight.w500)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(Icons.arrow_right_alt_rounded,
                              size: 14,
                              color: AppColor.greyColor.withOpacity(0.5)),
                        ),
                        Text(currentPriceStr,
                            style: TextStyle(
                                fontSize: 13,
                                color: AppColor.textColor,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                    Row(
                      children: [
                        Text('Vol:',
                            style: TextStyle(
                                fontSize: 13,
                                color: AppColor.greyColor,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(width: 8),
                        Text(
                          (t.lot ?? 0.0).toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppColor.textColor,
                          ),
                        ),
                      ],
                    )
                  ],
                ),

                if (!widget.isHistory) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, thickness: 0.5),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCompactButton(
                          label: 'Modify',
                          icon: Icons.edit_outlined,
                          color: AppFlavorColor.primary,
                          bgColor: Colors.transparent,
                          onTap: () async {
                            if (widget.onModify != null) {
                              await widget.onModify!();
                            }
                          },

                        ),
                      ),
                      Container(
                          width: 1,
                          height: 16,
                          color: AppColor.greyColor.withOpacity(0.2)),
                      Expanded(
                        child: _buildCompactButton(
                          label: 'Close',
                          icon: Icons.close,
                          color: AppFlavorColor.error,
                          bgColor: Colors.transparent,
                          onTap: () async => widget.onDelete(),
                        ),
                      ),
                    ],
                  )
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactButton({
    required String label,
    required IconData icon,
    required Color color,
    required Color bgColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/

/*
import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/view/account/buy_sell_trade/model/trade_model.dart';
import 'package:exness_clone/view/account/buy_sell_trade/model/ws_equity_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderProgressCard extends StatefulWidget {
  final TradeModel trade;
  final LiveProfit liveProfit;
  final Future<void> Function() onDelete;
  final bool isHistory;

  const OrderProgressCard({
    super.key,
    required this.onDelete,
    required this.liveProfit,
    required this.trade,
    this.isHistory = false,
  });

  @override
  State<OrderProgressCard> createState() => _OrderProgressCardState();
}

class _OrderProgressCardState extends State<OrderProgressCard> {
  @override
  Widget build(BuildContext context) {
    final t = widget.trade;
    final lp = widget.liveProfit;
    final isBuy = (t.bs ?? 'Buy').toLowerCase() == 'buy';
    final displayProfit =
        widget.isHistory ? (t.profitLossAmount ?? 0.0) : lp.profit;

    final pnlColor =
        displayProfit >= 0 ? AppFlavorColor.success : AppFlavorColor.error;
    final typeColor = isBuy ? AppFlavorColor.success : AppFlavorColor.error;
    final entryPrice = (t.avg ?? 0.0).toStringAsFixed(5);
    final currentPrice = widget.isHistory
        ? (t.exit ?? 0.0).toStringAsFixed(5)
        : (t.avg ?? 0.0).toStringAsFixed(5);
    final dateStr = t.openedAt != null
        ? DateFormat('dd MMM HH:mm')
            .format(DateTime.parse(t.openedAt!).toLocal())
        : DateFormat('dd MMM HH:mm').format(DateTime.now());

    return Container(
      // margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.greyColor.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          t.symbol ?? "Unknown",
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 1),
                          decoration: BoxDecoration(
                            color: isBuy
                                ? AppFlavorColor.success.withValues(alpha: 0.2)
                                : AppFlavorColor.error.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isBuy ? "BUY" : "SELL",
                            style: TextStyle(
                                color: isBuy
                                    ? AppFlavorColor.success
                                    : AppFlavorColor.error,
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'PnL ',
                          style: TextStyle(
                              fontSize: 13,
                              color: AppColor.textColor,
                              fontWeight: FontWeight.w600),
                        ),
                        Text(
                          displayProfit.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: pnlColor,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(entryPrice,
                            style: TextStyle(
                                fontSize: 13,
                                color: AppColor.greyColor,
                                fontWeight: FontWeight.w500)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(Icons.arrow_right_alt_rounded,
                              size: 14,
                              color: AppColor.greyColor.withOpacity(0.5)),
                        ),
                        Text(currentPrice,
                            style: TextStyle(
                                fontSize: 13,
                                color: AppColor.textColor,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                    Row(
                      children: [
                        Text('Vol:',
                            style: TextStyle(
                                fontSize: 13,
                                color: AppColor.greyColor,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(width: 8),
                        Text(
                          (t.lot ?? 0.0).toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppColor.textColor,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                if (!widget.isHistory) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, thickness: 0.5),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCompactButton(
                          label: 'Modify',
                          icon: Icons.edit_outlined,
                          color: AppFlavorColor.primary,
                          bgColor: Colors.transparent,
                        ),
                      ),
                      Container(
                          width: 1,
                          height: 16,
                          color: AppColor.greyColor.withOpacity(0.2)),
                      Expanded(
                        child: _buildCompactButton(
                          label: 'Close',
                          icon: Icons.close,
                          color: AppFlavorColor.error,
                          bgColor: Colors.transparent,
                          onTap: () async => widget.onDelete(),
                        ),
                      ),
                    ],
                  )
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactButton({
    required String label,
    required IconData icon,
    required Color color,
    required Color bgColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/

/*
import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/view/account/buy_sell_trade/model/trade_model.dart';
import 'package:exness_clone/view/account/buy_sell_trade/model/ws_equity_data.dart';
import 'package:exness_clone/view/trade/widget/order_close.dart';
import 'package:exness_clone/view/trade/widget/pl_success.dart';
import 'package:exness_clone/view/trade/widget/success_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderProgressCard extends StatefulWidget {
  final TradeModel trade;
  final LiveProfit liveProfit;
  final Future<void> Function() onDelete;
  final bool isHistory;

  const OrderProgressCard({
    super.key,
    required this.onDelete,
    required this.liveProfit,
    required this.trade,
    this.isHistory = false,
  });

  @override
  State<OrderProgressCard> createState() => _OrderProgressCardState();
}

class _OrderProgressCardState extends State<OrderProgressCard> {
  @override
  Widget build(BuildContext context) {
    final t = widget.trade;
    final lp = widget.liveProfit;

    final isBuy = (t.bs ?? 'Buy').toLowerCase() == 'buy';

    final displayProfit =
        widget.isHistory ? (t.profitLossAmount ?? 0.0) : lp.profit;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                    decoration: BoxDecoration(
                      color: isBuy
                          ? AppFlavorColor.success.withValues(alpha: 0.2)
                          : AppFlavorColor.error.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isBuy ? "BUY" : "SELL",
                      style: TextStyle(
                          color: isBuy
                              ? AppFlavorColor.success
                              : AppFlavorColor.error,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t.symbol ?? "Unknown",
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                  const Spacer(),
                  Icon(Icons.content_copy, size: 16, color: AppColor.greyColor),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      "#${t.id}",
                      style: TextStyle(
                          fontSize: 13,
                          color: AppColor.greyColor,
                          fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                t.openedAt != null
                    ? DateFormat('yyyy-MM-dd HH:mm')
                        .format(DateTime.parse(t.openedAt!).toLocal())
                    : DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
                style: TextStyle(
                    fontSize: 13,
                    color: AppColor.greyColor,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("PnL",
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColor.greyColor)),
                      Text(
                        displayProfit.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: displayProfit >= 0
                              ? AppFlavorColor.success
                              : AppFlavorColor.error,
                        ),
                      ),
                    ],
                  ),
                  _TradeInfoColumn(
                    title: "Entry Price",
                    value: (t.avg ?? 0.0).toStringAsFixed(5),
                    crossAxisAlignment: CrossAxisAlignment.end,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _TradeInfoColumn(
                      title: "Volume (Lots)",
                      value: (t.lot ?? 0.0).toString(),
                      crossAxisAlignment: CrossAxisAlignment.start),
                  _TradeInfoColumn(
                      title: widget.isHistory ? "Exit Price" : "Current Price",
                      value: widget.isHistory
                          ? (t.exit ?? 0.0).toStringAsFixed(5)
                          : (t.avg ?? 0.0).toStringAsFixed(5),
                      crossAxisAlignment: CrossAxisAlignment.start),
                  const _TradeInfoColumn(
                    title: "Charges/Swap",
                    value: "-",
                    crossAxisAlignment: CrossAxisAlignment.end,
                  ),
                ],
              ),
              if (!widget.isHistory) ...[
                SizedBox(height: 16),
                Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: _buildButton(
                        icon: Icons.edit_outlined,
                        label: 'Modify',
                        textColor: AppFlavorColor.primary,
                        iconColor: AppFlavorColor.primary,
                        bgColor: AppFlavorColor.primary.withValues(alpha: 0.1),
                        onTap: null,
                      ),
                    ),
                    Expanded(
                      child: _buildButton(
                        icon: Icons.close,
                        label: 'Close',
                        onTap: () async => widget.onDelete(),
                        bgColor: const Color(0xFFFFE5E0),
                        textColor: AppFlavorColor.error,
                        iconColor: AppFlavorColor.error,
                      ),
                    ),
                  ],
                )
              ],
            ],
          ),
        ),
        Divider(thickness: 0.3, color: AppColor.mediumGrey),
      ],
    );
  }

  void showCloseConfirmedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return OrderCloseWidget();
      },
    );
  }
}

class _TradeInfoColumn extends StatelessWidget {
  final String title;
  final String value;
  final CrossAxisAlignment crossAxisAlignment;

  const _TradeInfoColumn({
    required this.title,
    required this.value,
    required this.crossAxisAlignment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(title, style: TextStyle(fontSize: 13, color: AppColor.greyColor)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

Widget _buildButton({
  IconData? icon,
  required String label,
  required Color bgColor,
  Color textColor = Colors.black,
  Color iconColor = Colors.black,
  VoidCallback? onTap,
}) {
  return CupertinoButton(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    pressedOpacity: 0.7,
    borderRadius: BorderRadius.circular(6),
    onPressed: onTap,
    minimumSize: Size(0, 0),
    color: bgColor,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 10),
        ],
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
*/
