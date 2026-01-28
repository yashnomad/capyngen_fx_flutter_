import 'dart:io';
import 'package:dio/dio.dart';
import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/widget/simple_appbar.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart' as xml;
import 'package:intl/intl.dart'; // Ensure intl is imported
import '../account/search/browse_screen.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  // 1. Define Futures for two different sections
  late Future<List<NewsItem>> _newsFuture;
  late Future<List<NewsItem>> _economyFuture;

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      responseType: ResponseType.plain,
      // Add a User-Agent to avoid being blocked by some RSS feeds
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
      },
    ),
  );

  @override
  void initState() {
    super.initState();
    // 2. Fetch both feeds in parallel
    _newsFuture = _fetchFeed('https://cointelegraph.com/rss', 'CoinTelegraph');

    _economyFuture = _fetchFeed(
        'https://www.cnbc.com/id/20910258/device/rss/rss.html', 'CNBC Economy');
  }

  // 3. Reusable Fetch Function
  Future<List<NewsItem>> _fetchFeed(String url, String defaultSource) async {
    try {
      final response = await _dio.get(url);

      if (response.statusCode == 200 && response.data != null) {
        final document = xml.XmlDocument.parse(response.data as String);
        final items = document.findAllElements('item');

        return items.map((node) {
          final title = node.findElements('title').single.innerText;
          final link = node.findElements('link').single.innerText;

          // Parse Date
          String timeAgo = 'Today';
          final pubDateNode = node.findElements('pubDate');
          if (pubDateNode.isNotEmpty) {
            timeAgo = _parseTimeAgo(pubDateNode.single.innerText);
          }

          // Image handling (RSS feeds vary greatly)
          String? image;
          // Try media:content
          image = node
              .findElements('media:content')
              .firstOrNull
              ?.getAttribute('url');
          // Try standard enclosure
          image ??=
              node.findElements('enclosure').firstOrNull?.getAttribute('url');
          // Fallback image based on source
          image ??= defaultSource.contains("Coin")
              ? "https://cointelegraph.com/assets/img/share.png"
              : "https://sc.cnbcfm.com/applications/cnbc.com/staticcontent/img/cnbc_logo.gif";

          return NewsItem(
            title: title,
            url: link,
            imageUrl: image,
            source: defaultSource,
            timeAgo: timeAgo,
          );
        }).toList();
      } else {
        throw Exception('Failed to load feed');
      }
    } catch (e) {
      debugPrint("Error fetching $defaultSource: $e");
      return [];
    }
  }

  String _parseTimeAgo(String dateString) {
    try {
      DateTime date = HttpDate.parse(dateString);
      Duration diff = DateTime.now().difference(date);

      if (diff.inDays > 0) return '${diff.inDays}d ago';
      if (diff.inHours > 0) return '${diff.inHours}h ago';
      if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
      return 'Just now';
    } catch (e) {
      return 'Today';
    }
  }

  void _openBrowser(BuildContext context, String title, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BrowserScreen(url: url, title: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Market',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SECTION 1: TOP NEWS ---
              _buildSectionHeader('TOP NEWS'),
              const SizedBox(height: 10),
              _buildFeedList(_newsFuture),

              const SizedBox(height: 25), // Spacer between sections

              // --- SECTION 2: ECONOMIC CALENDAR & UPDATES ---
              _buildSectionHeader('ECONOMIC CALENDAR'),
              const SizedBox(height: 10),
              _buildFeedList(_economyFuture),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildFeedList(Future<List<NewsItem>> future) {
    return FutureBuilder<List<NewsItem>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: CircularProgressIndicator(),
          ));
        } else if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Text("Updates unavailable",
                style: TextStyle(color: Colors.grey)),
          );
        }

        final items = snapshot.data!;
        // Show top 3 items per section to keep UI clean
        final displayItems = items.take(3).toList();

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayItems.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = displayItems[index];
            return GestureDetector(
              onTap: () => _openBrowser(context, item.title, item.url),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.imageUrl,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(
                            width: 70, height: 70, color: Colors.grey[200]),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                item.source,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "• ${item.timeAgo}",
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class NewsItem {
  final String title;
  final String url;
  final String imageUrl;
  final String source;
  final String timeAgo;

  NewsItem({
    required this.title,
    required this.url,
    required this.imageUrl,
    required this.source,
    required this.timeAgo,
  });
}

/*
import 'package:exness_clone/constant/app_vector.dart';
import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/services/balance_masked.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/view/account/account_screen.dart';
import 'package:exness_clone/view/market/top_mover.dart';
import 'package:exness_clone/view/market/top_news.dart';
import 'package:exness_clone/view/market/top_news_details.dart';
import 'package:exness_clone/view/market/trading_signal.dart';
import 'package:exness_clone/view/market/trending_signal_details.dart';
import 'package:exness_clone/widget/slidepage_navigate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../config/flavor_config.dart';
import '../../services/switch_account_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/bottom_sheets.dart';
import '../../utils/common_utils.dart';
import '../../widget/account_bottom_sheet.dart';
import '../../widget/color.dart';
import '../account/btc_chart/btc_chart_screen.dart';
import '../account/detail_screen.dart';
import '../account/widget/deposit_bottomsheet.dart';
import '../account/widget/label_icon_button.dart';
import '../account/withdraw_deposit/bloc/select_account_bloc.dart';
import '../trade/model/trade_account.dart';
import 'economic_calender.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final List<Map<String, dynamic>> tradingData = [
    {
      'title': 'XPT/USD',
      'price': '1255.41',
      'change': '3.30%',
      'changeColor': AppColor.blueColor,
      'chartUrl': AppVector.line,
    },
    {
      'title': 'XPD/USD',
      'price': '1071.99',
      'change': '2.09%',
      'changeColor': AppColor.blueColor,
      'chartUrl': AppVector.line,
    },
    {
      'title': 'XAL/USD',
      'price': '2516.43',
      'change': '1.49%',
      'changeColor': AppColor.blueColor,
      'chartUrl': AppVector.line,
    },
  ];

  final List<Map<String, String>> events = [
    {
      'flag': 'https://flagcdn.com/w40/hu.png',
      'countryCode': 'HU',
      'title': 'Inflation Rate MoM',
      'time': '12:00',
      'countdown': 'In 6 minutes',
    },
    {
      'flag': 'https://flagcdn.com/w40/hu.png',
      'countryCode': 'HU',
      'title': 'Inflation Rate YoY',
      'time': '12:00',
      'countdown': 'In 6 minutes',
    },
    {
      'flag': 'https://flagcdn.com/w40/hu.png',
      'countryCode': 'HU',
      'title': 'Core Inflation Rate YoY',
      'time': '12:00',
      'countdown': 'In 6 minutes',
    },
  ];

  final List<Map<String, dynamic>> news = [
    {
      'image': 'assets/image/bull.jpg',
      'title': 'Crude Oil price today: WTI price bullish at European opening',
      'ticker': 'USOIL',
      'change': '+0.44%',
      'isUp': true,
      'time': '20 minutes ago',
    },
    {
      'image': 'assets/image/crpto.jpg',
      'title':
          'USD/MXN remains on the defensive near 19.00 ahead of US CPI release',
      'ticker': 'USD/MXN',
      'change': '-0.05%',
      'isUp': false,
      'time': '27 minutes ago',
    },
    {
      'image': 'assets/image/bull.jpg',
      'title':
          'Stellar Price Forecast: XLM is on the verge of a breakout as TVL reaches a …',
      'ticker': '',
      'change': '',
      'isUp': true,
      'time': '30 minutes ago',
    },
  ];

  String? _tradeUserId;

  void _route(Widget child) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => child));
  }

  void _getAccountId(Account account) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _tradeUserId = account.id ?? '';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(
                  'Markets',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            SliverAppBar(
              pinned: true,
              toolbarHeight: 160,
              flexibleSpace: Container(
                color: context.scaffoldBackgroundColor,
              ),
              title: SwitchAccountService(
                accountBuilder: (context, account) {
                  _getAccountId(account);
                  return buildTradeAccountCard(context, account);
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TOP MOVERS',
                          style: TextStyle(
                              color: AppColor.greyColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(context,
                                SlidePageRoute(page: TopMoversScreen()));
                          },
                          child: Text(
                            'Show more',
                            style: TextStyle(
                                color: AppColor.blueColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                        )
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        spacing: 10,
                        children: List.generate(tradingData.length, (index) {
                          final item = tradingData[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BTCChartScreen()));
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Stack(
                                        clipBehavior: Clip.none,
                                        alignment: Alignment.centerLeft,
                                        children: [
                                          CircleAvatar(
                                            radius: 12,
                                            backgroundImage: NetworkImage(
                                                'https://cdn-icons-png.flaticon.com/512/197/197484.png'), // Shadow-style icon
                                          ),
                                          Positioned(
                                            right: -12,
                                            bottom: -8,
                                            child: CircleAvatar(
                                              radius: 12,
                                              backgroundImage: NetworkImage(
                                                  'https://cdn-icons-png.flaticon.com/512/330/330425.png'), // US Flag icon
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Expanded(
                                        child: Text(
                                          item['title'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Image.asset(
                                    item['chartUrl'],
                                    height: 40,
                                  ),
                                  SizedBox(height: 4),
                                  Center(
                                    child: Text(
                                      item['price'],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Center(
                                    child: Text(
                                      "↑ ${item['change']}",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TRENDING SIGNALS',
                          style: TextStyle(
                              color: AppColor.greyColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        TradingSignalsScreen()));
                          },
                          child: Text(
                            'Show more',
                            style: TextStyle(
                                color: AppColor.blueColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                        )
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: List.generate(tradingData.length, (index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TrendingSignalDetails(),
                                ),
                              );
                            },
                            child: Container(
                              width: MediaQuery.sizeOf(context).width *
                                  0.55, // responsive width
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                color: context.backgroundColor,
                                border: Border.all(
                                    color: AppColor.mediumGrey, width: 0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// image takes fixed height relative to card
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(12),
                                      topLeft: Radius.circular(12),
                                    ),
                                    child: AspectRatio(
                                      aspectRatio:
                                          16 / 9, // ✅ responsive image height
                                      child: Image.asset(
                                        AppVector.graph,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                    ),
                                  ),

                                  /// content expands dynamically
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          index == 0
                                              ? 'DE30: the downside prevails'
                                              : 'DE30: the downside',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 8),

                                        /// bottom row
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.red.shade600,
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                              ),
                                              child: Text(
                                                '↓ Intraday',
                                                style: TextStyle(
                                                  color: AppColor.whiteColor,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '11:34',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppColor.greyColor,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'UPCOMING EVENTS',
                          style: TextStyle(
                              color: AppColor.greyColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        EconomicCalendarScreen()));
                          },
                          child: Text(
                            'Show more',
                            style: TextStyle(
                                color: AppColor.blueColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    EconomicCalenderDetails()));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: AppColor.mediumGrey, width: 0.6),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListView.separated(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(15),
                          itemCount: events.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            color: AppColor.mediumGrey,
                          ),
                          itemBuilder: (context, index) {
                            final item = events[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 12),
                              child: Row(
                                children: [
                                  // Flag
                                  ClipOval(
                                    child: Image.network(
                                      item['flag']!,
                                      width: 25,
                                      height: 25,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 10),

                                  // Country code and red bars
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['countryCode']!,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: List.generate(
                                          3,
                                          (i) => Container(
                                            width: 4,
                                            height: 12,
                                            margin:
                                                const EdgeInsets.only(right: 2),
                                            decoration: BoxDecoration(
                                              color: AppColor.redColor,
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(width: 14),

                                  // Title and time
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['title']!,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              item['time']!,
                                              style: TextStyle(
                                                color: AppColor.greyColor,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              '– ${item['countdown']}',
                                              style: TextStyle(
                                                color: AppColor.greyColor,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TOP NEWS',
                          style: TextStyle(
                              color: AppColor.greyColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TopNewsScreen()));
                          },
                          child: Text(
                            'Show more',
                            style: TextStyle(
                                color: AppColor.blueColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TopNewsDetails()));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: AppColor.mediumGrey, width: 0.6),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListView.separated(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(15),
                          itemCount: events.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            color: AppColor.mediumGrey,
                          ),
                          itemBuilder: (context, index) {
                            final item = news[index];

                            return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Thumbnail image
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.asset(
                                        item['image']!,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 10),

                                    // Title + Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Title
                                          Text(
                                            item['title']!,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 6),

                                          // Ticker & Time Row
                                          Row(
                                            children: [
                                              if (item['ticker']!.isNotEmpty)
                                                Text(
                                                  item['ticker'],
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: AppColor.greyColor,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              if (item['change']
                                                  .isNotEmpty) ...[
                                                const SizedBox(width: 6),
                                                Text(
                                                  item['change'],
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: item['isUp']
                                                        ? AppColor.blueColor
                                                        : Colors.red.shade600,
                                                  ),
                                                ),
                                              ],
                                              const SizedBox(width: 8),
                                              Text(
                                                item['time'],
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColor.greyColor,
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ));
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  BoxDecoration buildBoxDecoration(
      Account? selectedAccount, BuildContext context) {
    return BoxDecoration(
      gradient: (selectedAccount != null)
          ? LinearGradient(colors: [
              AppFlavorColor.primary,
              AppFlavorColor.darkPrimary,
            ])
          : null,
      color: context.scaffoldBackgroundColor,
      borderRadius: BorderRadius.circular(12),
    );
  }

  Widget buildTradeAccountCard(BuildContext context, Account account) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            // AppFlavorColor.primary.withOpacity(0.6),
            // AppFlavorColor.primary.withOpacity(0.9),
            AppFlavorColor.primary,
            AppFlavorColor.darkPrimary
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppFlavorColor.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              UIBottomSheets.accountBottomSheet<String>(
                  context, AccountsTabSheet());
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: AppColor.whiteColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColor.whiteColor.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: AppColor.whiteColor,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Account",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColor.whiteColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColor.whiteColor,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColor.whiteColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            account.group?.groupName ?? 'Standard',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColor.whiteColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColor.whiteColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            CommonUtils.capitalizeFirst(account.accountType) ??
                                '',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColor.whiteColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "# ${account.accountId}",
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColor.whiteColor.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              BalanceMasked(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Balance",
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColor.whiteColor.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          CommonUtils.formatBalance(
                              account.balance?.toDouble() ?? 0),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColor.whiteColor,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColor.whiteColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "USD",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColor.whiteColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
*/
