import 'flavor_config.dart';

class FlavorAssets {
  static String get logoPath {
    switch (FlavorConfig.appFlavor) {
      case Flavor.capmarket:
        return 'assets/image/capmarket/splash.png';
      case Flavor.ellitefx:
        return 'assets/image/ellitefx/splash.png';
      case Flavor.nestpip:
        return 'assets/image/nestpip/splash.png';
      case Flavor.pipzomarket:
        return 'assets/image/pipzomarket/splash.png';
      case Flavor.righttrade:
        return 'assets/image/right-trade/splash.png';
      case Flavor.primeforex:
        return 'assets/image/prime-forex-market/splash.png';
      case Flavor.innovixcapital:
        return 'assets/image/innovixcapital/splash.jpg';
      case Flavor.forexmt:
        return 'assets/image/forexmt/splash.jpg';
      case Flavor.ivrfx:
        return 'assets/image/ivrfx/splash.jpg';
      case Flavor.enzo4ex:
        return 'assets/image/enzo4ex/splash.jpg';
      case Flavor.fynixfxweb:
        return 'assets/image/fynixfxweb/splash.jpg';
      case Flavor.finflymarket:
        return 'assets/image/finfly/splash.png';
      case Flavor.worldonecapital:
        return 'assets/image/world-one-capital/splash.png';
      case Flavor.sarthifxm:
        return 'assets/image/sarthifxm/splash.png';
      case Flavor.capyngen:
        return 'assets/image/capyngen/splash.png';
      case Flavor.ganecapitalfx:
        return 'assets/image/ganecapitalfx/splash.png';
      case Flavor.voltfxtrade:
        return 'assets/image/voltfxtrade/splash.png';
      case Flavor.zyrotrade:
        return 'assets/image/zyrotrade/splash.png';
      case Flavor.tgrxm:
        return 'assets/image/tgrxm/splash.png';
      case Flavor.valtradex:
        return 'assets/image/valtradex/splash.png';
      case Flavor.livefxm:
        return 'assets/image/livefxm/splash.png';
      case Flavor.iglobefx:
        return 'assets/image/iglobefx/splash.png';
      case Flavor.ryvotrade:
        return 'assets/image/ryvotrade/splash.png';
      case Flavor.kitefx:
        return 'assets/image/kitefx/splash.png';
      case Flavor.bluegatemarket:
        return 'assets/image/bluegatemarket/splash.png';
      case Flavor.nmatrixpro:
        return 'assets/image/nmatrixpro/splash.png';
      case Flavor.fourxtradz:
        return 'assets/image/fourxtradz/splash.png';
      case Flavor.fxcelite:
        return 'assets/image/fxcelite/splash.png';

      default:
        return 'assets/image/default/logo.png';
    }
  }

  static String get appName {
    switch (FlavorConfig.appFlavor) {
      case Flavor.capmarket:
        return 'CapMarket';
      case Flavor.ellitefx:
        return 'EliteFX';
      case Flavor.nestpip:
        return 'NestPip';
      case Flavor.pipzomarket:
        return 'PipzoMarket';
      case Flavor.righttrade:
        return 'Right Trade';
      case Flavor.primeforex:
        return 'Prime Forex';
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
        return 'Finfly Market';
      case Flavor.worldonecapital:
        return 'World One Capital';
      case Flavor.sarthifxm:
        return 'SarthiFXM';
      case Flavor.capyngen:
        return 'Capyngen';
      case Flavor.ganecapitalfx:
        return 'Gane Capital FX';
      case Flavor.voltfxtrade:
        return 'Volt FX Trade';
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
      // return 'iGlobeFX';
      case Flavor.ryvotrade:
        return 'RyvoTrade';
      case Flavor.kitefx:
        return 'KiteFX';
      case Flavor.bluegatemarket:
        return 'BlueGate Market';
      case Flavor.nmatrixpro:
        return 'NMatrixPro';
      case Flavor.fourxtradz:
        return '4xTradZ';
      case Flavor.fxcelite:
        return 'FxceElite';

      default:
        return 'Default App';
    }
  }

  static String get platformName {
    switch (FlavorConfig.appFlavor) {
      case Flavor.capmarket:
        return 'capMarkets';
      case Flavor.ellitefx:
        return 'eliteFx';
      case Flavor.nestpip:
        return 'nestPip';
      case Flavor.pipzomarket:
        return 'pipzoMarket';
      case Flavor.righttrade:
        return 'rightTradeCapital';
      case Flavor.primeforex:
        return 'primeForexMarket';
      case Flavor.innovixcapital:
        return 'innovixCapital';
      case Flavor.forexmt:
        return 'forexMT';
      case Flavor.ivrfx:
        return 'ivrFX';
      case Flavor.enzo4ex:
        return 'enzo4Ex';
      case Flavor.fynixfxweb:
        return 'fynixFXWeb';
      case Flavor.finflymarket:
        return 'FinFlyMK';
      case Flavor.worldonecapital:
        return 'worldOneCapital';
      case Flavor.sarthifxm:
        return 'sarthiFXM';
      case Flavor.capyngen:
        return 'capyngen';
      case Flavor.ganecapitalfx:
        return 'ganecapitalfx';
      case Flavor.voltfxtrade:
        // return 'voltfxtrade';
        return "voltfx";
      case Flavor.zyrotrade:
        return 'zyrotrade';
      case Flavor.tgrxm:
        return 'tgrxm';
      case Flavor.valtradex:
        return 'valtradex';
      case Flavor.livefxm:
        return 'livefxm';
      case Flavor.iglobefx:
        return 'iglobefx';
      case Flavor.ryvotrade:
        return 'ryvoTrade';
      case Flavor.kitefx:
        return 'kitefx';
      case Flavor.bluegatemarket:
        return 'blueGateMarket';
      case Flavor.nmatrixpro:
        return 'nmatrixPro';
      case Flavor.fourxtradz:
        return '4xTradZ';
      case Flavor.fxcelite:
        return 'FxceElite';
      default:
        return 'defaultApp';
    }
  }
}
