import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/view/account/widget/account_symbol_section.dart';
import 'package:exness_clone/view/account/widget/trading_item.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../config/flavor_config.dart';
import '../../widget/button/premium_app_button.dart';
import '../trade/symbol_bottom_sheet.dart';
import 'btc_chart/btc_chart_screen_updated.dart';
import 'chart_data/dummy_chart/dummy_chart_data.dart';

class PriceAlertScreen extends StatefulWidget {
  const PriceAlertScreen({super.key});

  @override
  State<PriceAlertScreen> createState() => _PriceAlertScreenState();
}

class _PriceAlertScreenState extends State<PriceAlertScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            size: 18,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintStyle: TextStyle(color: AppColor.greyColor),
                  border: InputBorder.none,
                ),
              )
            : Text(
                'Price alerts',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
              ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) => const  AccountSymbolSection(),
              );
            },
          ),
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : CupertinoIcons.search,
              color: _isSearching ? AppColor.greyColor : context.themeColor,
            ),
            onPressed: () {
              setState(() {
                _isSearching = true;
              });
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "No alerts",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 6),
            const Text(
              "Get notified when the price reaches its\nspecified level",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: PremiumAppButton(
                text: 'Add new alert',
                icon: Icons.add,
                showIcon: true,
                height: 48,
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    builder: (context) => const AccountSymbolSection(),
                  );
                },
              ),
            ),

            // ElevatedButton.icon(
            //   onPressed: () {
            //
            //   },
            //   icon: Icon(Icons.add, color: AppColor.blackColor),
            //   label: Text(
            //     "Add new alert",
            //     style: TextStyle(color: AppColor.blackColor, fontSize: 13),
            //   ),
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: AppColor.yellowColor,
            //     padding:
            //         const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(2),
            //     ),
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}

class AlertBottomSheet extends StatefulWidget {
  const AlertBottomSheet({super.key});

  @override
  State<AlertBottomSheet> createState() => _AlertBottomSheetState();
}

class _AlertBottomSheetState extends State<AlertBottomSheet> {
  double alertPrice = 204.97;
  String selectedType = 'Bid price';
  List<String> priceTypes = ['Bid price', 'Ask price'];

  bool alertSettings = true;
  bool recurring = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context)
          .viewInsets, // 👈 This moves the sheet up with keyboard

      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.network(
                        "https://cdn-icons-png.flaticon.com/512/888/888879.png", // placeholder chart icon
                        height: 20,
                        width: 20,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      const Text("AAPL",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  SizedBox(
                    width: 70,
                    height: 30,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              FlSpot(0, 1.0),
                              FlSpot(1, 1.3),
                              FlSpot(2, 1.2),
                              FlSpot(3, 1.4),
                              FlSpot(4, 1.6),
                              FlSpot(5, 1.0),
                              FlSpot(6, 1.3),
                              FlSpot(7, 1.2),
                              FlSpot(8, 1.4),
                              FlSpot(9, 0.2),
                              FlSpot(10, 1.0),
                              FlSpot(11, 1.3),
                              FlSpot(12, 1.2),
                              FlSpot(13, 1.4),
                              FlSpot(14, 1.3),
                              FlSpot(15, 1.0),
                              FlSpot(16, 1.3),
                              FlSpot(17, 1.2),
                              FlSpot(18, 1.4),
                              FlSpot(19, 1.6),
                              FlSpot(20, 1.0),
                              FlSpot(21, 1.3),
                              FlSpot(22, 1.2),
                              FlSpot(23, 1.4),
                              FlSpot(24, 0.2),
                              FlSpot(25, 1.0),
                              FlSpot(26, 1.3),
                              FlSpot(27, 1.2),
                              FlSpot(28, 1.4),
                              FlSpot(29, 1.3),
                            ],
                            isCurved: false,
                            color: AppColor.blueColor,
                            dotData: FlDotData(show: false),
                            barWidth: 0.8,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("205.06",
                          style: TextStyle(
                              color: AppColor.blueColor,
                              fontWeight: FontWeight.w500)),
                      Text("204.97",
                          style: TextStyle(
                              color: AppColor.redColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 15)),
                    ],
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  // Main Container
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          // Minus Button
                          IconButton(
                            icon: Icon(Icons.remove, size: 16),
                            onPressed: () {
                              alertPrice = double.parse(
                                  (alertPrice - 0.01).toStringAsFixed(2));
                              setState(() {});
                            },
                          ),

                          // Price Text
                          Expanded(
                              child: TextField(
                            textAlign: TextAlign.center,
                            controller:
                                TextEditingController(text: "$alertPrice"),
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                                isDense: true,
                                border: UnderlineInputBorder(
                                    borderSide: BorderSide.none)),
                          )),

                          // Plus Button
                          IconButton(
                            icon: Icon(Icons.add, size: 16),
                            onPressed: () {
                              alertPrice = double.parse(
                                  (alertPrice + 0.01).toStringAsFixed(2));
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Dropdown for "Bid price"
                  Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      onSelected: (value) {
                        selectedType = value;
                        setState(() {});
                      },
                      itemBuilder: (context) {
                        return priceTypes.map((type) {
                          return PopupMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList();
                      },
                      child: Row(
                        children: [
                          Text(
                            selectedType,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_drop_down, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              CustomSwitchTile(
                value: alertSettings,
                onChanged: (val) => setState(() => alertSettings = val),
                title: "Alert settings",
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 40,
                child: TextField(
                  cursorWidth: 1,
                  cursorHeight: 20,
                  style: TextStyle(fontWeight: FontWeight.w500),
                  textAlignVertical:
                      TextAlignVertical.center, // 👈 Cursor alignment
                  decoration: InputDecoration(
                    hintText: 'Add note...',
                    hintStyle:
                        TextStyle(fontSize: 12, color: AppColor.greyColor),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 8, horizontal: 12), // 👈 Adjust padding here
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColor.mediumGrey)),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: context.themeColor, width: 1)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text("Expiration",
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  Spacer(),
                  Text("7 days",
                      style: TextStyle(
                          color: AppColor.greyColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 25),
              CustomSwitchTile(
                value: recurring,
                onChanged: (val) => setState(() => recurring = val),
                title: "Recurring",
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle confirmation
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.mediumGrey,
                        elevation: 0,
                        foregroundColor: AppColor.blackColor,
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle confirmation
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(0, 35),
                        backgroundColor: Colors.yellow[700],
                        foregroundColor: Colors.black,
                      ),
                      child: const Text(
                        "✔️ Confirm",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CustomSwitchTile extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String title;

  const CustomSwitchTile({
    super.key,
    required this.value,
    required this.onChanged,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const Spacer(),
        GestureDetector(
          onTap: () => onChanged(!value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 50,
            height: 32,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: value ? AppColor.blueGrey : AppColor.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: value ? AppColor.transparent : AppColor.greyColor,
                width: 0.6, // ✅ Control the outline width here
              ),
            ),
            child: Align(
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: value ? AppColor.whiteColor : AppColor.blueGrey,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
