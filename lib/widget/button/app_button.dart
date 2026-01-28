import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;

  const AppButton({
    super.key,
     this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppFlavorColor.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style:  TextStyle(fontSize: 14, color: AppColor.whiteColor),
        ),
      ),
    );
  }
}


