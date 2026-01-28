import 'package:exness_clone/config/flavor_config.dart';
import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/utils/common_utils.dart';
import 'package:exness_clone/view/chat_screen/chat_screen.dart';
import 'package:exness_clone/view/ib_room/ib_room_screen.dart';
import 'package:exness_clone/view/profile/about_app.dart';
import 'package:exness_clone/view/profile/add_account/add_account.dart';
import 'package:exness_clone/view/profile/banking/bank_update_screen.dart';
import 'package:exness_clone/view/profile/crypto_wallet/crypto_wallet.dart';
import 'package:exness_clone/view/profile/feedback/feedback.dart';
import 'package:exness_clone/view/profile/helpdesk/helpdesk.dart';
import 'package:exness_clone/view/profile/legal_documents.dart';
import 'package:exness_clone/view/profile/negative_balance_protection.dart';
import 'package:exness_clone/view/profile/open_ticket.dart';
import 'package:exness_clone/view/profile/profile_details_screen.dart';
import 'package:exness_clone/view/profile/profile_info.dart';
import 'package:exness_clone/view/profile/setting.dart';
import 'package:exness_clone/view/profile/swap_free_screen.dart';
import 'package:exness_clone/view/profile/user_profile/bloc/user_profile_bloc.dart';
import 'package:exness_clone/view/profile/user_profile/bloc/user_profile_state.dart';
import 'package:exness_clone/view/profile/user_profile/model/user_profile.dart';
import 'package:exness_clone/view/profile/virtual_private_server.dart';
import 'package:exness_clone/view/saving/saving_screen.dart';
import 'package:exness_clone/widget/button/premium_app_button.dart';
import 'package:exness_clone/widget/color.dart';
import 'package:exness_clone/widget/loader.dart';
import 'package:exness_clone/widget/slidepage_navigate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../config/flavor_assets.dart';
import '../../network/api_service.dart';
import '../investors/leaderboard_screen.dart';
import 'help_center.dart';
import 'trading_management/trading_management_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  bool _investorOptions = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();

    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
      _slideController.forward();
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

  Widget _buildAnimatedSection({
    required String title,
    required List<Widget> children,
    int delay = 0,
  }) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildPremiumSectionCard(children),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 0,
            expandedHeight: 140,
            backgroundColor: AppColor.transparent,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    context.appBarGradientColor,
                    context.appBarGradientColorSecond
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 24, bottom: 20),
                title: Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: context.profileIconColor,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: context.profileBoxColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(CupertinoIcons.settings),
                  onPressed: () {
                    Navigator.push(
                        context, SlidePageRoute(page: SettingsScreen()));
                  },
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAnimatedSection(
                    title: 'Account',
                    children: [
                      BlocBuilder<UserProfileBloc, UserProfileState>(
                        builder: (context, state) {
                          if (state is UserProfileLoading) {
                            return const Loader();
                          } else if (state is UserProfileLoaded) {
                            final status = state.profile.profile?.kycStatus;
                            CommonUtils.debugPrintWithTrace(status!);

                            return Column(
                              children: [
                                _buildPremiumBenefitItem(
                                  onTap: () {
                                    Navigator.push(context,
                                        SlidePageRoute(page: ProfileInfo()));
                                  },
                                  icon: Icons.person_rounded,
                                  title: 'Personal details',
                                  context: context,
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: status == 'verified'
                                            ? [
                                                Colors.green.shade100,
                                                Colors.green.shade200
                                              ]
                                            : [
                                                Colors.orange.shade100,
                                                Colors.orange.shade200
                                              ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: status == 'verified'
                                            ? Colors.green.withOpacity(0.3)
                                            : Colors.orange.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          status == 'verified'
                                              ? Icons.verified_rounded
                                              : Icons.pending_rounded,
                                          color: status == 'verified'
                                              ? Colors.green.shade700
                                              : Colors.orange.shade700,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          status == 'verified'
                                              ? 'Verified'
                                              : 'Not verified',
                                          style: TextStyle(
                                            color: status == 'verified'
                                                ? Colors.green.shade700
                                                : Colors.orange.shade700,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                BlocBuilder<UserProfileBloc, UserProfileState>(
                                  builder: (context, state) {
                                    if (state is UserProfileLoading) {
                                      return const Loader();
                                    } else if (state is UserProfileLoaded) {
                                      final bank = state.profile.profile?.bank;

                                      return bank != null
                                          ? _buildPremiumBenefitItem(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    SlidePageRoute(
                                                        page:
                                                            UpdateBankScreen()));
                                              },
                                              context: context,
                                              icon:
                                                  Icons.account_balance_rounded,
                                              title: 'Bank Account',
                                            )
                                          : Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.amber.shade50,
                                                    Colors.orange.shade50,
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: Colors.orange
                                                      .withOpacity(0.2),
                                                  width: 1,
                                                ),
                                              ),
                                              padding: const EdgeInsets.all(20),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(12),
                                                        decoration:
                                                            BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              Colors.orange
                                                                  .shade100,
                                                              Colors.orange
                                                                  .shade200,
                                                            ],
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(16),
                                                        ),
                                                        child: Icon(
                                                          CupertinoIcons
                                                              .person_circle,
                                                          size: 28,
                                                          color: Colors
                                                              .orange.shade700,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 16),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              'Complete Your Profile',
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color: Colors
                                                                    .orange
                                                                    .shade800,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 4),
                                                            Text(
                                                              'Fill in your account details to make your first deposit',
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: Colors
                                                                    .orange
                                                                    .shade700,
                                                                height: 1.3,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 16),
                                                  PremiumAppButton(
                                                    text: 'Complete Profile',
                                                    icon: Icons
                                                        .person_add_rounded,
                                                    showIcon: true,
                                                    height: 48,
                                                    backgroundColor:
                                                        Colors.orange.shade600,
                                                    foregroundColor:
                                                        Colors.white,
                                                    enableGradient: false,
                                                    onPressed: () {
                                                      Navigator.push(
                                                          context,
                                                          SlidePageRoute(
                                                              page:
                                                                  AddBankAccount()));
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  },
                                ),
                              ],
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      ),
                      _buildPremiumBenefitItem(
                        onTap: () {
                          Navigator.push(
                              context, SlidePageRoute(page: SavingScreen()));
                        },
                        context: context,
                        icon: Icons.credit_card,
                        title: 'Savings',
                      )
                    ],
                  ),
                  _buildAnimatedSection(
                    title: 'Referral Program',
                    children: [
                      _buildPremiumBenefitItem(
                        context: context,
                        icon: Icons.account_balance_wallet_rounded,
                        iconColor: Colors.purple.shade600,
                        title:
                            'Earn stable income by introducing clients to ${FlavorAssets.appName}',
                        subtitle: Text(
                          'Share your referral link and earn commissions',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () {
                          showActionSheet(context);
                        },
                      ),
                    ],
                  ),
                  _buildAnimatedSection(
                    title: 'Social Trading',
                    children: [
                      _buildPremiumBenefitItem(
                        onTap: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => LeaderboardScreen()));
                        },
                        context: context,
                        icon: Icons.person_add,
                        iconColor: AppFlavorColor.primary,
                        title: 'For investors',
                        subtitle: Text(
                          'Copy successful strategies of other traders',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      _buildPremiumBenefitItem(
                        onTap: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) =>
                                      TradingManagementScreen()));
                        },
                        context: context,
                        icon: Icons.person_add,
                        iconColor: AppFlavorColor.primary,
                        title: 'My Copy',
                        subtitle: Text(
                          'Your active Copy, MAM & PAMM accounts',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      _buildPremiumBenefitItem(
                        onTap: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => IbReport()));
                        },
                        context: context,
                        icon: Icons.group_rounded,
                        iconColor: Colors.green.shade600,
                        title: 'IB Room',
                        subtitle: Text(
                          'IB Reports',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  _buildAnimatedSection(
                    title: 'Support',
                    children: [
                      _buildPremiumBenefitItem(
                        icon: CupertinoIcons.question_circle_fill,
                        iconColor: Colors.blue.shade600,
                        context: context,
                        title: 'Help Desk',
                        onTap: () {
                          Navigator.push(context,
                              SlidePageRoute(page: HelpdeskSupportScreen()));
                        },
                        subtitle: Text(
                          'Find answers to your questions',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      _buildPremiumBenefitItem(
                        icon: CupertinoIcons.doc_text_fill,
                        iconColor: Colors.indigo.shade600,
                        context: context,
                        onTap: () {
                          Navigator.push(context,
                              SlidePageRoute(page: LegalDocumentsScreen()));
                        },
                        title: 'Legal Documents',
                        subtitle: Text(
                          FlavorAssets.appName,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      _buildPremiumBenefitItem(
                        icon: Icons.feedback_rounded,
                        iconColor: Colors.teal.shade600,
                        context: context,
                        title: 'Feedback',
                        onTap: () {
                          Navigator.push(
                              context, SlidePageRoute(page: FeedbackScreen()));
                        },
                        subtitle: Text(
                          "We'd love to hear your thoughts on our platform",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      _buildPremiumBenefitItem(
                        icon: CupertinoIcons.hand_thumbsup_fill,
                        iconColor: Colors.pink.shade600,
                        title: 'Rate the App',
                        context: context,
                        subtitle: Text(
                          "Love the app? Rate us or reach out for support",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      _buildPremiumBenefitItem(
                        icon: CupertinoIcons.info_circle_fill,
                        iconColor: Colors.grey.shade600,
                        title: 'About the app',
                        context: context,
                        onTap: () {
                          Navigator.push(
                              context, SlidePageRoute(page: AboutAppScreen()));
                        },
                      ),
                    ],
                  ),
                  _buildAnimatedSection(
                    title: '',
                    children: [
                      BlocBuilder<UserProfileBloc, UserProfileState>(
                        builder: (context, state) {
                          if (state is UserProfileLoading) {
                            return const Loader();
                          } else if (state is UserProfileError) {
                            return const SizedBox.shrink();
                          } else if (state is UserProfileLoaded) {
                            return _buildPremiumBenefitItem(
                              icon: Icons.logout_rounded,
                              title: 'Log Out',
                              onTap: () {
                                showLogoutDialog(context);
                              },
                              iconColor: Colors.red.shade600,
                              context: context,
                              subtitle: Text(
                                state.profile.profile?.email ?? '',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumBenefitItem({
    required IconData icon,
    required String title,
    Widget? subtitle,
    Widget? trailing,
    IconData? arrowIcon,
    Function()? onTap,
    Color? iconColor,
    required BuildContext context,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.transparent,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        (iconColor ?? Colors.blue.shade600).withOpacity(0.1),
                        (iconColor ?? Colors.blue.shade600).withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color:
                          (iconColor ?? Colors.blue.shade600).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? Colors.blue.shade600,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                          letterSpacing: 0.2,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        subtitle,
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 12),
                  trailing,
                ],
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    arrowIcon ?? Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumInvestorsOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(left: 20, right: 4, bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: context.scaffoldBackgroundColor,
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? AppFlavorColor.icon,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.appBarGradientColor,
                context.appBarGradientColorSecond,
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 24),
                BlocBuilder<UserProfileBloc, UserProfileState>(
                  builder: (context, state) {
                    if (state is UserProfileLoading) {
                      return const Loader();
                    } else if (state is UserProfileError) {
                      return const SizedBox.shrink();
                    } else if (state is UserProfileLoaded) {
                      return _buildPremiumModalItem(
                        icon: Icons.share_rounded,
                        title: 'Share the link',
                        subtitle: 'Share your referral link with friends',
                        onTap: () {
                          CommonUtils.shareApp(context,
                              state.profile.profile?.referedCode ?? '');
                          Navigator.pop(context);
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                _buildPremiumModalItem(
                  icon: Icons.open_in_new_rounded,
                  title: 'Learn more',
                  subtitle: 'Discover how our referral program works',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPremiumModalItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: AppFlavorColor.buttonGradient
                          .map((color) => color.withOpacity(0.2))
                          .toList()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: AppFlavorColor.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.red.shade50],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.red.shade100, Colors.red.shade200],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.logout_rounded,
                          color: context.tabLabelColor,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Are you sure?',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppFlavorColor.darkPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You will be logged out of your account',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: PremiumAppButton(
                          text: 'Cancel',
                          enableGradient: false,
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.grey.shade700,
                          enableShadow: false,
                          height: 48,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PremiumAppButton(
                          text: 'Log Out',
                          backgroundColor: AppFlavorColor.primary,
                          foregroundColor: AppColor.whiteColor,
                          enableGradient: false,
                          height: 48,
                          icon: Icons.logout_rounded,
                          showIcon: true,
                          onPressed: () {
                            Navigator.pop(context);
                            ApiService.logout(context);
                          },
                        ),
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
  }

  Widget _buildPremiumSectionCard(List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.appBarGradientColor,
            context.appBarGradientColorSecond,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
