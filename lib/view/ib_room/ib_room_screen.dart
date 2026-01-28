import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../widget/loader.dart';
import 'cubit/ibreport_cubit.dart';
import 'cubit/ibreport_state.dart';
import 'model/referral_model.dart';

class IbReport extends StatelessWidget {
  const IbReport({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => IbReportCubit()..fetchReferralCommission(),
      child: const IbReportView(),
    );
  }
}

class IbReportView extends StatefulWidget {
  const IbReportView({super.key});

  @override
  State<IbReportView> createState() => _IbReportViewState();
}

class _IbReportViewState extends State<IbReportView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          color: context.ibRoomAppBarBackgroundColor,
        ),
        titleSpacing: 0,
        title: const Text(
          "IB Reports",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.refresh),
            onPressed: () {
              context.read<IbReportCubit>().fetchReferralCommission();
            },
          ),
        ],
      ),
      body: BlocBuilder<IbReportCubit, IbReportState>(
        builder: (context, state) {
          if (state is IbReportLoading) {
            return Loader();
          } else if (state is IbReportError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.exclamationmark_triangle,
                    size: 64,
                    color: Colors.red.withOpacity(0.6),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: context.profileIconColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.ibRoomTextColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<IbReportCubit>().fetchReferralCommission();
                    },
                    icon: const Icon(CupertinoIcons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is IbReportLoaded) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with stats cards
                    _buildStatsCards(state.summary),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      'Referral Leaderboard',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: context.profileIconColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Search and Filter Row
                    _buildSearchAndFilter(context, state),
                    const SizedBox(height: 16),

                    // Results count
                    Text(
                      'Showing ${state.filteredReferrals.length} of ${state.referrals.length} results',
                      style: TextStyle(
                        color: context.ibRoomTextColor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Data Table
                    _buildReferralList(state.filteredReferrals),
                    // _buildDataTable(state.filteredReferrals),
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

  Widget _buildStatsCards(ReferralSummary summary) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Users',
            '${summary.uniqueUsers}',
            CupertinoIcons.person_2_fill,
            AppFlavorColor.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Trade Accounts',
            '${summary.totalTradeAccounts}',
            CupertinoIcons.chart_bar_fill,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Without Accounts',
            '${summary.usersWithoutTradeAccounts}',
            CupertinoIcons.exclamationmark_triangle_fill,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.ibRoomAppBarBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: context.profileIconColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: context.ibRoomTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(BuildContext context, IbReportLoaded state) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              color: context.ibRoomAppBarBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, account, country...',
                hintStyle: TextStyle(
                  color: context.ibRoomIconColor,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  CupertinoIcons.search,
                  size: 20,
                  color: context.ibRoomIconColor,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                context.read<IbReportCubit>().searchReferrals(value);
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: context.ibRoomAppBarBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButton<String>(
            value: state.selectedLevel,
            underline: const SizedBox(),
            icon: const Icon(CupertinoIcons.chevron_down, size: 16),
            style: TextStyle(
              fontSize: 14,
              color: context.profileIconColor,
            ),
            dropdownColor: context.ibRoomAppBarBackgroundColor,
            items: ['All Levels', 'Level 1', 'Level 2', 'Level 3']
                .map((level) => DropdownMenuItem(
                      value: level,
                      child: Text(level),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                context.read<IbReportCubit>().filterByLevel(value);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDataTable(List<ReferralModel> referrals) {
    if (referrals.isEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: context.ibRoomAppBarBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.doc_text,
                size: 64,
                color: context.ibRoomTextColor,
              ),
              const SizedBox(height: 16),
              Text(
                'No referrals found',
                style: TextStyle(
                  fontSize: 16,
                  color: context.ibRoomTextColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
          ),
          child: DataTable(
            dividerThickness: 0,
            headingRowColor: MaterialStateProperty.all(
              context.ibRoomTableColor,
            ),
            columnSpacing: 24,
            columns: [
              DataColumn(
                label: Text(
                  'Name',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.profileIconColor,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Country',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.profileIconColor,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'City',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.profileIconColor,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Account ID',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.profileIconColor,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Account Type',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.profileIconColor,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Volume',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.profileIconColor,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Equity',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.profileIconColor,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Commission',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.profileIconColor,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Level',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.profileIconColor,
                  ),
                ),
              ),
            ],
            rows: referrals.map((referral) {
              return DataRow(
                cells: [
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          referral.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: context.profileIconColor,
                          ),
                        ),
                        Text(
                          referral.email,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.ibRoomTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    Text(
                      referral.country,
                      style: TextStyle(
                        color: context.profileTextColor,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      referral.city,
                      style: TextStyle(
                        color: context.profileTextColor,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      referral.userAccountId,
                      style: TextStyle(
                        color: context.profileTextColor,
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getAccountTypeColor(referral.accountType)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _getAccountTypeColor(referral.accountType)
                              .withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        referral.accountType,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _getAccountTypeColor(referral.accountType),
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      referral.volume.toStringAsFixed(2),
                      style: TextStyle(
                        color: context.profileTextColor,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      '\$${referral.equity.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: referral.equity > 0
                            ? AppColor.greenColor
                            : context.profileTextColor,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      '\$${referral.commission.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: referral.commission > 0
                            ? AppColor.greenColor
                            : context.profileTextColor,
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Level ${referral.level}',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildReferralList(List<ReferralModel> referrals) {
    if (referrals.isEmpty) return _buildEmptyState();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: referrals.length,
      itemBuilder: (context, index) {
        final user = referrals[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: context.ibRoomAppBarBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              // 1. Header: Avatar + Name + Level
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppFlavorColor.primary.withOpacity(0.1),
                  child: Text(user.name[0].toUpperCase(),
                      style: TextStyle(
                          color: AppFlavorColor.primary,
                          fontWeight: FontWeight.bold)),
                ),
                title: Text(user.fullName,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: context.profileIconColor)),
                subtitle:
                    Text(user.email, style: const TextStyle(fontSize: 12)),
                trailing:
                    _buildBadge("Level ${user.level}", AppFlavorColor.primary),
              ),
              const Divider(height: 1),

              // 2. Info Grid (Account ID, Country, Volume)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _infoColumn("Account ID", user.userAccountId),
                    _infoColumn("Country", user.country),
                    _infoColumn("Volume", user.volume.toStringAsFixed(2)),
                  ],
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppFlavorColor.primary.withOpacity(0.05),
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _financialText(
                        "Equity", "\$${user.equity}", context.profileIconColor),
                    _financialText(
                        "Commission", "\$${user.commission}", Colors.green,
                        isBold: true),
                    _financialText("Status", user.kycStatus.toUpperCase(),
                        AppFlavorColor.primary,
                        isBold: true),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.profileIconColor)),
      ],
    );
  }

  Widget _financialText(String label, String value, Color color,
      {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(value,
            style: TextStyle(
                fontSize: 15,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                color: color)),
      ],
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20)),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text("No referrals found"));
  }

  Color _getAccountTypeColor(String accountType) {
    switch (accountType.toLowerCase()) {
      case 'vip':
        return Colors.purple;
      case 'standard':
        return AppColor.greenColor;
      case 'premium':
        return AppColor.orangeColor;
      default:
        return AppColor.greyColor;
    }
  }
}
