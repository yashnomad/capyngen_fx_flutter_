import 'package:exness_clone/constant/app_vector.dart';
import 'package:exness_clone/core/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widget/color.dart';
import '../account/detail_screen.dart';

class TrendingSignalDetails extends StatefulWidget {
  const TrendingSignalDetails({super.key});

  @override
  State<TrendingSignalDetails> createState() => _TrendingSignalDetailsState();
}

class _TrendingSignalDetailsState extends State<TrendingSignalDetails> {
  @override
  Widget build(BuildContext context) {

    // final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: context.profileScaffoldColor,
      // isDark ? Colors.white10 : Colors.grey.shade50,
      appBar: AppBar(
        titleSpacing: 0,
        toolbarHeight: 110,

        flexibleSpace: Container(
          color:context.profileScaffoldColor,
        ),
        automaticallyImplyLeading: false,
        title: Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Card(
            elevation: 0,
            color: context.backgroundColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("10,000.00 USD",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        DetailScreen()));
                          },
                          child: Icon(
                            CupertinoIcons.list_bullet,
                            size: 20,
                          ))
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color:context.profileScaffoldColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Standard',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness ==
                              Brightness.dark
                              ? Colors.white10
                              : AppColor.lightGrey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Real',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      SizedBox(width: 6),
                      Text("# 105258715", style: TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15)),

          color: context.backgroundColor,
        ),

        child: ClipRRect(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15)),

            child: SupportResistanceScreen()),

      ),
    );
  }
}



class SupportResistanceScreen extends StatelessWidget {
  const SupportResistanceScreen({super.key});

  Widget buildLevelRow(String value, String label, Color color, [String? dots]) {
    return Row(
      children: [
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w600, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(color: color,fontWeight: FontWeight.w500),
        ),
        if (dots != null)
          Text(
            " $dots",
            style: TextStyle(color: color),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const resistanceColor = Colors.green;
    const supportColor = Colors.red;
    const pivotColor = Colors.blue;

    return Scaffold(

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 10),
        child: Column(
          children: [
            Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.grey.shade200
              ),
            ),

            SizedBox(height: 10,),

            Expanded(
              child: ListView(
                children: [
                  SizedBox(height: 10,),
                  Image.asset(AppVector.graph),
                  SizedBox(height: 10,),
                  Text('Intraday: as long as 0.56 is support look for 0.59',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w700),),
                  SizedBox(height: 10,),
                  Text('XTZ may rise 0.01 - 0.02 USD',style: TextStyle(color: AppColor.greyColor,fontWeight: FontWeight.w500),),
                  SizedBox(height: 20,),
                  const Text("Our preference",
                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16)),
                  const SizedBox(height: 4),
                  const Text("As long as 0.56 is support look for 0.59."),
                  const SizedBox(height: 20),
              
                  // Support/Resistance List
                  buildLevelRow("0.60000", "Resistance", resistanceColor, "•••"),
                  const SizedBox(height: 15),
                  buildLevelRow("0.59000", "Resistance", resistanceColor, "••"),
                  const SizedBox(height: 15),
                  buildLevelRow("0.58000", "Resistance", resistanceColor, "•"),
                  const SizedBox(height: 15),
                  buildLevelRow("0.57000", "Last", Theme.of(context).brightness == Brightness.dark ? AppColor.whiteColor:AppColor.blackColor),
                  const SizedBox(height: 15),
                  buildLevelRow("0.56000", "Pivot", pivotColor),
                  const SizedBox(height: 15),
                  buildLevelRow("0.56000", "Support", supportColor, "•"),
                  const SizedBox(height: 15),
                  buildLevelRow("0.54000", "Support", supportColor, "••"),
                  const SizedBox(height: 15),
                  buildLevelRow("0.53000", "Support", supportColor, "•••"),
                  const SizedBox(height: 20),
              
                  // Comment Section
                  const Text("Comment",
                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16)),
                  const SizedBox(height: 6),
                  const Text(
                    "The RSI is above its neutrality area at 50. The MACD is below its signal line and positive. The price could retrace. Moreover, the price is trading under its 20 period moving average (0.57) but above its 50 period moving average (0.56).",
                    style: TextStyle(height: 1.4),
                  ),
                  const SizedBox(height: 20),
              
                  // Alternative Scenario
                  const Text("Alternative scenario",
                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16)),
                  const SizedBox(height: 6),
                  const Text(
                    "The downside breakout of 0.56 would call for 0.54 and 0.53.",
                    style: TextStyle(height: 1.4),
                  ),
                  const SizedBox(height: 20),
              
                  // Current Trend
                  const Text("Current trend",
                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      buildTrendCard("Intraday",AppColor.blueColor, Icons.arrow_upward, ""),
                      buildTrendCard("Short term", AppColor.redColor, Icons.arrow_downward, "no change"),
                      buildTrendCard("Medium term", AppColor.redColor, Icons.arrow_downward, "no change"),
                    ],
                  ),
              
              
              
              
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTrendCard(String title, Color color, IconData icon, String status) {
    return Column(
      children: [
        Text(title,style: TextStyle(fontWeight: FontWeight.w600,fontSize: 13,),),
        SizedBox(height: 4,),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
          child: Row(
            children: [
              Icon(icon, size: 14, color: AppColor.whiteColor),
              const SizedBox(width: 4),
              Text(title, style: TextStyle(color: AppColor.whiteColor, fontWeight: FontWeight.w600,fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(status, style:  TextStyle(color: AppColor.greyColor, fontSize: 12,fontWeight: FontWeight.w500)),
      ],
    );
  }
}

