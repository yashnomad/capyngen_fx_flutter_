import 'package:exness_clone/constant/app_strings.dart';
import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/view/auth_screen/verification/upload_document_screen.dart';
import 'package:exness_clone/widget/slidepage_navigate.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DocumentVerification extends StatefulWidget {
  const DocumentVerification({super.key});

  @override
  State<DocumentVerification> createState() => _DocumentVerificationState();
}

class _DocumentVerificationState extends State<DocumentVerification> {
  String? selectedDocument;

  int currentStep = 1;

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
                          gradient: LinearGradient(colors: AppFlavorColor.buttonGradient),
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
                            height: 40,
                          ),
                          Text(
                            'Select Document Type',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColor.blackColor),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Please select one of the following documents for identity verification. Make sure your document is valid and not expired.',
                            style: TextStyle(
                                color: AppColor.greyColor,
                                fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          buildDocumentBox(
                              "National ID",
                              "Upload your government-issued National ID card",
                              Icons.badge),
                          buildDocumentBox(
                              "Passport",
                              "Upload your valid Passport",
                              Icons.travel_explore),
                          buildDocumentBox(
                              "Driving License",
                              "Upload your Driving License",
                              Icons.directions_car),
                          SizedBox(height: 30),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: AppFlavorColor.primary
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColor.lightGrey)),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.info,
                                    color: AppFlavorColor.primary, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Document requirements:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: AppFlavorColor.primary,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      buildBulletText(
                                          "Document must be original and valid (not expired)"),
                                      buildBulletText(
                                          "All details must be clearly visible"),
                                      buildBulletText(
                                          "All four corners must be visible in the image"),
                                      buildBulletText(
                                          "No glare or shadows covering important information"),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: selectedDocument == null
                                  ? null
                                  : () {
                                      Navigator.push(
                                          context,
                                          SlidePageRoute(
                                              page: UploadDocument(
                                            idTitle: '$selectedDocument',
                                          )));
                                    },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: selectedDocument == null
                                      ? null
                                      : LinearGradient(colors: [
                                          AppFlavorColor.primary,
                                          AppFlavorColor.secondary,
                                        ]),
                                  color: selectedDocument == null
                                      ? AppColor.lightGrey
                                      : null,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25, vertical: 12),
                                  child: Text(
                                    AppStrings.continueText,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: selectedDocument == null
                                          ? Colors.white
                                          : Colors
                                              .white, // You can customize this if needed
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: double.infinity,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(15)),
                          color: AppColor.lightGrey),
                      child: Column(
                        children: [
                          Divider(
                            height: 0,
                            color: Colors.grey.shade300,
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Row(
                                children: [
                                  Text(
                                    'Need help? ',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: AppColor.greyColor,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    'Contact Support',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: AppFlavorColor.primary,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  // Spacer(),
                                  // Text(
                                  //   'Back to Dashboard',
                                  //   style: TextStyle(
                                  //       fontWeight: FontWeight.w500,
                                  //       color: AppColor.greyColor,
                                  //       fontSize: 12),
                                  // )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Icon(
                    Icons.security,
                    color: AppFlavorColor.primary,
                    size: 14,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: Text(
                    'Your information is encrypted and securely stored. We comply with GDPR and data protection regulations.',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColor.greyColor,
                        fontWeight: FontWeight.w500),
                  ))
                ],
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDocumentBox(String title, String description, IconData icon) {
    bool isSelected = selectedDocument == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDocument = title;
        });
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          boxShadow: [
            BoxShadow(
                color: isSelected ? AppFlavorColor.primary : AppColor.lightGrey,
                spreadRadius: 1,
                blurRadius: 3)
          ],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: AppFlavorColor.primary.withValues(alpha: 0.1),
              radius: 30,
              child: Icon(
                icon,
                color: AppFlavorColor.primary,
                size: 30,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: AppColor.blackColor),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColor.greyColor),
            ),
            const SizedBox(height: 12),
            if (isSelected)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppFlavorColor.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Selected",
                  style: TextStyle(
                      color: AppFlavorColor.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: 12),
                ),
              ),
          ],
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

  Widget buildBulletText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• ", style: TextStyle(color: AppFlavorColor.primary)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                  color: AppFlavorColor.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
