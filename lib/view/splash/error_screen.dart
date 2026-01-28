import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/widget/button/premium_app_button.dart';
import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_off,
                  color: AppFlavorColor.error,
                  size: 100,
                ),
                const SizedBox(height: 24),
                Text(
                  "Oops! Something went wrong",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    // color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  "We're having trouble connecting to our servers.\nPlease check your internet connection or try again later.",
                  style: TextStyle(
                    fontSize: 16,
                    // color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                PremiumAppButton(
                  width: MediaQuery.of(context).size.width * 0.5,
                  icon: Icons.refresh,
                  showIcon: true,
                  onPressed: () {

                  },
                  text: "Retry",
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
