import 'package:exness_clone/theme/blue_gate_market_colors.dart';
import 'package:exness_clone/theme/capyngen_colors.dart';
import 'package:exness_clone/theme/finfly_market_colors.dart';
import 'package:exness_clone/theme/fourxtradz_colors.dart';
import 'package:exness_clone/theme/fxcelite_colors.dart';
import 'package:exness_clone/theme/ganecapitalx_colors.dart';
import 'package:exness_clone/theme/kitefx_colors.dart';
import 'package:exness_clone/theme/pipzo_colors.dart';
import 'package:exness_clone/theme/prime_forex_color.dart';
import 'package:exness_clone/theme/right_trade_color.dart';
import 'package:exness_clone/theme/ivrfx_colors.dart';
import 'package:exness_clone/theme/innovixcapital_colors.dart';
import 'package:exness_clone/theme/flynix_colors.dart';
import 'package:exness_clone/theme/forexmt_colors.dart';
import 'package:exness_clone/theme/enzo4ex_colors.dart';
import 'package:exness_clone/theme/ryvo_trade_colors.dart';
import 'package:exness_clone/theme/sarthifxm_color.dart';
import 'package:exness_clone/theme/tgrxm_colors.dart';
import 'package:exness_clone/theme/valtradex_colors.dart';
import 'package:exness_clone/theme/vintageprimefx_colors.dart';
import 'package:exness_clone/theme/voltfxtrade_colors.dart';
import 'package:exness_clone/theme/world_one_capital_colors.dart';
import 'package:exness_clone/theme/zyrotrade_colors.dart';
import 'package:flutter/material.dart';
import '../config/flavor_config.dart';
import 'capmarket_colors.dart';
import 'ellitefx_colors.dart';
import 'iglobefx_colors.dart';
import 'livefxm_colors.dart';
import 'nestpip_colors.dart';
import 'nmatrixpro_colors.dart';

class AppFlavorColor {
  static Color _getColor({
    required Color capmarket,
    required Color ellitefx,
    required Color nestpip,
    required Color pipzo,
    required Color righttrade,
    required Color primeforex,
    required Color ivrfx,
    required Color innovixcapital,
    required Color flynix,
    required Color forexmt,
    required Color enzo4ex,
    required Color finflymarket,
    required Color worldonecapital,
    required Color sarthifxm,
    required Color capyngen,
    required Color voltfxtrade,
    required Color ganecapitalfx,
    required Color zyrotrade,
    required Color tgrxm,
    required Color valtradex,
    required Color livefxm,
    required Color iglobefx,
    required Color ryvotrade,
    required Color kitefx,
    required Color bluegatemarket,
    required Color nmatrixpro,
    required Color fourxtradz,
    required Color fxcelite,
    required Color vintageprimefx,
    required Color aoneprimefx,
    required Color aurelianglobal,
  }) {
    switch (FlavorConfig.appFlavor) {
      case Flavor.capmarket:
        return capmarket;
      case Flavor.ellitefx:
        return ellitefx;
      case Flavor.nestpip:
        return nestpip;
      case Flavor.pipzomarket:
        return pipzo;
      case Flavor.righttrade:
        return righttrade;
      case Flavor.primeforex:
        return primeforex;
      case Flavor.ivrfx:
        return ivrfx;
      case Flavor.innovixcapital:
        return innovixcapital;
      case Flavor.fynixfxweb:
        return flynix;
      case Flavor.forexmt:
        return forexmt;
      case Flavor.enzo4ex:
        return enzo4ex;
      case Flavor.finflymarket:
        return finflymarket;
      case Flavor.worldonecapital:
        return worldonecapital;
      case Flavor.sarthifxm:
        return sarthifxm;
      case Flavor.capyngen:
        return capyngen;
      case Flavor.ganecapitalfx:
        return ganecapitalfx;
      case Flavor.voltfxtrade:
        return voltfxtrade;
      case Flavor.zyrotrade:
        return zyrotrade;
      case Flavor.tgrxm:
        return tgrxm;
      case Flavor.valtradex:
        return valtradex;
      case Flavor.livefxm:
        return livefxm;
      case Flavor.iglobefx:
        return iglobefx;
      case Flavor.ryvotrade:
        return ryvotrade;
      case Flavor.kitefx:
        return kitefx;
      case Flavor.bluegatemarket:
        return bluegatemarket;
      case Flavor.nmatrixpro:
        return nmatrixpro;
      case Flavor.fourxtradz:
        return fourxtradz;
      case Flavor.fxcelite:
        return fxcelite;
      case Flavor.vintageprimefx:
        return vintageprimefx;
      case Flavor.aoneprimefx:
        return aoneprimefx;
      case Flavor.aurelianglobal:
        return aurelianglobal;
      default:
        return capmarket;
    }
  }

  static Color get background => _getColor(
        capmarket: CapMarketColors.bg,
        ellitefx: ElliteFxColors.bg,
        nestpip: NestPipColors.bg,
        pipzo: PipzoColors.bg,
        righttrade: RightTradeColors.bg,
        primeforex: PrimeForexColors.bg,
        ivrfx: IvrfxColors.bg,
        innovixcapital: InnovixcapitalColors.bg,
        flynix: FlynixColors.bg,
        forexmt: ForexmtColors.bg,
        enzo4ex: Enzo4exColors.bg,
        finflymarket: FinFlyMarketColors.bg,
        worldonecapital: WorldOneCapitalColors.bg,
        sarthifxm: SarthifxmColor.bg,
        capyngen: CapyngenColors.bg,
        ganecapitalfx: GaneCapitalFxColors.bg,
        voltfxtrade: VoltFxTradeColors.bg,
        zyrotrade: ZyrotradeColors.bg,
        iglobefx: IglobefxColors.bg,
        tgrxm: TgrxmColors.bg,
        valtradex: ValtradexColors.bg,
        livefxm: LivefxmColors.bg,
        ryvotrade: RyvoTradeColors.bg,
        kitefx: KiteFxColors.bg,
        bluegatemarket: BlueGateMarketColors.bg,
        nmatrixpro: NMatrixProColors.bg,
        fourxtradz: FourXTradzColors.bg,
        fxcelite: FxceliteColors.bg,
        vintageprimefx: VintagePrimeFxColors.bg,
        aoneprimefx: VintagePrimeFxColors.bg,
        aurelianglobal: VintagePrimeFxColors.bg,
      );

  static Color get cardBackground => _getColor(
        capmarket: CapMarketColors.cardBg,
        ellitefx: ElliteFxColors.cardBg,
        nestpip: NestPipColors.cardBg,
        pipzo: PipzoColors.cardBg,
        righttrade: RightTradeColors.cardBg,
        primeforex: PrimeForexColors.cardBg,
        ivrfx: IvrfxColors.cardBg,
        innovixcapital: InnovixcapitalColors.cardBg,
        flynix: FlynixColors.cardBg,
        forexmt: ForexmtColors.cardBg,
        enzo4ex: Enzo4exColors.cardBg,
        finflymarket: FinFlyMarketColors.cardBg,
        worldonecapital: WorldOneCapitalColors.cardBg,
        sarthifxm: SarthifxmColor.cardBg,
        capyngen: CapyngenColors.cardBg,
        ganecapitalfx: GaneCapitalFxColors.cardBg,
        voltfxtrade: VoltFxTradeColors.cardBg,
        zyrotrade: ZyrotradeColors.cardBg,
        iglobefx: IglobefxColors.cardBg,
        tgrxm: TgrxmColors.cardBg,
        valtradex: ValtradexColors.cardBg,
        livefxm: LivefxmColors.cardBg,
        ryvotrade: RyvoTradeColors.cardBg,
        kitefx: KiteFxColors.cardBg,
        bluegatemarket: BlueGateMarketColors.cardBg,
        nmatrixpro: NMatrixProColors.cardBg,
        fourxtradz: FourXTradzColors.cardBg,
        fxcelite: FxceliteColors.cardBg,
        vintageprimefx: VintagePrimeFxColors.cardBg,
        aoneprimefx: VintagePrimeFxColors.cardBg,
        aurelianglobal: VintagePrimeFxColors.cardBg,
      );

  static Color get primary => _getColor(
        capmarket: CapMarketColors.primary,
        ellitefx: ElliteFxColors.primary,
        nestpip: NestPipColors.primary,
        pipzo: PipzoColors.primary,
        righttrade: RightTradeColors.primary,
        primeforex: PrimeForexColors.primary,
        ivrfx: IvrfxColors.primary,
        innovixcapital: InnovixcapitalColors.primary,
        flynix: FlynixColors.primary,
        forexmt: ForexmtColors.primary,
        enzo4ex: Enzo4exColors.primary,
        finflymarket: FinFlyMarketColors.primary,
        worldonecapital: WorldOneCapitalColors.primary,
        sarthifxm: SarthifxmColor.primary,
        capyngen: CapyngenColors.primary,
        ganecapitalfx: GaneCapitalFxColors.primary,
        voltfxtrade: VoltFxTradeColors.primary,
        zyrotrade: ZyrotradeColors.primary,
        iglobefx: IglobefxColors.primary,
        tgrxm: TgrxmColors.primary,
        valtradex: ValtradexColors.primary,
        livefxm: LivefxmColors.primary,
        ryvotrade: RyvoTradeColors.primary,
        kitefx: KiteFxColors.primary,
        bluegatemarket: BlueGateMarketColors.primary,
        nmatrixpro: NMatrixProColors.primary,
        fourxtradz: FourXTradzColors.primary,
        fxcelite: FxceliteColors.primary,
        vintageprimefx: VintagePrimeFxColors.primary,
        aoneprimefx: VintagePrimeFxColors.primary,
        aurelianglobal: VintagePrimeFxColors.primary,
      );
  static Color get secondary => _getColor(
        capmarket: CapMarketColors.secondary,
        ellitefx: ElliteFxColors.secondary,
        nestpip: NestPipColors.secondary,
        pipzo: PipzoColors.secondary,
        righttrade: RightTradeColors.secondary,
        primeforex: PrimeForexColors.secondary,
        ivrfx: IvrfxColors.secondary,
        innovixcapital: InnovixcapitalColors.secondary,
        flynix: FlynixColors.secondary,
        forexmt: ForexmtColors.secondary,
        enzo4ex: Enzo4exColors.secondary,
        finflymarket: FinFlyMarketColors.secondary,
        worldonecapital: WorldOneCapitalColors.secondary,
        sarthifxm: SarthifxmColor.secondary,
        capyngen: CapyngenColors.secondary,
        ganecapitalfx: GaneCapitalFxColors.secondary,
        voltfxtrade: VoltFxTradeColors.secondary,
        zyrotrade: ZyrotradeColors.secondary,
        iglobefx: IglobefxColors.secondary,
        tgrxm: TgrxmColors.secondary,
        valtradex: ValtradexColors.secondary,
        livefxm: LivefxmColors.secondary,
        ryvotrade: RyvoTradeColors.secondary,
        kitefx: KiteFxColors.secondary,
        bluegatemarket: BlueGateMarketColors.secondary,
        nmatrixpro: NMatrixProColors.secondary,
        fourxtradz: FourXTradzColors.secondary,
        fxcelite: FxceliteColors.secondary,
        vintageprimefx: VintagePrimeFxColors.secondary,
        aoneprimefx: VintagePrimeFxColors.secondary,
        aurelianglobal: VintagePrimeFxColors.secondary,
      );

  static Color get darkPrimary => _getColor(
        capmarket: CapMarketColors.primaryDark,
        ellitefx: ElliteFxColors.primaryDark,
        nestpip: NestPipColors.primaryDark,
        pipzo: PipzoColors.primaryDark,
        righttrade: RightTradeColors.primaryDark,
        primeforex: PrimeForexColors.primaryDark,
        ivrfx: IvrfxColors.primaryDark,
        innovixcapital: InnovixcapitalColors.primaryDark,
        flynix: FlynixColors.primaryDark,
        forexmt: ForexmtColors.primaryDark,
        enzo4ex: Enzo4exColors.primaryDark,
        finflymarket: FinFlyMarketColors.primaryDark,
        worldonecapital: WorldOneCapitalColors.primaryDark,
        sarthifxm: SarthifxmColor.primaryDark,
        capyngen: CapyngenColors.primaryDark,
        ganecapitalfx: GaneCapitalFxColors.primaryDark,
        voltfxtrade: VoltFxTradeColors.primaryDark,
        zyrotrade: ZyrotradeColors.primaryDark,
        iglobefx: IglobefxColors.primaryDark,
        tgrxm: TgrxmColors.primaryDark,
        valtradex: ValtradexColors.primaryDark,
        livefxm: LivefxmColors.primaryDark,
        ryvotrade: RyvoTradeColors.primaryDark,
        kitefx: KiteFxColors.primaryDark,
        bluegatemarket: BlueGateMarketColors.primaryDark,
        nmatrixpro: NMatrixProColors.primaryDark,
        fourxtradz: FourXTradzColors.primaryDark,
        fxcelite: FxceliteColors.primaryDark,
        vintageprimefx: VintagePrimeFxColors.primaryDark,
        aoneprimefx: VintagePrimeFxColors.primaryDark,
        aurelianglobal: VintagePrimeFxColors.primaryDark,
      );

  static Color get theme => primary;

  static Color get button => _getColor(
        capmarket: CapMarketColors.button,
        ellitefx: ElliteFxColors.button,
        nestpip: NestPipColors.button,
        pipzo: PipzoColors.button,
        righttrade: RightTradeColors.button,
        primeforex: PrimeForexColors.button,
        ivrfx: IvrfxColors.button,
        innovixcapital: InnovixcapitalColors.button,
        flynix: FlynixColors.button,
        forexmt: ForexmtColors.button,
        enzo4ex: Enzo4exColors.button,
        finflymarket: FinFlyMarketColors.button,
        worldonecapital: WorldOneCapitalColors.button,
        sarthifxm: SarthifxmColor.button,
        capyngen: CapyngenColors.button,
        ganecapitalfx: GaneCapitalFxColors.button,
        voltfxtrade: VoltFxTradeColors.button,
        zyrotrade: ZyrotradeColors.button,
        iglobefx: IglobefxColors.button,
        tgrxm: TgrxmColors.button,
        valtradex: ValtradexColors.button,
        livefxm: LivefxmColors.button,
        ryvotrade: RyvoTradeColors.button,
        kitefx: KiteFxColors.button,
        bluegatemarket: BlueGateMarketColors.button,
        nmatrixpro: NMatrixProColors.button,
        fourxtradz: FourXTradzColors.button,
        fxcelite: FxceliteColors.button,
        vintageprimefx: VintagePrimeFxColors.button,
        aoneprimefx: VintagePrimeFxColors.button,
        aurelianglobal: VintagePrimeFxColors.button,
      );

  static Color get buttonText => _getColor(
        capmarket: CapMarketColors.buttonText,
        ellitefx: ElliteFxColors.buttonText,
        nestpip: NestPipColors.buttonText,
        pipzo: PipzoColors.buttonText,
        righttrade: RightTradeColors.buttonText,
        primeforex: PrimeForexColors.buttonText,
        ivrfx: IvrfxColors.buttonText,
        innovixcapital: InnovixcapitalColors.buttonText,
        flynix: FlynixColors.buttonText,
        forexmt: ForexmtColors.buttonText,
        enzo4ex: Enzo4exColors.buttonText,
        finflymarket: FinFlyMarketColors.buttonText,
        worldonecapital: WorldOneCapitalColors.buttonText,
        sarthifxm: SarthifxmColor.buttonText,
        capyngen: CapyngenColors.buttonText,
        ganecapitalfx: GaneCapitalFxColors.buttonText,
        voltfxtrade: VoltFxTradeColors.buttonText,
        zyrotrade: ZyrotradeColors.buttonText,
        iglobefx: IglobefxColors.buttonText,
        tgrxm: TgrxmColors.buttonText,
        valtradex: ValtradexColors.buttonText,
        livefxm: LivefxmColors.buttonText,
        ryvotrade: RyvoTradeColors.buttonText,
        kitefx: KiteFxColors.buttonText,
        bluegatemarket: BlueGateMarketColors.buttonText,
        nmatrixpro: NMatrixProColors.buttonText,
        fourxtradz: FourXTradzColors.buttonText,
        fxcelite: FxceliteColors.buttonText,
        vintageprimefx: VintagePrimeFxColors.buttonText,
        aoneprimefx: VintagePrimeFxColors.buttonText,
        aurelianglobal: VintagePrimeFxColors.buttonText,
      );

  static Color get text => _getColor(
        capmarket: CapMarketColors.text,
        ellitefx: ElliteFxColors.text,
        nestpip: NestPipColors.text,
        pipzo: PipzoColors.text,
        righttrade: RightTradeColors.text,
        primeforex: PrimeForexColors.text,
        ivrfx: IvrfxColors.text,
        innovixcapital: InnovixcapitalColors.text,
        flynix: FlynixColors.text,
        forexmt: ForexmtColors.text,
        enzo4ex: Enzo4exColors.text,
        finflymarket: FinFlyMarketColors.text,
        worldonecapital: WorldOneCapitalColors.text,
        sarthifxm: SarthifxmColor.text,
        capyngen: CapyngenColors.text,
        ganecapitalfx: GaneCapitalFxColors.text,
        voltfxtrade: VoltFxTradeColors.text,
        zyrotrade: ZyrotradeColors.text,
        iglobefx: IglobefxColors.text,
        tgrxm: TgrxmColors.text,
        valtradex: ValtradexColors.text,
        livefxm: LivefxmColors.text,
        ryvotrade: RyvoTradeColors.text,
        kitefx: KiteFxColors.text,
        bluegatemarket: BlueGateMarketColors.text,
        nmatrixpro: NMatrixProColors.text,
        fourxtradz: FourXTradzColors.text,
        fxcelite: FxceliteColors.text,
        vintageprimefx: VintagePrimeFxColors.text,
        aoneprimefx: VintagePrimeFxColors.text,
        aurelianglobal: VintagePrimeFxColors.text,
      );

  static Color get headerText => _getColor(
        capmarket: CapMarketColors.headerText,
        ellitefx: ElliteFxColors.headerText,
        nestpip: NestPipColors.headerText,
        pipzo: PipzoColors.headerText,
        righttrade: RightTradeColors.headerText,
        primeforex: PrimeForexColors.headerText,
        ivrfx: IvrfxColors.headerText,
        innovixcapital: InnovixcapitalColors.headerText,
        flynix: FlynixColors.headerText,
        forexmt: ForexmtColors.headerText,
        enzo4ex: Enzo4exColors.headerText,
        finflymarket: FinFlyMarketColors.headerText,
        worldonecapital: WorldOneCapitalColors.headerText,
        sarthifxm: SarthifxmColor.headerText,
        capyngen: CapyngenColors.headerText,
        ganecapitalfx: GaneCapitalFxColors.headerText,
        voltfxtrade: VoltFxTradeColors.headerText,
        zyrotrade: ZyrotradeColors.headerText,
        iglobefx: IglobefxColors.headerText,
        tgrxm: TgrxmColors.headerText,
        valtradex: ValtradexColors.headerText,
        livefxm: LivefxmColors.headerText,
        ryvotrade: RyvoTradeColors.headerText,
        kitefx: KiteFxColors.headerText,
        bluegatemarket: BlueGateMarketColors.headerText,
        nmatrixpro: NMatrixProColors.headerText,
        fourxtradz: FourXTradzColors.headerText,
        fxcelite: FxceliteColors.headerText,
        vintageprimefx: VintagePrimeFxColors.headerText,
        aoneprimefx: VintagePrimeFxColors.headerText,
        aurelianglobal: VintagePrimeFxColors.headerText,
      );

  static Color get icon => _getColor(
        capmarket: CapMarketColors.icon,
        ellitefx: ElliteFxColors.icon,
        nestpip: NestPipColors.icon,
        pipzo: PipzoColors.icon,
        righttrade: RightTradeColors.icon,
        primeforex: PrimeForexColors.icon,
        ivrfx: IvrfxColors.icon,
        innovixcapital: InnovixcapitalColors.icon,
        flynix: FlynixColors.icon,
        forexmt: ForexmtColors.icon,
        enzo4ex: Enzo4exColors.icon,
        finflymarket: FinFlyMarketColors.icon,
        worldonecapital: WorldOneCapitalColors.icon,
        sarthifxm: SarthifxmColor.icon,
        capyngen: CapyngenColors.icon,
        ganecapitalfx: GaneCapitalFxColors.icon,
        voltfxtrade: VoltFxTradeColors.icon,
        zyrotrade: ZyrotradeColors.icon,
        iglobefx: IglobefxColors.icon,
        tgrxm: TgrxmColors.icon,
        valtradex: ValtradexColors.icon,
        livefxm: LivefxmColors.icon,
        ryvotrade: RyvoTradeColors.icon,
        kitefx: KiteFxColors.icon,
        bluegatemarket: BlueGateMarketColors.icon,
        nmatrixpro: NMatrixProColors.icon,
        fourxtradz: FourXTradzColors.icon,
        fxcelite: FxceliteColors.icon,
        vintageprimefx: VintagePrimeFxColors.icon,
        aoneprimefx: VintagePrimeFxColors.icon,
        aurelianglobal: VintagePrimeFxColors.icon,
      );

  static Color get iconSecondary => _getColor(
        capmarket: CapMarketColors.iconSecondary,
        ellitefx: ElliteFxColors.iconSecondary,
        nestpip: NestPipColors.iconSecondary,
        pipzo: PipzoColors.iconSecondary,
        righttrade: RightTradeColors.iconSecondary,
        primeforex: PrimeForexColors.iconSecondary,
        ivrfx: IvrfxColors.iconSecondary,
        innovixcapital: InnovixcapitalColors.iconSecondary,
        flynix: FlynixColors.iconSecondary,
        forexmt: ForexmtColors.iconSecondary,
        enzo4ex: Enzo4exColors.iconSecondary,
        finflymarket: FinFlyMarketColors.iconSecondary,
        worldonecapital: WorldOneCapitalColors.iconSecondary,
        sarthifxm: SarthifxmColor.iconSecondary,
        capyngen: CapyngenColors.iconSecondary,
        ganecapitalfx: GaneCapitalFxColors.iconSecondary,
        voltfxtrade: VoltFxTradeColors.iconSecondary,
        zyrotrade: ZyrotradeColors.iconSecondary,
        iglobefx: IglobefxColors.iconSecondary,
        tgrxm: TgrxmColors.iconSecondary,
        valtradex: ValtradexColors.iconSecondary,
        livefxm: LivefxmColors.iconSecondary,
        ryvotrade: RyvoTradeColors.iconSecondary,
        kitefx: KiteFxColors.iconSecondary,
        bluegatemarket: BlueGateMarketColors.iconSecondary,
        nmatrixpro: NMatrixProColors.iconSecondary,
        fourxtradz: FourXTradzColors.iconSecondary,
        fxcelite: FxceliteColors.iconSecondary,
        vintageprimefx: VintagePrimeFxColors.iconSecondary,
        aoneprimefx: VintagePrimeFxColors.iconSecondary,
        aurelianglobal: VintagePrimeFxColors.iconSecondary,
      );

  static Color get shadowColor => _getColor(
        capmarket: CapMarketColors.shadow,
        ellitefx: ElliteFxColors.shadow,
        nestpip: NestPipColors.shadow,
        pipzo: PipzoColors.shadow,
        righttrade: RightTradeColors.shadow,
        primeforex: PrimeForexColors.shadow,
        ivrfx: IvrfxColors.shadow,
        innovixcapital: InnovixcapitalColors.shadow,
        flynix: FlynixColors.shadow,
        forexmt: ForexmtColors.shadow,
        enzo4ex: Enzo4exColors.shadow,
        finflymarket: FinFlyMarketColors.shadow,
        worldonecapital: WorldOneCapitalColors.shadow,
        sarthifxm: SarthifxmColor.shadow,
        capyngen: CapyngenColors.shadow,
        ganecapitalfx: GaneCapitalFxColors.shadow,
        voltfxtrade: VoltFxTradeColors.shadow,
        zyrotrade: ZyrotradeColors.shadow,
        iglobefx: IglobefxColors.shadow,
        tgrxm: TgrxmColors.shadow,
        valtradex: ValtradexColors.shadow,
        livefxm: LivefxmColors.shadow,
        ryvotrade: RyvoTradeColors.shadow,
        kitefx: KiteFxColors.shadow,
        bluegatemarket: BlueGateMarketColors.shadow,
        nmatrixpro: NMatrixProColors.shadow,
        fourxtradz: FourXTradzColors.shadow,
        fxcelite: FxceliteColors.shadow,
        vintageprimefx: VintagePrimeFxColors.shadow,
        aoneprimefx: VintagePrimeFxColors.shadow,
        aurelianglobal: VintagePrimeFxColors.shadow,
      );

  static Color get success => _getColor(
        capmarket: CapMarketColors.success,
        ellitefx: ElliteFxColors.success,
        nestpip: NestPipColors.success,
        pipzo: PipzoColors.success,
        righttrade: RightTradeColors.success,
        primeforex: PrimeForexColors.success,
        ivrfx: IvrfxColors.success,
        innovixcapital: InnovixcapitalColors.success,
        flynix: FlynixColors.success,
        forexmt: ForexmtColors.success,
        enzo4ex: Enzo4exColors.success,
        finflymarket: FinFlyMarketColors.success,
        worldonecapital: WorldOneCapitalColors.success,
        sarthifxm: SarthifxmColor.success,
        capyngen: CapyngenColors.success,
        ganecapitalfx: GaneCapitalFxColors.success,
        voltfxtrade: VoltFxTradeColors.success,
        zyrotrade: ZyrotradeColors.success,
        iglobefx: IglobefxColors.success,
        tgrxm: TgrxmColors.success,
        valtradex: ValtradexColors.success,
        livefxm: LivefxmColors.success,
        ryvotrade: RyvoTradeColors.success,
        kitefx: KiteFxColors.success,
        bluegatemarket: BlueGateMarketColors.success,
        nmatrixpro: NMatrixProColors.success,
        fourxtradz: FourXTradzColors.success,
        fxcelite: FxceliteColors.success,
        vintageprimefx: VintagePrimeFxColors.success,
        aoneprimefx: VintagePrimeFxColors.success,
        aurelianglobal: VintagePrimeFxColors.success,
      );

  static Color get error => _getColor(
        capmarket: CapMarketColors.error,
        ellitefx: ElliteFxColors.error,
        nestpip: NestPipColors.error,
        pipzo: PipzoColors.error,
        righttrade: RightTradeColors.error,
        primeforex: PrimeForexColors.error,
        ivrfx: IvrfxColors.error,
        innovixcapital: InnovixcapitalColors.error,
        flynix: FlynixColors.error,
        forexmt: ForexmtColors.error,
        enzo4ex: Enzo4exColors.error,
        finflymarket: FinFlyMarketColors.error,
        worldonecapital: WorldOneCapitalColors.error,
        sarthifxm: SarthifxmColor.error,
        capyngen: CapyngenColors.error,
        ganecapitalfx: GaneCapitalFxColors.error,
        voltfxtrade: VoltFxTradeColors.error,
        zyrotrade: ZyrotradeColors.error,
        iglobefx: IglobefxColors.error,
        tgrxm: TgrxmColors.error,
        valtradex: ValtradexColors.error,
        livefxm: LivefxmColors.error,
        ryvotrade: RyvoTradeColors.error,
        kitefx: KiteFxColors.error,
        bluegatemarket: BlueGateMarketColors.error,
        nmatrixpro: NMatrixProColors.error,
        fourxtradz: FourXTradzColors.error,
        fxcelite: FxceliteColors.error,
        vintageprimefx: VintagePrimeFxColors.error,
        aoneprimefx: VintagePrimeFxColors.error,
        aurelianglobal: VintagePrimeFxColors.error,
      );

  static Color get warning => _getColor(
        capmarket: CapMarketColors.warning,
        ellitefx: ElliteFxColors.warning,
        nestpip: NestPipColors.warning,
        pipzo: PipzoColors.warning,
        righttrade: RightTradeColors.warning,
        primeforex: PrimeForexColors.warning,
        ivrfx: IvrfxColors.warning,
        innovixcapital: InnovixcapitalColors.warning,
        flynix: FlynixColors.warning,
        forexmt: ForexmtColors.warning,
        enzo4ex: Enzo4exColors.warning,
        finflymarket: FinFlyMarketColors.warning,
        worldonecapital: WorldOneCapitalColors.warning,
        sarthifxm: SarthifxmColor.warning,
        capyngen: CapyngenColors.warning,
        ganecapitalfx: GaneCapitalFxColors.warning,
        voltfxtrade: VoltFxTradeColors.warning,
        zyrotrade: ZyrotradeColors.warning,
        iglobefx: IglobefxColors.warning,
        tgrxm: TgrxmColors.warning,
        valtradex: ValtradexColors.warning,
        livefxm: LivefxmColors.warning,
        ryvotrade: RyvoTradeColors.warning,
        kitefx: KiteFxColors.warning,
        bluegatemarket: BlueGateMarketColors.warning,
        nmatrixpro: NMatrixProColors.warning,
        fourxtradz: FourXTradzColors.warning,
        fxcelite: FxceliteColors.warning,
        vintageprimefx: VintagePrimeFxColors.warning,
        aoneprimefx: VintagePrimeFxColors.warning,
        aurelianglobal: VintagePrimeFxColors.warning,
      );

  static Color get info => _getColor(
        capmarket: CapMarketColors.info,
        ellitefx: ElliteFxColors.info,
        nestpip: NestPipColors.info,
        pipzo: PipzoColors.info,
        righttrade: RightTradeColors.info,
        primeforex: PrimeForexColors.info,
        ivrfx: IvrfxColors.info,
        innovixcapital: InnovixcapitalColors.info,
        flynix: FlynixColors.info,
        forexmt: ForexmtColors.info,
        enzo4ex: Enzo4exColors.info,
        finflymarket: FinFlyMarketColors.info,
        worldonecapital: WorldOneCapitalColors.info,
        sarthifxm: SarthifxmColor.info,
        capyngen: CapyngenColors.info,
        ganecapitalfx: GaneCapitalFxColors.info,
        voltfxtrade: VoltFxTradeColors.info,
        zyrotrade: ZyrotradeColors.info,
        iglobefx: IglobefxColors.info,
        tgrxm: TgrxmColors.info,
        valtradex: ValtradexColors.info,
        livefxm: LivefxmColors.info,
        ryvotrade: RyvoTradeColors.info,
        kitefx: KiteFxColors.info,
        bluegatemarket: BlueGateMarketColors.info,
        nmatrixpro: NMatrixProColors.info,
        fourxtradz: FourXTradzColors.info,
        fxcelite: FxceliteColors.info,
        vintageprimefx: VintagePrimeFxColors.info,
        aoneprimefx: VintagePrimeFxColors.info,
        aurelianglobal: VintagePrimeFxColors.info,
      );

  static List<Color> get buttonGradient {
    switch (FlavorConfig.appFlavor) {
      case Flavor.capmarket:
        return [
          CapMarketColors.primary,
          CapMarketColors.primaryDark.withOpacity(0.5),
        ];
      case Flavor.ellitefx:
        return [
          ElliteFxColors.primary,
          ElliteFxColors.primaryDark.withOpacity(0.5),
        ];
      case Flavor.nestpip:
        return [
          NestPipColors.primary,
          NestPipColors.primaryDark.withOpacity(0.5),
        ];
      case Flavor.pipzomarket:
        return [
          PipzoColors.primary,
          PipzoColors.primaryDark.withOpacity(0.5),
        ];
      case Flavor.righttrade:
        return [
          RightTradeColors.primary,
          RightTradeColors.primaryDark.withOpacity(0.5),
        ];
      case Flavor.primeforex:
        return [
          PrimeForexColors.primary,
          PrimeForexColors.primaryDark.withOpacity(0.5),
        ];
      case Flavor.ivrfx:
        return [
          IvrfxColors.primary,
          IvrfxColors.primaryDark.withOpacity(0.5),
        ];
      case Flavor.innovixcapital:
        return [
          InnovixcapitalColors.primary,
          InnovixcapitalColors.primaryDark.withOpacity(0.5),
        ];
      case Flavor.fynixfxweb:
        return [
          FlynixColors.primary,
          FlynixColors.primaryDark.withOpacity(0.5),
        ];
      case Flavor.forexmt:
        return [
          ForexmtColors.primary,
          ForexmtColors.primaryDark.withOpacity(0.5),
        ];
      case Flavor.enzo4ex:
        return [
          Enzo4exColors.primary,
          Enzo4exColors.primaryDark.withOpacity(0.5),
        ];
      case Flavor.finflymarket:
        return [
          FinFlyMarketColors.primary,
          FinFlyMarketColors.primaryDark.withOpacity(0.5),
        ];
      case Flavor.worldonecapital:
        return [
          WorldOneCapitalColors.primary,
          WorldOneCapitalColors.primaryDark.withOpacity(0.5),
        ];
      case Flavor.sarthifxm:
        return [
          SarthifxmColor.primary,
          SarthifxmColor.primaryDark.withOpacity(0.5),
        ];
      case Flavor.capyngen:
        return [
          CapyngenColors.primary,
          CapyngenColors.primaryDark.withOpacity(0.5),
        ];
      case Flavor.ganecapitalfx:
        return [
          GaneCapitalFxColors.primary,
          GaneCapitalFxColors.primaryDark.withOpacity(0.5),
        ];
      case Flavor.voltfxtrade:
        return [
          VoltFxTradeColors.primary,
          VoltFxTradeColors.primaryDark.withOpacity(0.5),
        ];

      case Flavor.zyrotrade:
        return [
          ZyrotradeColors.primary,
          ZyrotradeColors.primaryDark.withOpacity(0.5),
        ];
      case Flavor.tgrxm:
        return [
          TgrxmColors.primary,
          TgrxmColors.primaryDark.withOpacity(0.5),
        ];
      case Flavor.valtradex:
        return [
          ValtradexColors.primary,
          ValtradexColors.primaryDark.withOpacity(0.5),
        ];
      case Flavor.livefxm:
        return [
          LivefxmColors.primary,
          LivefxmColors.primaryDark.withOpacity(0.5),
        ];
      case Flavor.iglobefx:
        return [
          IglobefxColors.primary,
          IglobefxColors.primaryDark.withOpacity(0.5),
        ];
      case Flavor.ryvotrade:
        return [
          RyvoTradeColors.primary,
          RyvoTradeColors.primaryDark.withOpacity(0.5),
        ];
      case Flavor.kitefx:
        return [
          KiteFxColors.primary,
          KiteFxColors.primaryDark.withOpacity(0.5),
        ];
      case Flavor.bluegatemarket:
        return [
          BlueGateMarketColors.primary,
          BlueGateMarketColors.primaryDark.withOpacity(0.5),
        ];
      case Flavor.nmatrixpro:
        return [
          NMatrixProColors.primary,
          NMatrixProColors.primaryDark.withOpacity(0.5),
        ];
      case Flavor.fourxtradz:
        return [
          FourXTradzColors.primary,
          FourXTradzColors.primaryDark.withOpacity(0.5),
        ];
      case Flavor.fxcelite:
        return [
          FxceliteColors.primary,
          FxceliteColors.primaryDark.withOpacity(0.5),
        ];
      case Flavor.vintageprimefx:
        return [
          VintagePrimeFxColors.primary,
          VintagePrimeFxColors.primaryDark.withOpacity(0.5),
        ];
      case Flavor.aoneprimefx:
        return [
          VintagePrimeFxColors.primary,
          VintagePrimeFxColors.primaryDark.withOpacity(0.5),
        ];
      case Flavor.aurelianglobal:
        return [
          VintagePrimeFxColors.primary,
          VintagePrimeFxColors.primaryDark.withOpacity(0.5),
        ];

      default:
        return [Colors.grey, Colors.grey.shade700.withOpacity(0.5)];
    }
  }
}
