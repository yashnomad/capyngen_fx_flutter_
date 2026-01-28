import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/widget/button/premium_app_button.dart';
import 'package:exness_clone/widget/color.dart';
import 'package:exness_clone/widget/simple_appbar.dart';
import 'package:flutter/material.dart';

import '../../../config/flavor_config.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/validators.dart';


class ResetPasswordSecondScreen extends StatefulWidget {
  const ResetPasswordSecondScreen({super.key});

  @override
  State<ResetPasswordSecondScreen> createState() => _ResetPasswordSecondScreenState();
}

class _ResetPasswordSecondScreenState extends State<ResetPasswordSecondScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();



  final FocusNode _passwordFocus = FocusNode();

  bool isObscure = true;
  bool isConfirmObscure = true;





  bool hasUpperLower = false;
  bool hasNumber = false;
  bool hasSpecialChar = false;
  bool hasValidLength = false;

  String get password => passwordController.text;

  void validatePassword(String value) {
    setState(() {
      hasValidLength = value.length >= 8 && value.length <= 15;
      hasUpperLower = RegExp(r'(?=.*[a-z])(?=.*[A-Z])').hasMatch(value);
      hasNumber = RegExp(r'[0-9]').hasMatch(value);
      hasSpecialChar = RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value);
    });
  }

  @override
  void initState() {
    super.initState();

    passwordController.addListener(() => setState(() {}));
    confirmPasswordController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {



    return Scaffold(
      appBar:SimpleAppbar(title: 'Reset password'),
      bottomSheet:  Container(
        color: context.backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: PremiumAppButton(text: 'Change password',onPressed: (password == confirmPasswordController.text &&
              hasUpperLower &&
              hasSpecialChar &&
              hasNumber &&
              hasValidLength)
              ? () {
            Navigator.pop(context);

          }
              : null,),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter a new password twice',
              style: TextStyle( fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            const Text("Password", style: TextStyle(fontSize: 13,fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),



            TextField(
              controller: passwordController,
              obscureText: isObscure,
              style: TextStyle(fontWeight: FontWeight.w500),
              onChanged: validatePassword,
              decoration: InputDecoration(

                filled: true,
                fillColor:context.textFieldFillColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                suffixIcon: IconButton(
                  icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => isObscure = !isObscure),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        passwordRequirement('Between 8–15 characters', hasValidLength),
                        passwordRequirement('At least one upper and one lower case letter', hasUpperLower),
                        passwordRequirement('At least one number', hasNumber),
                        passwordRequirement('At least one special character', hasSpecialChar),
                      ],
                    ),
                  ),
                  Text('${password.length}', style:  TextStyle(fontSize: 12, color:password.length>8?AppColor.greenColor: AppColor.greyColor,fontWeight: FontWeight.w500)),
                ],
              ),
            ),


            const SizedBox(height: 20),
            const Text("Confirm new password", style: TextStyle(fontSize: 13,fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: confirmPasswordController,
              obscureText: isConfirmObscure,
              style: TextStyle(fontWeight: FontWeight.w500),
              decoration: InputDecoration(

                filled: true,
                fillColor: context.textFieldFillColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                suffixIcon: IconButton(
                  icon: Icon(isConfirmObscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => isConfirmObscure = !isConfirmObscure),
                ),
              ),
            ),


            // PremiumAppButton(text: 'Change password',onPressed: (password == confirmPasswordController.text &&
            //     hasUpperLower &&
            //     hasSpecialChar &&
            //     hasNumber &&
            //     hasValidLength)
            //     ? () {
            //   Navigator.pop(context);
            //
            // }
            //     : null,),


          ],
        ),
      ),
    );
  }

  Widget passwordRequirement(String text, bool valid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Row(
        children: [
          Icon(valid ? Icons.check_circle : Icons.radio_button_unchecked,
              color: valid ? AppColor.greenColor : AppColor.greyColor, size: 10),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: valid ? AppColor.greenColor : AppColor.greyColor,
                fontSize: 12,
              ),
            ),
          )
        ],
      ),
    );
  }




}
