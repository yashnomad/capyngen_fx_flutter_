import 'package:exness_clone/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../widget/color.dart';
import '../../widget/simple_appbar.dart';

class NegativeBalanceProtection extends StatefulWidget {
  const NegativeBalanceProtection({super.key});

  @override
  State<NegativeBalanceProtection> createState() => _NegativeBalanceProtectionState();
}

class _NegativeBalanceProtectionState extends State<NegativeBalanceProtection> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:SimpleAppbar(title: 'Negative Balance Protection',),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Placeholder for the image and play icon
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity,
                  height: MediaQuery.sizeOf(context).height * 0.3,
                  decoration: BoxDecoration(
                    color: AppColor.lightGrey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:  Icon(
                    Icons.circle,
                    size: 80,
                    color: AppColor.mediumGrey,
                  ), // Replace with Image.asset or Image.network
                ),
                Icon(
                  CupertinoIcons.play,
                  size: 30,
                  color: AppColor.blackColor,
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Text(
              "You will never lose more than the amount you crypto_deposit into your account. If all your positions are closed due to a stop-out and your balance goes negative, we’ll automatically restore it to zero.",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 16,),
            const Text(
              "For example, if your account has a balance of \$100 and your trades result in a \$150 loss, your balance would be -\$50. With Negative Balance Protection, we will reset your balance to \$0 — you won’t have to cover the loss from your own funds."
                  ,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),



          ],
        ),
      ),
    );
  }
}
