import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../buy_sell_trade/model/trade_model.dart';

class HistorySummaryCard extends StatelessWidget {
  final List<TradeModel> trades;
  final VoidCallback onDownload;

  const HistorySummaryCard({
    super.key,
    required this.trades,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Calculate Stats
    final totalTrades = trades.length;
    final wins = trades.where((t) => (t.profitLossAmount ?? 0) > 0).length;
    final losses = trades.where((t) => (t.profitLossAmount ?? 0) < 0).length;
    final netPnL =
        trades.fold(0.0, (sum, t) => sum + (t.profitLossAmount ?? 0));

    final isPositive = netPnL >= 0;
    final currencyFormatter = NumberFormat("#,##0.00", "en_US");

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: context.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.1)),
          bottom: BorderSide(color: Colors.grey.withOpacity(0.1)),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildHorizontalChip("TOTAL TRADES", "$totalTrades.00"),
            const SizedBox(width: 8),
            _buildHorizontalChip("WINS", "$wins.00", valueColor: Colors.green),
            const SizedBox(width: 8),
            _buildHorizontalChip("LOSSES", "$losses.00",
                valueColor: Colors.blueGrey),

            // Vertical Divider as seen in image
            Container(
              height: 40,
              width: 1,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.grey.withOpacity(0.3),
            ),

            // Net P/L Pill Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isPositive
                    ? Colors.green.withOpacity(0.05)
                    : Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isPositive
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    "NET P/L: ",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isPositive ? Colors.green[700] : Colors.red[700],
                    ),
                  ),
                  Text(
                    "${isPositive ? '+' : ''}${currencyFormatter.format(netPnL)}",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: isPositive ? Colors.green[800] : Colors.red[800],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            IconButton(
              onPressed: onDownload,
              icon: Icon(Icons.picture_as_pdf_rounded,
                  color: AppFlavorColor.primary),
              tooltip: "Download Report",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalChip(String label, String value, {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey.shade700,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.blueGrey.shade900,
            ),
          ),
        ],
      ),
    );
  }
}
