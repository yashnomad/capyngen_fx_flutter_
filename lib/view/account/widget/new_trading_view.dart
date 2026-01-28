import 'package:flutter/material.dart';
import 'package:exness_clone/theme/app_colors.dart';

class NewTradingItem extends StatelessWidget {
  final String symbol;
  final double bid;
  final double ask;
  final double? low;
  final double? high;
  final bool isEven;

  const NewTradingItem({
    super.key,
    required this.symbol,
    required this.bid,
    required this.ask,
    this.low,
    this.high,
    this.isEven = false,
  });

  int _detectFeedDecimals(double value) {
    final s = value.toString();
    if (!s.contains('.')) return 0;
    final part = s.split('.')[1];

    return part.length.clamp(2, 5);
  }

  @override
  Widget build(BuildContext context) {
    final decimals = _detectFeedDecimals(ask);
    final spread = (ask - bid).abs();
    final lowValue = low ?? (bid * 0.999);
    final highValue = high ?? (ask * 1.001);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  symbol,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  bid.toStringAsFixed(decimals),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: AppColor.blueColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Text(
                  ask.toStringAsFixed(decimals),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: AppColor.redColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  spread.toStringAsFixed(decimals),
                  style: TextStyle(
                    color: AppColor.greyColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  "L:${lowValue.toStringAsFixed(decimals)}",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: AppColor.greyColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Text(
                  "H:${highValue.toStringAsFixed(decimals)}",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: AppColor.greyColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
