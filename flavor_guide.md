# Exness Clone: Flavor Management Guide

This guide explains **how to add or remove flavors** in the Exness Clone Flutter project. Follow step-by-step to ensure all files, configurations, and assets are correctly created.

---

## 1. Flavor Enum

All flavors are defined in `lib/config/flavor_config.dart`:

```dart
enum Flavor {
  capmarket,
  ellitefx,
  nestpip,
  pipzomarket,
  righttrade,
  primeforex,
  innovixcapital,
  forexmt,
  ivrfx,
  enzo4ex,
  fynixfxweb
}
```

**Tip:** Add a new flavor here first before creating any files.

---

## 2. Main Entry Files

For each flavor, create a `main_<flavor>.dart` file:

**Example for `innovixcapital`:**

```dart
import 'package:exness_clone/config/flavor_config.dart';
import 'package:exness_clone/main_common.dart';

void main() async {
  FlavorConfig.appFlavor = Flavor.innovixcapital;
  await initializeApp();
}
```

Repeat for all flavors using the pattern:

```
main_<flavor>.dart
```

---

## 3. Assets

Create an **asset folder** for each flavor:

```
assets/image/<flavor>/
```

Inside each folder, place:

1. `logo.jpg` → rename a copy to `logo.png`
2. `splash.jpg` → rename a copy to `splash.png`

**Update `pubspec.yaml`** to include all asset folders:

```yaml
assets:
  - assets/image/
  - assets/image/capmarket/
  - assets/image/ellitefx/
  - assets/image/nestpip/
  - assets/image/pipzomarket/
  - assets/image/prime-forex-market/
  - assets/image/right-trade/
  - assets/image/innovixcapital/
  - assets/image/forexmt/
  - assets/image/ivrfx/
  - assets/image/enzo4ex/
  - assets/image/fynixfxweb/
```

---

## 4. Launcher Icons and Splash Files

Create **Flutter launcher icon YAML** and **splash YAML** for each flavor:

**Pattern:**

```
flutter_launcher_icons-<flavor>.yaml
flutter_native_splash-<flavor>.yaml
```

**Example `flutter_launcher_icons_innovixcapital.yaml`:**

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: assets/image/innovixcapital/logo.png
  min_sdk_android: 21
```

**Example `flutter_native_splash_innovixcapital.yaml`:**

```yaml
flutter_native_splash:
  color: "#147086"
  image: assets/image/innovixcapital/splash.png
  color_dark: "#D4D4D4"
  image_dark: assets/image/innovixcapital/splash.png
  android_12:
    image: assets/image/innovixcapital/splash.png
    color: "#147086"
  web: false
  android: true
  ios: true
```

Run these commands to generate icons and splash screens:

```bash
flutter pub get
flutter pub run flutter_launcher_icons:main -f flutter_launcher_icons-<flavor>.yaml
dart pub run flutter_native_splash:create --path flutter_native_splash-<flavor>.yaml
```

---

## 5. Color Files

Create a color file for each flavor (`<flavor>_color.dart`) and define primary and secondary colors.

**Example for `ivrfx_color.dart`:**

```dart
import 'package:flutter/material.dart';

class IvrFxColors {
  static const Color primary = Color(0xFF17477B);
  static const Color secondary = Color(0xFFC2C2C2);
  static const Color bg = Colors.white;
  static const Color cardBg = Colors.white;
  static const Color text = Colors.black;
}
```

---

## 6. AppFlavorColor

Update `AppFlavorColor` class to include new flavors:

```dart
case Flavor.innovixcapital:
  return InnovixCapitalColors.primary;
case Flavor.forexmt:
  return ForexMTColors.primary;
case Flavor.ivrfx:
  return IvrFxColors.primary;
case Flavor.enzo4ex:
  return Enzo4ExColors.primary;
case Flavor.fynixfxweb:
  return FynixFXWebColors.primary;
```

Repeat for all color getters: `primary`, `button`, `text`, etc.

---

## 7. Running Flavors

**Run commands per flavor:**

```bash
flutter run --flavor <flavor> -t lib/main_<flavor>.dart
flutter build apk --flavor <flavor> -t lib/main_<flavor>.dart
```

**Generate icons and splash:**

```bash
flutter pub run flutter_launcher_icons:main -f flutter_launcher_icons-<flavor>.yaml
dart pub run flutter_native_splash:create --path flutter_native_splash-<flavor>.yaml
```

Replace `<flavor>` with the appropriate flavor name.

---

## 8. Adding / Removing Flavors

1. Add/remove flavor in `Flavor` enum.
2. Add/remove main Dart file (`main_<flavor>.dart`).
3. Add/remove assets folder (`assets/image/<flavor>/`).
4. Add/remove color file (`<flavor>_color.dart`).
5. Add/remove launcher/splash YAML.
6. Update `pubspec.yaml` with asset folder.
7. Update `AppFlavorColor` class for new flavor.
8. Run commands to generate icons/splash and build app.

---

## 9. Notes

- Ensure logo and splash images exist before running launcher icon/splash commands.
- Logo files must be in `.png` format.
- Always update `pubspec.yaml` after adding new assets.
- Follow consistent naming conventions for all files.

---

**This guide ensures any developer can add or remove flavors safely without missing files or steps.**

