import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DepositFundsShimmer extends StatelessWidget {
  const DepositFundsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    // Helper for rounded rectangles
    Widget shimmerBox({double height = 16, double width = double.infinity, BorderRadius? borderRadius}) {
      return Container(
        height: height,
        width: width,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      );
    }

    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            shimmerBox(height: 20, width: 120), // Account label
            shimmerBox(height: 54, width: double.infinity), // Dropdown skeleton
            shimmerBox(height: 20, width: 120), // Amount label
            shimmerBox(height: 54, width: double.infinity), // Input skeleton
            Align(
                alignment: Alignment.centerLeft,
                child: shimmerBox(height: 16, width: 160)), // Available balance
            const SizedBox(height: 32),
            shimmerBox(height: 70, width: double.infinity, borderRadius: BorderRadius.circular(12)), // Bank details
            const SizedBox(height: 48),
            Row(
              children: [
                Expanded(
                  child: shimmerBox(
                    height: 48,
                    borderRadius: BorderRadius.circular(24), // AppButton
                  ),
                ),
                const SizedBox(width: 12),
                shimmerBox(
                  height: 36,
                  width: 80,
                  borderRadius: BorderRadius.circular(18), // Cancel button
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
