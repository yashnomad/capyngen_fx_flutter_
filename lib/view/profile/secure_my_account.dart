import 'package:exness_clone/constant/app_vector.dart';
import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/widget/color.dart';
import 'package:flutter/material.dart';

import '../../config/flavor_assets.dart';
import '../../theme/app_colors.dart';

class SecureMyAccount extends StatelessWidget {
  const SecureMyAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Close icon
              InkWell(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, size: 28),
              ),
              const SizedBox(height: 60),

              // Arrow image (replace with your own asset if needed)
              Center(
                child: Image.asset(
                  AppVector.arrow,
                  height: 80,
                  color: context.themeColor,
                ),
              ),
              const SizedBox(height: 30),

              // "Are you sure?"
              const Center(
                child: Text(
                  "Are you sure?",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Subtitle
               Center(
                child: Text(
                  "This will remove access to your ${FlavorAssets.appName} account from all other devices. You'll stay logged in on this device only.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13),
                ),
              ),
              const Spacer(),

              // Warning box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF5E3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded, color: AppColor.orangeColor),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "If you think someone else has access your Personal Area, you should reset your password after signing out of other devices.",
                        style: TextStyle(fontSize: 13, color: AppColor.blackColor),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),


              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppFlavorColor.primary,
                  foregroundColor: AppColor.whiteColor,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: () {

                },
                child: const Text(
                  "Log out",
                  style: TextStyle(fontSize: 13),
                ),
              ),
              const SizedBox(height: 6),

              // Cancel button
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  elevation: 0,
                  foregroundColor: AppColor.blackColor,
                  minimumSize: const Size(double.infinity, 40),
                  backgroundColor: Colors.grey.shade100,
                  side:  BorderSide(color: AppColor.transparent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  "Cancel",
                  style: TextStyle(fontSize: 13),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
