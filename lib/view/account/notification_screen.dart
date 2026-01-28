import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/utils/snack_bar.dart';
import 'package:exness_clone/widget/button/premium_app_button.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<Map<String, String>> notifications = const [
    {
      "time": "14:02, 4 Jun",
      "title": "Account balance",
      "message":
          "The balance of 271351095 has changed. The new balance is 10000.0 USD"
    },
    // Add more notifications here if needed
  ];

  @override
  Widget build(BuildContext context) {
    // final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
            )),
        title: const Text("Notifications",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
        actions: [
          Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: TextButton(
                  onPressed: null,
                  child: Text(
                    'Read all',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  )))
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. The Visual Illustration
              _buildIllustration(AppFlavorColor.primary),

              const SizedBox(height: 32),

              // 2. The Title
              const Text(
                "No Notifications Yet",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 12),

              // 3. The Subtitle
              Text(
                "When you get notifications, they will\nshow up here right away.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 48),

              // 4. Action Button (Optional but recommended)
              _buildActionButton(context, AppFlavorColor.primary),
            ],
          ),
        ),
      ), // body: _buildNotificationList(),
    );
  }

  Widget _buildIllustration(Color color) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), // Soft background circle
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 80,
              color: color.withOpacity(0.5),
            ),
            Positioned(
              top: 48,
              right: 48,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 24,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, Color color) {
    return PremiumAppButton(
      text: 'Refresh',
      onPressed: () => SnackBarService.showSuccess('Refreshing...'),
    );
  }

  ListView _buildNotificationList() {
    return ListView.builder(
      itemCount: notifications.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final item = notifications[index];
        return InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              builder: (context) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${notifications[index]['time']}',
                        style:
                            TextStyle(fontSize: 13, color: AppColor.greyColor),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${notifications[index]['title']}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${notifications[index]['message']}',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: context.notificationBoxColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['time'] ?? '',
                  style: TextStyle(
                    color: AppColor.greyColor,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['title'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['message'] ?? '',
                  style: const TextStyle(
                      fontSize: 13, height: 1.3, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
