import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

class PLSuccessWidget extends StatelessWidget {
  const PLSuccessWidget({
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

            // Title
            Text(
              "Set Up Successful",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),

            // Details
            Text("NAS100.r 79,70 Lot",
                style:
                TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            Text("Sell Market",
                style:
                TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            Text("Order Number #30538716",
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
                child: Text("Confirm",
                    style: TextStyle(color: AppColor.whiteColor)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
