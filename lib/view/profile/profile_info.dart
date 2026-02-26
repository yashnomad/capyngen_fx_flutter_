import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/utils/common_utils.dart';
import 'package:exness_clone/utils/snack_bar.dart';
import 'package:exness_clone/view/profile/user_profile/bloc/user_profile_bloc.dart';
import 'package:exness_clone/view/profile/user_profile/bloc/user_profile_state.dart';
import 'package:exness_clone/view/profile/user_profile/model/user_profile.dart';
import 'package:exness_clone/view/profile/user_profile/update_profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../widget/slidepage_navigate.dart';
import 'add_account/add_account.dart';
import 'package:exness_clone/view/auth_screen/verification/document_verification_screen.dart';

class ProfileInfo extends StatefulWidget {
  const ProfileInfo({super.key});

  @override
  State<ProfileInfo> createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo>
    with TickerProviderStateMixin {
  late TabController _tabController;

  late AnimationController _heroController;
  late Animation<double> _heroFade;
  late Animation<Offset> _heroSlide;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _heroController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _heroFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.easeOut),
    );

    _heroSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _heroController, curve: Curves.easeOutCubic));

    Future.delayed(const Duration(milliseconds: 80), () {
      _heroController.forward();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _heroController.dispose();
    super.dispose();
  }

  Color get _accent => AppFlavorColor.primary;

  // ─────────────────────────────────────────────────────────
  // ROOT BUILD
  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);

    return Scaffold(
      backgroundColor: bg,
      body: BlocBuilder<UserProfileBloc, UserProfileState>(
        builder: (context, state) {
          if (state is UserProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserProfileLoaded) {
            final user = state.profile.profile;
            if (user == null) return const SizedBox.shrink();

            return FadeTransition(
              opacity: _heroFade,
              child: SlideTransition(
                position: _heroSlide,
                child: Column(
                  children: [
                    // ── Hero Header ──
                    _buildHeroHeader(user, isDark),
                    // ── Custom Tab Bar ──
                    _buildTabBar(isDark),
                    // ── Tab Content ──
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildOverviewTab(user, isDark),
                          _buildKycTab(user, isDark),
                          _buildBankingTab(user, isDark),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // HERO HEADER
  // ─────────────────────────────────────────────────────────
  Widget _buildHeroHeader(Profile profile, bool isDark) {
    final name = profile.fullName ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final kycStatus = profile.kycStatus ?? 'pending';

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 24,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          // ── Nav Row ──
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    CupertinoIcons.chevron_back,
                    size: 18,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Personal Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                  letterSpacing: -0.2,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<UserProfileBloc>(),
                      child: const UpdateProfileScreen(),
                    ),
                  ),
                ),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    CupertinoIcons.pencil,
                    size: 18,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // ── Avatar + Name ──
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_accent, AppFlavorColor.darkPrimary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _accent.withOpacity(0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // Verified dot
              if (kycStatus == 'verified')
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: const Color(0xFF34C759),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color:
                              isDark ? const Color(0xFF1C1C1E) : Colors.white,
                          width: 2.5),
                    ),
                    child:
                        const Icon(Icons.check, size: 12, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile.email ?? '',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white54 : Colors.black45,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 14),
          // ── Stats row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatPill(
                  CupertinoIcons.number, 'ID: ${profile.accountId ?? '—'}',
                  isDark: isDark),
              const SizedBox(width: 8),
              _buildStatPill(
                CupertinoIcons.calendar,
                CommonUtils.formatDateTime(profile.createdAt),
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill(IconData icon, String label, {required bool isDark}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.08)
            : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: isDark ? Colors.white54 : Colors.black45),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // CUSTOM TAB BAR
  // ─────────────────────────────────────────────────────────
  Widget _buildTabBar(bool isDark) {
    final tabs = [
      (CupertinoIcons.square_grid_2x2_fill, 'Overview'),
      (CupertinoIcons.shield_fill, 'KYC Status'),
      (CupertinoIcons.building_2_fill, 'Banking'),
    ];

    return Container(
      color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
        ),
        child: TabBar(
          controller: _tabController,
          dividerColor: Colors.transparent,
          indicator: BoxDecoration(
            gradient: LinearGradient(
              colors: [_accent, AppFlavorColor.darkPrimary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _accent.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.all(3),
          labelPadding: EdgeInsets.zero,
          labelColor: Colors.white,
          unselectedLabelColor: isDark ? Colors.white54 : Colors.black45,
          labelStyle: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.2),
          unselectedLabelStyle:
              const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          tabs: tabs
              .map((t) => Tab(
                    height: 44,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(t.$1, size: 13),
                        const SizedBox(width: 5),
                        Text(t.$2),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // OVERVIEW TAB
  // ─────────────────────────────────────────────────────────
  Widget _buildOverviewTab(Profile profile, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Account Information', isDark),
          _infoCard(isDark, children: [
            _infoRow(
                icon: CupertinoIcons.person_fill,
                label: 'Full Name',
                value: profile.fullName ?? '—',
                isDark: isDark),
            _divider(isDark),
            _infoRow(
                icon: CupertinoIcons.number,
                label: 'Account ID',
                value: profile.accountId ?? '—',
                isDark: isDark),
            _divider(isDark),
            _infoRow(
                icon: CupertinoIcons.mail_solid,
                label: 'Email',
                value: profile.email ?? '—',
                isDark: isDark),
            _divider(isDark),
            _infoRow(
                icon: CupertinoIcons.globe,
                label: 'Country',
                value: profile.country ?? '—',
                isDark: isDark),
            _divider(isDark),
            _infoRow(
                icon: CupertinoIcons.location_solid,
                label: 'City',
                value: profile.city ?? '—',
                isDark: isDark),
          ]),
          const SizedBox(height: 20),
          _sectionLabel('Status', isDark),
          _infoCard(isDark, children: [
            _infoRow(
              icon: CupertinoIcons.check_mark_circled_solid,
              label: 'Verification',
              value:
                  profile.verificationStatus == true ? 'Verified' : 'Pending',
              isDark: isDark,
              valueColor: profile.verificationStatus == true
                  ? const Color(0xFF34C759)
                  : const Color(0xFFFF9F0A),
            ),
            _divider(isDark),
            _infoRow(
              icon: CupertinoIcons.circle_fill,
              label: 'Account Status',
              value: profile.accountStatus != null ? 'Active' : 'Pending',
              isDark: isDark,
              valueColor: profile.accountStatus != null
                  ? const Color(0xFF34C759)
                  : const Color(0xFFFF9F0A),
            ),
            _divider(isDark),
            _infoRow(
                icon: CupertinoIcons.money_dollar_circle_fill,
                label: 'Currency',
                value: 'USD',
                isDark: isDark),
            _divider(isDark),
            _infoRow(
              icon: CupertinoIcons.time_solid,
              label: 'Last Login',
              value: CommonUtils.formatDateTime(profile.loginAt),
              isDark: isDark,
            ),
          ]),
          const SizedBox(height: 20),
          _sectionLabel('Referral Code', isDark),
          _buildReferralCard(profile.referedCode ?? '', isDark),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // KYC TAB
  // ─────────────────────────────────────────────────────────
  Widget _buildKycTab(Profile profile, bool isDark) {
    final kycStatus = profile.kycStatus ?? 'pending';
    final docType = profile.documentType;
    final hasDoc = docType != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ── Status Hero Card ──
          _buildKycStatusCard(kycStatus, isDark),
          const SizedBox(height: 16),

          // ── Document Details — always show when a doc exists ──
          if (hasDoc) ...[
            _sectionLabel('Document Details', isDark),
            _infoCard(isDark, children: [
              _infoRow(
                icon: CupertinoIcons.doc_fill,
                label: 'Document Type',
                value:
                    (docType.value?.isNotEmpty == true) ? docType.value! : '—',
                isDark: isDark,
              ),
              _divider(isDark),
              _infoRow(
                icon: CupertinoIcons.calendar_today,
                label: 'Submitted On',
                value: (docType.submittedAt?.isNotEmpty == true)
                    ? docType.submittedAt!
                    : '—',
                isDark: isDark,
              ),
              if (docType.approvedAt != null &&
                  docType.approvedAt!.isNotEmpty) ...[
                _divider(isDark),
                _infoRow(
                  icon: CupertinoIcons.checkmark_seal_fill,
                  label: 'Accepted On',
                  value: docType.approvedAt!,
                  isDark: isDark,
                  valueColor: const Color(0xFF34C759),
                ),
              ],
              if (docType.rejectedAt != null &&
                  docType.rejectedAt!.isNotEmpty) ...[
                _divider(isDark),
                _infoRow(
                  icon: CupertinoIcons.xmark_seal_fill,
                  label: 'Rejected On',
                  value: docType.rejectedAt!,
                  isDark: isDark,
                  valueColor: const Color(0xFFFF3B30),
                ),
              ],
              _divider(isDark),
              _infoRow(
                icon: CupertinoIcons.shield_lefthalf_fill,
                label: 'Status',
                value: kycStatus == 'verified'
                    ? 'Verified'
                    : kycStatus == 'rejected'
                        ? 'Rejected'
                        : kycStatus == 'under_review'
                            ? 'Under Review'
                            : 'Pending',
                isDark: isDark,
                valueColor: _kycStatusColor(kycStatus),
              ),
            ]),
          ],

          // ── Uploaded Document Images — show for all statuses ──
          if (hasDoc &&
              (docType.frontImageUrl != null ||
                  docType.backImageUrl != null)) ...[
            const SizedBox(height: 16),
            _sectionLabel('Uploaded Documents', isDark),
            _infoCard(isDark, children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (docType.frontImageUrl != null)
                      Expanded(
                          child: _docImageCard(
                              'Front Side', docType.frontImageUrl!, isDark)),
                    if (docType.frontImageUrl != null &&
                        docType.backImageUrl != null)
                      const SizedBox(width: 12),
                    if (docType.backImageUrl != null)
                      Expanded(
                          child: _docImageCard(
                              'Back Side', docType.backImageUrl!, isDark)),
                  ],
                ),
              ),
            ]),
          ],
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildKycStatusCard(String status, bool isDark) {
    final Color statusColor = _kycStatusColor(status);
    final IconData statusIcon = _kycStatusIcon(status);
    final String statusTitle = _kycStatusTitle(status);
    final String statusDesc = _kycStatusDesc(status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: statusColor.withOpacity(0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
        border: Border.all(
          color: statusColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Icon ring
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            statusTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            statusDesc,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white54 : Colors.black45,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          if (status == 'pending' || status == 'rejected') ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context,
                      SlidePageRoute(page: const DocumentVerification()));
                },
                icon: Icon(
                  status == 'rejected'
                      ? CupertinoIcons.refresh
                      : CupertinoIcons.shield_fill,
                  size: 16,
                ),
                label: Text(
                  status == 'rejected' ? 'Submit Again' : 'Complete KYC',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: statusColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _docImageCard(String label, String url, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white54 : Colors.black45,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            url,
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 160,
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.image_not_supported_outlined,
                  color: isDark ? Colors.white38 : Colors.black26, size: 28),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  // BANKING TAB
  // ─────────────────────────────────────────────────────────
  Widget _buildBankingTab(Profile profile, bool isDark) {
    final bank = profile.bank;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (bank != null) ...[
            // Bank card header
            _buildBankHeroCard(bank, isDark),
            const SizedBox(height: 20),
            _sectionLabel('Account Details', isDark),
            _infoCard(isDark, children: [
              _infoRow(
                icon: CupertinoIcons.building_2_fill,
                label: 'Bank Name',
                value: bank.bankName ?? '—',
                isDark: isDark,
              ),
              _divider(isDark),
              _infoRow(
                icon: CupertinoIcons.creditcard_fill,
                label: 'Account Number',
                value: bank.bankAccountNumber ?? '—',
                isDark: isDark,
              ),
              _divider(isDark),
              _infoRow(
                icon: CupertinoIcons.lock_fill,
                label: 'IFSC Code',
                value: bank.ifscCode ?? '—',
                isDark: isDark,
              ),
            ]),
          ] else ...[
            const SizedBox(height: 20),
            _buildNoBankCard(isDark),
          ],
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildBankHeroCard(dynamic bank, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_accent, AppFlavorColor.darkPrimary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _accent.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(CupertinoIcons.creditcard_fill,
                    color: Colors.white, size: 18),
              ),
              const Spacer(),
              Text(
                'Bank Account',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            bank.bankName ?? 'Bank',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _maskAccountNumber(bank.bankAccountNumber ?? ''),
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoBankCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child:
                Icon(CupertinoIcons.creditcard_fill, color: _accent, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            'No Bank Account Added',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your bank account details to enable\ndeposits and withdrawals.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white54 : Colors.black45,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                  context, SlidePageRoute(page: AddBankAccount())),
              icon: const Icon(CupertinoIcons.add_circled_solid, size: 16),
              label: const Text('Add Bank Details',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // SHARED UI HELPERS
  // ─────────────────────────────────────────────────────────

  Widget _sectionLabel(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: isDark ? Colors.white38 : Colors.black38,
        ),
      ),
    );
  }

  Widget _infoCard(bool isDark, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(children: children),
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _accent, size: 15),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white38 : Colors.black38,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color:
                        valueColor ?? (isDark ? Colors.white : Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 46,
      color: isDark ? Colors.white10 : Colors.black.withOpacity(0.07),
    );
  }

  Widget _buildReferralCard(String code, bool isDark) {
    return GestureDetector(
      onTap: () async {
        if (code.isNotEmpty) {
          await Clipboard.setData(ClipboardData(text: code));
          SnackBarService.showSuccess('Referral code copied!');
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF007AFF).withOpacity(0.08),
              const Color(0xFF5856D6).withOpacity(0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF007AFF).withOpacity(0.15),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF007AFF).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(CupertinoIcons.gift_fill,
                  color: Color(0xFF007AFF), size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    code.isEmpty ? 'No referral code' : code,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF007AFF),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap to copy',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF007AFF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(CupertinoIcons.doc_on_doc_fill,
                  color: Colors.white, size: 14),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // KYC helpers (logic unchanged)
  // ─────────────────────────────────────────────────────────
  Color _kycStatusColor(String status) {
    switch (status) {
      case 'verified':
        return const Color(0xFF34C759);
      case 'under_review':
        return const Color(0xFF007AFF);
      case 'rejected':
        return const Color(0xFFFF3B30);
      default:
        return const Color(0xFFFF9F0A);
    }
  }

  IconData _kycStatusIcon(String status) {
    switch (status) {
      case 'verified':
        return CupertinoIcons.checkmark_seal_fill;
      case 'under_review':
        return CupertinoIcons.time_solid;
      case 'rejected':
        return CupertinoIcons.xmark_circle_fill;
      default:
        return CupertinoIcons.shield_lefthalf_fill;
    }
  }

  String _kycStatusTitle(String status) {
    switch (status) {
      case 'verified':
        return 'Identity Verified';
      case 'under_review':
        return 'Under Review';
      case 'rejected':
        return 'Verification Rejected';
      default:
        return 'Complete KYC';
    }
  }

  String _kycStatusDesc(String status) {
    switch (status) {
      case 'verified':
        return 'Your identity has been successfully verified. You have full access to all features.';
      case 'under_review':
        return 'Our team is reviewing your documents. We\'ll notify you once verification is complete.';
      case 'rejected':
        return 'Your documents were rejected. Please review the requirements and submit again.';
      default:
        return 'Upload your identity documents to complete verification and unlock all features.';
    }
  }

  String _maskAccountNumber(String number) {
    if (number.length <= 4) return number;
    final visible = number.substring(number.length - 4);
    final masked = '•' * (number.length - 4);
    return '$masked  $visible';
  }
}
