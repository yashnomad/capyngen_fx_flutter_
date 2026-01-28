import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/widget/color.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class SimpleAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? action;

  const SimpleAppbar({super.key, required this.title, this.action});

  @override
  Widget build(BuildContext context) {


    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 5,
      elevation: 0,
      flexibleSpace: Container(
        color: context.backgroundColor,
      ),
      leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios_new_outlined,
            size: 18,
          )),
      title: Text(
        title,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      ),
      actions: action,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
