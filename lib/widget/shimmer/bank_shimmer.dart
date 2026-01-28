import 'package:exness_clone/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class BankFormShimmer extends StatelessWidget {
  final int fieldsCount;

  const BankFormShimmer({super.key, this.fieldsCount = 3});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: [
          ...List.generate(fieldsCount, (index) {
            return Container(
              height: 50,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
              decoration: BoxDecoration(
                color: AppColor.greyColor,
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
          const SizedBox(height: 20),
          // Simulate button
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: AppColor.greyColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }
}
