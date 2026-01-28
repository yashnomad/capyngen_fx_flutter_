import 'package:exness_clone/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TradingItemShimmer extends StatelessWidget {
  const TradingItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColor.whiteColor,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 12, width: 60, color:AppColor.whiteColor),
                  const SizedBox(height: 4),
                  Container(height: 10, width: 100, color: AppColor.whiteColor),
                ],
              ),
            ),
            const SizedBox(width: 15),
            Container(width: 60, height: 30, color: AppColor.whiteColor),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(height: 12, width: 50, color: AppColor.whiteColor),
                const SizedBox(height: 4),
                Container(height: 10, width: 40, color: AppColor.whiteColor),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
