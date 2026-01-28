import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/network/api_endpoint.dart';
import 'package:exness_clone/network/api_service.dart';
import 'package:exness_clone/provider/datafeed_provider.dart';
import 'package:exness_clone/services/balance_masked.dart';
import 'package:exness_clone/services/switch_account_service.dart';
import 'package:exness_clone/services/storage_service.dart';
import 'package:exness_clone/services/data_feed_ws.dart';
import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/utils/common_utils.dart';
import 'package:exness_clone/utils/snack_bar.dart';
import 'package:exness_clone/view/account/notification_screen.dart';
import 'package:exness_clone/view/account/price_alert_screen.dart';
import 'package:exness_clone/view/account/search/search_symbol_screen.dart';
import 'package:exness_clone/view/account/search_coin.dart';
import 'package:exness_clone/view/account/widget/account_symbol_section.dart';
import 'package:exness_clone/view/account/widget/compact_icon.dart';
import 'package:exness_clone/view/account/widget/new_trading_view.dart';
import 'package:exness_clone/view/account/widget/trading_item.dart';
import 'package:exness_clone/view/account/withdraw_deposit/bloc/select_account_bloc.dart';
import 'package:exness_clone/widget/loader.dart';
import 'package:exness_clone/widget/slidepage_navigate.dart';
import 'package:exness_clone/widget/touchable_effect.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:exness_clone/utils/bottom_sheets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../cubit/symbol/symbol_cubit.dart';
import '../../cubit/symbol/symbol_state.dart';
import '../../models/symbol_model.dart';
import '../../services/symbol_service.dart';
import '../../services/trading_view_service.dart';
import '../../widget/account_bottom_sheet.dart';
import '../../widget/button/premium_icon_button.dart';
import '../trade/bloc/accounts_bloc.dart';
import '../trade/model/trade_account.dart';
import 'btc_chart/btc_chart_screen_updated.dart';
import 'chart_data/dummy_chart/dummy_chart_data.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen>
    with SingleTickerProviderStateMixin {
  @override
  void dispose() {
    tradeUserIdVN.dispose();
    super.dispose();
  }

  void _route(Widget child) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => child));
  }

  final ValueNotifier<String?> tradeUserIdVN = ValueNotifier(null);

  void _onAccountChanged(Account account) {
    final id = account.id;
    if (tradeUserIdVN.value != id) {
      tradeUserIdVN.value = id;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: context.backgroundColor,
        body: RefreshIndicator(
            onRefresh: () async {
              context.read<AccountsBloc>().add(RefreshAccounts());
              await Future.delayed(Duration(seconds: 1));
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Expanded(
                        flex: 0,
                        child: Container(
                          decoration: BoxDecoration(),
                          child: SafeArea(
                            bottom: false,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  height: 56,
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    children: [
                                      const Text(
                                        "Accounts",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      Spacer(),
                                      PremiumIconButton(
                                        icon: Icons.notifications_none_rounded,
                                        onPressed: () =>
                                            _route(NotificationScreen()),
                                        tooltip: 'Notifications',
                                        size: 24,
                                        backgroundColor: AppColor.transparent,
                                      ),
                                      const SizedBox(width: 16),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: SwitchAccountService(
                                    accountBuilder: (context, account) {
                                      _onAccountChanged(account);
                                      return Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                AppFlavorColor.primary,
                                                AppFlavorColor.darkPrimary
                                              ]),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppFlavorColor.primary
                                                  .withOpacity(0.2),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                AppColor.whiteColor
                                                    .withOpacity(0.1),
                                                AppColor.transparent,
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    UIBottomSheets
                                                        .accountBottomSheet<
                                                                String>(context,
                                                            AccountsTabSheet());
                                                  },
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 6),
                                                    decoration: BoxDecoration(
                                                      color: AppColor.whiteColor
                                                          .withOpacity(0.15),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      border: Border.all(
                                                        color: AppColor
                                                            .whiteColor
                                                            .withOpacity(0.2),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .account_balance_wallet,
                                                          color: AppColor
                                                              .whiteColor,
                                                          size: 14,
                                                        ),
                                                        const SizedBox(
                                                            width: 6),
                                                        Text(
                                                          "Account",
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: AppColor
                                                                .whiteColor,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 4),
                                                        Icon(
                                                          Icons
                                                              .keyboard_arrow_down_rounded,
                                                          color: AppColor
                                                              .whiteColor,
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
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Container(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8,
                                                                    vertical:
                                                                        3),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: AppColor
                                                                      .whiteColor
                                                                      .withOpacity(
                                                                          0.2),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              12),
                                                                ),
                                                                child: Text(
                                                                  account.group
                                                                          ?.groupName ??
                                                                      'Standard',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    color: AppColor
                                                                        .whiteColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 6),
                                                              Container(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8,
                                                                    vertical:
                                                                        3),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: AppColor
                                                                      .whiteColor
                                                                      .withOpacity(
                                                                          0.15),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              12),
                                                                ),
                                                                child: Text(
                                                                  CommonUtils.capitalizeFirst(
                                                                          account
                                                                              .accountType) ??
                                                                      '',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    color: AppColor
                                                                        .whiteColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 4),
                                                          Text(
                                                            "# ${account.accountId}",
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              color: AppColor
                                                                  .whiteColor
                                                                  .withOpacity(
                                                                      0.7),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    _balanceMasked(account),
                                                  ],
                                                ),
                                                const SizedBox(height: 16),
                                                _transactionSection(context)
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      AccountSymbolSection(),
                    ],
                  ),
                ),
              ],
            )));
  }

  Widget _balanceMasked(Account account) {
    return BalanceMasked(
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
                CommonUtils.formatBalance(account.balance?.toDouble() ?? 0),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColor.whiteColor,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
    );
  }

  Widget _transactionSection(BuildContext context) {
    return Row(
      children: [
        CompactActionButton(
          icon: CupertinoIcons.arrow_down_circle,
          label: "Deposit",
          color: AppColor.greenColor,
          onTap: () => context.push('/depositFundScreen'),
        ),
        const SizedBox(width: 20),
        CompactActionButton(
          icon: CupertinoIcons.arrow_up_right_circle,
          label: "Withdraw",
          color: AppColor.blueColor,
          onTap: () => context.push('/withdrawFundsScreen'),
        ),
        const SizedBox(width: 20),
        ValueListenableBuilder<String?>(
          valueListenable: tradeUserIdVN,
          builder: (_, tradeUserId, __) {
            return CompactActionButton(
              icon: Icons.history,
              label: "History",
              color: AppColor.darkBlueColor,
              onTap: tradeUserId == null
                  ? () => SnackBarService.showSnackBar(
                        message: 'No account selected',
                      )
                  : () => context.pushNamed(
                        'transactionScreen',
                        extra: tradeUserId,
                      ),
            );
          },
        ),
        const SizedBox(width: 20),
        CompactActionButton(
          icon: Icons.swap_horiz,
          label: "Transfer",
          color: AppColor.greyColor,
          onTap: () => context.pushNamed('internalTransfer'),
        ),
      ],
    );
  }

  Widget buildCompactActionButton(IconData icon, String label, Color color,
      {VoidCallback? onTap}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColor.whiteColor.withOpacity(0.15),
                AppColor.whiteColor.withOpacity(0.05),
              ],
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColor.whiteColor.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColor.blackColor.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              splashColor: AppColor.whiteColor.withOpacity(0.3),
              highlightColor: AppColor.transparent,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      color,
                      color.withOpacity(0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: AppColor.whiteColor,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColor.whiteColor,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}
