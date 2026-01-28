import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/widget/color.dart';
import 'package:exness_clone/widget/simple_appbar.dart';
import 'package:flutter/material.dart';

class ChangePasscodeScreen extends StatefulWidget {
  const ChangePasscodeScreen({super.key});

  @override
  State<ChangePasscodeScreen> createState() => _ChangePasscodeScreenState();
}

class _ChangePasscodeScreenState extends State<ChangePasscodeScreen> with SingleTickerProviderStateMixin {
  final int passcodeLength = 6;
  List<String> enteredDigits = [];

  void onKeyTap(String value) {
    if (enteredDigits.length < passcodeLength) {
      setState(() {
        enteredDigits.add(value);
      });

      if (enteredDigits.length == passcodeLength) {
        String passcode = enteredDigits.join();
        print('Entered Passcode: $passcode');

        // Auto close the screen after a short delay
        Future.delayed(const Duration(milliseconds: 300), () {
          Navigator.pop(context, passcode); // or just pop without value
        });
      }
    }
  }

  void onBackspace() {
    if (enteredDigits.isNotEmpty) {
      setState(() {
        enteredDigits.removeLast();
      });
    }
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        passcodeLength,
            (index) {
          bool isFilled = index < enteredDigits.length;
          bool showBorder = !isFilled;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 6),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: showBorder ? Border.all(color: AppColor.mediumGrey,width: 1.5) : null,
              color: isFilled ? AppFlavorColor.primary : AppColor.transparent,
            ),
          );
        },
      ),
    );
  }


  Widget _buildKey(String digit) {
    return InkWell(
      onTap: () {
        if (digit == '←') {
          onBackspace();
        } else {
          onKeyTap(digit);
        }
      },
      child: Center(
        child: digit == '←'
            ? (enteredDigits.isNotEmpty
            ? const Icon(Icons.arrow_back_ios_new_rounded, size: 22)
            : const SizedBox.shrink())
            : Text(
          digit,
          style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildKeyboard() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '←']
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: row.map((key) {
            return Expanded(
              child: SizedBox(
                height: 90,
                child: key.isEmpty
                    ? const SizedBox()
                    : _buildKey(key),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppbar(title: 'Change passcode'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Enter your existing passcode',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            _buildIndicator(),
            _buildKeyboard(),
          ],
        ),
      ),
    );
  }
}
