import 'package:exness_clone/config/flavor_assets.dart';
import 'package:exness_clone/core/extensions.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

class BTCSettingsScreen extends StatefulWidget {
  const BTCSettingsScreen({super.key});

  @override
  State<BTCSettingsScreen> createState() => _BTCSettingsScreenState();
}

class _BTCSettingsScreenState extends State<BTCSettingsScreen> {
  final Map<String, bool> chartSettings = {
    'Trading signals': false,
    'HMR periods': true,
    'Price alerts': true,
    'Position profit / loss': true,
    'Closed orders': false,
    'Potential Stop Out line': true,
  };

  String selectedChart = FlavorAssets.appName;
  String selectedOrderMode = 'Regular';

  void _selectChartOption() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          children: [FlavorAssets.appName, 'TradingView'].map((chart) {
            return ListTile(
              title: Text(chart),
              trailing: chart == selectedChart ? const Icon(Icons.check) : null,
              onTap: () {
                setState(() => selectedChart = chart);
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  void _selectOrderModeOption() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          children: ['Regular', 'Netting'].map((mode) {
            return ListTile(
              title: Text(mode),
              trailing:
                  mode == selectedOrderMode ? const Icon(Icons.check) : null,
              onTap: () {
                setState(() => selectedOrderMode = mode);
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  @override

  Widget build(BuildContext context) {
    // final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontSize: 22),
        ),
        titleSpacing: 0,
        flexibleSpace: Container(
          color: context.scaffoldBackgroundColor,
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              size: 20,
            )),
        elevation: 0,
      ),
      backgroundColor: context.scaffoldBackgroundColor,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('SHOW ON CHART',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColor.greyColor,
                fontSize: 12,
                letterSpacing: 1,
              )),
          const SizedBox(height: 10),
          Card(
            color: context.backgroundColor,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: chartSettings.entries.map((entry) {
                return ListTile(
                  title: Text(
                    entry.key,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  trailing:
                      entry.value ? const Icon(Icons.check, size: 20) : null,
                  onTap: () {
                    setState(() {
                      chartSettings[entry.key] = !entry.value;
                    });
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 30),
          Text('CHART PREFERENCES',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColor.greyColor,
                fontSize: 12,
                letterSpacing: 1,
              )),
          const SizedBox(height: 10),
          Card(
            elevation: 0,
            color: context.backgroundColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  title: const Text(
                    'Chart',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selectedChart,
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                      ),
                    ],
                  ),
                  onTap: _selectChartOption,
                ),
                ListTile(
                  title: const Text(
                    'Open order mode',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selectedOrderMode,
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                      ),
                    ],
                  ),
                  onTap: _selectOrderModeOption,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Chart preferences are applied to all trading accounts and instruments',
            style: TextStyle(
                fontSize: 12,
                color: AppColor.greyColor,
                fontWeight: FontWeight.w500),
          )
        ],
      ),
    );
  }
}
