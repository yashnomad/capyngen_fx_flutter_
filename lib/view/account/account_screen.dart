import 'dart:ui';
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
import '../../widget/verification_status_banner.dart';
import '../profile/user_profile/bloc/user_profile_bloc.dart';
import '../profile/user_profile/bloc/user_profile_event.dart';
import '../profile/user_profile/bloc/user_profile_state.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    // Only fetch if profile isn't already loaded (avoids overwriting optimistic KYC status)
    final bloc = context.read<UserProfileBloc>();
    if (bloc.state is! UserProfileLoaded) {
      bloc.add(FetchUserProfile());
    }
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
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
          await Future.delayed(const Duration(seconds: 1));
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
                      decoration: const BoxDecoration(),
                      child: SafeArea(
                        bottom: false,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildAppBar(),
                            const VerificationStatusBanner(),
                            SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.15),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: _animController,
                                curve: Curves.easeOutCubic,
                              )),
                              child: FadeTransition(
                                opacity: CurvedAnimation(
                                  parent: _animController,
                                  curve: Curves.easeOut,
                                ),
                                child: SwitchAccountService(
                                  accountBuilder: (context, account) {
                                    _onAccountChanged(account);
                                    return _AccountCard(
                                      account: account,
                                      tradeUserIdVN: tradeUserIdVN,
                                    );
                                  },
                                ),
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
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 52,
        child: Row(
          children: [
            const Text(
              "Welcome Back,",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.3,
              ),
            ),
            const Spacer(),
            GestureDetector(
                onTap: () => _route(NotificationScreen()),
                child: Icon(Icons.notifications_active_outlined,
                    size: 24, color: Colors.black)),
            // PremiumIconButton(
            //   icon: Icons.notifications_none_rounded,
            //   onPressed: () => _route(NotificationScreen()),
            //   tooltip: 'Notifications',
            //   size: 22,
            //   backgroundColor: AppColor.transparent,
            // ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
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

// ─────────────────────────────────────────────────────────
// Account Card
// ─────────────────────────────────────────────────────────
class _AccountCard extends StatefulWidget {
  final Account account;
  final ValueNotifier<String?> tradeUserIdVN;

  const _AccountCard({
    required this.account,
    required this.tradeUserIdVN,
  });

  @override
  State<_AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<_AccountCard>
    with TickerProviderStateMixin {
  late AnimationController _actionsController;
  Account get account => widget.account;

  @override
  void initState() {
    super.initState();
    _actionsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _actionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppFlavorColor.primary,
              AppFlavorColor.darkPrimary,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppFlavorColor.primary.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Row 1: Switcher + Balance ──
              Row(
                children: [
                  _buildSwitcher(context),
                  const SizedBox(width: 6),
                  _metaChip(account.group?.groupName ?? 'Standard'),
                  const SizedBox(width: 4),
                  _metaChip(
                    CommonUtils.capitalizeFirst(account.accountType) ?? '',
                  ),
                  const Spacer(),
                  Text(
                    "#${account.accountId}",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.4),
                      fontWeight: FontWeight.w400,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ── Balance ──
              _buildBalance(),

              const SizedBox(height: 16),

              // ── Actions ──
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitcher(BuildContext context) {
    return GestureDetector(
      onTap: () => UIBottomSheets.accountBottomSheet<String>(
        context,
        AccountsTabSheet(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Account",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white.withOpacity(0.7),
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _metaChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Colors.white.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildBalance() {
    return BalanceMasked(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: child,
        ),
        child: Row(
          key: ValueKey(account.accountId),
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              CommonUtils.formatBalance(account.balance?.toDouble() ?? 0),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.5,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              "USD",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    final actions = <_ActionData>[
      _ActionData(
        icon: CupertinoIcons.arrow_down_circle_fill,
        label: "Deposit",
        colors: [const Color(0xFF22C55E), const Color(0xFF16A34A)],
        onTap: () => context.push('/depositFundScreen'),
      ),
      _ActionData(
        icon: CupertinoIcons.arrow_up_right_circle_fill,
        label: "Withdraw",
        colors: [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
        onTap: () => context.push('/withdrawFundsScreen'),
      ),
      _ActionData(
        icon: CupertinoIcons.clock_fill,
        label: "History",
        colors: [const Color(0xFFA855F7), const Color(0xFF9333EA)],
        onTap: () {
          final id = widget.tradeUserIdVN.value;
          if (id == null) {
            SnackBarService.showSnackBar(message: 'No account selected');
          } else {
            context.pushNamed('transactionScreen', extra: id);
          }
        },
      ),
      _ActionData(
        icon: CupertinoIcons.arrow_right_arrow_left,
        label: "Transfer",
        colors: [const Color(0xFFF59E0B), const Color(0xFFD97706)],
        onTap: () => context.pushNamed('internalTransfer'),
      ),
    ];

    return Row(
      children: List.generate(actions.length, (i) {
        final delay = i * 0.15;
        return Expanded(
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.4),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _actionsController,
              curve: Interval(delay, (delay + 0.6).clamp(0, 1),
                  curve: Curves.easeOutCubic),
            )),
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: _actionsController,
                curve: Interval(delay, (delay + 0.5).clamp(0, 1),
                    curve: Curves.easeOut),
              ),
              child: _ActionButton(data: actions[i]),
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Action Data
// ─────────────────────────────────────────────────────────
class _ActionData {
  final IconData icon;
  final String label;
  final List<Color> colors;
  final VoidCallback onTap;

  const _ActionData({
    required this.icon,
    required this.label,
    required this.colors,
    required this.onTap,
  });
}

// ─────────────────────────────────────────────────────────
// Action Button with tap animation
// ─────────────────────────────────────────────────────────
class _ActionButton extends StatefulWidget {
  final _ActionData data;

  const _ActionButton({required this.data});

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _tapCtrl;
  late Animation<double> _scale;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _tapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _tapCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _tapCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _tapCtrl.forward();
        setState(() => _pressed = true);
      },
      onTapUp: (_) {
        _tapCtrl.reverse();
        setState(() => _pressed = false);
        widget.data.onTap();
      },
      onTapCancel: () {
        _tapCtrl.reverse();
        setState(() => _pressed = false);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.data.colors,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: widget.data.colors.first
                        .withOpacity(_pressed ? 0.5 : 0.3),
                    blurRadius: _pressed ? 12 : 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                widget.data.icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.data.label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.65),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
