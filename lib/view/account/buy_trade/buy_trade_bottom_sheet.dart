import 'package:exness_clone/core/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

class BuyTradeBottomSheet extends StatefulWidget {
  const BuyTradeBottomSheet({super.key});

  @override
  State<BuyTradeBottomSheet> createState() => _BuyTradeBottomSheetState();
}

class _BuyTradeBottomSheetState extends State<BuyTradeBottomSheet>
    with SingleTickerProviderStateMixin {
  double volume = 0.01;
  double? takeProfit;
  double? stopLoss;

  late TabController _tabController;

  double margin = 2.74;
  double fee = 0.22;
  double sellPrice = 109688.60;

  double alertPrice = 0.01;
  String selectedType = 'Price';
  List<String> priceTypes = ['Price', 'USD', 'Loss in %', 'Pips'];

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          MediaQuery.of(context).viewInsets, // for keyboard-safe bottom sheet
      child: SizedBox(
        width: double.infinity,
        height: MediaQuery.sizeOf(context).height * 0.58,
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color:context.sellTradeButtonColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 10),
            const Text("Regular",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TabBar(
              controller: _tabController,
              unselectedLabelColor: AppColor.greyColor,
              dividerColor: AppColor.mediumGrey,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(text: "Market"),
                Tab(text: "Limit"),
                Tab(text: "Stop"),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: buildTradeTab(sellPrice, fee, margin),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: buildTradeTab(sellPrice, fee, margin),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: buildTradeTab(sellPrice, fee, margin),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTradeTab(double sellPrice, double fee, double margin) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Volume',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 6),
          Container(
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: AppColor.mediumGrey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // Minus Button
                IconButton(
                  icon: Icon(
                    Icons.remove,
                    size: 16,
                    color: AppColor.greyColor,
                  ),
                  onPressed: () {
                    alertPrice =
                        double.parse((alertPrice - 0.01).toStringAsFixed(2));
                    setState(() {});
                  },
                ),

                // Price Text
                Expanded(
                    child: TextField(
                  textAlign: TextAlign.center,
                  controller: TextEditingController(text: "$alertPrice"),
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                      isDense: true,
                      border:
                          UnderlineInputBorder(borderSide: BorderSide.none)),
                )),

                // Plus Button
                IconButton(
                  icon: Icon(
                    Icons.add,
                    size: 16,
                    color: AppColor.greyColor,
                  ),
                  onPressed: () {
                    alertPrice =
                        double.parse((alertPrice + 0.01).toStringAsFixed(2));
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Take Profit',
                style: TextStyle(fontSize: 12),
              ),
              Text(
                'Clear',
                style: TextStyle(fontSize: 12, color: AppColor.greyColor),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              // Main Container
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColor.mediumGrey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      // Minus Button
                      IconButton(
                        icon: Icon(
                          Icons.remove,
                          size: 16,
                          color: AppColor.greyColor,
                        ),
                        onPressed: () {},
                      ),

                      // Price Text
                      Expanded(
                          child: TextField(
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                            isDense: true,
                            hintText: 'not set',
                            hintStyle: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade400,
                                fontWeight: FontWeight.w500),
                            border: UnderlineInputBorder(
                                borderSide: BorderSide.none)),
                      )),

                      // Plus Button
                      IconButton(
                        icon: Icon(
                          Icons.add,
                          size: 16,
                          color: AppColor.greyColor,
                        ),
                        onPressed: () {},
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
                  border: Border.all(color: AppColor.mediumGrey),
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
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 20,
                        color: AppColor.greyColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Stop Loss',
                style: TextStyle(fontSize: 12),
              ),
              Text(
                'Clear',
                style: TextStyle(fontSize: 12, color: AppColor.greyColor),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              // Main Container
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColor.mediumGrey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      // Minus Button
                      IconButton(
                        icon: Icon(
                          Icons.remove,
                          size: 16,
                          color: AppColor.greyColor,
                        ),
                        onPressed: () {},
                      ),

                      // Price Text
                      Expanded(
                          child: TextField(
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                            isDense: true,
                            hintText: 'not set',
                            hintStyle: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade400,
                                fontWeight: FontWeight.w500),
                            border: UnderlineInputBorder(
                                borderSide: BorderSide.none)),
                      )),

                      // Plus Button
                      IconButton(
                        icon: Icon(
                          Icons.add,
                          size: 16,
                          color: AppColor.greyColor,
                        ),
                        onPressed: () {},
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
                  border: Border.all(color: Colors.grey.shade300),
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
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 20,
                        color: AppColor.greyColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor:
                      context.sellTradeButtonColor),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.blueColor),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Confirm Buy ${volume.toStringAsFixed(2)} lots\n${sellPrice.toStringAsFixed(2)}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColor.whiteColor,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Fees: ~ \$${fee.toStringAsFixed(2)} | Margin: \$${margin.toStringAsFixed(2)} (1:400)",
                style: TextStyle(
                    color: AppColor.greyColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w500),
              ),
              Icon(
                CupertinoIcons.info,
                size: 20,
                color: AppColor.greyColor,
              )
            ],
          ),
        ],
      ),
    );
  }
}
