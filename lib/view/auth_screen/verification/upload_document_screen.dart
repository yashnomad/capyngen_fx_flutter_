import 'dart:io';

import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/network/api_service.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/utils/snack_bar.dart';
import 'package:exness_clone/view/auth_screen/verification/verification_submitted_screen.dart';
import 'package:exness_clone/widget/button/app_button.dart';
import 'package:exness_clone/widget/button/premium_app_button.dart';
import 'package:exness_clone/widget/button/premium_icon_button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../constant/app_strings.dart';
import '../../../theme/app_colors.dart';
import '../../../widget/slidepage_navigate.dart';
import '../../profile/user_profile/bloc/user_profile_bloc.dart';
import '../../profile/user_profile/bloc/user_profile_event.dart';

class UploadDocument extends StatefulWidget {
  final String idTitle;

  const UploadDocument({super.key, required this.idTitle});

  @override
  State<UploadDocument> createState() => _UploadDocumentState();
}

class _UploadDocumentState extends State<UploadDocument> {
  late String idTitle;

  // Map display names to backend API values
  static const Map<String, String> _docTypeMap = {
    'National ID': 'nationalId',
    'Passport': 'passport',
    'Driving License': 'drivingLicense',
  };

  @override
  void initState() {
    super.initState();
    idTitle = _docTypeMap[widget.idTitle] ?? widget.idTitle.toLowerCase();
    debugPrint('[Upload] Document type: ${widget.idTitle} → $idTitle');
  }

  int currentStep = 2;

  PlatformFile? frontFile;
  PlatformFile? backFile;
  String? _sizeWarning;
  bool _isSubmitting = false;

  static const int _maxFileSizeBytes = 200 * 1024; // 200KB

  Future _uploadDocument() async {
    if (frontFile == null || backFile == null) {
      SnackBarService.showError('Please select both front and back images');
      return;
    }

    if (frontFile!.path == null || backFile!.path == null) {
      SnackBarService.showError('Invalid file paths');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      debugPrint('[Upload] 📤 Preparing KYC data');

      final kycData = {
        'documentType': idTitle,
        'frontSide': frontFile!,
        'backSide': backFile!,
      };

      debugPrint(
          '[Upload] Sending: documentType=$idTitle, frontSide=${frontFile!.name}, backSide=${backFile!.name}');

      final response = await ApiService.submitKyc(kycData);

      final data = response.data;
      debugPrint('[Upload] ✅ API Response: $data');

      if (data?['success'] == true) {
        SnackBarService.showSuccess(
            data?['message'] ?? 'KYC submitted successfully');
        if (mounted) {
          // Optimistically set kycStatus to 'under_review' locally
          context.read<UserProfileBloc>().add(KycSubmitted());
          // Navigate to home (NOT '/' which is splash and re-fetches profile)
          context.go('/home');
        }
      } else {
        SnackBarService.showError(data?['message'] ?? 'Submission failed');
      }
    } catch (e) {
      debugPrint('❌ Upload error: $e');
      SnackBarService.showError('Upload failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
                    SizedBox(height: 12),
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
                              SizedBox(width: 10),
                              buildStep(
                                  stepIndex: 2,
                                  stepNumber: "2",
                                  title: "Upload\nDocuments"),
                              SizedBox(width: 10),
                              buildStep(
                                  stepIndex: 3,
                                  stepNumber: "3",
                                  title: "Complete"),
                            ],
                          ),
                          SizedBox(height: 20),

                          // Size warning banner
                          if (_sizeWarning != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Colors.red.shade200, width: 1),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline,
                                      color: Colors.red.shade600, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _sizeWarning!,
                                      style: TextStyle(
                                        color: Colors.red.shade700,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () =>
                                        setState(() => _sizeWarning = null),
                                    child: Icon(Icons.close,
                                        color: Colors.red.shade400, size: 18),
                                  ),
                                ],
                              ),
                            ),

                          // Title row with max size badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Upload Your ${widget.idTitle}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: AppColor.blackColor),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Please provide clear photos of both sides.',
                                      style: TextStyle(
                                          color: AppColor.greyColor,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: Colors.blue.shade200),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.photo_size_select_large,
                                        color: Colors.blue.shade600, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Max size: 200KB',
                                      style: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),

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
                                      const SizedBox(height: 20),

                                      // Document Requirements
                                      Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: Colors.blue.shade100),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.info_outline_rounded,
                                                    color: Colors.blue.shade600,
                                                    size: 18),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Document Requirements:',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 13,
                                                      color:
                                                          Colors.blue.shade700),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            _buildRequirementItem(
                                                'Ensure the image is not blurry and details are readable.'),
                                            _buildRequirementItem(
                                                'All four corners of the document must be visible.'),
                                            _buildRequirementItem(
                                                'File size strictly under 200KB.',
                                                isBold: true),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 24),
                                      Row(
                                        children: [
                                          PremiumIconButton(
                                            icon: CupertinoIcons.back,
                                            onPressed: () =>
                                                Navigator.pop(context),
                                          ),
                                          SizedBox(width: 20),
                                          Expanded(
                                            child: _isSubmitting
                                                ? Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: AppFlavorColor
                                                          .primary,
                                                    ),
                                                  )
                                                : PremiumAppButton(
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
                    SizedBox(height: 10),
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
              SizedBox(height: 20),
              Row(
                children: [
                  Icon(
                    Icons.security,
                    color: AppFlavorColor.primary,
                    size: 14,
                  ),
                  SizedBox(width: 10),
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
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequirementItem(String text, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, left: 26),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• ",
              style: TextStyle(color: Colors.blue.shade600, fontSize: 13)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.blue.shade600,
                fontSize: 12,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> pickFile(bool isFront) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      final fileSize = file.size;

      if (fileSize > _maxFileSizeBytes) {
        final sizeInKB = (fileSize / 1024).toStringAsFixed(1);
        setState(() {
          _sizeWarning =
              '${file.name} exceeds 200KB limit ($sizeInKB KB). Please compress the image.';
        });
        return;
      }

      setState(() {
        _sizeWarning = null;
        if (isFront) {
          frontFile = file;
        } else {
          backFile = file;
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
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColor.blackColor)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => pickFile(isFront),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: file != null
                        ? AppFlavorColor.primary.withOpacity(0.3)
                        : AppColor.lightGrey,
                    style:
                        file != null ? BorderStyle.solid : BorderStyle.solid)),
            child: Center(
              child: file == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.cloud_upload,
                            color: AppFlavorColor.primary, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          "Click or Drag & Drop",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppColor.blackColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 4),
                        Text("Supported: JPG, PNG, PDF",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 11, color: AppColor.greyColor)),
                        SizedBox(height: 2),
                        Text("MAX SIZE: 200KB",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 10,
                                color: AppColor.greyColor,
                                fontWeight: FontWeight.w600)),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color: Colors.green, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          file.name,
                          style: TextStyle(
                              fontSize: 13, color: AppColor.blackColor),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 4),
                        Text("${(file.size / 1024).toStringAsFixed(1)} KB",
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w500)),
                        SizedBox(height: 2),
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
    bool isCompleted = currentStep > stepIndex;
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
