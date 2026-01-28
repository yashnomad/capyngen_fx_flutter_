import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/services/account_initializer.dart';
import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/widget/account_selector_widget.dart';
import 'package:exness_clone/widget/button/app_button.dart';
import 'package:exness_clone/widget/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../config/flavor_config.dart';
import '../view/open_account/open_new_account.dart';
import '../view/account/withdraw_deposit/bloc/select_account_bloc.dart';
import '../view/trade/bloc/accounts_bloc.dart';
import '../view/trade/model/trade_account.dart';
import '../view/trade/widget/account_card_widget.dart';
import 'button/premium_app_button.dart';

class AccountsTabSheet extends StatefulWidget {
  const AccountsTabSheet({super.key});

  @override
  State<AccountsTabSheet> createState() => _AccountsTabSheetState();
}

class _AccountsTabSheetState extends State<AccountsTabSheet>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _headerController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _headerScaleAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _headerScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.elasticOut,
    ));

    _slideController.forward();
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _headerController.forward();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountsBloc>().add(RefreshAccounts());
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AccountInitializer(
      child: BlocBuilder<AccountsBloc, AccountsState>(
        builder: (context, state) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
              gradient: context.bottomSheetGradientColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: AppColor.blackColor.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SlideTransition(
              position: _slideAnimation,
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 8),
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 800),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: 0.7 + (0.3 * value),
                            child: Container(
                              width: 48,
                              height: 4,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppFlavorColor.primary.withOpacity(0.6),
                                    AppFlavorColor.primary.withOpacity(0.3),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    ScaleTransition(
                      scale: _headerScaleAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppFlavorColor.primary,
                                      AppFlavorColor.primary.withOpacity(0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppFlavorColor.primary
                                          .withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Icon(
                                  Icons.account_balance_wallet,
                                  color: AppColor.whiteColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Your Accounts',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      'Manage your trading portfolio',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColor.greyColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _buildAddAccountButton(
                                context,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: context.backgroundColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColor.mediumGrey.withOpacity(0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.blackColor.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TabBar(
                        isScrollable: false,
                        indicator: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppFlavorColor.primary,
                              AppFlavorColor.primary.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppFlavorColor.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorPadding: const EdgeInsets.all(4),
                        labelColor: AppColor.whiteColor,
                        unselectedLabelColor: AppColor.greyColor,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        dividerHeight: 0,
                        tabs: [
                          _buildPremiumTab('Live', state, 'live'),
                          _buildPremiumTab('Demo', state, 'demo'),
                          _buildPremiumTab('Archived', state, 'archived'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: BlocBuilder<AccountsBloc, AccountsState>(
                        builder: (context, state) {
                          if (state is AccountsLoading) {
                            return _buildLoadingState();
                          } else if (state is AccountsError) {
                            return _buildErrorState(
                              context,
                            );
                          } else if (state is AccountsLoaded) {
                            return TabBarView(
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                _buildAccountsList(
                                    context, state.liveAccounts, 'live'),
                                _buildAccountsList(
                                    context, state.demoAccounts, 'demo'),
                                _buildAccountsList(context,
                                    state.archivedAccounts, 'archived'),
                              ],
                            );
                          }

                          return _buildWelcomeState();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPremiumTab(String title, AccountsState state, String type) {
    int count = 0;
    Color badgeColor = AppColor.greyColor;

    if (state is AccountsLoaded) {
      switch (type) {
        case 'live':
          count = state.liveAccounts.length;
          badgeColor = AppColor.greenColor;
          break;
        case 'demo':
          count = state.demoAccounts.length;
          badgeColor = AppColor.blueColor;
          break;
        case 'archived':
          count = state.archivedAccounts.length;
          badgeColor = AppColor.greyColor;
          break;
      }
    }

    return Tab(
      height: 48,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title),
          if (state is AccountsLoaded && count > 0) ...[
            const SizedBox(width: 8),
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 500),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (0.2 * value),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          badgeColor,
                          badgeColor.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: badgeColor.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        color: AppColor.whiteColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddAccountButton(
    BuildContext context,
  ) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1200),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.rotate(
          angle: (1 - value) * 0.5,
          child: GestureDetector(
            onTap: () async {
              Navigator.pop(context);
              final result = await showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (context) => AccountTypeSelector(),
              );

              if (result == true) {
                context.read<AccountsBloc>().add(RefreshAccounts());
              }
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColor.greenColor,
                    AppColor.greenColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.greenColor.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(
                Icons.add,
                color: AppColor.whiteColor,
                size: 24,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppFlavorColor.primary.withOpacity(0.1),
                  AppFlavorColor.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(24),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1500),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.rotate(
                  angle: value * 6.28,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppFlavorColor.primary,
                          AppFlavorColor.primary.withOpacity(0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.account_balance_wallet,
                      color: AppColor.whiteColor,
                      size: 32,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading your accounts...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (0.2 * value),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColor.redColor.withOpacity(0.1),
                          AppColor.redColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColor.redColor.withOpacity(0.2),
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      size: 48,
                      color: Colors.red[400],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Unable to Load Accounts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your connection and try again',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColor.greyColor,
              ),
            ),
            const SizedBox(height: 24),
            PremiumAppButtonVariants.primary(
              text: 'Retry',
              icon: Icons.refresh,
              showIcon: true,
              onPressed: () {
                context.read<AccountsBloc>().add(LoadAccounts());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1000),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (0.2 * value),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppFlavorColor.primary.withOpacity(0.1),
                          AppFlavorColor.primary.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Icon(
                      Icons.account_circle_outlined,
                      size: 64,
                      color: AppFlavorColor.primary,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to Trading',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pull down to refresh and see your accounts',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColor.greyColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountsList(
      BuildContext context, List<Account> accounts, String type) {
    if (accounts.isEmpty) {
      return _buildEmptyState(
        type,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<AccountsBloc>().add(RefreshAccounts());
      },
      color: AppColor.darkBlueColor,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColor.blackColor
          : AppColor.whiteColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            if (type != 'archived' && accounts.isNotEmpty)
              _buildAccountSummary(accounts, type),
            const SizedBox(height: 16),
            ...accounts.asMap().entries.map((entry) {
              final index = entry.key;
              final account = entry.value;

              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 300 + (index * 100)),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildPremiumAccountCard(account, type, context),
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumAccountCard(
      Account account, String type, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        context.read<SelectedAccountCubit>().selectAccount(account);
        Navigator.pop(context);
      },
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 200),
        tween: Tween(begin: 1.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          AppColor.blackColor.withOpacity(0.8),
                          AppColor.blackColor.withOpacity(0.6),
                        ]
                      : [
                          AppColor.whiteColor,
                          const Color(0xFFFDFDFD),
                        ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColor.mediumGrey.withOpacity(0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: AccountCard(
                account: account,
                showSwipeActions: type != 'archived',
                onTap: () {
                  context.read<SelectedAccountCubit>().selectAccount(account);
                  Navigator.pop(context);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAccountSummary(List<Account> accounts, String type) {
    final totalBalance = accounts.fold<double>(
      0.0,
      (sum, account) => sum + (account.balance ?? 0.0),
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: type == 'live'
              ? [
                  AppColor.greenColor.withOpacity(0.1),
                  AppColor.greenColor.withOpacity(0.05),
                ]
              : [
                  AppColor.blueColor.withOpacity(0.1),
                  AppColor.blueColor.withOpacity(0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: type == 'live'
              ? AppColor.greenColor.withOpacity(0.3)
              : AppColor.blueColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: type == 'live' ? AppColor.greenColor : AppColor.blueColor,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(
              type == 'live' ? Icons.trending_up : Icons.play_circle_outline,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${accounts.length} ${type.toUpperCase()} ${accounts.length == 1 ? 'ACCOUNT' : 'ACCOUNTS'}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: type == 'live'
                        ? AppColor.greenColor
                        : AppColor.blueColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${totalBalance.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    String type,
  ) {
    Map<String, dynamic> config = {
      'live': {
        'title': 'No Live Accounts',
        'subtitle': 'Create a live account to start trading with real money',
        'icon': Icons.account_balance_wallet,
        'color': AppColor.greenColor,
      },
      'demo': {
        'title': 'No Demo Accounts',
        'subtitle': 'Create a demo account to practice trading risk-free',
        'icon': Icons.play_circle_outline,
        'color': AppColor.blueColor,
      },
      'archived': {
        'title': 'No Archived Accounts',
        'subtitle': 'Swipe on accounts to archive them when needed',
        'icon': Icons.archive_outlined,
        'color': AppColor.greyColor,
      },
    };

    final settings = config[type] ?? config['live']!;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (0.2 * value),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          settings['color'].withOpacity(0.1),
                          settings['color'].withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: settings['color'].withOpacity(0.2),
                      ),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Icon(
                      settings['icon'],
                      size: 64,
                      color: settings['color'],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              settings['title'],
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              settings['subtitle'],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColor.greyColor,
                height: 1.4,
              ),
            ),
            if (type != 'archived') ...[
              const SizedBox(height: 32),
              PremiumAppButtonVariants.primary(
                text: 'Create ${type.toUpperCase()} Account',
                icon: Icons.add_circle_outline,
                showIcon: true,
                onPressed: () async {
                  Navigator.pop(context);
                  final result = await showModalBottomSheet(
                    context: context,
                    backgroundColor: AppColor.transparent,
                    isScrollControlled: true,
                    builder: (context) => AccountTypeSelector(),
                  );

                  if (result == true) {
                    context.read<AccountsBloc>().add(RefreshAccounts());
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

}

class EmptyAccountState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const EmptyAccountState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (0.2 * value),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppFlavorColor.primary.withOpacity(0.1),
                          AppFlavorColor.primary.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Icon(
                      icon,
                      size: 64,
                      color: AppFlavorColor.primary,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColor.greyColor,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AccountSummaryWidget extends StatelessWidget {
  final Summary summary;

  const AccountSummaryWidget({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * value),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppFlavorColor.primary.withOpacity(0.1),
                  AppFlavorColor.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppFlavorColor.primary.withOpacity(0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  'Total',
                  '${summary.totalAccounts ?? 0}',
                  Icons.account_circle,
                  AppColor.darkBlueColor,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColor.mediumGrey.withOpacity(0.3),
                ),
                _buildSummaryItem(
                  'Active',
                  '${summary.activeAccounts ?? 0}',
                  Icons.check_circle,
                  AppColor.greenColor,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColor.mediumGrey.withOpacity(0.3),
                ),
                _buildSummaryItem(
                  'Balance',
                  '\$${((summary.totalBalance ?? 0) / 100).toStringAsFixed(2)}',
                  Icons.account_balance_wallet,
                  AppColor.blueColor,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColor.greyColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
