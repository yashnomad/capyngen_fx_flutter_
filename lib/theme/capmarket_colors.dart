import 'package:flutter/material.dart';
import 'package:snippet_coder_utils/hex_color.dart';

class CapMarketColors {
  // 🔹 Backgrounds
  static const Color bg = Color(0xFFFFFFFF);
  static const Color transparent = Colors.transparent;
  static final Color cardBg = Colors.white;

  static const Color primary = Color(0xFF039BE5); // Bright Blue
  static const Color primaryDark = Color(0xFF0277BD); // Darker Blue
  static const Color secondary = Color(0xFFFFFFFF); // White accent
  static Color shadow = primary.withOpacity(0.4);

  // 🔹 Buttons
  static final Color button = primary;
  static final Color buttonText = Colors.white;
  static final Color disabledButton = Colors.grey.shade400;

  // 🔹 Text
  static final Color text = HexColor('626364');
  static final Color textLight = Colors.grey.shade600;
  static final Color textDark = Colors.black;
  static final Color headerText = HexColor('F8AE5F');

  // 🔹 Icons
  static final Color icon = Colors.black87;
  static final Color iconSecondary = Colors.blueGrey;

  // 🔹 Dividers / Borders
  static final Color divider = HexColor('808080');
  static final Color border = Colors.grey.shade300;

  // 🔹 Gradients
  static final Color gradient1 = HexColor('47F09C');
  static final Color gradient2 = HexColor('08904C');

  // 🔹 Alerts / States
  static final Color success = Colors.green;
  static final Color error = HexColor('FF4B4B');
  static final Color warning = Colors.amber;
  static final Color info = Colors.blue;

  // 🔹 Extra palette (jo tune diye the)
  static final Color nestPipColor = Color(0xfff56105);
  static final Color orangeColor = Colors.orange;
  static final Color deepPurpleColor = Colors.deepPurple;
  static final Color lightGrey = Colors.grey.shade200;
  static final Color mediumGrey = Colors.grey.shade300;
  static final Color amberColor = Colors.amber;
  static final Color blueGrey = Colors.blueGrey;
  static final Color elliteFxColor = Color(0xff0aeca8);

  static final Color lightOrange = HexColor('F8AE5F');
  static final Color darkOrange = HexColor('F79B39');
  static final Color headerColor = HexColor('F8AE5F');
  static final Color darkBlue = const Color(0xff01103f);
  static final Color whiteColor = HexColor('FFFFFF');
  static final Color blackColor = HexColor('020000');
  static final Color redColor = HexColor('FF4B4B');
  static final Color greyColor = Colors.grey;
  static final Color greenColor = Colors.green;
  static final Color pinkColor = HexColor('E957C2');
  static final Color indigoColor = HexColor('7B5BDF');
  static final Color lightBlueColor = HexColor('77A6F8');
  static final Color lightPurpleColor = HexColor('77A6F8');
  static final Color myStoreQrColor = HexColor('C190F8');
  static final Color yellowColor = Colors.yellow;
  static final Color promoteStoreColor = HexColor('AEA4F8');
  static final Color helpColor = HexColor('6879C1');
  static final Color darkPurpleColor = HexColor('5B607E');
  static final Color darkGreenColor = HexColor('3DE994');
  static final Color pipzoColor = HexColor('283B96');
  static final Color darkBlueColor = HexColor('283B96');
  static final Color darkIndigo = HexColor('3E4152');
  static final Color brown = HexColor('E7874B');
  static final Color golden = HexColor('FBC142');
  static final Color maroon = HexColor('BA3636');
  static final Color lightPinkColor = HexColor('FDE2E2');
  static final Color comingSoonColor = HexColor('F66D70');
  static final Color navyColor = HexColor('000C66');
  static final Color blueColor = Colors.blue;
}
