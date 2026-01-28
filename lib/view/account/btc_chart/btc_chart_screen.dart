import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/services/switch_account_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../constant/app_vector.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/common_utils.dart';
import '../../../widget/slidepage_navigate.dart';
import '../btc_setting/btc_setting_screen.dart';
import '../buy_trade/buy_trade_bottom_sheet.dart';
import '../calculator_screen.dart';
import '../detail_screen.dart';
import '../price_alert_screen.dart';
import '../sell_trade/sell_trade_bottom_sheet.dart';
import '../widget/tab_selector.dart';

class BTCChartScreen extends StatefulWidget {
  const BTCChartScreen({super.key});

  @override
  State<BTCChartScreen> createState() => _BTCChartScreenState();
}

class _BTCChartScreenState extends State<BTCChartScreen> {
  List<String> tabTitle = ['Chart', 'Analytics', 'Specifications'];

  double sellValue = 109439.10;
  double buyValue = 109460.70;
  int sellPercentage = 51;
  int buyPercentage = 49;

  final List<Map<String, String>> tradingSignals = const [
    {
      'type': 'Intraday',
      'title':
          'Bitcoin / Dollar intraday: as long as 107890 is support look for 112330',
      'time': '3 hours ago',
    },
    {
      'type': 'Short term',
      'title':
          'Bitcoin / Dollar ST: as long as 101790 is support look for 127050',
      'time': '2 hours ago',
    },
    {
      'type': 'Medium term',
      'title': 'MT: bullish bias above 53000.',
      'time': '29 Oct 2024',
    },
  ];

  final List<Map<String, String>> events = const [
    {
      'title': 'Redbook YoY',
      'time': '18:25',
      'countdown': 'In 29 minutes',
    },
    {
      'title': '52-Week Bill Auction',
      'time': '21:00',
      'countdown': 'In 3 hours',
    },
    {
      'title': '3-Year Note Auction',
      'time': '22:30',
      'countdown': 'In 4 hours',
    },
  ];

  final List<Map<String, String>> newsItems = const [
    {
      'image': AppVector.bull,
      'title':
          "Bitcoin spikes above \$110K after account of Paraguay's president claims BTC legal t...",
      'coin': 'BTC',
      'change': '-0.70%',
      'time': '9 hours ago',
    },
    {
      'image': AppVector.crypto,
      'title':
          'Crypto products mark \$224 million of inflows after strong performance in IBIT an...',
      'coin': 'BTC',
      'change': '-0.70%',
      'time': '14 hours ago',
    },
    {
      'image': AppVector.bull,
      'title':
          'Why the US should care about GENIUS Act as stablecoin market hits new record in 20...',
      'coin': 'BTC',
      'change': '-0.70%',
      'time': '14 hours ago',
    },
  ];

  Color getLabelColor(String type) {
    switch (type) {
      case 'Intraday':
        return AppColor.blueColor;
      case 'Short term':
        return AppColor.blueColor;
      case 'Medium term':
        return AppColor.blueColor;
      default:
        return AppColor.greyColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    void showSellTradeBottomSheet(BuildContext context) {
      showModalBottomSheet(
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        context: context,
        builder: (context) {
          return SellTradeBottomSheet();
        },
      );
    }

    void showBuyTradeBottomSheet(BuildContext context) {
      showModalBottomSheet(
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        context: context,
        builder: (context) {
          return BuyTradeBottomSheet();
        },
      );
    }

    final items = [
      {'label': 'Hour', 'value': '+0.24%', 'color': AppColor.blueColor},
      {'label': 'Today', 'value': '-0.72%', 'color': AppColor.redColor},
      {'label': 'Week', 'value': '+4.19%', 'color': AppColor.blueColor},
      {'label': 'Month', 'value': '+5.51%', 'color': AppColor.blueColor},
      {'label': 'Year', 'value': '+87.45%', 'color': AppColor.blueColor},
    ];

    return DefaultTabController(
      length: tabTitle.length,
      child: Scaffold(
        backgroundColor: context.scaffoldBackgroundColor,
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Row(
                    spacing: 10,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            showSellTradeBottomSheet(context);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColor.redColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Sell',
                                    style: TextStyle(
                                        color: AppColor.whiteColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500)),
                                Text(
                                  sellValue.toStringAsFixed(2),
                                  style: TextStyle(
                                      color: AppColor.whiteColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            showBuyTradeBottomSheet(context);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColor.blueColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Buy',
                                    style: TextStyle(
                                        color: AppColor.whiteColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500)),
                                Text(
                                  buyValue.toStringAsFixed(2),
                                  style: TextStyle(
                                      color: AppColor.whiteColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      (buyValue - sellValue).toStringAsFixed(2),
                      style:
                          TextStyle(fontSize: 10, color: AppColor.blackColor),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                spacing: 15,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(height: 3, color: AppColor.lightGrey),
                            FractionallySizedBox(
                              widthFactor: sellPercentage / 100,
                              child: Container(
                                  height: 3, color: AppColor.redColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$sellPercentage%',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColor.redColor,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(height: 3, color: AppColor.lightGrey),
                            FractionallySizedBox(
                              widthFactor: buyPercentage / 100,
                              child: Container(
                                  height: 3, color: AppColor.blueColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$buyPercentage%',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColor.blueColor,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Top Balance and Menu

              SwitchAccountService(accountBuilder: (context, account) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Card(
                    elevation: 2,
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
                              Row(
                                children: [
                                  Text(
                                      CommonUtils.formatBalance(
                                          account.balance?.toDouble() ?? 0),
                                      style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold)),
                                  Text(" USD",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
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
                                  color: context.scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  account.group?.groupName ?? 'Standard',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                              SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color:context.scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  CommonUtils.capitalizeFirst(
                                          account.accountType) ??
                                      '',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                              SizedBox(width: 6),
                              Text("# ${account.accountId}",
                                  style: TextStyle(fontSize: 10)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              // Account Type

              // BTC Info Row
              Container(
                color: context.backgroundColor,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColor.orangeColor,
                            radius: 16,
                            child: Icon(
                              Icons.currency_bitcoin,
                              color: AppColor.whiteColor,
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('BTC ',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                          Icon(Icons.keyboard_arrow_down_rounded),
                        ],
                      ),
                      Spacer(),
                      IconButton(
                          style: IconButton.styleFrom(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            Navigator.push(context,
                                SlidePageRoute(page: PriceAlertScreen()));
                          },
                          icon: Icon(
                            Icons.access_alarm_rounded,
                            size: 22,
                          )),
                      IconButton(
                          style: IconButton.styleFrom(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            Navigator.push(context,
                                SlidePageRoute(page: CalculatorScreen()));
                          },
                          icon: Icon(
                            CupertinoIcons.square_list,
                            size: 22,
                          )),
                      IconButton(
                          style: IconButton.styleFrom(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            Navigator.push(context,
                                SlidePageRoute(page: BTCSettingsScreen()));
                          },
                          icon: Icon(
                            CupertinoIcons.gear,
                            size: 22,
                          )),
                    ],
                  ),
                ),
              ),
              // Tabs
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    TabSelector(title: 'Open', count: 0),
                    SizedBox(width: 8),
                    TabSelector(title: 'Pending', count: 0),
                  ],
                ),
              ),
              TabBar(
                dividerColor: AppColor.transparent,
                labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.4),
                labelColor: context.themeColor,
                unselectedLabelColor: AppColor.greyColor,
                indicatorColor: context.themeColor,
                indicatorWeight: 2,
                tabs: tabTitle.map((tab) => Tab(text: tab)).toList(),
              ), // Chart

              Expanded(
                child: TabBarView(children: [
                  Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Image.asset(
                            AppVector.trading,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            _buildButton(
                              child: const Icon(
                                Icons.show_chart,
                                size: 16,
                              ),
                              decoration: BoxDecoration(
                                color: context.scaffoldBackgroundColor, // light gray background
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildButton(
                              child: const Text(
                                '5 m',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: context.scaffoldBackgroundColor, // light gray background
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildButton(
                              child: const Icon(
                                Icons.insert_chart_outlined,
                                size: 16,
                              ),
                              decoration: BoxDecoration(
                                color: context.scaffoldBackgroundColor, // light gray background
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColor.mediumGrey),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: items.map((item) {
                                final isSelected =
                                    item['label'] == 'Hour'; // Highlight 'Hour'
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: isSelected
                                      ? BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        )
                                      : null,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${item['label']}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${item['value']}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: item['color'] as Color,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        Image.asset(
                          AppVector.trading,
                          height: 150,
                          fit: BoxFit.fill,
                          width: double.infinity,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'UPCOMING HMR PERIODS',
                                style: TextStyle(
                                    color: AppColor.greyColor,
                                    fontSize: 12,
                                    letterSpacing: 1.5),
                              ),
                              Icon(
                                CupertinoIcons.info,
                                size: 24,
                              )
                            ],
                          ),
                        ),
                        Divider(
                          color: AppColor.mediumGrey,
                        ),
                        Column(
                          children: List.generate(3, (index) {
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15, right: 15),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    dense: true,
                                    title: Text(
                                      '21:15 - 21:31',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15),
                                    ),
                                    subtitle: Text(
                                      'Leverage 1:200',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: AppColor.greyColor,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    trailing: Icon(CupertinoIcons.bell),
                                  ),
                                ),
                                Divider(
                                  color: AppColor.mediumGrey,
                                  thickness: 0.6,
                                  height: 10,
                                ),
                              ],
                            );
                          }),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                foregroundColor: AppColor.blackColor,
                                backgroundColor: AppColor.lightGrey,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text(
                                "Show More",
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                        Divider(
                          color: AppColor.mediumGrey,
                          thickness: 0.6,
                          height: 10,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            'TRADING SIGNALS',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: AppColor.greyColor,
                                fontSize: 12,
                                letterSpacing: 1.5),
                          ),
                        ),
                        Divider(
                          color: AppColor.mediumGrey,
                          height: 15,
                        ),
                        Column(
                          spacing: 15,
                          children:
                              List.generate(tradingSignals.length, (index) {
                            final signal = tradingSignals[index];

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: getLabelColor(signal['type']!),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '↑ ${signal['type']}',
                                          style: TextStyle(
                                              color: AppColor.whiteColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        signal['title']!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 6,
                                      ),
                                      Text(
                                        signal['time']!,
                                        style: TextStyle(
                                          color: AppColor.greyColor,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),
                                Divider(
                                  thickness: 0.5,
                                  color: AppColor.mediumGrey,
                                  height: 0,
                                )
                              ],
                            );
                          }),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                foregroundColor: AppColor.blackColor,
                                backgroundColor: AppColor.lightGrey,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text(
                                "Show More",
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            'UPCOMING EVENTS',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: AppColor.greyColor,
                                fontSize: 12,
                                letterSpacing: 1.5),
                          ),
                        ),
                        Divider(
                          color: AppColor.mediumGrey,
                          height: 15,
                        ),
                        Column(
                          spacing: 15,
                          children:
                              List.generate(tradingSignals.length, (index) {
                            final event = events[index];

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 10),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const CircleAvatar(
                                        radius: 18,
                                        backgroundColor: Colors.transparent,
                                        backgroundImage: AssetImage(AppVector
                                            .usFlag), // Replace with correct path
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              event['title']!,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Text("US",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                                const SizedBox(width: 6),
                                                Container(
                                                  width: 4,
                                                  height: 16,
                                                  decoration: BoxDecoration(
                                                    color: AppColor.amberColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            2),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  "${event['time']} – ${event['countdown']}",
                                                  style: TextStyle(
                                                      color: AppColor.greyColor,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),
                                Divider(
                                  thickness: 0.5,
                                  color: AppColor.mediumGrey,
                                  height: 0,
                                )
                              ],
                            );
                          }),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                foregroundColor: AppColor.blackColor,
                                backgroundColor: AppColor.lightGrey,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text(
                                "Show More",
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                        Divider(
                            color: AppColor.mediumGrey,
                            thickness: 0.6,
                            height: 10),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            'LATEST NEWS',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: AppColor.greyColor,
                                fontSize: 12,
                                letterSpacing: 1.5),
                          ),
                        ),
                        Divider(
                          color: AppColor.mediumGrey,
                          height: 15,
                        ),
                        Column(
                          spacing: 15,
                          children:
                              List.generate(tradingSignals.length, (index) {
                            final news = newsItems[index];

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 10),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Thumbnail Image
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: Image.asset(
                                          news['image']!,
                                          width: 70,
                                          height: 70,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      // Text Content
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              news['title']!,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Text(
                                                  news['coin']!,
                                                  style: TextStyle(
                                                      color: AppColor.greyColor,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  '↓ ${news['change']}',
                                                  style: TextStyle(
                                                    color: AppColor.redColor,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  news['time']!,
                                                  style: TextStyle(
                                                    color: AppColor.greyColor,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 12,
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
                                SizedBox(height: 10),
                                Divider(
                                  thickness: 0.5,
                                  color: AppColor.mediumGrey,
                                  height: 0,
                                )
                              ],
                            );
                          }),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                foregroundColor: AppColor.blackColor,
                                backgroundColor: AppColor.lightGrey,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text(
                                "Show More",
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                        Divider(
                            color: AppColor.mediumGrey,
                            thickness: 0.6,
                            height: 10),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Text('TRADING HOURS',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.greyColor,
                                  letterSpacing: 0.8)),
                          const SizedBox(height: 8),
                          Row(
                            children: const [
                              Icon(
                                Icons.access_time,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text("Market is open",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 18,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Info Section
                          Text('INFO',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.greyColor,
                                  letterSpacing: 0.8)),
                          const SizedBox(height: 12),
                          _infoRow(
                            'Minimum volume, lots',
                            '0.01',
                          ),
                          _infoRow(
                            'Maximum volume, lots',
                            '100',
                          ),
                          _infoRow(
                            'Step',
                            '0.01',
                          ),
                          _infoRow(
                            'Contract size',
                            '1',
                          ),
                          _infoRow(
                            'Spread units',
                            'USD',
                          ),
                          _infoRow(
                            'Stop level, pips',
                            '0.0',
                          ),
                          _infoRow(
                            'Swap long, pips',
                            '-225.2',
                          ),
                          _infoRow(
                            'Swap short, pips',
                            '0.0',
                          ),
                        ],
                      ),
                    ),
                  )
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Text(
            label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          )),
          const SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColor.greyColor),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
      {required Widget child, required BoxDecoration decoration}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: decoration,
      child: child,
    );
  }
}
