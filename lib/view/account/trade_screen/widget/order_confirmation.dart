import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:flutter/material.dart';
import '../../../../services/reactive_data_service.dart';
import '../../../../widget/button/premium_app_button.dart';

class OrderConfirmationWidget extends StatefulWidget {
  final String? symbol;
  final String? orderType;
  final String? direction;
  final String? volume;
  final String? margin;
  final String? takeProfit;
  final String? stopLoss;
  final bool doNotShowAgain;
  final ValueChanged<bool>? onDoNotShowAgainChanged;
  final VoidCallback? onConfirm;

  const OrderConfirmationWidget({
    super.key,
    this.symbol,
    this.orderType,
    this.direction,
    this.volume,
    this.margin,
    this.takeProfit,
    this.stopLoss,
    this.doNotShowAgain = false,
    this.onDoNotShowAgainChanged,
    this.onConfirm,
  });

  @override
  State<OrderConfirmationWidget> createState() =>
      _OrderConfirmationWidgetState();
}

class _OrderConfirmationWidgetState extends State<OrderConfirmationWidget> {
  late bool _doNotShowAgain;

  @override
  void initState() {
    super.initState();
    _doNotShowAgain = widget.doNotShowAgain;
  }

  String _safeValue(String? value) =>
      (value == null || value.trim().isEmpty) ? "-" : value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Order Confirmation",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _safeValue(widget.symbol),
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            ),
          ),
          const SizedBox(height: 15),
          ReactiveDataService(
            builder: (context, liveData, calculations) {
              return Column(
                children: [
                  _buildRow("Type", _safeValue(widget.orderType)),
                  _buildRow("Direction", _safeValue(widget.direction)),
                  _buildRow(
                      "Current Price",
                      _safeValue(widget.direction == "Buy"
                          ? calculations.bidValue.toString()
                          : calculations.askValue.toString())),
                  _buildRow("Volume", _safeValue(widget.volume)),
                  _buildRow("Margin", _safeValue(widget.margin)),
                  _buildRow("Take Profit", _safeValue(widget.takeProfit)),
                  _buildRow("Stop Loss", _safeValue(widget.stopLoss)),
                ],
              );
            },
            symbolName: widget.symbol ?? '',
          ),
          // const SizedBox(height: 10),
          // RadioListTile<bool>(
          //   contentPadding: EdgeInsets.zero,
          //   value: true,
          //   groupValue: _doNotShowAgain,
          //   title: const Text(
          //     "Do not show again. You may update this feature in Trade Settings.",
          //     style: TextStyle(fontSize: 12),
          //   ),
          //   onChanged: (val) {
          //     setState(() {
          //       _doNotShowAgain = val ?? false;
          //     });
          //     widget.onDoNotShowAgainChanged?.call(val ?? false);
          //   },
          // ),
          const SizedBox(height: 15),
          PremiumAppButton(
            text: 'Confirm',
            onPressed: () {
              Navigator.pop(context, true);
              widget.onConfirm?.call();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    Color textColor = value == "Buy"
        ? AppFlavorColor.primary
        : (value == "Sell" ? Colors.red : context.themeColor);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
