import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

extension StringX on String {
  String capitalize() => this[0].toUpperCase() + substring(1);
}

extension ThemeX on BuildContext {
  //nav color

  Color get tabBackgroundColor {
    return Theme.of(this).brightness == Brightness.dark
        ? Colors.grey.shade700.withOpacity(0.8)
        : AppFlavorColor.primary.withOpacity(0.12);
    // : AppColor.whiteColor;
  }

  Color get backgroundColor {
    return Theme.of(this).brightness == Brightness.dark
        ? AppColor.blackColor
        : AppFlavorColor.background;
    // : AppColor.whiteColor;
  }

  Color get themeColor {
    return Theme.of(this).brightness == Brightness.dark
        ? AppColor.whiteColor
        : AppColor.blackColor;
  }

  Color get boxDecorationColor {
    return Theme.of(this).brightness == Brightness.dark
        ? Colors.white10
        : AppColor.lightGrey;
    // : AppColor.whiteColor;
  }

  Color get helpIconColor {
    return Theme.of(this).brightness == Brightness.dark
        ? AppColor.whiteColor
        : Colors.grey.shade700;
    // : AppColor.whiteColor;
  }

  Color get textFieldFillColor {
    return Theme.of(this).brightness == Brightness.dark
        ? Colors.white10
        : Colors.grey.shade100;
    // : AppColor.whiteColor;
  }

  // appBar brightness

  SystemUiOverlayStyle get appBarIconBrightness {
    return Theme.of(this).brightness == Brightness.dark
        ? SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light)
        : SystemUiOverlayStyle(statusBarIconBrightness: Brightness.dark);
  }

  Color get primaryColor {
    return Theme.of(this).brightness == Brightness.dark
        ? AppColor.blackColor
        : AppFlavorColor.primary;
  }

  Color get tabLabelColor {
    return Theme.of(this).brightness == Brightness.dark
        ? AppFlavorColor.background
        : AppFlavorColor.primary;
  }

  Color get borderColor {
    return Theme.of(this).brightness == Brightness.dark
        ? AppColor.whiteColor
        : AppFlavorColor.primary.withOpacity(0.5);
  }

  // appBar gradient color

  Color get appBarGradientColor {
    return Theme.of(this).brightness == Brightness.dark
        // ? Colors.grey.shade800
        ? AppColor.blackColor
        // : AppFlavorColor.primary;
        : AppColor.whiteColor;

  }

  Color get appBarGradientColorSecond {
    return Theme.of(this).brightness == Brightness.dark
        ? AppColor.blackColor
        // ? Colors.grey.shade700
        // : AppFlavorColor.primary.withOpacity(0.7);
        : AppFlavorColor.primary.withOpacity(0.1);

  }

  // scaffold Background Color

  Color get scaffoldBackgroundColor {
    return Theme.of(this).brightness == Brightness.dark
        // ? Colors.white10
        ? AppColor.blackColor
        : Colors.grey.shade50;
  }

  // bottom sheet container Color

  LinearGradient get bottomSheetGradientColor {
    return Theme.of(this).brightness == Brightness.dark
        ? LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColor.blackColor,
              AppColor.blackColor.withOpacity(0.95),
            ],
          )
        : LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColor.whiteColor,
              const Color(0xFFF8FAFC),
            ],
          );
  }

  // profile info icon color

  Color get profileIconColor {
    return Theme.of(this).brightness == Brightness.dark
        ? AppColor.whiteColor
        : Colors.black87;
  }

  Color get profileBoxColor {
    return Theme.of(this).brightness == Brightness.dark
        ? Colors.grey.shade500.withOpacity(0.3)
        : Colors.grey.shade50.withOpacity(0.8);
  }

  Color get profileTextColor {
    return Theme.of(this).brightness == Brightness.dark
        ? Colors.white70
        : Colors.black87;
  }

  Color get disableBoxColor {
    return Theme.of(this).brightness == Brightness.dark
        ? AppColor.blackColor.withOpacity(0.6)
        : Colors.grey.shade100;
  }

  Color get profileScaffoldColor {
    return Theme.of(this).brightness == Brightness.dark
        ? Colors.grey.shade900
        : Colors.grey.shade50;
  }

  // chatScreen

  Color get chatScaffoldColor {
    return Theme.of(this).brightness == Brightness.dark
        ? Colors.white24
        : AppColor.whiteColor;
  }

  Color get chatTextColor {
    return Theme.of(this).brightness == Brightness.dark
        ? AppColor.whiteColor
        : AppColor.greyColor;
  }

  Color get chatBoxDecorationColor {
    return Theme.of(this).brightness == Brightness.dark
        ? AppColor.blackColor
        : Colors.grey.shade100;
  }

  Color get chatAppBackgroundColor {
    return Theme.of(this).brightness == Brightness.dark
        ? Colors.black
        : Colors.grey.shade100;
  }

  // your residence

  Color get residenceRichTextColor {
    return Theme.of(this).brightness == Brightness.dark
        ? Colors.grey.shade300
        : Colors.grey.shade700;
  }

  // registerScreen

  Color get registerFocusColor {
    return Theme.of(this).brightness == Brightness.dark
        ? Colors.blue.shade300
        : Colors.blue.shade600;
  }

  Color get registerFocusSecondColor {
    return Theme.of(this).brightness == Brightness.dark
        ? Colors.grey.shade300
        : Colors.grey.shade600;
  }

  // internal transfer color

  Color get internalDopDownColor {
    return Theme.of(this).brightness == Brightness.dark
        ? Colors.grey.shade900
        : AppColor.whiteColor;
  }

  // deposit fund screen color

  Color get depositContainerColor {
    return Theme.of(this).brightness == Brightness.dark
        ? Colors.white10
        : AppColor.whiteColor;
  }

  Color get depositBoxShadowColor {
    return Theme.of(this).brightness == Brightness.dark
        ? Colors.black26
        : Colors.grey.withOpacity(0.2);
  }

  // withdrawal fund screen color

  Color get withdrawalBoxColor {
    return Theme.of(this).brightness == Brightness.dark
        ? Colors.white10
        : AppColor.lightGrey.withValues(alpha: 0.3);
  }

  // quick line card color

  Color get quickLineShadowColor {
    return Theme.of(this).brightness == Brightness.dark
        ? AppColor.transparent
        : AppColor.lightGrey;
  }

  // sell trade

  Color get sellTradeButtonColor {
    return Theme.of(this).brightness == Brightness.dark
        ? Colors.white10
        : Colors.grey.shade300;
  }

  // detail screen color

  Color get detailBoxColor {
    return Theme.of(this).brightness == Brightness.dark
        ? Colors.white24
        : AppColor.lightGrey;
  }

  // Notification screen color

  Color get notificationBoxColor {
    return Theme.of(this).brightness == Brightness.dark
        ? Colors.white24
        : Colors.grey.shade100;
  }

// open new account

  Color get openNewAccountBoxColor {
    return Theme.of(this).brightness == Brightness.dark
        ? AppColor.whiteColor
        : Colors.grey.shade500;
  }

  // Ib room screen Color

  Color get ibRoomScaffoldColor {
    return Theme.of(this).brightness == Brightness.dark
        ? Color(0xFF1A1A1A)
        : Color(0xFFF8FAFC);
  }

  Color get ibRoomAppBarBackgroundColor {
    return Theme.of(this).brightness == Brightness.dark
        ? Color(0xFF2D2D2D)
        : AppColor.whiteColor;
  }

  Color get ibRoomTextColor {
    return Theme.of(this).brightness == Brightness.dark
        ? Colors.white70
        : Colors.black54;
  }

  Color get ibRoomTableColor {
    return Theme.of(this).brightness == Brightness.dark
        ? Colors.white.withOpacity(0.05)
        : Colors.grey.withOpacity(0.1);
  }

  Color get ibRoomIconColor {
    return Theme.of(this).brightness == Brightness.dark
        ? Colors.white54
        : Colors.black54;
  }
}
