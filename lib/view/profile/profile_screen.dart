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
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final bgColor = isDark ? const Color(0xFF000000) : const Color(0xFFF5F5F7);

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Minimal App Bar ──
          SliverAppBar(
            pinned: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: bgColor,
            expandedHeight: 110,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
              title: Text(
                'Profile',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
              collapseMode: CollapseMode.pin,
            ),
            actions: [
              GestureDetector(
                onTap: () => Navigator.push(
                    context, SlidePageRoute(page: SettingsScreen())),
                child: Container(
                  margin: const EdgeInsets.only(right: 20, top: 8, bottom: 8),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    CupertinoIcons.settings,
                    size: 18,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),

          // ── User Header Card ──
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: BlocBuilder<UserProfileBloc, UserProfileState>(
                  builder: (context, state) {
                    if (state is UserProfileLoaded) {
                      return _buildUserHeaderCard(
                          context, state.profile.profile, isDark, surfaceColor);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),

          // ── Body Content ──
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection(
                        context: context,
                        title: 'Account',
                        isDark: isDark,
                        surfaceColor: surfaceColor,
                        children: [
                          BlocBuilder<UserProfileBloc, UserProfileState>(
                            builder: (context, state) {
                              if (state is UserProfileLoading) {
                                return const Loader();
                              } else if (state is UserProfileLoaded) {
                                final status =
                                    state.profile.profile?.kycStatus ??
                                        'pending';
                                final bank = state.profile.profile?.bank;

                                return Column(
                                  children: [
                                    _buildMenuItem(
                                      context: context,
                                      isDark: isDark,
                                      icon: CupertinoIcons.person_crop_circle,
                                      iconColor: AppFlavorColor.primary,
                                      title: 'Personal Details',
                                      trailing: status == 'verified'
                                          ? _buildKycPill(status,
                                              overrideLabel: 'KYC Verified')
                                          : null,
                                      onTap: () => Navigator.push(context,
                                          SlidePageRoute(page: ProfileInfo())),
                                      isFirst: true,
                                      isLast: bank == null,
                                    ),
                                    if (bank != null)
                                      _buildMenuItem(
                                        context: context,
                                        isDark: isDark,
                                        icon: CupertinoIcons.building_2_fill,
                                        iconColor: Colors.indigo,
                                        title: 'Bank Account',
                                        onTap: () => Navigator.push(
                                            context,
                                            SlidePageRoute(
                                                page: UpdateBankScreen())),
                                        isFirst: false,
                                        isLast: true,
                                      ),
                                    if (bank == null) ...[
                                      const SizedBox(height: 12),
                                      _buildCompleteProfileBanner(
                                          context, isDark),
                                    ],
                                  ],
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                          const SizedBox(height: 8),
                          _buildSingleItem(
                            context: context,
                            isDark: isDark,
                            icon: CupertinoIcons.creditcard_fill,
                            iconColor: const Color(0xFF34C759),
                            title: 'Savings',
                            onTap: () => Navigator.push(
                                context, SlidePageRoute(page: SavingScreen())),
                          ),
                        ],
                      ),
                      _buildSection(
                        context: context,
                        title: 'Referral Program',
                        isDark: isDark,
                        surfaceColor: surfaceColor,
                        children: [
                          _buildMenuItem(
                            context: context,
                            isDark: isDark,
                            icon: CupertinoIcons.gift_fill,
                            iconColor: const Color(0xFFAF52DE),
                            title:
                                'Earn income by introducing clients to ${FlavorAssets.appName}',
                            subtitle:
                                'Share your referral link and earn commissions',
                            onTap: () => showActionSheet(context),
                            isFirst: true,
                            isLast: true,
                          ),
                        ],
                      ),
                      _buildSection(
                        context: context,
                        title: 'Social Trading',
                        isDark: isDark,
                        surfaceColor: surfaceColor,
                        children: [
                          _buildMenuItem(
                            context: context,
                            isDark: isDark,
                            icon: CupertinoIcons.chart_bar_fill,
                            iconColor: AppFlavorColor.primary,
                            title: 'For Investors',
                            subtitle:
                                'Copy successful strategies of other traders',
                            onTap: () => Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => LeaderboardScreen())),
                            isFirst: true,
                            isLast: false,
                          ),
                          _buildMenuItem(
                            context: context,
                            isDark: isDark,
                            icon: CupertinoIcons.arrow_2_circlepath,
                            iconColor: const Color(0xFF007AFF),
                            title: 'My Copy',
                            subtitle: 'Your active Copy, MAM & PAMM accounts',
                            onTap: () => Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) =>
                                        TradingManagementScreen())),
                            isFirst: false,
                            isLast: false,
                          ),
                          _buildMenuItem(
                            context: context,
                            isDark: isDark,
                            icon: CupertinoIcons.group_solid,
                            iconColor: const Color(0xFF34C759),
                            title: 'IB Room',
                            subtitle: 'IB Reports',
                            onTap: () => Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => IbReport())),
                            isFirst: false,
                            isLast: true,
                          ),
                        ],
                      ),
                      _buildSection(
                        context: context,
                        title: 'Support',
                        isDark: isDark,
                        surfaceColor: surfaceColor,
                        children: [
                          _buildMenuItem(
                            context: context,
                            isDark: isDark,
                            icon: CupertinoIcons.question_circle_fill,
                            iconColor: const Color(0xFF007AFF),
                            title: 'Help Desk',
                            subtitle: 'Find answers to your questions',
                            onTap: () => Navigator.push(context,
                                SlidePageRoute(page: HelpdeskSupportScreen())),
                            isFirst: true,
                            isLast: false,
                          ),
                          _buildMenuItem(
                            context: context,
                            isDark: isDark,
                            icon: CupertinoIcons.doc_text_fill,
                            iconColor: const Color(0xFF5856D6),
                            title: 'Legal Documents',
                            subtitle: FlavorAssets.appName,
                            onTap: () => Navigator.push(context,
                                SlidePageRoute(page: LegalDocumentsScreen())),
                            isFirst: false,
                            isLast: false,
                          ),
                          _buildMenuItem(
                            context: context,
                            isDark: isDark,
                            icon: CupertinoIcons.chat_bubble_text_fill,
                            iconColor: const Color(0xFF32ADE6),
                            title: 'Feedback',
                            subtitle: "We'd love to hear your thoughts",
                            onTap: () => Navigator.push(context,
                                SlidePageRoute(page: FeedbackScreen())),
                            isFirst: false,
                            isLast: false,
                          ),
                          _buildMenuItem(
                            context: context,
                            isDark: isDark,
                            icon: CupertinoIcons.hand_thumbsup_fill,
                            iconColor: const Color(0xFFFF9F0A),
                            title: 'Rate the App',
                            subtitle: 'Love the app? Rate us!',
                            isFirst: false,
                            isLast: false,
                          ),
                          _buildMenuItem(
                            context: context,
                            isDark: isDark,
                            icon: CupertinoIcons.info_circle_fill,
                            iconColor: Colors.grey.shade500,
                            title: 'About the App',
                            onTap: () => Navigator.push(context,
                                SlidePageRoute(page: AboutAppScreen())),
                            isFirst: false,
                            isLast: true,
                          ),
                        ],
                      ),

                      // ── Log Out ──
                      _buildSection(
                        context: context,
                        title: '',
                        isDark: isDark,
                        surfaceColor: surfaceColor,
                        children: [
                          BlocBuilder<UserProfileBloc, UserProfileState>(
                            builder: (context, state) {
                              if (state is UserProfileLoaded) {
                                return _buildMenuItem(
                                  context: context,
                                  isDark: isDark,
                                  icon: CupertinoIcons.square_arrow_left_fill,
                                  iconColor: const Color(0xFFFF3B30),
                                  title: 'Log Out',
                                  subtitle: state.profile.profile?.email ?? '',
                                  onTap: () => showLogoutDialog(context),
                                  isFirst: true,
                                  isLast: true,
                                  titleColor: const Color(0xFFFF3B30),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // User Header Card
  // ─────────────────────────────────────────────
  Widget _buildUserHeaderCard(
      BuildContext context, Profile? profile, bool isDark, Color surfaceColor) {
    final name = profile?.fullName ?? '';
    final email = profile?.email ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final kycStatus = profile?.kycStatus ?? 'pending';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppFlavorColor.primary,
                      AppFlavorColor.darkPrimary
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Name & email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white54 : Colors.black45,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // KYC pill — top-right corner
        Positioned(
          top: 4,
          right: 16,
          child: _buildKycPill(kycStatus),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Section Builder
  // ─────────────────────────────────────────────
  Widget _buildSection({
    required BuildContext context,
    required String title,
    required bool isDark,
    required Color surfaceColor,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8, top: 20),
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          )
        else
          const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Menu Item (inside a section card)
  // ─────────────────────────────────────────────
  Widget _buildMenuItem({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
    required bool isFirst,
    required bool isLast,
  }) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.vertical(
              top: isFirst ? const Radius.circular(16) : Radius.zero,
              bottom: isLast ? const Radius.circular(16) : Radius.zero,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Icon container
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: iconColor, size: 18),
                  ),
                  const SizedBox(width: 14),
                  // Title + subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: titleColor ??
                                (isDark ? Colors.white : Colors.black87),
                          ),
                        ),
                        if (subtitle != null && subtitle.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white38 : Colors.black38,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Trailing widget or arrow
                  if (trailing != null) ...[
                    const SizedBox(width: 8),
                    trailing,
                  ] else if (onTap != null) ...[
                    const SizedBox(width: 8),
                    Icon(
                      CupertinoIcons.chevron_right,
                      size: 14,
                      color: isDark ? Colors.white24 : Colors.black26,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 0.5,
            indent: 64,
            endIndent: 0,
            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.07),
          ),
      ],
    );
  }

  // single standalone card item (not grouped)
  Widget _buildSingleItem({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return _buildMenuItem(
      context: context,
      isDark: isDark,
      icon: icon,
      iconColor: iconColor,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
      isFirst: true,
      isLast: true,
    );
  }

  // ─────────────────────────────────────────────
  // Complete Profile Banner
  // ─────────────────────────────────────────────
  Widget _buildCompleteProfileBanner(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.orange.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(CupertinoIcons.person_crop_circle_badge_plus,
                color: Colors.orange.shade700, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Complete Your Profile',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Add banking details to enable deposits',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () =>
                Navigator.push(context, SlidePageRoute(page: AddBankAccount())),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.shade600,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Add',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // KYC Status Pill
  // ─────────────────────────────────────────────
  Widget _buildKycPill(String status, {String? overrideLabel}) {
    Color bg;
    Color text;
    String label;
    IconData icon;

    switch (status) {
      case 'verified':
        bg = const Color(0xFFD4EDDA);
        text = const Color(0xFF1B7A36);
        label = overrideLabel ?? 'Verified';
        icon = CupertinoIcons.checkmark_seal_fill;
        break;
      case 'under_review':
        bg = const Color(0xFFD1ECF1);
        text = const Color(0xFF0C5460);
        label = overrideLabel ?? 'In Review';
        icon = CupertinoIcons.time;
        break;
      case 'rejected':
        bg = const Color(0xFFF8D7DA);
        text = const Color(0xFF721C24);
        label = overrideLabel ?? 'Rejected';
        icon = CupertinoIcons.xmark_circle_fill;
        break;
      default:
        bg = const Color(0xFFFFF3CD);
        text = const Color(0xFF856404);
        label = overrideLabel ?? 'Pending';
        icon = CupertinoIcons.exclamationmark_circle_fill;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: text),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: text,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // KYC navigation (unchanged logic)
  // ─────────────────────────────────────────────
  void _handleKycNavigation(
      BuildContext context, String status, bool hasDocuments) {
    switch (status) {
      case 'verified':
        Navigator.push(context, SlidePageRoute(page: ProfileInfo()));
        break;
      case 'rejected':
        _showRejectedDialog(context);
        break;
      case 'under_review':
        context.push('/kycStatus');
        break;
      case 'pending':
      default:
        if (hasDocuments) {
          context.push('/kycStatus');
        } else {
          context.push('/kycVerification');
        }
        break;
    }
  }

  // ─────────────────────────────────────────────
  // KYC status badge (legacy, for profile_screen backward compat)
  // ─────────────────────────────────────────────
  Widget _buildKycStatusBadge(String status) => _buildKycPill(status);

  void _showRejectedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Colors.red.shade600, size: 28),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Verification Rejected',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
            ),
          ],
        ),
        content: const Text(
          'Your identity verification was rejected. Please review your documents and submit again.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.push('/kycVerification');
            },
            child: const Text(
              'Try to Submit Again',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Referral bottom sheet (logic unchanged)
  // ─────────────────────────────────────────────
  void showActionSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Referral Program',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                BlocBuilder<UserProfileBloc, UserProfileState>(
                  builder: (context, state) {
                    if (state is UserProfileLoaded) {
                      return _buildModalItem(
                        isDark: isDark,
                        icon: CupertinoIcons.share,
                        iconColor: AppFlavorColor.primary,
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
                _buildModalItem(
                  isDark: isDark,
                  icon: CupertinoIcons.arrow_up_right_square,
                  iconColor: const Color(0xFF007AFF),
                  title: 'Learn more',
                  subtitle: 'Discover how our referral program works',
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalItem({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
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
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: isDark ? Colors.white : Colors.black,
                        )),
                    Text(subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.black45,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Logout Dialog (logic unchanged)
  // ─────────────────────────────────────────────
  void showLogoutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF3B30).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          CupertinoIcons.square_arrow_left_fill,
                          color: Color(0xFFFF3B30),
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Log Out?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You will be signed out of your account.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white54 : Colors.black45,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white12
                                  : Colors.black.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color:
                                      isDark ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            ApiService.logout(context);
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF3B30),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Center(
                              child: Text(
                                'Log Out',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
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

  // ─────────────────────────────────────────────
  // Legacy helpers (kept for backward compat with other references)
  // ─────────────────────────────────────────────
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
    return _buildMenuItem(
      context: context,
      isDark: Theme.of(context).brightness == Brightness.dark,
      icon: icon,
      iconColor: iconColor ?? Colors.blue,
      title: title,
      trailing: trailing,
      onTap: onTap,
      isFirst: true,
      isLast: true,
    );
  }

  Widget _buildKycDocumentsSection(DocumentType docType, String status) {
    return const SizedBox.shrink();
  }

  Widget _buildPremiumSectionCard(List<Widget> children) {
    return Column(children: children);
  }
}
