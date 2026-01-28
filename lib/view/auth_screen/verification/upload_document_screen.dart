import 'dart:io';

import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/network/api_service.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/utils/common_utils.dart';
import 'package:exness_clone/utils/snack_bar.dart';
import 'package:exness_clone/view/auth_screen/verification/verification_submitted_screen.dart';
import 'package:exness_clone/widget/button/app_button.dart';
import 'package:exness_clone/widget/button/premium_app_button.dart';
import 'package:exness_clone/widget/button/premium_icon_button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../constant/app_strings.dart';
import '../../../theme/app_colors.dart';
import '../../../widget/slidepage_navigate.dart';

class UploadDocument extends StatefulWidget {
  final String idTitle;

  const UploadDocument({super.key, required this.idTitle});

  @override
  State<UploadDocument> createState() => _UploadDocumentState();
}

class _UploadDocumentState extends State<UploadDocument> {
  late String idTitle;

  @override
  void initState() {
    super.initState();
    idTitle = CommonUtils.toCamelCase(widget.idTitle);
    debugPrint(idTitle);
  }

  int currentStep = 2;

  PlatformFile? frontFile;
  PlatformFile? backFile;

  Future _uploadDocument() async {
    if (frontFile == null || backFile == null) {
      SnackBarService.showError('Please select both front and back images');
      return;
    }

    if (frontFile!.path == null || backFile!.path == null) {
      SnackBarService.showError('Invalid file paths');
      return;
    }

    try {
      debugPrint('[Upload] 📤 Preparing KYC data');

      final kycData = {
        'documentType': idTitle,
        'frontSide': frontFile!,  // ✅ Matches backend expectation
        'backSide': backFile!,    // ✅ Matches backend expectation
      };

      debugPrint('[Upload] Sending: documentType=$idTitle, frontSide=${frontFile!.name}, backSide=${backFile!.name}');

      final response = await ApiService.submitKyc(kycData);

      final data = response.data;
      debugPrint('[Upload] ✅ API Response: $data');

      if (data?['success'] == true) {
        SnackBarService.showSuccess(
            data?['message'] ?? 'KYC submitted successfully');
        if (mounted) {
          context.pushNamed('verificationSubmitted');
        }
      } else {
        SnackBarService.showError(data?['message'] ?? 'Submission failed');
      }
    } catch (e) {
      debugPrint('❌ Upload error: $e');
      SnackBarService.showError('Upload failed: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFormComplete = frontFile != null && backFile != null;

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
                            height: 40,
                          ),
                          Text(
                            'Upload Your ${widget.idTitle}',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColor.blackColor),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Please upload clear photos or scans of both the front and back sides of your ${widget.idTitle}.',
                            style: TextStyle(
                                color: AppColor.greyColor,
                                fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 50,
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  alignment: Alignment.centerLeft,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(15)),
                                      color: AppColor.lightGrey),
                                  child: Text(widget.idTitle,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColor.blackColor)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      buildFileUploadBox(
                                          title: "Front Side", isFront: true),
                                      const SizedBox(height: 20),
                                      buildFileUploadBox(
                                          title: "Back Side", isFront: false),
                                      const SizedBox(height: 30),
                                      Row(
                                        children: [
                                          PremiumIconButton(
                                            icon: CupertinoIcons.back,
                                            onPressed: () =>
                                                Navigator.pop(context),
                                          ),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          Expanded(
                                            child: PremiumAppButton(
                                                text: 'Submit Verification',
                                                onPressed: _uploadDocument),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
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

  Future<void> pickFile(bool isFront) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        if (isFront) {
          frontFile = result.files.first;
        } else {
          backFile = result.files.first;
        }
      });
    }
  }

  Widget buildFileUploadBox({required String title, required bool isFront}) {
    final file = isFront ? frontFile : backFile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: AppColor.greyColor)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => pickFile(isFront),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColor.lightGrey)),
            child: Center(
              child: file == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.cloud_upload,
                            color: AppFlavorColor.primary, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          "Drag & drop your file here or click to browse",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppColor.greyColor, fontSize: 12),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Text("JPG, PNG or PDF (max 5MB)",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 10, color: AppColor.greyColor)),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.insert_drive_file,
                            color: AppFlavorColor.primary, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          file.name,
                          style: TextStyle(
                              fontSize: 13, color: AppColor.blackColor),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Text("Tap to change",
                            style: TextStyle(
                                fontSize: 12, color: AppColor.greyColor)),
                      ],
                    ),
            ),
          ),
        ),
      ],
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
