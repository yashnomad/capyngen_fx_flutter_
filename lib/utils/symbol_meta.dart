import 'package:flutter/material.dart';

class SymbolMeta {
  final String symbol;
  final String subtitle;
  final String flag;
  final IconData icon;

  const SymbolMeta(this.symbol, this.subtitle, this.flag, this.icon);
}

const Map<String, SymbolMeta> symbolMeta = {
  "XAUUSD": SymbolMeta("XAUUSD", "Gold vs US Dollar", "🥇", Icons.circle),
  "EURUSD": SymbolMeta("EURUSD", "Euro vs US Dollar", "🇪🇺", Icons.euro),
  "GBPUSD": SymbolMeta(
      "GBPUSD", "British Pound vs US Dollar", "🇬🇧", Icons.currency_pound),
};

/*
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class SymbolMeta {
  final String name;
  final IconData icon;
  final Color color;

  SymbolMeta({required this.name, required this.icon, required this.color});
}

final Map<String, SymbolMeta> symbolMetaMap = {
  'BTCUSDT': SymbolMeta(
    name: 'Bitcoin',
    icon: Icons.currency_bitcoin,
    color: AppColor.orangeColor,
  ),
  'ETHUSDT': SymbolMeta(
    name: 'Ethereum',
    icon: Icons.hexagon,
    color: AppColor.blueColor,
  ),


};

SymbolMeta getSymbolMeta(String symbol) {
  return symbolMetaMap[symbol.toUpperCase()] ??
      SymbolMeta(
        name: symbol,
        icon: Icons.monetization_on,
        color: Colors.grey,
      );
}
*/
