import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/utils/common_utils.dart';
import 'package:flutter/material.dart';
import '../../../utils/snack_bar.dart';
import '../model/trade_account.dart';

class AccountCard extends StatelessWidget {
  final Account account;
  final VoidCallback? onTap;
  final bool showSwipeActions;

  const AccountCard({
    super.key,
    required this.account,
    this.onTap,
    this.showSwipeActions = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget card = Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: context.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.group?.groupName ?? 'Standard',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getAccountTypeColor(
                                  account.accountType, isDark),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              account.accountType?.toUpperCase() ?? 'UNKNOWN',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: _getAccountTypeTextColor(
                                    account.accountType),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '#${account.accountId ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Leverage: 1:${account.leverage ?? 0}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      ' ${CommonUtils.formatBalance(account.balance?.toDouble())} ${account.currency ?? 'USD'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    if (account.equity != null &&
                        account.equity != account.balance) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Equity: ${CommonUtils.formatBalance(account.equity?.toDouble())} ${account.currency ?? 'USD'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoChip(
                label: "Swap Days",
                value: account.group?.swapDays?.toString() ?? "N/A",
                color: Colors.blueAccent,
                icon: Icons.calendar_today,
              ),
              _infoChip(
                label: "Commission",
                value: account.group?.commission?.toString() ?? "N/A",
                color: Colors.redAccent,
                icon: Icons.percent,
              ),
            ],
          ),

          const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _depositChip(
                  label: "Min",
                  value: CommonUtils.formatBalance(
                    account.group?.minDeposit?.toDouble(),
                  ),
                  color: Colors.green,
                ),
                _depositChip(
                  label: "Max",
                  value: CommonUtils.formatBalance(
                    account.group?.maxDeposit?.toDouble(),
                  ),
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(account.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    account.status?.toUpperCase() ?? 'UNKNOWN',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (account.createdAt != null)
                  Text(
                    'Created: ${CommonUtils.formatDate(account.createdAt!)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );

    if (showSwipeActions) {
      return Dismissible(
        key: Key(account.id ?? ''),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.archive,
            color: AppColor.whiteColor,
          ),
        ),
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Archive Account'),
                content: const Text(
                    'Are you sure you want to archive this account?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Archive'),
                  ),
                ],
              );
            },
          );
        },
        onDismissed: (direction) {
          SnackBarService.showSuccess('Account #${account.accountId} archived');
        },
        child: card,
      );
    }

    return card;
  }

  Widget _infoChip({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            "$label: $value",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _depositChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        "$label: $value",
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _getAccountTypeColor(String? accountType, bool isDark) {
    switch (accountType?.toLowerCase()) {
      case 'live':
        return Colors.green.withOpacity(0.2);
      case 'demo':
        return Colors.blue.withOpacity(0.2);
      default:
        return isDark ? Colors.white24 : Colors.grey[300]!;
    }
  }

  Color _getAccountTypeTextColor(String? accountType) {
    switch (accountType?.toLowerCase()) {
      case 'live':
        return Colors.green;
      case 'demo':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.orange;
      case 'archived':
        return Colors.grey;
      case 'suspended':
        return Colors.red;
      default:
        return Colors.grey;
    }
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
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
