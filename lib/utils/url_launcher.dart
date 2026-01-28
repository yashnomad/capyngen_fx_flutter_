import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class UrlLauncher {
  static Future<void> openGmailApp() async {
    final Uri gmailInboxUri = Uri.parse("https://mail.google.com/mail/u/0/#inbox");

    if (await canLaunchUrl(gmailInboxUri)) {
      await launchUrl(gmailInboxUri, mode: LaunchMode.externalApplication);
    } else {
      final Uri fallbackUri = Uri.parse('mailto:');
      if (await canLaunchUrl(fallbackUri)) {
        await launchUrl(fallbackUri);
      } else {
        debugPrint('Could not launch Gmail or fallback mail client.');
      }
    }
  }
}