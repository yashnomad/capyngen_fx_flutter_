import 'package:exness_clone/core/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widget/color.dart';
import '../account/detail_screen.dart';

class TopNewsDetails extends StatefulWidget {
  const TopNewsDetails({super.key});

  @override
  State<TopNewsDetails> createState() => _TopNewsDetailsState();
}

class _TopNewsDetailsState extends State<TopNewsDetails> {
  @override
  Widget build(BuildContext context) {
    // final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: context.profileScaffoldColor,
      appBar: AppBar(
        titleSpacing: 0,
        toolbarHeight: 110,
        flexibleSpace: Container(
          color: context.profileScaffoldColor,
        ),
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Card(
            elevation: 0,
            color: context.backgroundColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                    builder: (context) => DetailScreen()));
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
                          color: context.profileScaffoldColor,
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
                          color: Theme.of(context).brightness == Brightness.dark
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
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15), topRight: Radius.circular(15)),
          color: context.backgroundColor,
        ),
        child: ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15)),
            child: NewsBodyDetails()),
      ),
    );
  }
}

class NewsBodyDetails extends StatelessWidget {
  const NewsBodyDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: [
            Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: AppColor.lightGrey),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: ListView(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 12,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'USOIL',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          Text(
                            'Crude Oil',
                            style: TextStyle(
                                color: AppColor.greyColor, fontSize: 12),
                          )
                        ],
                      ),
                      Spacer(),
                      Text(
                        '71.860',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Image.asset(
                    'assets/image/bull.jpg',
                    fit: BoxFit.fill,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Oil Price Forecast: WTI rallies to \$74 before settling above \$72',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    '14.06.2025 02:18 By Tammy Da Costa, CFTe@',
                    style: TextStyle(
                        color: AppColor.greyColor, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                      "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(
                        Icons.open_in_new,
                        size: 20,
                      ),
                      Text('  FXStreet')
                    ],
                  ),
                  SizedBox(height: 10),
                  Divider(color: AppColor.mediumGrey),
                  SizedBox(height: 10),
                  Text(
                    'Information on these pages contains forward-looking statements that involve risks and uncertainties. Markets and instruments profiled on this page are for informational purposes only and should not in any way come across as a recommendation to buy or sell in these assets. You should do your own thorough research before making any investment decisions. FXStreet does not in any way guarantee that this information is free from mistakes, errors, or material misstatements. It also does not guarantee that this information is of a timely nature. Investing in Open Markets involves a great deal of risk, including the loss of all or a portion of your investment, as well as emotional distress. All risks, losses and costs associated with investing, including total loss of principal, are your responsibility.',
                    style: TextStyle(color: AppColor.greyColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTrendCard(
      String title, Color color, IconData icon, String status) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        SizedBox(
          height: 4,
        ),
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
              Text(title,
                  style: TextStyle(
                      color: AppColor.whiteColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(status,
            style: TextStyle(
                color: AppColor.greyColor,
                fontSize: 12,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}
