import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

class DummyTradingModel {
  final String title;
  final String id;
  final String subtitle;
  final double price;
  final String change;
  final Color chartColor;
  final String flag;
  final IconData icon;
  final List<double> chartData;

  DummyTradingModel({
    required this.title,
    required this.id,
    required this.subtitle,
    required this.price,
    required this.change,
    required this.chartColor,
    required this.flag,
    required this.icon,
    required this.chartData,
  });
}

final List<DummyTradingModel> dummyTradingData = [
  DummyTradingModel(
    title: "C:GBPUSD",
    id: "690b675780f9635233c4a48e",
    subtitle: "British Pound vs US Dollar",
    price: 1.35473,
    change: "↑ 0.42%",
    chartColor: AppColor.blueColor,
    flag: "🇬🇧",
    icon: Icons.currency_pound,
    chartData: List<double>.generate(30, (i) => 1.2 + (i % 5) * 0.05),
  ),
  DummyTradingModel(
    title: "C:EURUSD",
    id: '690b675780f9635233c4a48f',
    subtitle: "Euro vs US Dollar",
    price: 1.14228,
    change: "↓ 0.26%",
    chartColor: AppColor.redColor,
    flag: "🇪🇺",
    icon: Icons.euro,
    chartData: List<double>.generate(30, (i) => 1.1 + (i % 4) * 0.03),
  ),
  DummyTradingModel(
    title: "C:XAUUSD",
    id: '690b675780f9635233c4a48d',
    subtitle: "US Dollar vs Japanese Yen",
    price: 148.52,
    change: "↑ 0.12%",
    chartColor: AppColor.blueColor,
    flag: "🇯🇵",
    icon: Icons.currency_yen,
    chartData: List<double>.generate(30, (i) => 1.0 + (i % 6) * 0.04),
  ),
];
