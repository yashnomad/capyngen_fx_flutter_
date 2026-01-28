
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../constant/app_vector.dart';
import '../../../theme/app_colors.dart';

class OrderCloseWidget extends StatelessWidget {
  const OrderCloseWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Green Circle Icon
            Lottie.asset(
              AppVector.success,
              height: 100,
            ),

            // Title
            Text(
              "Close confirmed",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),

            const SizedBox(height: 20),

            // OK Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.blackColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text("OK",
                    style: TextStyle(color: AppColor.whiteColor)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}