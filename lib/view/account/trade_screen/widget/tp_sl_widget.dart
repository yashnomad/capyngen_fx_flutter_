import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../theme/app_colors.dart';

class TPAndSLWidget extends StatefulWidget {
  final double initialTP;
  final double minTP;
  final double initialSL;
  final double minSL;
  final ValueChanged<double?>? onTPChanged;
  final ValueChanged<double?>? onSLChanged;

  const TPAndSLWidget({
    super.key,
    required this.initialTP,
    required this.minTP,
    required this.initialSL,
    required this.minSL,
    this.onTPChanged,
    this.onSLChanged,
  });

  @override
  State<TPAndSLWidget> createState() => _TPAndSLWidgetState();
}

class _TPAndSLWidgetState extends State<TPAndSLWidget> {
  late final ValueNotifier<bool> showTP;
  late final ValueNotifier<bool> showSL;

  late final TextEditingController tpController;
  late final TextEditingController slController;

  @override
  void initState() {
    super.initState();
    showTP = ValueNotifier(false);
    showSL = ValueNotifier(false);

    tpController =
        TextEditingController(text: widget.initialTP.toStringAsFixed(2));
    slController =
        TextEditingController(text: widget.initialSL.toStringAsFixed(2));
  }

  double _smartIncrement(double value) {
    // If value is less than 1.0, jump to 1.0
    if (value < 1.0) {
      return 1.0;
    }

    // Get the integer and decimal parts
    int wholePart = value.floor();
    double decimalPart = double.parse((value - wholePart).toStringAsFixed(1));

    // If decimal part is 0.9, jump to next whole number
    if (decimalPart >= 0.9) {
      return (wholePart + 1).toDouble();
    } else {
      // Otherwise, increment by 0.1
      return double.parse((value + 0.1).toStringAsFixed(1));
    }
  }

  double _smartDecrement(double value) {
    // Don't go below 0.1
    if (value <= 0.1) {
      return 0.1;
    }

    // If value is exactly a whole number (like 2.0, 3.0), go to previous x.9
    int wholePart = value.floor();
    double decimalPart = double.parse((value - wholePart).toStringAsFixed(1));

    if (decimalPart == 0.0 && wholePart > 1) {
      return double.parse((wholePart - 1 + 0.9).toStringAsFixed(1));
    } else if (value <= 1.0) {
      // If we're at 1.0 or below, go to 0.1
      return 0.1;
    } else {
      // Otherwise, decrement by 0.1
      return double.parse((value - 0.1).toStringAsFixed(1));
    }
  }

  void tpIncrement() {
    double val = double.tryParse(tpController.text) ?? widget.minTP;
    val = _smartIncrement(val);
    tpController.text = val.toStringAsFixed(1);
    widget.onTPChanged?.call(val);
  }

  void tpDecrement() {
    double val = double.tryParse(tpController.text) ?? widget.minTP;
    val = _smartDecrement(val);
    tpController.text = val.toStringAsFixed(1);
    widget.onTPChanged?.call(val);
  }

  void slIncrement() {
    double val = double.tryParse(slController.text) ?? widget.minSL;
    val = _smartIncrement(val);
    slController.text = val.toStringAsFixed(1);
    widget.onSLChanged?.call(val);
  }

  void slDecrement() {
    double val = double.tryParse(slController.text) ?? widget.minSL;
    val = _smartDecrement(val);
    slController.text = val.toStringAsFixed(1);
    widget.onSLChanged?.call(val);
  }

  @override
  void dispose() {
    showTP.dispose();
    showSL.dispose();
    tpController.dispose();
    slController.dispose();
    super.dispose();
  }

  Widget _buildInput({
    required String label,
    required ValueNotifier<bool> showNotifier,
    required TextEditingController controller,
    required double minValue,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            showNotifier.value = !showNotifier.value;
            // When toggling, notify parent with value or null
            if (showNotifier.value) {
              // When enabling, send current controller value
              double val = double.tryParse(controller.text) ?? minValue;
              if (label == "Take Profit") {
                widget.onTPChanged?.call(val);
              } else {
                widget.onSLChanged?.call(val);
              }
            } else {
              // When disabling, send null
              if (label == "Take Profit") {
                widget.onTPChanged?.call(null);
              } else {
                widget.onSLChanged?.call(null);
              }
            }
          },
          child: ValueListenableBuilder<bool>(
            valueListenable: showNotifier,
            builder: (_, active, __) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                active
                    ? Icon(Icons.radio_button_on,
                        size: 16, color: AppColor.blueGrey)
                    : Container(
                        height: 15,
                        width: 15,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColor.greyColor),
                        ),
                      ),
                const SizedBox(width: 10),
                Text(label,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        ValueListenableBuilder<bool>(
          valueListenable: showNotifier,
          builder: (_, active, __) {
            if (!active) return const SizedBox();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: 50,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          onChanged: (val) {
                            double? numVal = double.tryParse(val);
                            if (numVal != null && numVal >= 0) {
                              if (label == "Take Profit") {
                                widget.onTPChanged?.call(numVal);
                              } else {
                                widget.onSLChanged?.call(numVal);
                              }
                            }
                          },
                          inputFormatters: [
                            TextInputFormatter.withFunction(
                                (oldValue, newValue) {
                              // Allow empty string for editing
                              if (newValue.text.isEmpty) {
                                return newValue;
                              }

                              // Check if the new value is a valid positive number
                              double? value = double.tryParse(newValue.text);
                              if (value != null && value >= 0) {
                                return newValue;
                              }

                              // If invalid, keep the old value
                              return oldValue;
                            }),
                          ],
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500),
                          cursorWidth: 1,
                          cursorHeight: 20,
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(
                                borderSide: BorderSide.none),
                            isDense: true,
                          ),
                        ),
                      ),
                      IconButton(
                          onPressed: onDecrement,
                          icon: const Icon(Icons.remove, size: 20)),
                      IconButton(
                          onPressed: onIncrement,
                          icon: const Icon(Icons.add, size: 20)),
                    ],
                  ),
                ),
                if ((double.tryParse(controller.text) ?? 0) < minValue)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'Min value: ${minValue.toStringAsFixed(2)}',
                      style: TextStyle(color: AppColor.redColor, fontSize: 11),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInput(
          label: "Take Profit",
          showNotifier: showTP,
          controller: tpController,
          minValue: widget.minTP,
          onIncrement: tpIncrement,
          onDecrement: tpDecrement,
        ),
        _buildInput(
          label: "Stop Loss",
          showNotifier: showSL,
          controller: slController,
          minValue: widget.minSL,
          onIncrement: slIncrement,
          onDecrement: slDecrement,
        ),
      ],
    );
  }
}
