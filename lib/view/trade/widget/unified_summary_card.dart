import 'package:flutter/material.dart';
import '../../account/buy_sell_trade/cubit/trade_state.dart';

class UnifiedSummaryCard extends StatelessWidget {
  final int selectedIndex;
  final TradeState state;
  final VoidCallback? onDownloadPdf;

  const UnifiedSummaryCard({
    super.key,
    required this.selectedIndex,
    required this.state,
    this.onDownloadPdf,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildInfoCard(_getLabel1(), _getValue1())),
              const SizedBox(width: 10),
              Expanded(child: _buildInfoCard(_getLabel2(), _getValue2())),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: _buildInfoCard(
                      "Used Mrg", state.equity?.usedMargin ?? '0.00')),
              const SizedBox(width: 10),
              Expanded(
                  child: _buildInfoCard(
                      "Free Mrg", state.equity?.freeMargin ?? '0.00')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: _buildPnLCard(_getPnLLabel(), _getPnLValue()),
              ),
              if (selectedIndex == 2) ...[
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: _buildPdfButton(),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _getLabel1() => selectedIndex == 2 ? "Total Trades" : "Balance";
  String _getValue1() => selectedIndex == 2
      ? state.historyTrades.length.toString()
      : (state.equity?.balance ?? '0.00');

  String _getLabel2() => selectedIndex == 1 ? "Pending Count" : "Equity";
  String _getValue2() => selectedIndex == 1
      ? state.pendingTrades.length.toString()
      : (state.equity?.equity ?? '0.00');

  String _getPnLLabel() => selectedIndex == 2 ? "Net History: " : "Total P/L: ";
  String _getPnLValue() {
    if (selectedIndex == 2) {
      double total = state.historyTrades
          .fold(0.0, (sum, item) => sum + (item.profitLossAmount ?? 0.0));
      return total.toStringAsFixed(2);
    }
    return state.equity?.pnl ?? '0.00';
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        // color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Text(label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
          Text(value,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPnLCard(String label, String value) {
    final double pnlVal = double.tryParse(value) ?? 0.0;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        // color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            Text(value,
                style: TextStyle(
                    fontSize: 12,
                    color: pnlVal >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfButton() {
    return InkWell(
      onTap: onDownloadPdf,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.red.shade100),
        ),
        child: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
      ),
    );
  }
}
