import 'package:exness_clone/view/account/price_alert_screen.dart';
import 'package:exness_clone/view/account/widget/trading_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'btc_chart/btc_chart_screen_updated.dart';
import 'chart_data/dummy_chart/dummy_chart_data.dart';

class SearchCoin extends StatefulWidget {
  const SearchCoin({super.key});

  @override
  State<SearchCoin> createState() => _SearchCoinState();
}

class _SearchCoinState extends State<SearchCoin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_new_outlined,
              size: 20,
            )),
        title: TextField(
          autofocus: true,
          decoration: InputDecoration(
              border: OutlineInputBorder(borderSide: BorderSide.none)),
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: dummyTradingData.length,
            itemBuilder: (context, i) {
              final item = dummyTradingData[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: InkWell(
                  onTap: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => BTCChartScreenUpdated(
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
                ),
              );
            },
          )),
    );
  }
}
