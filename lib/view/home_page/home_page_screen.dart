import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/utils/bottom_nav_helper.dart';
import 'package:exness_clone/view/account/account_screen.dart';
import 'package:exness_clone/view/market/market.dart';
import 'package:exness_clone/view/performance/performance_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../../config/flavor_config.dart';
import '../account/chart_page.dart';
import '../profile/profile_screen.dart';
import '../account/trade_screen/trade_screen.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  final List<Widget> _widgetOptions = <Widget>[
    AccountScreen(),
    TradeScreen(),
    ChartPage(),
    PerformanceScreen(),
    MarketScreen(),
    ProfileScreen(),
  ];

  final List<String> _labels = [
    'Home',
    'Trade',
    'Chart',
    'Performance',
    'Markets',
    'Profile'
  ];

  final List<IconData> _icons = [
    Icons.home_filled,
    Icons.candlestick_chart,
    Icons.insights,
    Icons.speed_rounded,
    CupertinoIcons.chart_bar_alt_fill,
    CupertinoIcons.person,
  ];
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: BottomNavHelper.indexNotifier,
      builder: (context, selectedIndex, _) {
        return Scaffold(
          body: IndexedStack(
            index: selectedIndex,
            children: _widgetOptions,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              color: context.tabBackgroundColor,
            ),
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                child: GNav(
                  rippleColor: AppFlavorColor.primary.withOpacity(0.2),
                  gap: 6,
                  activeColor: context.tabLabelColor,
                  iconSize: 24,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 10.0),
                  duration: const Duration(milliseconds: 200),
                  tabBackgroundColor: context.tabBackgroundColor,
                  tabBorderRadius: 16,
                  tabActiveBorder: Border.all(
                    color: AppFlavorColor.primary.withOpacity(0.2),
                    width: 1,
                  ),
                  color: Colors.grey.shade500,
                  tabs: List.generate(_icons.length, (index) {
                    return GButton(
                      icon: _icons[index],
                      text: selectedIndex == index ? _labels[index] : '',
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: context.tabLabelColor,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                      backgroundColor: selectedIndex == index
                          ? (context.tabBackgroundColor)
                          : Colors.transparent,
                      iconActiveColor: context.tabLabelColor,
                    );
                  }),
                  selectedIndex: selectedIndex,
                  onTabChange: (index) {
                    BottomNavHelper.goTo(index);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
