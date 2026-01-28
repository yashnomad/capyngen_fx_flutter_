import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/widget/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../widget/simple_appbar.dart';




class SwapFreeScreen extends StatelessWidget {
  const SwapFreeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppbar(title: 'Swap-free',),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

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
                "No more overnight charges. Trade popular instruments without paying swaps. Your qualification for swap-free status depends on your trading activity.",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text(
                    "Swap-free status:",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:  Text(
                      'Qualified',
                      style: TextStyle(color: AppColor.greenColor, fontSize: 13,fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              LinearProgressIndicator(
                value: 1.0,
                minHeight: 8,
                borderRadius: BorderRadius.circular(30),
                backgroundColor:AppColor.lightGrey,
                valueColor:  AlwaysStoppedAnimation<Color>(AppColor.greenColor),
              ),
              const SizedBox(height: 16),
              const Text(
                "To qualify for and maintain swap-free status, you need to trade primarily during the day and hold minimal overnight positions.",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 16,),
              const Text(
                "Check the Help Center for a list of instructions available for swap-free trading.",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () {
                  // Add your navigation or action here
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Read more in our Help Center ",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColor.blueColor,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColor.blueColor
                      ),
                    ),
                    Icon(Icons.open_in_new,size: 18,color: AppColor.blueColor,),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
