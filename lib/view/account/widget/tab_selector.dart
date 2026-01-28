
import 'package:exness_clone/core/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TabSelector extends StatelessWidget {
  final String title;
  final int count;

  const TabSelector({super.key, required this.title, required  this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: context.boxDecorationColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '$title $count',
          style: TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
