import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class AccountSummaryCard extends StatelessWidget {
  final String balance;
  final String equity;
  final String margin;
  final String freeMargin;
  final String floatingPnL;

  const AccountSummaryCard({
    super.key,
    required this.balance,
    required this.equity,
    required this.margin,
    required this.freeMargin,
    required this.floatingPnL,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildInfoCard("Balance:", balance)),
              const SizedBox(width: 12),
              Expanded(child: _buildInfoCard("Equity:", equity)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildInfoCard("Used Mrg:", margin)),
              const SizedBox(width: 12),
              Expanded(child: _buildInfoCard("Free Mrg:", freeMargin)),
            ],
          ),
          const SizedBox(height: 20),
          _buildPnLCard(),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPnLCard() {
    final double pnlValue = double.tryParse(floatingPnL) ?? 0.0;
    final bool isNegative = pnlValue < 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Total P/L: ",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            floatingPnL,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isNegative ? AppFlavorColor.error : AppFlavorColor.success,
            ),
          ),
        ],
      ),
    );
  }
}
