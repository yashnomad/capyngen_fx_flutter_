import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../constant/app_vector.dart';
import '../../../theme/app_colors.dart';

class ReverseSuccessWidget extends StatelessWidget {
  const ReverseSuccessWidget({
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
              "Reverse Successful",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),

            // Details
            Text("#305254576",
                style:
                TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            Text("Close Successful",
                style:
                TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            Text("#305254966",
                style:
                TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            Text("Placed Successful",
                style:
                TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
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