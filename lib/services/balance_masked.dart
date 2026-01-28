import 'package:flutter/material.dart';
import 'package:exness_clone/theme/app_colors.dart';

final ValueNotifier<bool> globalBalanceMaskController =
    ValueNotifier<bool>(true);

class BalanceMasked extends StatelessWidget {
  final Widget child;

  const BalanceMasked({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: globalBalanceMaskController,
      builder: (context, visible, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => globalBalanceMaskController.value = !visible,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    visible ? Icons.visibility : Icons.visibility_off,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            visible
                ? child
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Balance",
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColor.whiteColor.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'xxxxxxx',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColor.whiteColor,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColor.whiteColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "USD",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColor.whiteColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ],
        );
      },
    );
  }
}
