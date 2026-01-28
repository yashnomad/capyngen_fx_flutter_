import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/widget/color.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';



class TopNewsScreen extends StatefulWidget {
  const TopNewsScreen({super.key});

  @override
  State<TopNewsScreen> createState() => _TopNewsScreenState();
}

class _TopNewsScreenState extends State<TopNewsScreen> with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.profileScaffoldColor,
      appBar: AppBar(
        title: const Text("News",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600),),

        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios,size: 18,)),
       flexibleSpace: Container(
         color: context.profileScaffoldColor,
       ),
        elevation: 0.5,

        bottom:  TabBar(
          controller: _tabController,
          padding: EdgeInsets.symmetric(horizontal: 10),
          unselectedLabelStyle: TextStyle(color: AppColor.greyColor),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.grey.shade300,
          tabs: [
            Tab(text: "Favorites"),
            Tab(text: "All"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          NewsListView(data: newsList),
          NewsListView(data: newsList),
        ],
      ),
    );
  }
}

class NewsListView extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const NewsListView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 20),
        child: Container(
          decoration: BoxDecoration(
            color: context.backgroundColor,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(15),
              topLeft: Radius.circular(15),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              children: List.generate(data.length, (index) {
                final item = data[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          item['image'],
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  item['symbol'],
                                  style:  TextStyle(
                                      color: AppColor.greyColor, fontSize: 12),
                                ),
                                const SizedBox(width: 10),
                                if (item['change'] != null)
                                  Text(
                                    item['change'],
                                    style:  TextStyle(
                                        color: AppColor.redColor, fontSize: 12),
                                  ),
                                const SizedBox(width: 10),
                                Text(
                                  item['time'],
                                  style:  TextStyle(
                                      color: AppColor.greyColor, fontSize: 12),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    )
    ;
  }
}

// 📰 Sample news list (replace with real data or API later)
final List<Map<String, dynamic>> newsList = [
  {
    'image': 'assets/image/crpto.jpg',
    'title': 'Oil Price Forecast: WTI rallies to \$74 before settling above \$72',
    'symbol': 'USOIL',
    'time': '21 hours ago',
  },
  {
    'image': 'assets/image/bull.jpg',
    'title': 'EUR/USD retreats as Israel-Iran conflict jolts markets, ends 4-day rally',
    'symbol': 'EUR/USD',
    'time': '22 hours ago',
  },
  {
    'image': 'assets/image/crpto.jpg',
    'title': 'USD/JPY recovers above 144.00 on Israel-Iran tensions, cautious BoJ',
    'symbol': 'USD/JPY',
    'time': '2 days ago',
  },
  {
    'image': 'assets/image/bull.jpg',
    'title': 'Gold surges past \$3,400 on Israel-Iran war risk, soft US inflation boosts safe-haven',
    'symbol': 'XAU/USD',
    'time': '2 days ago',
  },
  {
    'image': 'assets/image/crpto.jpg',
    'title': 'AI Tokens Price Forecast: Bittensor, Kaito target weekend rally',
    'symbol': 'BTC',
    'change': '↓ 1.52%',
    'time': '2 days ago',
  },
  {
    'image': 'assets/image/bull.jpg',
    'title': 'GBP/USD plunges as Israel-Iran conflict rattles markets, boosts USD',
    'symbol': 'GBP/USD',
    'time': '2 days ago',
  },
  {
    'image': 'assets/image/crpto.jpg',
    'title': 'Crypto Today: BTC, ETH, XRP clamber for support amid volatility',
    'symbol': 'BTC',
    'change': '↓ 1.52%',
    'time': '2 days ago',
  },
  {
    'image': 'assets/image/bull.jpg',
    'title': 'EUR fades a portion of this week’s gains on sentiment and soft data',
    'symbol': 'EUR/USD',
    'time': '2 days ago',
  },
  {
    'image': 'assets/image/crpto.jpg',
    'title': 'Oil Price Forecast: WTI rallies to \$74 before settling above \$72',
    'symbol': 'USOIL',
    'time': '21 hours ago',
  },
  {
    'image': 'assets/image/bull.jpg',
    'title': 'EUR/USD retreats as Israel-Iran conflict jolts markets, ends 4-day rally',
    'symbol': 'EUR/USD',
    'time': '22 hours ago',
  },
  {
    'image': 'assets/image/crpto.jpg',
    'title': 'USD/JPY recovers above 144.00 on Israel-Iran tensions, cautious BoJ',
    'symbol': 'USD/JPY',
    'time': '2 days ago',
  },
  {
    'image': 'assets/image/bull.jpg',
    'title': 'Gold surges past \$3,400 on Israel-Iran war risk, soft US inflation boosts safe-haven',
    'symbol': 'XAU/USD',
    'time': '2 days ago',
  },
  {
    'image': 'assets/image/crpto.jpg',
    'title': 'AI Tokens Price Forecast: Bittensor, Kaito target weekend rally',
    'symbol': 'BTC',
    'change': '↓ 1.52%',
    'time': '2 days ago',
  },
  {
    'image': 'assets/image/bull.jpg',
    'title': 'GBP/USD plunges as Israel-Iran conflict rattles markets, boosts USD',
    'symbol': 'GBP/USD',
    'time': '2 days ago',
  },
  {
    'image': 'assets/image/crpto.jpg',
    'title': 'Crypto Today: BTC, ETH, XRP clamber for support amid volatility',
    'symbol': 'BTC',
    'change': '↓ 1.52%',
    'time': '2 days ago',
  },
  {
    'image': 'assets/image/bull.jpg',
    'title': 'EUR fades a portion of this week’s gains on sentiment and soft data',
    'symbol': 'EUR/USD',
    'time': '2 days ago',
  },
];
