import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/theme/capmarket_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../constant/app_strings.dart';
import '../../../theme/app_colors.dart';

class VerificationSubmitted extends StatefulWidget {
  const VerificationSubmitted({super.key});

  @override
  State<VerificationSubmitted> createState() => _VerificationSubmittedState();
}

class _VerificationSubmittedState extends State<VerificationSubmitted> {
  int currentStep = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        flexibleSpace: Container(color: context.chatBoxDecorationColor),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: AppColor.lightGrey)),
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: AppFlavorColor.buttonGradient),
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(15))),
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.identityVerification,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.whiteColor),
                            ),
                            Text(
                              AppStrings.titleIdentityVerification,
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.whiteColor),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildStep(
                                  stepIndex: 1,
                                  stepNumber: "1",
                                  title: "Select\nDocument"),
                              SizedBox(
                                width: 10,
                              ),
                              buildStep(
                                  stepIndex: 2,
                                  stepNumber: "2",
                                  title: "Upload\nDocuments"),
                              SizedBox(
                                width: 10,
                              ),
                              buildStep(
                                  stepIndex: 3,
                                  stepNumber: "3",
                                  title: "Complete"),
                            ],
                          ),
                          SizedBox(
                            height: 30,
                          ),

                          Container(
                            decoration: BoxDecoration(
                              color:
                                  AppFlavorColor.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 20),
                            child: Row(
                              children: [
                                Text(
                                  '•',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: AppFlavorColor.primary),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "Your verification has been submitted successfully. We will review your information shortly and update your verification status.",
                                    style: TextStyle(
                                        color: AppFlavorColor.primary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(
                            height: 50,
                          ),

                          Center(
                              child: CircleAvatar(
                                  backgroundColor: AppFlavorColor.primary
                                      .withValues(alpha: 0.1),
                                  radius: 30,
                                  child: Icon(
                                      CupertinoIcons.check_mark_circled_solid,
                                      size: 30,
                                      color: AppFlavorColor.primary))),
                          const SizedBox(height: 20),
                          Center(
                            child: Text(
                              "Verification Submitted!",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.blackColor),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: Text(
                              "Your identity verification documents have been submitted successfully. Our team will review them shortly and you'll receive a notification once the verification is complete.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.greyColor),
                            ),
                          ),

                          const SizedBox(height: 30),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppFlavorColor.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("What happens next?",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AppFlavorColor.primary)),
                                SizedBox(height: 10),
                                Text(
                                  "1. Our team will review your documents (usually within 24-48 hours)",
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: AppFlavorColor.primary),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "2. You'll receive an email notification with the verification result",
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: AppFlavorColor.primary),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "3. Once verified, you'll have full access to all platform features",
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: AppFlavorColor.primary),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(
                            height: 20,
                          ),

                          // SizedBox(
                          //   width: double.infinity,
                          //   child: ElevatedButton(
                          //     onPressed: () {},
                          //     style: ElevatedButton.styleFrom(
                          //
                          //         padding: const EdgeInsets.symmetric(vertical: 14),
                          //         shape: RoundedRectangleBorder(
                          //           borderRadius: BorderRadius.circular(8),
                          //         ),
                          //         backgroundColor: AppColor.darkBlueColor // workaround will be handled below
                          //     ),
                          //     child:  Text("Return to Dashboard",style: TextStyle(color: AppColor.whiteColor),),
                          //   ),
                          // )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildStep({
    required int stepIndex,
    required String stepNumber,
    required String title,
  }) {
    bool isActive = currentStep >= stepIndex;
    bool isCompleted = currentStep >= 3 && stepIndex == 3;
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor:
                isActive ? AppFlavorColor.primary : AppColor.lightGrey,
            child: isCompleted
                ? Icon(CupertinoIcons.check_mark_circled_solid,
                    size: 16, color: AppColor.whiteColor)
                : Text(
                    stepNumber,
                    style: TextStyle(
                      fontSize: 13,
                      color:
                          isActive ? AppColor.whiteColor : AppColor.greyColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? AppFlavorColor.primary : AppColor.greyColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
