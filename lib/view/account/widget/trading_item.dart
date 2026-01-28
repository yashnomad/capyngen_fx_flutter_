import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/flavor_config.dart';
import '../../../theme/app_colors.dart';
import '../btc_chart/btc_chart_screen.dart';

class TradingItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final double price;
  final String change;
  final Color chartColor;
  final String flag;
  final IconData icon;
  final List<double> chartData;

  const TradingItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.change,
    required this.chartColor,
    required this.flag,
    required this.icon,
    required this.chartData,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColor.lightGrey,
            child: Icon(
              icon,
              color:AppFlavorColor.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style:
                        TextStyle(color: AppColor.greyColor, fontSize: 11)),
              ],
            ),
          ),
          SizedBox(
            width: 15,
          ),
          SizedBox(
            width: 60,
            height: 30,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: false,
                    color: chartColor,
                    dotData: FlDotData(show: false),
                    barWidth: 1,
                  )
                ],
              ),
            ),
          ),
          Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  )),
              Text(
                change,
                style: TextStyle(
                    color: change.contains("↑")
                        ? AppColor.blueColor
                        : AppColor.redColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
            ],
          )
        ],
      ),
    );
  }
}
