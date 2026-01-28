import 'dart:convert';

import 'package:exness_clone/config/flavor_assets.dart';
import 'package:exness_clone/utils/snack_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class CommonUtils {
  static void prettyPrint(dynamic data, {String prefix = ""}) {
    try {
      final encoder = const JsonEncoder.withIndent("  ");
      final pretty = encoder.convert(data);
      debugPrint("$prefix$pretty");
    } catch (_) {
      debugPrint("$prefix$data");
    }
  }

  static void debugPrintWithTrace(
    String message, {
    String tag = 'DEBUG',
    int wrapWidth = 80,
  }) {
    final dividerTop = '╔${'═' * (wrapWidth - 1)}';
    final dividerMid = '╟${'─' * (wrapWidth - 1)}';
    final dividerBottom = '╚${'═' * (wrapWidth - 1)}';

    final timestamp = DateTime.now().toIso8601String();

    final lines = message.split('\n');
    final formattedLines = lines.map((line) => '║ $line').join('\n');

    final log = '''
$dividerTop
║ [$tag] $timestamp
$dividerMid
$formattedLines
$dividerBottom''';

    debugPrint(log);
  }

  static String toCamelCase(String input) {
    final words = input.split(RegExp(r'[\s-]+'));
    if (words.isEmpty) return '';

    final first = words.first.toLowerCase();
    final rest = words.skip(1).map((word) => word.isNotEmpty
        ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
        : '');

    return first + rest.join();
  }

  static String capitalize(String name) {
    if (name.isEmpty) return '';
    return name[0].toUpperCase();
  }

  static String formatDateTime(DateTime? dateTime) {
    final DateFormat formatter = DateFormat('d MMM y, h:mm a');
    return formatter.format(dateTime!);
  }

  /*static String formatBalance(double? balance) {
    if (balance == null) return '0.00';
    final amount = balance / 100;
    return NumberFormat("#,##0.00", "en_US").format(amount);
  }*/

  static String formatBalance(double? amount) {
    if (amount == null) return '0.00';
    final formatter = NumberFormat('#,##0.00');
    return '\$${formatter.format(amount)}';
    // return formatter.format("\$ $amount");
  }

  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static String capitalizeFirst(String? input) {
    if (input == null || input.isEmpty) return '';
    return '${input[0].toUpperCase()}${input.substring(1)}';
  }

  // Helper method to parse different date formats
  static DateTime parseDateTime(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();

    String dateString = dateValue.toString();

    try {
      // Try ISO format first (withdrawal API format)
      if (dateString.contains('T') && dateString.contains('Z')) {
        return DateTime.parse(dateString);
      }

      // Try custom format (crypto_deposit API format): "05/07/2025, 03:11:35 pm"
      if (dateString.contains('/') && dateString.contains(',')) {
        // Parse format: "05/07/2025, 03:11:35 pm"
        final formatter = DateFormat('dd/MM/yyyy, hh:mm:ss a');
        return formatter.parse(dateString);
      }

      // Try other common formats
      if (dateString.contains('-')) {
        return DateTime.parse(dateString);
      }

      // If all else fails, return current time
      debugPrint(
          "=== Could not parse date: $dateString, using current time ===");
      return DateTime.now();
    } catch (e) {
      debugPrint("=== Error parsing date '$dateString': $e ===");
      return DateTime.now();
    }
  }

  static Future<void> launchPaymentUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        SnackBarService.showError('Could not launch payment URL');
      }
    } catch (e) {
      SnackBarService.showError('Error launching payment URL: $e');
    }
  }

  static Future<void> shareApp(BuildContext context, String url) async {
    final shareText =
        '📈 Trade Smarter with ${FlavorAssets.appName}\n\n'
        '✔ Real-time market data\n'
        '✔ Fast & secure trading\n'
        '✔ Advanced charts & indicators\n\n'
        'Start trading now 👇\n' '$url';

    final box = context.findRenderObject() as RenderBox?;

    final params = ShareParams(
      text: shareText,
      subject: 'Trade with ${FlavorAssets.appName}',
      sharePositionOrigin:
      box != null ? box.localToGlobal(Offset.zero) & box.size : null,
    );

    final result = await SharePlus.instance.share(params);

    if (result.status == ShareResultStatus.success) {
      SnackBarService.showSuccess('User shared trading app successfully');
    }
  }


}
