# exness_clone

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:


# Capmarket
flutter pub get
dart pub run flutter_launcher_icons:main -f flutter_launcher_icons-capmarket.yaml
dart pub run flutter_native_splash:create --path flutter_native_splash-capmarket.yaml

# EliteFX
dart pub run flutter_launcher_icons:main -f flutter_launcher_icons-ellitefx.yaml
dart pub run flutter_native_splash:create --path flutter_native_splash-ellitefx.yaml

# NestPip
dart pub run flutter_launcher_icons:main -f flutter_launcher_icons-nestpip.yaml
dart pub run flutter_native_splash:create --path flutter_native_splash-nestpip.yaml

# Pipzomarket
dart pub run flutter_launcher_icons:main -f flutter_launcher_icons-pipzomarket.yaml
dart pub run flutter_native_splash:create --path flutter_native_splash-pipzomarket.yaml

# RightTrade
dart pub run flutter_launcher_icons:main -f flutter_launcher_icons-right-trade.yaml
dart pub run flutter_native_splash:create --path flutter_native_splash-right-trade.yaml

# PrimeForex
dart pub run flutter_launcher_icons:main -f flutter_launcher_icons-prime-forex.yaml
dart pub run flutter_native_splash:create --path flutter_native_splash-prime-forex.yaml


# InnovixCapital
dart pub run flutter_launcher_icons:main -f flutter_launcher_icons-innovixcapital.yaml
dart pub run flutter_native_splash:create --path flutter_native_splash-innovixcapital.yaml

# ForexMT
dart pub run flutter_launcher_icons:main -f flutter_launcher_icons-forexmt.yaml
flutter pub run flutter_native_splash:create --path flutter_native_splash-forexmt.yaml

# IVRFX
dart pub run flutter_launcher_icons:main -f flutter_launcher_icons-ivrfx.yaml
dart pub run flutter_native_splash:create --path flutter_native_splash-ivrfx.yaml

# Enzo4ex
dart pub run flutter_launcher_icons:main -f flutter_launcher_icons_enzo4ex.yaml
dart pub run flutter_native_splash:create --path flutter_native_splash-enzo4ex.yaml

# FynixFXWeb
dart pub run flutter_launcher_icons:main -f flutter_launcher_icons-fynixfxweb.yaml
dart pub run flutter_native_splash:create --path flutter_native_splash-fynixfxweb.yaml

# FinflyMarket
dart pub run flutter_launcher_icons:main -f flutter_launcher_icons-finflymarket.yaml
dart pub run flutter_native_splash:create --path flutter_native_splash-finflymarket.yaml

# WorldOneCapital
dart pub run flutter_launcher_icons:main -f flutter_launcher_icons-worldonecapital.yaml
dart pub run flutter_native_splash:create --path flutter_native_splash-worldonecapital.yaml

# Sarthifxm
dart pub run flutter_launcher_icons:main -f flutter_launcher_icons-sarthifxm.yaml
dart pub run flutter_native_splash:create --path flutter_native_splash-sarthifxm.yaml


# Capyngen
dart pub run flutter_launcher_icons:main -f flutter_launcher_icons-capyngen.yaml
dart pub run flutter_native_splash:create --path flutter_native_splash-capyngen.yaml

# Ganecapital
dart pub run flutter_launcher_icons:main -f flutter_launcher_icons-ganecapitalfx.yaml
dart pub run flutter_native_splash:create --path flutter_native_splash-ganecapitalfx.yaml

# Voltfxtrade
dart pub run flutter_launcher_icons:main -f flutter_launcher_icons-voltfxtrade.yaml
dart pub run flutter_native_splash:create --path flutter_native_splash-voltfxtrade.yaml



### **6. iOS Configuration**

For iOS, you'll need to manually set up different app icons in Xcode:

1. Open `ios/Runner.xcworkspace` in Xcode
2. Create separate build configurations for each flavor
3. In Build Settings, add user-defined variables:


# Run specific flavors
flutter run --flavor capmarket -t lib/main_capmarket.dart
flutter run --flavor ellitefx -t lib/main_ellitefx.dart
flutter run --flavor nestpip -t lib/main_nestpip.dart
flutter run --flavor pipzomarket -t lib/main_pipzomarket.dart
flutter run --flavor primeforex -t lib/main_prime_forex.dart
flutter run --flavor righttrade -t lib/main_right_trade.dart
flutter run --flavor innovixcapital -t lib/main_innovixcapital.dart
flutter run --flavor forexmt -t lib/main_forexmt.dart
flutter run --flavor ivrfx -t lib/main_ivrfx.dart
flutter run --flavor enzo4ex -t lib/main_enzo4ex.dart
flutter run --flavor fynixfxweb -t lib/main_fynixfxweb.dart
flutter run --flavor sarthifxm -t lib/main_sarthifxm.dart
flutter run --flavor finflymarket -t lib/main_finfly_market.dart
flutter run --flavor worldonecapital -t lib/main_world_one_capital.dart
flutter run --flavor capyngen -t lib/main_capyngen.dart
flutter run --flavor ganecapitalfx -t lib/main_ganecapitalfx.dart
flutter run --flavor voltfxtrade -t lib/main_voltfxtrade.dart


# Build APKs
flutter build apk --flavor capmarket -t lib/main_capmarket.dart
flutter build apk --flavor ellitefx -t lib/main_ellitefx.dart
flutter build apk --flavor nestpip -t lib/main_nestpip.dart
flutter build apk --flavor pipzomarket -t lib/main_pipzomarket.dart
flutter build apk --flavor primeforex -t lib/main_prime_forex.dart
flutter build apk --flavor righttrade -t lib/main_right_trade.dart
flutter build apk --flavor innovixcapital -t lib/main_innovixcapital.dart
flutter build apk --flavor forexmt -t lib/main_forexmt.dart
flutter build apk --flavor ivrfx -t lib/main_ivrfx.dart
flutter build apk --flavor enzo4ex -t lib/main_enzo4ex.dart
flutter build apk --flavor fynixfxweb -t lib/main_fynixfxweb.dart
flutter build apk --flavor finflymarket -t lib/main_finfly_market.dart
flutter build apk --flavor worldonecapital -t lib/main_world_one_capital.dart
flutter build apk --flavor sarthifxm -t lib/main_sarthifxm.dart
flutter build apk --flavor capyngen -t lib/main_capyngen.dart
flutter build apk --flavor ganecapitalfx -t lib/main_ganecapitalfx.dart
flutter build apk --flavor voltfxtrade -t lib/main_voltfxtrade.dart

# New brokers 

# Zyrotrade
dart pub run flutter_launcher_icons:main -f flutter_launcher_icons-zyrotrade.yaml
dart pub run flutter_native_splash:create --path flutter_native_splash-zyrotrade.yaml
flutter run --flavor zyrotrade -t lib/main_zyrotrade.dart
flutter build apk --flavor zyrotrade -t lib/main_zyrotrade.dart

# Tgrxm
dart pub run flutter_launcher_icons:main -f flutter_launcher_icons-tgrxm.yaml
dart pub run flutter_native_splash:create --path flutter_native_splash-tgrxm.yaml
flutter run --flavor tgrxm -t lib/main_tgrxm.dart
flutter build apk --flavor tgrxm -t lib/main_tgrxm.dart

# Valtradex
dart pub run flutter_launcher_icons:main -f flutter_launcher_icons-valtradex.yaml
dart pub run flutter_native_splash:create --path flutter_native_splash-valtradex.yaml
flutter run --flavor valtradex -t lib/main_valtradex.dart
flutter build apk --flavor valtradex -t lib/main_valtradex.dart

# Livefxm
dart pub run flutter_launcher_icons:main -f flutter_launcher_icons-livefxm.yaml
dart pub run flutter_native_splash:create --path flutter_native_splash-livefxm.yaml
flutter run --flavor livefxm -t lib/main_livefxm.dart
flutter build apk --flavor livefxm -t lib/main_livefxm.dart

# Iglobefx  old __ new ------------> Staar Market
// now it become Staar Market
dart pub run flutter_launcher_icons:main -f flutter_launcher_icons-iglobefx.yaml
dart pub run flutter_native_splash:create --path flutter_native_splash-iglobefx.yaml
flutter run --flavor iglobefx -t lib/main_iglobefx.dart
flutter build apk --flavor iglobefx -t lib/main_iglobefx.dart





# RyvoTrade
dart pub run flutter_launcher_icons:main -f flutter_launcher_icons-ryvotrade.yaml
dart pub run flutter_native_splash:create --path flutter_native_splash-ryvotrade.yaml
flutter run --flavor ryvotrade -t lib/main_ryvotrade.dart
flutter build apk --flavor ryvotrade -t lib/main_ryvotrade.dart



flutter pub run flutter_native_splash:create --path=exness_clone/flutter_native_splash.yaml



# KiteFX
dart pub run flutter_launcher_icons:main -f flutter_launcher_icons-kitefx.yaml
dart pub run flutter_native_splash:create --path flutter_native_splash-kitefx.yaml
flutter run --flavor kitefx -t lib/main_kitefx.dart
flutter build apk --flavor kitefx -t lib/main_kitefx.dart



# BlueGateMarket
dart pub run flutter_launcher_icons:main -f flutter_launcher_icons-bluegatemarket.yaml
dart pub run flutter_native_splash:create --path flutter_native_splash-bluegatemarket.yaml
flutter run --flavor bluegatemarket -t lib/main_bluegatemarket.dart
flutter build apk --flavor bluegatemarket -t lib/main_bluegatemarket.dart


# NMatrixPro
dart pub run flutter_launcher_icons:main -f flutter_launcher_icons-nmatrixpro.yaml
dart pub run flutter_native_splash:create --path flutter_native_splash-nmatrixpro.yaml
flutter run --flavor nmatrixpro -t lib/main_nmatrixpro.dart
flutter build apk --flavor nmatrixpro -t lib/main_nmatrixpro.dart


# FourXTradz ------> 4xtradz
dart pub run flutter_launcher_icons:main -f flutter_launcher_icons-fourxtradz.yaml
dart pub run flutter_native_splash:create --path flutter_native_splash-fourxtradz.yaml
flutter run --flavor fourxtradz -t lib/main_fourxtradz.dart
flutter build apk --flavor fourxtradz -t lib/main_fourxtradz.dart

# Fxcelite
dart pub run flutter_launcher_icons:main -f flutter_launcher_icons-fxcelite.yaml
dart pub run flutter_native_splash:create --path flutter_native_splash-fxcelite.yaml
flutter run --flavor fxcelite -t lib/main_fxcelite.dart
flutter build apk --flavor fxcelite -t lib/main_fxcelite.dart

# agmmarket
dart pub run flutter_launcher_icons:main -f flutter_launcher_icons-agmmarket.yaml
dart pub run flutter_native_splash:create --path flutter_native_splash-agmmarket.yaml

# aoneprimefx
dart pub run flutter_launcher_icons:main -f flutter_launcher_icons-aoneprimefx.yaml
dart pub run flutter_native_splash:create --path flutter_native_splash-aoneprimefx.yaml
flutter run --flavor aoneprimefx -t lib/main_aoneprimefx.dart
flutter build apk --flavor aoneprimefx -t lib/main_aoneprimefx.dart

# Vintageprime
dart pub run flutter_launcher_icons:main -f flutter_launcher_icons-vintageprimefx.yaml
dart pub run flutter_native_splash:create --path flutter_native_splash-vintageprimefx.yaml
flutter run --flavor vintageprimefx -t lib/main_vintageprimefx.dart
flutter build apk --flavor vintageprimefx -t lib/main_vintageprimefx.dart

# Aurelianglobal
dart pub run flutter_launcher_icons:main -f flutter_launcher_icons-aurelianglobal.yaml
dart pub run flutter_native_splash:create --path flutter_native_splash-aurelianglobal.yaml
flutter run --flavor aurelianglobal -t lib/main_aurelianglobal.dart
flutter build apk --flavor aurelianglobal -t lib/main_aurelianglobal.dart