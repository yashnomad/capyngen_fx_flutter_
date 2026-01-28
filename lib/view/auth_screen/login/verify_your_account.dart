import 'dart:async';
import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/view/auth_screen/login/reset_password_second.dart';
import 'package:flutter/material.dart';

class VerifyAccountScreen extends StatefulWidget {
  const VerifyAccountScreen({super.key});

  @override
  State<VerifyAccountScreen> createState() => _VerifyAccountScreenState();
}

class _VerifyAccountScreenState extends State<VerifyAccountScreen> {
  final List<TextEditingController> _controllers =
  List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  int _secondsRemaining = 31;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _secondsRemaining = 31;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
        setState(() {}); // Update UI when timer ends
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Check if all OTP boxes are filled
    bool allFilled = _controllers.every((controller) => controller.text.length == 1);
    if (allFilled) {
      String otp = _controllers.map((e) => e.text).join();
      // Navigate to next screen
      Future.delayed(const Duration(milliseconds: 300), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ResetPasswordSecondScreen()),
        );
      });
    }
  }

  void _resendCode() {
    setState(() {
      _secondsRemaining = 31;
    });
    _startCountdown();
    // Add actual resend logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Code resent!')),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 45,
      height: 50,
      child: TextField(
        controller: _controllers[index],
        cursorColor: AppColor.blackColor,
        focusNode: _focusNodes[index],
        cursorHeight: 20,
        onChanged: (value) => _onOtpChanged(value, index),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style:  TextStyle(fontSize: 22, fontWeight: FontWeight.bold,color: AppColor.blackColor),
        decoration: InputDecoration(
          isDense: true,
          counterText: "",
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const CloseButton(), elevation: 0,flexibleSpace: Container(color: context.backgroundColor,),),

      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Verify your account",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Text(
              "Confirm the operation",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            const Text(
              "Enter the confirmation code sent to your current 2-Step verification method",
              style: TextStyle(fontSize: 13,fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 30),

            /// OTP Boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, _buildOtpBox),
            ),
            const SizedBox(height: 20),

            /// Timer Text or Resend Option
            _secondsRemaining == 0
                ? GestureDetector(
              onTap: _resendCode,
              child:  Text(
                "Send code again",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColor.blueColor),
              ),
            )
                : Text.rich(
              TextSpan(
                text: "Get a new code in ",
                children: [
                  TextSpan(
                    text: "00:${_secondsRemaining.toString().padLeft(2, '0')}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              style:  TextStyle(fontSize: 14, color: AppColor.greyColor),
            ),
          ],
        ),
      ),
    );
  }
}


