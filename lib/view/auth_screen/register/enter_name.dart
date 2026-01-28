import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/view/auth_screen/register/enter_email.dart';
import 'package:exness_clone/widget/simple_appbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/app_colors.dart';
import '../../../widget/color.dart';
import 'choose_password.dart';
import '../../../utils/validators.dart';

class EnterNameScreen extends StatefulWidget {
  const EnterNameScreen({super.key});

  @override
  State<EnterNameScreen> createState() => _EnterNameScreenState();
}

class _EnterNameScreenState extends State<EnterNameScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  void _onContinuePressed() {
    if (_formKey.currentState?.validate() ?? false) {
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => EnterEmailScreen()),
      // );
      context.pushNamed('enterEmailScreen');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppbar(title: 'Enter your name'),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Use your valid name of your identity',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),
              const Text(
                'Full Name',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                validator: Validators.validateName,
                keyboardType: TextInputType.name,
                style: const TextStyle(fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onContinuePressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppFlavorColor.primary,
                    foregroundColor: AppColor.blackColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child:  Text(
                    'Continue',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColor.whiteColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
