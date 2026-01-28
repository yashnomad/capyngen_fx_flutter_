import 'package:exness_clone/view/account/btc_chart/btc_chart_screen_updated.dart';
import 'package:exness_clone/view/account/widget/trading_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../btc_chart/btc_chart_screen.dart';
import '../chart_data/dummy_chart/dummy_chart_data.dart';

class ChartDataWidget extends StatefulWidget {
  const ChartDataWidget({super.key});

  @override
  State<ChartDataWidget> createState() => _ChartDataWidgetState();
}

class _ChartDataWidgetState extends State<ChartDataWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero, // Add this line to remove extra space
      itemCount: dummyTradingData.length,
      shrinkWrap: true, // This makes ListView only take the space it needs
      physics: ClampingScrollPhysics(), // Disable ListView scrolling
      itemBuilder: (context, index) {
        final item = dummyTradingData[index];
        return InkWell(
          onTap: () => Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) =>
                      BTCChartScreenUpdated(
                        symbolName: item.title,
                        id: item.id,
                        tradeUserId: '',
                      ))),
          child: TradingItem(
            title: item.title,
            subtitle: item.subtitle,
            price: item.price,
            change: item.change,
            chartColor: item.chartColor,
            flag: item.flag,
            icon: item.icon,
            chartData: item.chartData,
          ),
        );
      },
    );
  }
}
