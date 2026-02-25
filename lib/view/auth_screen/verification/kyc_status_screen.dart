import 'package:exness_clone/core/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_flavor_color.dart';
import '../../profile/user_profile/bloc/user_profile_bloc.dart';
import '../../profile/user_profile/bloc/user_profile_event.dart';
import '../../profile/user_profile/bloc/user_profile_state.dart';

class KYCStatusScreen extends StatefulWidget {
  const KYCStatusScreen({super.key});

  @override
  State<KYCStatusScreen> createState() => _KYCStatusScreenState();
}

class _KYCStatusScreenState extends State<KYCStatusScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh profile to get latest status
    context.read<UserProfileBloc>().add(FetchUserProfile());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        flexibleSpace: Container(color: context.chatBoxDecorationColor),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ),
      backgroundColor: AppColor.whiteColor,
      body: BlocBuilder<UserProfileBloc, UserProfileState>(
        builder: (context, state) {
          if (state is UserProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is! UserProfileLoaded) {
            return const Center(child: Text('Unable to load KYC status'));
          }

          final profile = state.profile.profile;
          final kycStatus = profile?.kycStatus ?? 'pending';
          final docType = profile?.documentType;
          final docName = docType?.value ?? 'Document';
          final submittedAt = docType?.submittedAt;
          final formattedDate = submittedAt ?? 'N/A';

          final isRejected = kycStatus == 'rejected';

          return SingleChildScrollView(
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

                  // Status card
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 25),
                      decoration: BoxDecoration(
                        color: isRejected
                            ? Colors.red.withOpacity(0.07)
                            : AppColor.blueColor.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          // Status icon
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isRejected
                                  ? Colors.red.withOpacity(0.15)
                                  : AppColor.blueColor.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isRejected
                                  ? Icons.cancel_outlined
                                  : Icons.shield_outlined,
                              size: 30,
                              color: isRejected ? Colors.red : Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Title
                          Text(
                            isRejected
                                ? 'KYC Verification Rejected'
                                : 'KYC Verification Under Review',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColor.blackColor),
                          ),
                          const SizedBox(height: 10),

                          // Description
                          Text(
                            isRejected
                                ? 'Your identity verification was rejected. Please review the requirements and resubmit your documents.'
                                : 'Our team is currently reviewing your documents. We\'ll notify you once the verification is complete.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 13,
                                color: AppColor.greyColor,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 25),

                          // Submission details
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
                                  'SUBMISSION DETAILS',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                      letterSpacing: 0.5,
                                      color: AppColor.greyColor),
                                ),
                                SizedBox(height: 12),
                                _buildDetailRow(Icons.description_outlined,
                                    "Document Type", docName),
                                const SizedBox(height: 10),
                                _buildDetailRow(Icons.calendar_today_outlined,
                                    "Submitted On", formattedDate),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.pending_outlined,
                                            size: 14,
                                            color: AppColor.greyColor),
                                        SizedBox(width: 6),
                                        Text(
                                          "Current Status",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 11,
                                              color: AppColor.greyColor),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          color: isRejected
                                              ? Colors.red.withOpacity(0.1)
                                              : AppColor.blueColor
                                                  .withOpacity(0.1)),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        child: Text(
                                          isRejected ? "Rejected" : "In Review",
                                          style: TextStyle(
                                              color: isRejected
                                                  ? Colors.red
                                                  : AppColor.blueColor,
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

                          // What happens next / Resubmit
                          if (isRejected) ...[
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  context.push('/kycVerification');
                                },
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Submit Again',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ] else ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Colors.green.withOpacity(0.2)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline,
                                      color: Colors.green.shade700, size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'You will receive an email notification once the review process is complete.',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Need Help section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 25),
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
                          'If you have any questions about your KYC verification status, our support team is here to help.',
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
                              bgColor:
                                  AppColor.deepPurpleColor.withOpacity(0.1),
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
                      SizedBox(width: 10),
                      Expanded(
                          child: Text(
                        'Your data is encrypted and securely stored according to GDPR standards.',
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
          );
        },
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
        icon: Icon(icon, color: textColor, size: 16),
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

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColor.greyColor),
            SizedBox(width: 6),
            Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColor.greyColor,
                    fontSize: 11)),
          ],
        ),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColor.blackColor,
                fontSize: 11)),
      ],
    );
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}
