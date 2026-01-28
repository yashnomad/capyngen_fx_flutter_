import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/widget/simple_appbar.dart';
import 'package:flutter/material.dart';

class SettingNotification extends StatefulWidget {
  const SettingNotification({super.key});

  @override
  State<SettingNotification> createState() => _SettingNotificationState();
}

class _SettingNotificationState extends State<SettingNotification> {
  final Map<String, bool> isChecked = {
    'Trading': true,
    'Financial': true,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppbar(title: 'Notifications'),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // Header Section
          _buildSectionHeader('Operations'),
          const SizedBox(height: 12),

          // Notifications Card
          _buildNotificationsCard(),

          const SizedBox(height: 20),

          // Info Card
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppFlavorColor.headerText,
        ),
      ),
    );
  }

  Widget _buildNotificationsCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppFlavorColor.primary.withOpacity(0.05),
            AppFlavorColor.primary.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppFlavorColor.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildNotificationTile(
            icon: Icons.trending_up,
            iconColor: Colors.green,
            title: 'Trading',
            subtitle: 'Get updates about your trades and positions',
            isChecked: isChecked['Trading'] ?? false,
            onTap: () {
              setState(() {
                isChecked['Trading'] = !(isChecked['Trading'] ?? false);
              });
            },
            isFirst: true,
          ),
          _buildDivider(),
          _buildNotificationTile(
            icon: Icons.account_balance_wallet,
            iconColor: Colors.blue,
            title: 'Financial',
            subtitle: 'Receive notifications about deposits and withdrawals',
            isChecked: isChecked['Financial'] ?? false,
            onTap: () {
              setState(() {
                isChecked['Financial'] = !(isChecked['Financial'] ?? false);
              });
            },
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isChecked,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(16) : Radius.zero,
          bottom: isLast ? const Radius.circular(16) : Radius.zero,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              // Icon Badge
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),

              const SizedBox(width: 14),

              // Title and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppFlavorColor.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColor.greyColor,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Custom Checkbox
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  gradient: isChecked
                      ? LinearGradient(
                    colors: AppFlavorColor.buttonGradient,
                  )
                      : null,
                  color: isChecked ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isChecked
                        ? AppFlavorColor.primary
                        : AppColor.greyColor.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: isChecked
                    ? const Icon(
                  Icons.check,
                  size: 16,
                  color: Colors.white,
                )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppFlavorColor.info.withOpacity(0.1),
            AppFlavorColor.info.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppFlavorColor.info.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppFlavorColor.info.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.info_outline,
              color: AppFlavorColor.info,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About Notifications',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppFlavorColor.text,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Enable notifications to stay updated with your trading activities and financial transactions in real-time.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColor.greyColor,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 64),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: AppColor.greyColor.withOpacity(0.2),
      ),
    );
  }
}