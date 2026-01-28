import 'package:flutter/material.dart';

import '../../widget/simple_appbar.dart';

class SettingLanguage extends StatefulWidget {
  const SettingLanguage({super.key});

  @override
  State<SettingLanguage> createState() => _SettingLanguageState();
}

class _SettingLanguageState extends State<SettingLanguage> {

  final List<String> languages = [
    'English',
    // 'Español',
    // 'Français',
    // 'العربية',
    // 'हिन्दी',
    // 'Indonesia',
    // '日本語',
    // '한국어',
    // 'Português',
    // 'ไทย',
    // 'Tiếng Việt',
    // '中文',
    // 'Oʻzbek',
  ];

  String selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppbar(title: 'Language'),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: languages.length,
        itemBuilder: (context, index) {
          final lang = languages[index];
          return ListTile(
            title: Text(
              lang,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            trailing: selectedLanguage == lang
                ? const Icon(Icons.check, size: 20)
                : null,
            onTap: () {

              setState(() {
                selectedLanguage = lang;
              });
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
