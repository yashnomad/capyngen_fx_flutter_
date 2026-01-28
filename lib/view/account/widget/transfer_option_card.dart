import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

class TransferOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String processingTime;
  final String fee;
  final String limits;
  final bool? active;

  const TransferOptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.processingTime,
    required this.fee,
    required this.limits,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final defaultColor = AppColor.greyColor;

    final cardContent = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: defaultColor, width: 0.4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30, color: AppColor.blackColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColor.blackColor)),
                  const SizedBox(height: 4),
                  if (active == false)
                    Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lock_outline,
                                size: 14, color: AppColor.amberColor),
                            const SizedBox(width: 4),
                            Text('Unavailable',
                                style: TextStyle(
                                    fontSize: 12, color: AppColor.amberColor)),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  Row(
                    children: [
                      Text("Processing time ",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColor.greyColor,
                          )),
                      Flexible(
                        child: Text(
                          processingTime,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: AppColor.blackColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text("Fee ",
                          style: TextStyle(
                              fontSize: 12, color: AppColor.greyColor)),
                      Flexible(
                        child: Text(
                          fee,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: AppColor.blackColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text("Limits ",
                          style: TextStyle(
                              fontSize: 12, color: AppColor.greyColor)),
                      Flexible(
                        child: Text(
                          limits,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: AppColor.blackColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
    return active == false
        ? Opacity(
            opacity: 0.5,
            child: cardContent,
          )
        : cardContent;
  }
}
