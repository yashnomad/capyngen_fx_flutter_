import 'package:flutter/material.dart';

class UIBottomSheets {
  static Future<T?> accountBottomSheet<T>(BuildContext context, Widget child) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return child;
      },
    );
  }

  static Future<T?> showBankDialog<T>(BuildContext context, Widget child) async{
   return showDialog(
      context: context,
      builder: (context) => child,
    );
  }
}
