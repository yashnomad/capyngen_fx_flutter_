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
  fynixfxweb,
  finflymarket,
  worldonecapital,
  sarthifxm,
  capyngen,
  ganecapitalfx,
  voltfxtrade,
  zyrotrade,
  tgrxm,
  valtradex,
  livefxm,
  iglobefx,
  ryvotrade,
  kitefx,
  bluegatemarket,
  nmatrixpro,
  fourxtradz,
}

class FlavorConfig {
  static Flavor? appFlavor;
  static String get name => appFlavor?.name ?? '';

  static String get title {
    switch (appFlavor) {
      case Flavor.capmarket:
        return 'Capmarket';
      case Flavor.ellitefx:
        return 'ElliteFX';
      case Flavor.nestpip:
        return 'NestPip';
      case Flavor.pipzomarket:
        return 'PipzoMarket';
      case Flavor.righttrade:
        return 'RightTradeCapital';
      case Flavor.primeforex:
        return 'PrimeForexMarket';
      case Flavor.innovixcapital:
        return 'Innovix Capital';
      case Flavor.forexmt:
        return 'ForexMT';
      case Flavor.ivrfx:
        return 'IVRFX';
      case Flavor.enzo4ex:
        return 'Enzo4Ex';
      case Flavor.fynixfxweb:
        return 'FynixFXWeb';
      case Flavor.finflymarket:
        return 'FinflyMarkets';
      case Flavor.worldonecapital:
        return 'WorldOneCapital';
      case Flavor.sarthifxm:
        return 'SarthiFXM';
      case Flavor.capyngen:
        return 'Capyngen';
      case Flavor.ganecapitalfx:
        return 'GanaCapitalFX';
      case Flavor.voltfxtrade:
        return 'VoltFXTrade';
      case Flavor.zyrotrade:
        return 'ZyroTrade';
      case Flavor.tgrxm:
        return 'TGRXM';
      case Flavor.valtradex:
        return 'Valtradex';
      case Flavor.livefxm:
        return 'LiveFXM';
      case Flavor.iglobefx:
        return 'Staar Market';
      // return 'IGlobeFX';
      case Flavor.ryvotrade:
        return 'RyvoTrade';
      case Flavor.kitefx:
        return 'KiteFX';
      case Flavor.bluegatemarket:
        return 'BlueGateMarket';
      case Flavor.nmatrixpro:
        return 'NMatrixPro';
      case Flavor.fourxtradz:
        return '4xTradZ';

      default:
        return '';
    }
  }

  static String get baseUrl {
    return 'https://api.capyngen.us/user';
  }

  static String get packageName {
    switch (appFlavor) {
      case Flavor.capmarket:
        return 'com.capyngen.capmarket';
      case Flavor.ellitefx:
        return 'com.ellitefx.trader';
      case Flavor.nestpip:
        return 'com.nestpip.trading';
      case Flavor.pipzomarket:
        return 'com.pipzomarket.trading';
      case Flavor.righttrade:
        return 'com.righttradecapital';
      case Flavor.primeforex:
        return 'com.primeforexmarket';
      case Flavor.innovixcapital:
        return 'com.innovixcapital.trading';
      case Flavor.forexmt:
        return 'com.forexmt.trading';
      case Flavor.ivrfx:
        return 'com.ivrfx.trading';
      case Flavor.enzo4ex:
        return 'com.enzo4ex.trading';
      case Flavor.fynixfxweb:
        return 'com.fynixfxweb.trading';
      case Flavor.finflymarket:
        return 'com.finflymarket.trading';
      case Flavor.worldonecapital:
        return 'com.worldonecapital.trading';
      case Flavor.sarthifxm:
        return 'com.sarthifxm.trading';
      case Flavor.capyngen:
        return 'com.capyngen.trading';
      case Flavor.ganecapitalfx:
        return 'com.ganecapitalfx.trading';
      case Flavor.voltfxtrade:
        return 'com.voltfxtrade.trading';
      case Flavor.zyrotrade:
        return 'com.zyrotrade.trading';
      case Flavor.tgrxm:
        return 'com.tgrxm.trading';
      case Flavor.valtradex:
        return 'com.valtradex.trading';
      case Flavor.livefxm:
        return 'com.livefxm.trading';
      case Flavor.iglobefx:
        return 'com.iglobefx.trading';
      case Flavor.ryvotrade:
        return 'com.ryvotrade.trading';
      case Flavor.kitefx:
        return 'com.kitefx.trading';
      case Flavor.bluegatemarket:
        return 'com.bluegatemarket.trading';
      case Flavor.nmatrixpro:
        return 'com.nmatrixpro.trading';
      case Flavor.fourxtradz:
        return 'com.4xtradz.trading';

      default:
        return "com.example.exness_clone";
    }
  }

  static Map<String, dynamic> get appConfig {
    switch (appFlavor) {
      case Flavor.capmarket:
        return {
          'primaryColor': 0xFFFFFFF,
          'accentColor': 0xFFFFFFF,
          'logoPath': 'assets/image/capmarket/logo.png',
          'splashPath': 'assets/image/capmarket/splash.png',
        };
      case Flavor.ellitefx:
        return {
          'primaryColor': 0xFFFFFFF,
          'accentColor': 0xFFFFFFF,
          'logoPath': 'assets/image/ellitefx/logo.png',
          'splashPath': 'assets/image/ellitefx/splash.png',
        };
      case Flavor.nestpip:
        return {
          'primaryColor': 0xFFFFFFF,
          'accentColor': 0xFFFFFFF,
          'logoPath': 'assets/image/nestpip/logo.png',
          'splashPath': 'assets/image/nestpip/splash.png',
        };
      case Flavor.pipzomarket:
        return {
          'primaryColor': 0xFFFFFFF,
          'accentColor': 0xFFFFFFF,
          'logoPath': 'assets/image/pipzomarket/logo.png',
          'splashPath': 'assets/image/pipzomarket/splash.png',
        };
      case Flavor.righttrade:
        return {
          'primaryColor': 0xFFFFFFF,
          'accentColor': 0xFFFFFFF,
          'logoPath': 'assets/image/right-trade/logo.png',
          'splashPath': 'assets/image/right-trade/splash.png',
        };
      case Flavor.primeforex:
        return {
          'primaryColor': 0xFFFFFFF,
          'accentColor': 0xFFFFFFF,
          'logoPath': 'assets/image/prime-forex-market/logo.png',
          'splashPath': 'assets/image/prime-forex-market/splash.png',
        };
      case Flavor.innovixcapital:
        return {
          'primaryColor': 0xFFFFFFF,
          'accentColor': 0xFFFFFFF,
          'logoPath': 'assets/image/innovixcapital/logo.png',
          'splashPath': 'assets/image/innovixcapital/splash.png',
        };
      case Flavor.forexmt:
        return {
          'primaryColor': 0xFFFFFFF,
          'accentColor': 0xFFFFFFF,
          'logoPath': 'assets/image/forexmt/logo.jpg',
          'splashPath': 'assets/image/forexmt/splash.jpg',
        };
      case Flavor.ivrfx:
        return {
          'primaryColor': 0xFFFFFFF,
          'accentColor': 0xFFFFFFF,
          'logoPath': 'assets/image/ivrfx/logo.jpg',
          'splashPath': 'assets/image/ivrfx/splash.jpg',
        };
      case Flavor.enzo4ex:
        return {
          'primaryColor': 0xFFFFFFF,
          'accentColor': 0xFFFFFFF,
          'logoPath': 'assets/image/enzo4ex/logo.jpg',
          'splashPath': 'assets/image/enzo4ex/splash.jpg',
        };
      case Flavor.fynixfxweb:
        return {
          'primaryColor': 0xFFFFFFF,
          'accentColor': 0xFFFFFFF,
          'logoPath': 'assets/image/fynixfxweb/logo.jpg',
          'splashPath': 'assets/image/fynixfxweb/splash.jpg',
        };
      case Flavor.finflymarket:
        return {
          'primaryColor': 0xFFFFFFF,
          'accentColor': 0xFFFFFFF,
          'logoPath': 'assets/image/finfly/logo.png',
          'splashPath': 'assets/image/finfly/splash.png',
        };

      case Flavor.worldonecapital:
        return {
          'primaryColor': 0xFFFFFFF,
          'accentColor': 0xFFFFFFF,
          'logoPath': 'assets/image/world-one-capital/logo.png',
          'splashPath': 'assets/image/world-one-capital/splash.png',
        };
      case Flavor.sarthifxm:
        return {
          'primaryColor': 0xFFFFFFF,
          'accentColor': 0xFFFFFFF,
          'logoPath': 'assets/image/sarthifxm/logo.png',
          'splashPath': 'assets/image/sarthifxm/splash.png',
        };
      case Flavor.capyngen:
        return {
          'primaryColor': 0xFFFFFFF,
          'accentColor': 0xFFFFFFF,
          'logoPath': 'assets/image/capyngen/logo.png',
          'splashPath': 'assets/image/capyngen/splash.png',
        };
      case Flavor.ganecapitalfx:
        return {
          'primaryColor': 0xFFFFFFF,
          'accentColor': 0xFFFFFFF,
          'logoPath': 'assets/image/ganecapitalfx/logo.png',
          'splashPath': 'assets/image/ganecapitalfx/splash.png',
        };
      case Flavor.voltfxtrade:
        return {
          'primaryColor': 0xFFFFFFF,
          'accentColor': 0xFFFFFFF,
          'logoPath': 'assets/image/voltfxtrade/logo.png',
          'splashPath': 'assets/image/voltfxtrade/splash.png',
        };

      case Flavor.zyrotrade:
        return {
          'primaryColor': 0xFFFFFFF,
          'accentColor': 0xFFFFFFF,
          'logoPath': 'assets/image/zyrotrade/logo.png',
          'splashPath': 'assets/image/zyrotrade/splash.png',
        };
      case Flavor.tgrxm:
        return {
          'primaryColor': 0xFFFFFFF,
          'accentColor': 0xFFFFFFF,
          'logoPath': 'assets/image/tgrxm/logo.png',
          'splashPath': 'assets/image/tgrxm/splash.png',
        };
      case Flavor.valtradex:
        return {
          'primaryColor': 0xFFFFFFF,
          'accentColor': 0xFFFFFFF,
          'logoPath': 'assets/image/valtradex/logo.png',
          'splashPath': 'assets/image/valtradex/splash.png',
        };
      case Flavor.livefxm:
        return {
          'primaryColor': 0xFFFFFFF,
          'accentColor': 0xFFFFFFF,
          'logoPath': 'assets/image/livefxm/logo.png',
          'splashPath': 'assets/image/livefxm/splash.png',
        };
      case Flavor.iglobefx:
        return {
          'primaryColor': 0xFFFFFFF,
          'accentColor': 0xFFFFFFF,
          'logoPath': 'assets/image/iglobefx/logo.png',
          'splashPath': 'assets/image/iglobefx/splash.png',
        };

      case Flavor.ryvotrade:
        return {
          'primaryColor': 0xFFFFFFF,
          'accentColor': 0xFFFFFFF,
          'logoPath': 'assets/image/ryvotrade/logo.png',
          'splashPath': 'assets/image/ryvotrade/splash.png',
        };
      case Flavor.kitefx:
        return {
          'primaryColor': 0xFFFFFFF,
          'accentColor': 0xFFFFFFF,
          'logoPath': 'assets/image/kitefx/logo.png',
          'splashPath': 'assets/image/kitefx/splash.png',
        };
      case Flavor.bluegatemarket:
        return {
          'primaryColor': 0xFFFFFFF,
          'accentColor': 0xFFFFFFF,
          'logoPath': 'assets/image/bluegatemarket/logo.png',
          'splashPath': 'assets/image/bluegatemarket/splash.png',
        };
      case Flavor.nmatrixpro:
        return {
          'primaryColor': 0xFFFFFFF,
          'accentColor': 0xFFFFFFF,
          'logoPath': 'assets/image/nmatrixpro/logo.png',
          'splashPath': 'assets/image/nmatrixpro/splash.png',
        };
      case Flavor.fourxtradz:
        return {
          'primaryColor': 0xFFFFFFF,
          'accentColor': 0xFFFFFFF,
          'logoPath': 'assets/image/fourxtradz/logo.png',
          'splashPath': 'assets/image/fourxtradz/splash.png',
        };

      default:
        return {};
    }
  }

  static bool get isCapmarket => appFlavor == Flavor.capmarket;
  static bool get isEliteFX => appFlavor == Flavor.ellitefx;
  static bool get isNestPip => appFlavor == Flavor.nestpip;
  static bool get isPipzomarket => appFlavor == Flavor.pipzomarket;
  static bool get isRightTrade => appFlavor == Flavor.righttrade;
  static bool get isPrimeForex => appFlavor == Flavor.primeforex;
  static bool get isInnovixCapital => appFlavor == Flavor.innovixcapital;
  static bool get isForexMT => appFlavor == Flavor.forexmt;
  static bool get isIVRFX => appFlavor == Flavor.ivrfx;
  static bool get isEnzo4Ex => appFlavor == Flavor.enzo4ex;
  static bool get isFynixFXWeb => appFlavor == Flavor.fynixfxweb;
  static bool get isFinflyMarket => appFlavor == Flavor.finflymarket;
  static bool get isWorldOneCapital => appFlavor == Flavor.worldonecapital;
  static bool get isSarthiFXM => appFlavor == Flavor.sarthifxm;
  static bool get isCapyngen => appFlavor == Flavor.capyngen;
  static bool get isGaneCapitalFX => appFlavor == Flavor.ganecapitalfx;
  static bool get isVoltFXTrade => appFlavor == Flavor.voltfxtrade;
  static bool get isZyroTrade => appFlavor == Flavor.zyrotrade;
  static bool get isTGRXM => appFlavor == Flavor.tgrxm;
  static bool get isValtradex => appFlavor == Flavor.valtradex;
  static bool get isLiveFXM => appFlavor == Flavor.livefxm;
  static bool get isIGlobeFX => appFlavor == Flavor.iglobefx;
  static bool get isRyvoTrade => appFlavor == Flavor.ryvotrade;
  static bool get isKiteFx => appFlavor == Flavor.kitefx;
  static bool get isBlueGateMarket => appFlavor == Flavor.bluegatemarket;
  static bool get isNMatrixPro => appFlavor == Flavor.nmatrixpro;
  static bool get isFourxTradz => appFlavor == Flavor.fourxtradz;
}
