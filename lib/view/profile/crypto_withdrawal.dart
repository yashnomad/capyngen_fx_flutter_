import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/widget/color.dart';
import 'package:exness_clone/widget/message_appbar.dart';
import 'package:flutter/material.dart';

class CryptoWithdrawal extends StatefulWidget {
  const CryptoWithdrawal({super.key});

  @override
  State<CryptoWithdrawal> createState() => _CryptoWithdrawalState();
}

class _CryptoWithdrawalState extends State<CryptoWithdrawal> {

  final GlobalKey _key = GlobalKey();
  String selected = 'Bitcoin (BTC)';
  final List<String> items = [
    'Bitcoin (BTC)',
    'Ethereum (ETH)',
    'Ripple (XRP)',
    'Litecoin (LTC)',
  ];



  @override
  Widget build(BuildContext context) {
    void showMenuSheet() async {
      final RenderBox renderBox = _key.currentContext!.findRenderObject() as RenderBox;
      final Offset offset = renderBox.localToGlobal(Offset.zero);
      final Size size = renderBox.size;

      final selectedItem = await showMenu<String>(
        context: context,
        position: RelativeRect.fromLTRB(
          offset.dx,                  // Left
          offset.dy + size.height + 4, // Top (just below the button)
          MediaQuery.of(context).size.width - offset.dx - size.width, // Right
          0,                           // Bottom (not needed here)
        ),        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        constraints: BoxConstraints(
          minWidth: size.width,
          maxWidth: size.width, // full width of the button
        ),
        elevation: 1,
        items: items
            .map((e) => PopupMenuItem<String>(
          value: e,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: Color(0xFFFFF3D9),
                child: Icon(Icons.currency_bitcoin, size: 16, color: AppColor.orangeColor),
              ),
              const SizedBox(width: 10),
              Text(e, style: const TextStyle(fontSize: 14, color: Colors.black)),
            ],
          ),
        ))
            .toList(),
      );

      if (selectedItem != null) {
        setState(() {
          selected = selectedItem;
        });
      }
    }
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: MessageAppbar(),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Withdrawal',style: TextStyle(fontSize: 26,fontWeight: FontWeight.w700,letterSpacing: 1.5,color: AppColor.blackColor),),
           SizedBox(height: 4,),
             Text(
              "See all payment methods",
              style: TextStyle(color: AppColor.blueColor, fontSize: 13,fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),

             Text("Payment Method", style: TextStyle(fontSize: 12,color: AppColor.blackColor)),
             SizedBox(height: 10,),
            GestureDetector(
              key: _key,
              onTap: showMenuSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColor.mediumGrey, width: 0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                     CircleAvatar(
                      backgroundColor: Color(0xFFFFF3D9),
                      radius: 12,
                      child: Icon(Icons.currency_bitcoin, size: 16, color: AppColor.orangeColor),
                    ),
                    const SizedBox(width: 10),
                    Text(selected, style:  TextStyle(fontSize: 14, color: AppColor.blackColor)),
                    const Spacer(),
                     Icon(Icons.keyboard_arrow_down, color: AppColor.greyColor, size: 20),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),


            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEFEF),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Please verify your profile to use this payment method.",
                    style: TextStyle(fontSize: 13,color: Colors.black87),
                  ),

                  const Text(
                    "Error ID: e74d0677-2dd9-4e40-8804-f54f8e39ec25",
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppFlavorColor.primary,
                        foregroundColor: AppColor.whiteColor,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text("Verify profile",style: TextStyle(fontSize: 13,fontWeight: FontWeight.w500),),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

    );
  }
}

