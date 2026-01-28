import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/view/app_auth/app_auth_screen.dart';
import 'package:exness_clone/widget/slidepage_navigate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/app_auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppAuthResetPinDialog {
  static void showAuthPinResetDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: _ResetPinDialogContent(
          onReset: () {
            context.read<AppAuthProvider>().resetPin();
            if (!context.mounted) return;
            Navigator.pop(ctx);
            Navigator.push(
              context,
              SlidePageRoute(
                page: const AppAuthScreen(isResettingPin: true),
              ),
            );
          },
          onCancel: () => Navigator.pop(ctx),
        ),
      ),
    );
  }
}

class _ResetPinDialogContent extends StatelessWidget {
  final VoidCallback onReset;
  final VoidCallback onCancel;

  const _ResetPinDialogContent({
    required this.onReset,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppFlavorColor.primary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon with gradient background
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.red.withOpacity(0.2),
                  Colors.orange.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.red.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.lock_reset,
              size: 35,
              color: Colors.red,
            ),
          ),

          const SizedBox(height: 20),

          // Title
          Text(
            'Reset PIN',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppFlavorColor.headerText,
            ),
          ),

          const SizedBox(height: 12),

          // Content
          Text(
            'Are you sure you want to reset your PIN? You will need to set a new one.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColor.greyColor,
            ),
          ),

          const SizedBox(height: 24),

          // Buttons
          Row(
            children: [
              // Cancel Button
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColor.lightGrey,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColor.mediumGrey,
                      width: 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onCancel,
                      borderRadius: BorderRadius.circular(12),
                      child: Center(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppFlavorColor.text,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Reset Button
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFF5252),
                        Color(0xFFFF6B6B),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onReset,
                      borderRadius: BorderRadius.circular(12),
                      child: const Center(
                        child: Text(
                          'Reset',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}