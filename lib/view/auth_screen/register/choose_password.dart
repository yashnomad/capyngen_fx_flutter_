import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/widget/color.dart';
import 'package:exness_clone/widget/simple_appbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/app_colors.dart';

class ChoosePasswordScreen extends StatefulWidget {
  final String name;
  final String email;
  const ChoosePasswordScreen({super.key, required this.name, required this.email});

  @override
  State<ChoosePasswordScreen> createState() => _ChoosePasswordScreenState();
}

class _ChoosePasswordScreenState extends State<ChoosePasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _obscure = true;

  bool get isLengthValid =>
      _passwordController.text.length >= 8 &&
      _passwordController.text.length <= 15;
  bool get hasUpperLower =>
      RegExp(r'(?=.*[a-z])(?=.*[A-Z])').hasMatch(_passwordController.text);
  bool get hasNumbersSpecials =>
      RegExp(r'(?=.*[0-9])(?=.*[!@#\$&*~%^\-_=+(){}[\]|;:<>,.?/])')
          .hasMatch(_passwordController.text);

  bool get allValid => isLengthValid && hasUpperLower && hasNumbersSpecials;

  void _onPasswordChanged() {
    setState(() {});
  }

  @override
  void initState() {
    _passwordController.addListener(_onPasswordChanged);
    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Widget buildRequirement(String text, bool isMet) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isMet ? AppColor.greenColor : AppColor.greyColor,
          size: 10,
        ),
        const SizedBox(width: 8),
        Expanded(
            child:
                Text(text, style: TextStyle(fontSize: 12, color: AppColor.greyColor))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppbar(title: 'Choose a password'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Password",
                style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: _passwordController,
              style: TextStyle(fontWeight: FontWeight.w500),
              obscureText: _obscure,
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: Icon(_obscure
                      ? Icons.remove_red_eye_outlined
                      : Icons.visibility_off_outlined),
                  onPressed: () {
                    setState(() {
                      _obscure = !_obscure;
                    });
                  },
                ),
                counterText: '${_passwordController.text.length}',
                counterStyle: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              maxLength:
                  null, // Optional: To enforce the 15-character upper limit visually
            ),
            const SizedBox(height: 20),
            buildRequirement("Use from 8 to 15 characters", isLengthValid),
            const SizedBox(height: 8),
            buildRequirement(
                "Use both uppercase and lowercase letters", hasUpperLower),
            const SizedBox(height: 8),
            buildRequirement(
                "Use a combination of numbers and English letters and supported special characters",
                hasNumbersSpecials),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: allValid
                    ? () {
                        // Proceed with password
                        // Navigator.pop(context);
                  context.pushReplacementNamed('auth');
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor:
                      allValid ? AppFlavorColor.primary : AppColor.mediumGrey,
                  foregroundColor: AppColor.whiteColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
                child: const Text("Continue"),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
