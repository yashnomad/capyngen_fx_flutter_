
import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/view/market/trending_signal_details.dart';
import 'package:exness_clone/widget/color.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';



class TradingSignalsScreen extends StatelessWidget {
  const TradingSignalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final isDark = Theme.of(context).brightness == Brightness.dark;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: context.profileScaffoldColor,
        appBar: AppBar(
          flexibleSpace: Container(
            color:context.profileScaffoldColor,
            // isDark? Colors.white10 : Colors.grey.shade50,
          ),
           leading: IconButton(onPressed: (){
             Navigator.pop(context);
           }, icon: Icon(Icons.arrow_back_ios,size: 18,)),
          elevation: 0.5,
          title: const Text("Trading Signals",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600),),
          bottom:  TabBar(
            padding: EdgeInsets.symmetric(horizontal: 10),
            unselectedLabelStyle: TextStyle(color: AppColor.greyColor),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: AppColor.mediumGrey,
            tabs: [
              Tab(text: "Favorites"),
              Tab(text: "All"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            SignalListTab(isFavorites: true),
            SignalListTab(isFavorites: false),
          ],
        ),
      ),
    );
  }
}

class SignalListTab extends StatelessWidget {
  final bool isFavorites;
  const SignalListTab({super.key, required this.isFavorites});

  @override
  Widget build(BuildContext context) {
    // final isDark = Theme.of(context).brightness == Brightness.dark;


    final signals = [
      {
        "icon": Icons.trending_down,
        "iconColor": AppColor.redColor,
        "pair": "BTC",
        "time": "14 Jun 12:20",
        "title": "Bitcoin / Dollar intraday: the downside prevails as long as 106240 is resistance",
        "desc": "Our preference: the downside prevails as long as 106240 is resistance.",
      },
      {
        "icon": Icons.trending_up,
        "iconColor": AppColor.blueColor,
        "pair": "USD/JPY",
        "time": "14 Jun 08:34",
        "title": "Intraday : as long as 143.34 is support look for 145.63",
        "desc": "The price could retrace.",
      },
      {
        "icon": Icons.trending_up,
        "iconColor": AppColor.blueColor,
        "pair": "GBP/USD",
        "time": "14 Jun 08:34",
        "title": "Intraday : as long as 1.3523 is support look for 1.3654",
        "desc": "The price could retrace.",
      },
      {
        "icon": Icons.trending_up,
        "iconColor":AppColor.blueColor,
        "pair": "EUR/USD",
        "time": "14 Jun 08:34",
        "title": "Intraday : the upside prevails as long as 1.1514 is support",
        "desc": "The configuration is positive.",
      },
      {
        "icon": Icons.trending_up,
        "iconColor": AppColor.blueColor,
        "pair": "EUR/USD",
        "time": "14 Jun 06:34",
        "title": "Intraday : the upside prevails as long as 1.1514 is support",
        "desc": "The configuration is positive.",
      },
      {
        "icon": Icons.trending_up,
        "iconColor": AppColor.blueColor,
        "pair": "GBP/USD",
        "time": "14 Jun 06:34",
        "title": "Intraday : as long as 1.3523 is support look for 1.3654",
        "desc": "The price could retrace.",
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: signals.length,
      itemBuilder: (context, index) {
        final signal = signals[index];
        return GestureDetector(
          onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => TrendingSignalDetails()));

          },
          child: Card(

            color: context.backgroundColor,
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(signal["icon"] as IconData, color: signal["iconColor"] as Color, size: 20),
                      const SizedBox(width: 8),
                      Text('${signal["pair"]}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text('${signal["time"]}', style:  TextStyle(color: AppColor.greyColor, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${signal["title"]}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text('${signal["desc"]}', style:  TextStyle(color: AppColor.greyColor)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
