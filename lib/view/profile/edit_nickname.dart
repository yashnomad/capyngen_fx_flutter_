import 'package:exness_clone/core/extensions.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widget/simple_appbar.dart';

class EditNickname extends StatefulWidget {
  const EditNickname({super.key});

  @override
  State<EditNickname> createState() => _EditNicknameState();
}

class _EditNicknameState extends State<EditNickname> {
  final TextEditingController _controller =
      TextEditingController(text: 'Capmarket702');
  static const int _maxLength = 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppbar(title: 'Edit Nickname'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                cursorColor: AppColor.blackColor,
                style: TextStyle(
                    color: AppColor.blackColor, fontWeight: FontWeight.w500),
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Enter your nickname',
                  hintStyle: TextStyle(fontSize: 12, color: AppColor.greyColor),
                  border: InputBorder.none,
                  counterText: '',
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${_controller.text.length}/$_maxLength',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.themeColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text("Save",
                    style: TextStyle(color: context.backgroundColor)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
