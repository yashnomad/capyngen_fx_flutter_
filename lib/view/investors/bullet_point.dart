import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class BulletPoint extends StatelessWidget {
  final String text;
  const BulletPoint({required this.text, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("• ", style: TextStyle(fontSize: 16, color: AppColor.blueColor)),
        Expanded(child: Text(text, style: TextStyle(fontSize: 12, height: 1.4,color: AppColor.blueColor))),
      ],
    );
  }
}
