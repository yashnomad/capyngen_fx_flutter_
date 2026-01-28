import 'package:exness_clone/core/extensions.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widget/simple_appbar.dart';

class EditBioScreen extends StatefulWidget {
  const EditBioScreen({super.key});

  @override
  State<EditBioScreen> createState() => _EditBioScreenState();
}

class _EditBioScreenState extends State<EditBioScreen> {
  final TextEditingController _controller = TextEditingController();
  static const int _maxLength = 2000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppbar(title: 'Edit Bio'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                cursorColor: AppColor.blackColor,
                style: TextStyle(color: AppColor.blackColor,fontWeight: FontWeight.w500),
                controller: _controller,
                maxLines: 8,
                maxLength: _maxLength,
                decoration:  InputDecoration(
                  hintText: 'Introduce yourself',
                  hintStyle: TextStyle(fontSize: 12,color: AppColor.greyColor),
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
            SizedBox(height: 30,),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:context.themeColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child:  Text("Save", style: TextStyle(color: context.backgroundColor)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}