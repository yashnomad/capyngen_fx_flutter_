import 'package:exness_clone/core/extensions.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

class KYCStatusScreen extends StatelessWidget {
  const KYCStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        flexibleSpace: Container(
            color: context.chatBoxDecorationColor),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ),
      backgroundColor: AppColor.whiteColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'KYC Verification Status',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColor.blackColor),
              ),
              const SizedBox(height: 4),
              Text(
                'Check the current status of your identity verification',
                style: TextStyle(
                    fontSize: 13,
                    color: AppColor.greyColor,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 30),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: AppColor.whiteColor,
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 3,
                          spreadRadius: 2,
                          color: AppColor.lightGrey)
                    ],
                    borderRadius: BorderRadius.circular(20)),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                  decoration: BoxDecoration(
                    color: AppColor.blueColor.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColor.blueColor.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.shield_outlined,
                            size: 30, color: Colors.blue),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'KYC Verification Under Review',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColor.blackColor),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Our team is currently reviewing your documents. We\'ll notify you once the verification is complete.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            color: AppColor.greyColor,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 25),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColor.whiteColor,
                          border: Border.all(color: AppColor.lightGrey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Review Details',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 12),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            _buildDetailRow("Document Type", "National ID"),
                            const SizedBox(height: 10),
                            _buildDetailRow("Submitted On", "Invalid Date"),
                            SizedBox(
                              height: 6,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Status",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 11,
                                      color: AppColor.greyColor),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadiusGeometry.circular(30),
                                      color:
                                          AppColor.blueColor.withOpacity(0.1)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    child: Text(
                                      "Under Review",
                                      style: TextStyle(
                                          color: AppColor.blueColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColor.blueColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "What happens next?",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: AppColor.blueColor),
                            ),
                            SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "• ",
                                  style: TextStyle(color: AppColor.blueColor),
                                ),
                                Expanded(
                                  child: Text(
                                    "Our compliance team will verify your identity documents",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: AppColor.blueColor,
                                        fontWeight: FontWeight.w500),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "• ",
                                  style: TextStyle(color: AppColor.blueColor),
                                ),
                                Expanded(
                                  child: Text(
                                    "You'll receive an email notification with the verification result",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: AppColor.blueColor,
                                        fontWeight: FontWeight.w500),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "• ",
                                  style: TextStyle(color: AppColor.blueColor),
                                ),
                                Expanded(
                                  child: Text(
                                    "Once verified, you'll have full access to trading features",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: AppColor.blueColor,
                                        fontWeight: FontWeight.w500),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                decoration: BoxDecoration(
                  color: AppColor.whiteColor,
                  border: Border.all(color: AppColor.lightGrey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Need Help?',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColor.blackColor),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'If you have any questions about your KYC verification status or need assistance with the verification process, our support team is here to help.',
                      style: TextStyle(
                          fontSize: 13,
                          color: AppColor.greyColor,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: [
                        _supportButton(
                          icon: Icons.info,
                          text: "FAQs",
                          bgColor: AppColor.blueColor.withOpacity(0.1),
                          textColor: AppColor.blueColor,
                          onPressed: () {},
                        ),
                        _supportButton(
                          icon: Icons.mail,
                          text: "Email Support",
                          textColor: AppColor.greenColor,
                          bgColor: AppColor.greenColor.withOpacity(0.1),
                          onPressed: () {},
                        ),
                        _supportButton(
                          icon: Icons.phone,
                          text: "Call Support",
                          textColor: AppColor.deepPurpleColor,
                          bgColor: AppColor.deepPurpleColor.withOpacity(0.1),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Icon(
                    Icons.security,
                    color: AppColor.greenColor,
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _supportButton({
    required IconData icon,
    required String text,
    required Color textColor,
    required Color bgColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: textColor,
          size: 16,
        ),
        label: Text(text,
            style: TextStyle(
                color: textColor, fontWeight: FontWeight.w600, fontSize: 12)),
        style: TextButton.styleFrom(
          minimumSize: Size(double.infinity, 35),
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColor.greyColor,
                fontSize: 11)),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColor.blackColor,
                fontSize: 11)),
      ],
    );
  }
}
