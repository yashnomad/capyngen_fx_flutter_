import 'package:exness_clone/widget/color.dart';
import 'package:exness_clone/widget/simple_appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class VirtualPrivateServer extends StatefulWidget {



  const VirtualPrivateServer({super.key, });

  @override
  State<VirtualPrivateServer> createState() => _VirtualPrivateServerState();
}

class _VirtualPrivateServerState extends State<VirtualPrivateServer> {

  final features = [
    {
      'icon': Icons.rocket_launch_outlined,
      'title': 'Speed',
      'description':
      'VPS servers are located in close proximity to Exness trading servers, ensuring fast and reliable execution.',
    },
    {
      'icon': Icons.balance_outlined,
      'title': 'Stability',
      'description':
      'Running your Expert Advisor on a VPS ensures that the EA\'s execution runs seamlessly, regardless of the quality of your internet connection.',
    },
    {
      'icon': Icons.access_time_outlined,
      'title': '24-hour trading',
      'description':
      'Trade on the financial markets using Expert Advisors even when your own computer is turned off.',
    },
    {
      'icon': Icons.devices_other_outlined,
      'title': 'Mobility & portability',
      'description':
      'Access your account and trade on the financial markets from anywhere in the world. VPS is available on any operating system.',
    },
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: SimpleAppbar(title: 'Virtual Private Server',),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Virtual Private Server',
                style: TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w700, height: 1.5),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'Virtual Private Servers allow you to run automated trading strategies with fast and reliable execution.',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              InkWell(
                  onTap: () {},
                  child: Text(
                    'Read more',
                    style: TextStyle(
                        color: AppColor.blueColor,
                        fontWeight: FontWeight.w500,
                        height: 1.5),
                  )),
              SizedBox(
                height: 20,
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(CupertinoIcons.exclamationmark_circle_fill,
                              color: AppColor.yellowColor),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "You do not currently qualify for a free VPS",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text(
                        "To qualify for a free VPS, you need to meet one of the following criteria:",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 16),
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColor.lightGrey,
                        child: Text("1",
                            style: TextStyle(fontSize: 12, color: AppColor.blackColor)),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Your balance across all your trading accounts needs to be at least 2,000 USD to immediately qualify for a free VPS. If your balance is between 500–1,999 USD, you can still get a free VPS if you meet the trading volume requirements below.",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Text("Balance required: ",
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500)),
                          Text("2,000 USD",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: 0, // change this dynamically
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(30),
                        backgroundColor: AppColor.mediumGrey,
                        color: Colors.blueAccent,
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("0 USD",
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                          Text("2,000 USD", style: TextStyle(fontSize: 13)),
                        ],
                      ),
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: AppColor.blueGrey,
                            borderRadius: BorderRadius.circular(30)),
                        child: Text(
                          "OR",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            color: AppColor.whiteColor,
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColor.lightGrey,
                        child: Text("2",
                            style: TextStyle(fontSize: 12, color: AppColor.blackColor)),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "If your account balance is between 500–1,999 USD, your total trading volume within the last 30 days needs to be equivalent to at least 1,500,000 USD, in any currency or assets.",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Text("Balance required: ",
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500)),
                          Text("500 USD",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Labels
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColor.lightGrey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 25, // From 0 to 500
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColor.mediumGrey,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            Container(height: 10,color: AppColor.whiteColor,width: 2,),
                            Expanded(
                              flex: 75, // From 500 to 2000
                              child: Container(

                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Labels
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                        Row(
                          children: [
                            Text('0 USD', style: TextStyle(fontSize: 13,fontWeight: FontWeight.w500)),
                            SizedBox(width: 30,),
                            Text('500 USD', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                          Text('2,000 USD', style: TextStyle(fontSize: 13)),
                        ],
                      ),


                      SizedBox(height: 20),
                      Row(
                        children: [
                          Text("Balance required: ",
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500)),
                          Text("1,500,000 USD",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: 0, // change this dynamically
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(30),
                        backgroundColor: AppColor.mediumGrey,
                        color: Colors.blueAccent,
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("0 USD",
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                          Text("1,500,000 USD", style: TextStyle(fontSize: 13)),
                        ],
                      ),

                      SizedBox(height: 16),

                      InkWell(
                          onTap: () {},
                          child: Text(
                            'More about VPS requirements',
                            style: TextStyle(
                                color: AppColor.blueColor,
                                fontWeight: FontWeight.w500,
                                height: 1.5),
                          )),

                    ],
                  ),
                ),
              ),


              SizedBox(height: 40,),



              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: features.map((feature) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child:  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          feature['icon'] as IconData,
                          size: 28,

                        ),
                        SizedBox(height: 25),
                        Text(
                          feature['title'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          feature['description'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                        ),
                      ],
                    )
                  );
                }).toList(),
              ),


            ],
          ),
        ),
      ),
    );
  }
}
