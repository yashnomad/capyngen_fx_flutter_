import 'package:exness_clone/config/flavor_assets.dart';
import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/services/switch_account_service.dart';
import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/utils/snack_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'widget/compact_icon.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Widget buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          Text(value,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget buildActionItem(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.grey[100],
          child: Icon(
            icon,
            color: AppColor.blackColor,
            size: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  final TextStyle labelStyle =
      TextStyle(fontWeight: FontWeight.w500, fontSize: 12);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColor.blackColor
          : Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(Icons.close)),
                  const SizedBox(width: 16),
                  const Text(
                    'Standard',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            // Tabs
            TabBar(
              controller: _tabController,
              padding: EdgeInsets.symmetric(horizontal: 10),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: AppColor.greyColor,
              dividerHeight: 0.4,
              unselectedLabelColor: AppColor.greyColor,
              tabs: const [
                Tab(text: 'Funds'),
                Tab(text: 'Settings'),
              ],
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Funds Tab
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Info Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: context.depositContainerColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              buildInfoRow('Balance', '0.00 USD'),
                              buildInfoRow('Equity', '0.00 USD'),
                              buildInfoRow('Total P/L', '0.00 USD'),
                              buildInfoRow('Margin', '0.00 USD'),
                              buildInfoRow('Free margin', '0.00 USD'),
                              buildInfoRow('Margin level', '–'),
                              buildInfoRow('Leverage', '1:2000'),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Action Buttons
                        SwitchAccountService(
                            accountBuilder: (context, account) {
                          return Container(
                            // width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: context.depositContainerColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                              children: [
                                CompactActionButton(
                                  icon: CupertinoIcons.arrow_down_circle,
                                  label: "Deposit",
                                  color: AppColor.greenColor,
                                  labelColor: context.themeColor,
                                  onTap: () =>
                                      context.push('/depositFundScreen'),
                                ),
                                const SizedBox(width: 16),
                                CompactActionButton(
                                  icon: CupertinoIcons.arrow_up_right_circle,
                                  label: "Withdraw",
                                  color: AppColor.blueColor,
                                  labelColor: context.themeColor,
                                  onTap: () =>
                                      context.push('/withdrawFundsScreen'),
                                ),
                                const SizedBox(width: 16),
                                CompactActionButton(
                                  icon: Icons.history,
                                  label: "History",
                                  color: AppColor.darkBlueColor,
                                  labelColor: context.themeColor,
                                  onTap: () {
                                    if (account.id != null) {
                                      context.pushNamed('transactionScreen',
                                          extra: account.id);
                                    } else {
                                      SnackBarService.showSnackBar(
                                          message: 'No account selected');
                                    }
                                  },
                                ),
                                const SizedBox(width: 16),
                                CompactActionButton(
                                  icon: Icons.swap_horiz,
                                  label: "Transfer",
                                  color: AppColor.greyColor,
                                  labelColor: context.themeColor,
                                  onTap: () =>
                                      context.pushNamed('internalTransfer'),
                                ),
                              ],
                            ),
                            // child: Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                            //   children: [
                            // buildActionItem(CupertinoIcons.arrow_down_circle, 'Deposit'),
                            // buildActionItem(CupertinoIcons.arrow_up_right_circle, 'Withdraw'),
                            // buildActionItem(Icons.history, 'History'),
                            // buildActionItem(CupertinoIcons.arrow_right_arrow_left, 'Transfer'),

                            //   ],
                            // ),
                          );
                        }),
                      ],
                    ),
                  ),

                  // Settings Tab
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildAccountTypeCard(),
                          SizedBox(height: 16),
                          _buildStandardAccountCard(),
                          SizedBox(height: 16),
                          _buildTradingPlatformCard(),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountTypeCard() {
    return _buildCard(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Type',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            Row(
              children: [
                _buildBadge("Standard"),
                SizedBox(
                  width: 10,
                ),
                _buildBadge("Real"),
              ],
            )
          ],
        ),
        SizedBox(height: 12),
        _buildRow("Number", "#105258715"),
        _buildRow("Name", "Standard", showArrow: true),
      ],
    );
  }

  Widget _buildStandardAccountCard() {
    return _buildCard(
      children: [
        _buildRow("No commission", ""),
        _buildRow("Minimum spread", "0.2"),
        _buildRow("Maximum leverage", "1:2000", showArrow: true),
      ],
    );
  }

  Widget _buildTradingPlatformCard() {
    return _buildCard(
      children: [
        _buildRow("Login", "105258715", showCopy: true),
        _buildRow("Server", FlavorAssets.appName, showCopy: true),
        // _buildRow("Server", "Exness-MT5Real15", showCopy: true),
        _buildRow("Change trading password", "", showArrow: true),
        _buildRow("Trading log", "", showArrow: true),
      ],
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.depositContainerColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...children,
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value,
      {bool showArrow = false, bool showCopy = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: Text(label, style: labelStyle)),
          if (value.isNotEmpty)
            Text(
              value,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          SizedBox(width: 8),
          if (showCopy)
            InkWell(
              child: Icon(Icons.copy, size: 18),
            ),
          SizedBox(
            width: 6,
          ),
          if (showArrow) Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: context.detailBoxColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: TextStyle(fontSize: 12)),
    );
  }
}
