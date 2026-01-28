import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/services/storage_service.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/widget/button/premium_app_button.dart'; // Import the premium button
import 'package:exness_clone/widget/shimmer/account_card_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../config/flavor_config.dart';
import '../theme/app_colors.dart';
import '../view/account/widget/label_icon_button.dart';
import '../view/account/withdraw_deposit/bloc/select_account_bloc.dart';
import '../view/trade/bloc/accounts_bloc.dart';
import '../view/trade/model/trade_account.dart';
import '../widget/account_selector_widget.dart';

typedef AccountBuilder = Widget Function(BuildContext context, Account account);

class SwitchAccountService extends StatefulWidget {
  final AccountBuilder accountBuilder;
  final Widget? emptyChild;

  const SwitchAccountService(
      {super.key, required this.accountBuilder, this.emptyChild});

  @override
  State<SwitchAccountService> createState() => _SwitchAccountServiceState();
}

class _SwitchAccountServiceState extends State<SwitchAccountService>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _fadeController.forward();
        _slideController.forward();
      }
    });
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountsBloc, AccountsState>(
      listenWhen: (previous, current) =>
          previous != current && current is AccountsLoaded,
      listener: (context, state) {
        if (state is AccountsLoaded) {
          final cubit = context.read<SelectedAccountCubit>();

          if (state.liveAccounts.isEmpty && state.demoAccounts.isEmpty) {
            cubit.clearAccount();
            return;
          }

          if (cubit.state == null) {
            final firstLive =
                state.liveAccounts.isNotEmpty ? state.liveAccounts.first : null;
            final firstDemo =
                state.demoAccounts.isNotEmpty ? state.demoAccounts.first : null;

            if (firstLive != null) {
              cubit.selectAccount(firstLive);
            } else if (firstDemo != null) {
              cubit.selectAccount(firstDemo);
            }
          }
        }
      },
      child: BlocBuilder<AccountsBloc, AccountsState>(
        builder: (context, accountsState) {
          final selectedAccount = context.watch<SelectedAccountCubit>().state;

          if (accountsState is AccountsLoading) {
            return widget.emptyChild ??
                AccountCardShimmer(
                  slideAnimation: _slideAnimation,
                  fadeAnimation: _fadeAnimation,
                );
          }

          if (selectedAccount == null) {
            return widget.emptyChild ?? _buildPremiumEmptyState(context);
          }

          if (accountsState is AccountsLoaded) {
            final allAccounts = [
              ...accountsState.liveAccounts,
              ...accountsState.demoAccounts,
            ];

            final exists = allAccounts.any((a) => a.id == selectedAccount.id);

            if (!exists) {
              context.read<SelectedAccountCubit>().clearAccount();
              return widget.emptyChild ?? _buildPremiumEmptyState(context);
            }

            final updatedAccount =
                allAccounts.firstWhere((a) => a.id == selectedAccount.id);

            return widget.accountBuilder(context, updatedAccount);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildPremiumEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isDark ? Colors.grey.shade800 : AppColor.whiteColor,
                isDark ? Colors.grey.shade800 : AppColor.whiteColor,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.borderColor,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Left Content (Compact)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppFlavorColor.primary.withOpacity(0.6),
                                    AppFlavorColor.primary.withOpacity(0.2),
                                  ]),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.account_balance_wallet_rounded,
                              color: AppFlavorColor.icon,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Let's Get Started! 🚀",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColor.whiteColor
                                        : Colors.black87,
                                  ),
                                ),
                                Text(
                                  "Create Your First Account",
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: AppFlavorColor.primary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Compact Description
                      Text(
                        "No trading accounts found. Create one to start your trading journey!",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Compact Button
                      PremiumAppButton(
                        text: "Add Account",
                        icon: Icons.add_rounded,
                        showIcon: true,
                        height: 42,

                        backgroundColor: AppFlavorColor.primary,
                        foregroundColor: AppColor.whiteColor,

                        // backgroundColor: Colors.orange.shade600,
                        // foregroundColor: Colors.white,

                        enableGradient: false,
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppFlavorColor.background,
                        ),
                        onPressed: () async {
                          final result = await showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (context) => Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColor.whiteColor,
                                    Colors.blue.shade50,
                                  ],
                                ),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, -4),
                                  ),
                                ],
                              ),
                              child: AccountTypeSelector(),
                            ),
                          );

                          if (result == true && mounted) {
                            context.read<AccountsBloc>().add(RefreshAccounts());
                          }
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Compact Right Side Illustration
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppFlavorColor.primary.withOpacity(0.6),
                          AppFlavorColor.primary.withOpacity(0.2),
                        ]),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: context.borderColor,
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Main Icon
                      Icon(Icons.trending_up_rounded,
                          size: 28, color: AppFlavorColor.icon),
                      // Small floating elements
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppFlavorColor.icon,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 8,
                        child: Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppFlavorColor.icon,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
