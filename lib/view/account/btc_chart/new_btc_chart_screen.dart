import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/widget/simple_appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../../../constant/app_vector.dart';
import '../../../theme/app_colors.dart';
import '../../../widget/slidepage_navigate.dart';
import '../btc_setting/btc_setting_screen.dart';
import '../buy_trade/buy_trade_bottom_sheet.dart';
import '../calculator_screen.dart';
import '../chart_data/finnhub/candle_data.dart';
import '../chart_data/finnhub/realtime_chart_service.dart';
import '../chart_data/finnhub/realtime_chart_widget.dart';
import '../detail_screen.dart';
import '../price_alert_screen.dart';
import '../sell_trade/sell_trade_bottom_sheet.dart';
import '../widget/tab_selector.dart';

class NewBTCChartScreen extends StatefulWidget {
  final String? symbol;
  final String? displayName;
  final double? currentPrice;
  final double? change;
  final double? changePercent;
  final IconData? icon;
  final List<double>? chartData;

  const NewBTCChartScreen({
    super.key,
    this.symbol,
    this.displayName,
    this.currentPrice,
    this.change,
    this.changePercent,
    this.icon,
    this.chartData,
  });

  @override
  State<NewBTCChartScreen> createState() => _NewBTCChartScreenState();
}

class _NewBTCChartScreenState extends State<NewBTCChartScreen> {
  List<String> tabTitle = ['Chart', 'Analytics', 'Specifications'];

  late double sellValue;
  late double buyValue;
  int sellPercentage = 51;
  int buyPercentage = 49;

  // Real-time chart variables
  final RealtimeChartService _chartService = RealtimeChartService();
  List<CandleData> _candleData = [];
  double _currentPrice = 0.0;
  String _selectedChartType = 'candle';
  String _selectedTimeframe = '5m';
  late StreamSubscription<double> _priceSubscription;
  late StreamSubscription<List<CandleData>> _candleSubscription;

  // Getters for dynamic data with fallbacks
  String get stockSymbol => widget.symbol ?? 'BTC';
  String get stockDisplayName => widget.displayName ?? 'Bitcoin';
  double get stockPrice =>
      _currentPrice > 0 ? _currentPrice : (widget.currentPrice ?? 109450.0);
  double get stockChange => widget.change ?? -772.30;
  double get stockChangePercent => widget.changePercent ?? -0.70;
  IconData get stockIcon => widget.icon ?? Icons.currency_bitcoin;

  @override
  void initState() {
    super.initState();
    _currentPrice = widget.currentPrice ?? 109450.0;
    // Calculate buy/sell prices based on current stock price
    sellValue = stockPrice - (stockPrice * 0.0001); // 0.01% below current price
    buyValue = stockPrice + (stockPrice * 0.0001); // 0.01% above current price

    _initializeRealTimeChart();
  }

  Future<void> _initializeRealTimeChart() async {
    // Subscribe to real-time price updates
    _priceSubscription = _chartService.priceStream.listen((price) {
      if (mounted) {
        setState(() {
          _currentPrice = price;
          // Update buy/sell values
          sellValue = price - (price * 0.0001);
          buyValue = price + (price * 0.0001);
        });
      }
    });

    // Subscribe to real-time candle data
    _candleSubscription = _chartService.candleStream.listen((candleData) {
      if (mounted) {
        setState(() {
          _candleData = candleData;
        });
      }
    });

    // Connect to WebSocket with current symbol
    await _chartService.connectWebSocket(stockSymbol);
  }

  String get changeText {
    final change = _currentPrice - (widget.currentPrice ?? _currentPrice);
    final changePercent = widget.currentPrice != null
        ? (change / widget.currentPrice!) * 100
        : stockChangePercent;

    return '${change >= 0 ? '↑' : '↓'} '
        '\$${change.abs().toStringAsFixed(2)} '
        '(${changePercent.toStringAsFixed(2)}%)';
  }

  Color get changeColor {
    final change = _currentPrice - (widget.currentPrice ?? _currentPrice);
    return change >= 0 ? AppColor.blueColor : AppColor.redColor;
  }

  final List<Map<String, String>> tradingSignals = const [
    {
      'type': 'Intraday',
      'title': 'Intraday analysis: bullish momentum above support levels',
      'time': '3 hours ago',
    },
    {
      'type': 'Short term',
      'title': 'Short term outlook: positive trend continuation expected',
      'time': '2 hours ago',
    },
    {
      'type': 'Medium term',
      'title': 'MT: bullish bias above key support.',
      'time': '29 Oct 2024',
    },
  ];

  final List<Map<String, String>> events = const [
    {
      'title': 'Market Opening Bell',
      'time': '09:30',
      'countdown': 'In 2 hours',
    },
    {
      'title': 'Earnings Report',
      'time': '16:00',
      'countdown': 'In 8 hours',
    },
    {
      'title': 'Market Close',
      'time': '16:30',
      'countdown': 'In 8.5 hours',
    },
  ];

  final List<Map<String, String>> newsItems = [
    {
      'image': AppVector.bull,
      'title': 'Stock shows strong performance amid market volatility...',
      'coin': 'Stock',
      'change': '-0.70%',
      'time': '9 hours ago',
    },
    {
      'image': AppVector.crypto,
      'title': 'Market analysis shows positive outlook for tech stocks...',
      'coin': 'Market',
      'change': '+1.24%',
      'time': '14 hours ago',
    },
    {
      'image': AppVector.bull,
      'title': 'Analysts predict continued growth in current sector...',
      'coin': 'Analysis',
      'change': '+0.85%',
      'time': '1 day ago',
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
  void dispose() {
    _priceSubscription.cancel();
    _candleSubscription.cancel();
    _chartService.dispose();
    super.dispose();
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
      {'label': 'Today', 'value': changeText, 'color': changeColor},
      {'label': 'Week', 'value': '+4.19%', 'color': AppColor.blueColor},
      {'label': 'Month', 'value': '+5.51%', 'color': AppColor.blueColor},
      {'label': 'Year', 'value': '+87.45%', 'color': AppColor.blueColor},
    ];

    return DefaultTabController(
      length: tabTitle.length,
      child: Scaffold(
        appBar: SimpleAppbar(title: 'Live Chart'),
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
              Padding(
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
                            Text("\$${stockPrice.toStringAsFixed(2)}",
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
                                color: changeColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                changeText,
                                style: TextStyle(
                                    fontSize: 12, color: AppColor.whiteColor),
                              ),
                            ),
                            SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: context.scaffoldBackgroundColor,
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

              // Stock Info Row - Updated with dynamic data
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
                              stockIcon, // Dynamic icon
                              color: AppColor.whiteColor,
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('$stockSymbol ', // Dynamic symbol
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
              ),

              Expanded(
                child: TabBarView(children: [
                  // UPDATED CHART TAB - Real-time charts
                  Column(
                    children: [
                      // Chart controls
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Chart type selector
                            _buildChartTypeButton(
                                'line', Icons.show_chart, 'Line'),
                            const SizedBox(width: 8),
                            _buildChartTypeButton(
                                'candle', Icons.candlestick_chart, 'Candle'),
                            const Spacer(),
                            // Timeframe selector
                            _buildTimeframeButton('1m'),
                            const SizedBox(width: 4),
                            _buildTimeframeButton('5m'),
                            const SizedBox(width: 4),
                            _buildTimeframeButton('1h'),
                          ],
                        ),
                      ),

                      // Real-time price display
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColor.blackColor
                            : Colors.grey.shade100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$${_currentPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              changeText,
                              style: TextStyle(
                                fontSize: 16,
                                color: changeColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Real-time chart
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                            context.backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: _candleData.isEmpty
                              ? const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(height: 16),
                                      Text('Loading real-time chart data...'),
                                    ],
                                  ),
                                )
                              // : RealtimeChartWidget(
                              //     candleData: _candleData,
                              //     chartType: _selectedChartType,
                              //     primaryColor: AppColor.blueColor,
                              //   ),
                          : SizedBox()
                        ),
                      ),
                    ],
                  ),

                  // Analytics Tab - Keep your existing content
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
                                final isSelected = item['label'] ==
                                    'Today'; // Highlight 'Today' for current stock
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
                        SizedBox(height: 20),
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
                          children: List.generate(events.length, (index) {
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
                          children: List.generate(newsItems.length, (index) {
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

                  // Specifications Tab - Updated with dynamic data
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20),
                          Text('TRADING HOURS',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.greyColor,
                                  letterSpacing: 0.8)),
                          const SizedBox(height: 8),
                          Row(
                            children: const [
                              Icon(Icons.access_time, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text("Market is open",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                              ),
                              Icon(Icons.arrow_forward_ios_rounded, size: 18),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Info Section - Updated with dynamic data
                          Text('INFO',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.greyColor,
                                  letterSpacing: 0.8)),
                          const SizedBox(height: 12),
                          _infoRow('Symbol', stockSymbol),
                          _infoRow('Name', stockDisplayName),
                          _infoRow('Current Price',
                              '\$${stockPrice.toStringAsFixed(2)}'),
                          _infoRow('24h Change', changeText),
                          _infoRow('Minimum volume, lots', '0.01'),
                          _infoRow('Maximum volume, lots', '100'),
                          _infoRow('Step', '0.01'),
                          _infoRow('Contract size', '1'),
                          _infoRow('Spread units', 'USD'),
                          _infoRow('Stop level, pips', '0.0'),
                          _infoRow('Swap long, pips', '-225.2'),
                          _infoRow('Swap short, pips', '0.0'),
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

  Widget _buildChartTypeButton(String type, IconData icon, String label) {
    final isSelected = _selectedChartType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedChartType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.blueColor : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.black,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeframeButton(String timeframe) {
    final isSelected = _selectedTimeframe == timeframe;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTimeframe = timeframe;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.blueColor : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          timeframe,
          style: TextStyle(
            fontSize: 11,
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
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
