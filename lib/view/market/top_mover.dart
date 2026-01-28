import 'package:exness_clone/constant/app_vector.dart';
import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/view/account/account_screen.dart';
import 'package:exness_clone/widget/simple_appbar.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widget/color.dart';
import '../account/btc_chart/btc_chart_screen.dart';



class TopMoversScreen extends StatefulWidget {
  const TopMoversScreen({super.key});

  @override
  State<TopMoversScreen> createState() => _TopMoversScreenState();
}

class _TopMoversScreenState extends State<TopMoversScreen> {

  final List<Map<String, dynamic>> tradingData = [
    {
      'title': 'XPT/USD',
      'price': '1255.41',
      'change': '3.30%',
      'changeColor': AppColor.blueColor,
      'chartUrl':AppVector.line,
    },
    {
      'title': 'XPD/USD',
      'price': '1071.99',
      'change': '2.09%',
      'changeColor': AppColor.blueColor,
      'chartUrl':AppVector.line,
    },
    {
      'title': 'XAL/USD',
      'price': '2516.43',
      'change': '1.49%',
      'changeColor':AppColor.blueColor,
      'chartUrl': AppVector.line,
    },
  ];

  @override
  Widget build(BuildContext context) {

    // final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: SimpleAppbar(title: 'Top Movers'),
      body: ListView(

        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 10),
            child: const SectionTitle(title: "ALL"),
          ),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                spacing: 10,
                children: List.generate(tradingData.length, (index){
                  final item = tradingData[index];
                  return GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => BTCChartScreen()));
                    },
                    child: Container(
                      width: MediaQuery.sizeOf(context).width * 0.36,

                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: context.backgroundColor,
                        border: Border.all(color: AppColor.mediumGrey),
                        borderRadius: BorderRadius.circular(12),

                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.centerLeft,
                                children: [
                                  CircleAvatar(
                                    radius: 10,
                                    backgroundImage: NetworkImage(
                                        'https://cdn-icons-png.flaticon.com/512/197/197484.png'), // Shadow-style icon
                                  ),
                                  Positioned(
                                    right: -8,
                                    bottom: -6,
                                    child: CircleAvatar(
                                      radius: 10,
                                      backgroundImage: NetworkImage(
                                          'https://cdn-icons-png.flaticon.com/512/330/330425.png'), // US Flag icon
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 20,),
                              Expanded(
                                child: Text(
                                  item['title'],

                                  maxLines: 1,overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),


                          SizedBox(height: 10),
                          Image.asset(item['chartUrl'],height: 40,),
                          SizedBox(height: 4),
                          Center(
                            child: Text(
                              item['price'],
                              maxLines: 1,overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          SizedBox(height: 4),
                          Center(
                            child: Text(
                              "↑ ${item['change']}",
                              maxLines: 1,overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: item['changeColor'],

                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child:  SectionTitle(title: "CRYPTO",),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                spacing: 10,
                children: List.generate(tradingData.length, (index){
                  final item = tradingData[index];
                  return GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => BTCChartScreen()));
                    },
                    child: Container(
                      width: MediaQuery.sizeOf(context).width * 0.36,

                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: context.backgroundColor,
                        border: Border.all(color: AppColor.mediumGrey),
                        borderRadius: BorderRadius.circular(12),

                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.centerLeft,
                                children: [
                                  CircleAvatar(
                                    radius: 10,
                                    backgroundImage: NetworkImage(
                                        'https://cdn-icons-png.flaticon.com/512/197/197484.png'), // Shadow-style icon
                                  ),
                                  Positioned(
                                    right: -8,
                                    bottom: -6,
                                    child: CircleAvatar(
                                      radius: 10,
                                      backgroundImage: NetworkImage(
                                          'https://cdn-icons-png.flaticon.com/512/330/330425.png'), // US Flag icon
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 20,),
                              Expanded(
                                child: Text(
                                  item['title'],

                                  maxLines: 1,overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),


                          SizedBox(height: 10),
                          Image.asset(item['chartUrl'],height: 40,),
                          SizedBox(height: 4),
                          Center(
                            child: Text(
                              item['price'],
                              maxLines: 1,overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          SizedBox(height: 4),
                          Center(
                            child: Text(
                              "↑ ${item['change']}",
                              maxLines: 1,overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: item['changeColor'],

                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style:  TextStyle( fontSize: 13,color: AppColor.greyColor,fontWeight: FontWeight.w500),
    );
  }
}


