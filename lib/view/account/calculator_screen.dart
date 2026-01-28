
import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/widget/simple_appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';



class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  double closeAt = 212.63;
  double alertPrice = 0.01;

  String leverage = '1:20(Fixed leverage)';
  List<String> leverageTypes = ['1:20(Fixed leverage)', '1:40(Fixed leverage)','1:60(Fixed leverage)',];

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  Widget _buildInfoTile(String label, String value) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(label,style: TextStyle(fontSize: 13,fontWeight: FontWeight.w500),),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style:  TextStyle(fontWeight: FontWeight.w500,fontSize: 13,color: AppColor.greyColor)),
           SizedBox(width: 8,),
          Icon(CupertinoIcons.info,size: 20,color: AppColor.greyColor,)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppbar(title: 'Calculator (AAPL)'),
      body: Column(
        children: [
          // Tab Bar
          Container(
            margin: const EdgeInsets.all(12),
            padding: EdgeInsets.symmetric(horizontal: 2,vertical: 2),
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color:AppColor.lightGrey),
              borderRadius: BorderRadius.circular(6),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColor.whiteColor,

              dividerColor:AppColor.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: AppFlavorColor.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              tabs: const [
                Tab(text: "Buy"),
                Tab(text: "Sell"),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCalculatorTab(),
                _buildCalculatorTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Volume, lots',style: TextStyle(fontSize: 12),),
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
                  icon: Icon(Icons.remove, size: 16,color: AppColor.greyColor,),
                  onPressed: () {
                    alertPrice = double.parse((alertPrice - 0.01).toStringAsFixed(2));
                    setState(() {});
                  },
                ),

                // Price Text
                Expanded(
                    child: TextField(
                      textAlign: TextAlign.center,
                      controller: TextEditingController(text: "$alertPrice"),
                      style: TextStyle(fontSize: 13,fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                          isDense: true,
                          border: UnderlineInputBorder(
                              borderSide: BorderSide.none
                          )
                      ),
                    )
                ),

                // Plus Button
                IconButton(
                  icon: Icon(Icons.add, size: 16,color: AppColor.greyColor,),
                  onPressed: () {
                    alertPrice = double.parse((alertPrice + 0.01).toStringAsFixed(2));
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text('Leverage',style: TextStyle(fontSize: 12),),
          const SizedBox(height: 6),
          Container(
            height: 40,

            decoration: BoxDecoration(
              border: Border.all(color: AppColor.mediumGrey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: PopupMenuButton<String>(
              position: PopupMenuPosition.under,
              padding: EdgeInsets.zero,
              onSelected: (value) {
                leverage = value;
                setState(() {});
              },
              itemBuilder: (context) {
                return leverageTypes.map((type) {
                  return PopupMenuItem<String>(
                    value: type,
                    child: SizedBox(
                      width: MediaQuery.sizeOf(context).width - 24,
                        child: Text(type)),
                  );
                }).toList();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      leverage,
                      style: const TextStyle(fontSize: 13,fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.keyboard_arrow_down, size: 20,color: AppColor.greyColor,),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Open at',style: TextStyle(fontSize: 12),),
              Text('Clear',style: TextStyle(fontSize: 12,color: AppColor.greyColor),),

            ],
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
                  icon: Icon(Icons.remove, size: 16,color: AppColor.greyColor,),
                  onPressed: () {

                  },
                ),

                // Price Text
                Expanded(
                    child: TextField(
                      textAlign: TextAlign.center,

                      style: TextStyle(fontSize: 13,fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                          isDense: true,
                          hintText: 'Market price (202.60)',
                          hintStyle: TextStyle(fontSize: 12,color: Colors.grey.shade400,fontWeight: FontWeight.w500),
                          border: UnderlineInputBorder(
                              borderSide: BorderSide.none
                          )
                      ),
                    )
                ),

                // Plus Button
                IconButton(
                  icon: Icon(Icons.add, size: 16,color: AppColor.greyColor,),
                  onPressed: () {

                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Close at',style: TextStyle(fontSize: 12),),
              Text('Clear',style: TextStyle(fontSize: 12,color: AppColor.blueColor,fontWeight: FontWeight.w500),),

            ],
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
                  icon: Icon(Icons.remove, size: 16,color: AppColor.greyColor,),
                  onPressed: () {

                  },
                ),

                // Price Text
                Expanded(
                    child: TextField(
                      controller: TextEditingController(text: '212.63'),
                      textAlign: TextAlign.center,

                      style: TextStyle(fontSize: 13,fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                          isDense: true,
                          hintText: 'Market price (202.60)',
                          hintStyle: TextStyle(fontSize: 12,color: Colors.grey.shade400,fontWeight: FontWeight.w500),
                          border: UnderlineInputBorder(
                              borderSide: BorderSide.none
                          )
                      ),
                    )
                ),

                // Plus Button
                IconButton(
                  icon: Icon(Icons.add, size: 16,color: AppColor.greyColor,),
                  onPressed: () {

                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: context.scaffoldBackgroundColor,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  _buildInfoTile("Margin", "10.13 USD"),
                  Divider(color: AppColor.mediumGrey,height: 0,),
                  _buildInfoTile("Commission", "0.00 USD"),
                  Divider(color: AppColor.mediumGrey,height: 0,),
                  _buildInfoTile("Swap", "-0.03 USD"),
                  Divider(color: AppColor.mediumGrey,height: 0,),
                  _buildInfoTile("Spread", "0.09 USD"),
                  Divider(color: AppColor.mediumGrey,height: 0,),
                  _buildInfoTile("Pip Value", "0.10 USD"),
                  Divider(color: AppColor.mediumGrey,height: 0,),
                  _buildInfoTile("P/L", "10.03 USD"),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: context.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(CupertinoIcons.info,size: 20,),
                SizedBox(width: 10,),
                Expanded(
                  child: const Text(
                    "Always review the Order Information when placing an order. Order parameters may vary depending on specific conditions.",
                    style: TextStyle(fontSize: 13,fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


}
