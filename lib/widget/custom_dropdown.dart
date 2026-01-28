import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomStyledDropdown<T> extends StatelessWidget {
  final List<T> items;
  final T? selectedItem;
  final ValueChanged<T?> onChanged;
  final String Function(T) itemBuilder;
  final String? hint;
  final String? label;

  const CustomStyledDropdown({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onChanged,
    required this.itemBuilder,
    this.hint,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),

        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black45 : Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<T>(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
            fontSize: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: context.backgroundColor,
          // fillColor: isDark ? Colors.grey[850] : AppColor.whiteColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        value: selectedItem,
        isExpanded: true,
        icon: Icon(
          CupertinoIcons.chevron_down,
          size: 16,
          color: isDark ? Colors.white70 : Colors.grey,
        ),
        style: TextStyle(
          fontSize: 14,
          color: isDark ? AppColor.whiteColor : Colors.black87,
        ),
        dropdownColor: isDark ? Colors.grey[900] : AppColor.whiteColor,

        hint: hint != null
            ? Text(
          hint!,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white54 : Colors.black54, // 👈 Matches placeholder styling
          ),
        )
            : null,
        items: items.map((item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(
              itemBuilder(item),
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColor.whiteColor : Colors.black87,
                fontWeight: FontWeight.w400,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}