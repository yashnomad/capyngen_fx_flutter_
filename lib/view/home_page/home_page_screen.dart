import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/utils/bottom_nav_helper.dart';
import 'package:exness_clone/view/account/account_screen.dart';
import 'package:exness_clone/view/account/buy_sell_trade/orders_screen.dart';
import 'package:exness_clone/view/market/market.dart';
import 'package:exness_clone/view/performance/performance_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../../config/flavor_config.dart';
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
    // OrdersScreen(),
    TradeScreen(),

    PerformanceScreen(),
    MarketScreen(),
    ProfileScreen(),
  ];

  final List<String> _labels = [
    'Home',
    'Trade',
    'Performance',
    'Markets',
    'Profile'
  ];

  final List<IconData> _icons = [
    Icons.home_filled,
    Icons.candlestick_chart,
    Icons.insights,
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
              // gradient: LinearGradient(
              //   begin: Alignment.topLeft,
              //   end: Alignment.bottomRight,
              //   colors: [
              //     context.appBarGradientColor,
              //     context.appBarGradientColorSecond,
              //   ],
              // ),
              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.black.withOpacity(0.1),
              //     blurRadius: 20,
              //     offset: const Offset(0, -8),
              //   ),
              // ],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                child: GNav(
                  rippleColor: AppFlavorColor.primary.withOpacity(0.2),
                  gap: 8,
                  activeColor: context.tabLabelColor,
                  iconSize: 24,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10.0),
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
                        fontSize: 13,
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

/*

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    AccountScreen(),
    OrdersScreen(),
    MarketScreen(),
    PerformanceScreen(),
    ProfileScreen(),
  ];

  final List<String> _labels = [
    'Home',
    'Trade',
    'Markets',
    'Performance',
    'Profile'
  ];

  final List<IconData> _icons = [
    Icons.home_filled,
    Icons.candlestick_chart,
    Icons.insights,
    CupertinoIcons.chart_bar_alt_fill,
    CupertinoIcons.person,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.appBarGradientColor,
              context.appBarGradientColorSecond,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -8),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),

          // border: Border.all(
          //   color: Colors.grey.withOpacity(0.1),
          //   width: 1,
          // ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: GNav(
              gap: 8,

              activeColor: context.tabLabelColor,

              // activeColor: isDark ? Colors.white : activeColor,

              iconSize: 24,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10.0),
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
                  text: _selectedIndex == index ? _labels[index] : '',
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: context.tabLabelColor,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                  backgroundColor: _selectedIndex == index
                      ? (context.tabBackgroundColor)
                      : Colors.transparent,
                  iconActiveColor: context.tabLabelColor,
                );
              }),
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
*/
