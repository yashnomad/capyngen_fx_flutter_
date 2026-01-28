import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/widget/simple_appbar.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../widget/color.dart';
import 'choose_password.dart';

class PartnerCode extends StatefulWidget {
  const PartnerCode({super.key});

  @override
  State<PartnerCode> createState() => _PartnerCodeState();
}

class _PartnerCodeState extends State<PartnerCode> {
  final TextEditingController codeController = TextEditingController();




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppbar(title: 'Enter your email'),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your partner code if you have one',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
             Text(
              'Partner code (optional)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,color: AppColor.greyColor),
            ),
            const SizedBox(height: 8),
            TextField(

              style: TextStyle(fontWeight: FontWeight.w500),

              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:(){
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppFlavorColor.primary,

                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child:  Text('Continue',style: TextStyle(fontWeight: FontWeight.w500,color: AppColor.whiteColor),),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
