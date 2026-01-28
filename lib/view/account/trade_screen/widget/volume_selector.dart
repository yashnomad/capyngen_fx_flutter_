import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VolumeSelector extends StatefulWidget {
  final TextEditingController controller;
  final String initialUnit;
  final void Function(double volume, String unit)? onChanged;
  final double minValue;

  const VolumeSelector({
    super.key,
    required this.controller,
    this.initialUnit = "Lots",
    this.onChanged,
    this.minValue = 0.01,
  });

  @override
  State<VolumeSelector> createState() => _VolumeSelectorState();
}

class _VolumeSelectorState extends State<VolumeSelector> {
  late ValueNotifier<String> unitNotifier;

  @override
  void initState() {
    super.initState();
    unitNotifier = ValueNotifier(widget.initialUnit);

    widget.controller.addListener(_notifyChange);

    if (widget.controller.text.isEmpty ||
        (double.tryParse(widget.controller.text) ?? 0) < widget.minValue) {
      widget.controller.text = widget.minValue.toStringAsFixed(2);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyChange();
    });
  }

  void _notifyChange() {
    String text = widget.controller.text;

    if (text == ".") {
      widget.controller.text = "0.";
      return;
    }

    double parsed = double.tryParse(text) ?? widget.minValue;

    if (parsed < widget.minValue) {
      parsed = widget.minValue;
      widget.controller.text = parsed.toString();
    }

    widget.onChanged?.call(parsed, unitNotifier.value);
  }

  double _smartIncrement(double value) {
    if (value < 1.0) {
      return 1.0;
    }

    int wholePart = value.floor();
    double decimalPart = double.parse((value - wholePart).toStringAsFixed(1));

    if (decimalPart >= 0.9) {
      return (wholePart + 1).toDouble();
    } else {
      return double.parse((value + 0.1).toStringAsFixed(1));
    }
  }

  double _smartDecrement(double value) {
    if (value <= widget.minValue) {
      return widget.minValue;
    }

    int wholePart = value.floor();
    double decimalPart = double.parse((value - wholePart).toStringAsFixed(1));

    if (decimalPart == 0.0 && wholePart > 1) {
      return double.parse((wholePart - 1 + 0.9).toStringAsFixed(1));
    } else if (value <= 1.0) {
      return widget.minValue;
    } else {
      double newValue = double.parse((value - 0.1).toStringAsFixed(1));
      return newValue < widget.minValue ? widget.minValue : newValue;
    }
  }

  void _changeVolumeIncrement() {
    double current = double.tryParse(widget.controller.text) ?? widget.minValue;
    double newValue = double.parse((current + 0.1).toStringAsFixed(2));
    widget.controller.text = newValue.toString();
    _notifyChange();
  }

  void _changeVolumeDecrement() {
    double current = double.tryParse(widget.controller.text) ?? widget.minValue;

    double newValue = double.parse((current - 0.1).toStringAsFixed(2));

    if (newValue < widget.minValue) {
      newValue = widget.minValue;
    }

    widget.controller.text = newValue.toString();
    _notifyChange();
  }

  void _showVolumeUnitSheet(BuildContext context) {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      context: context,
      builder: (context) {
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
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Volume Unit",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
              _buildUnitRadioTile("Lots"),
              // _buildUnitRadioTile("USD"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUnitRadioTile(String value) {
    return ValueListenableBuilder<String>(
      valueListenable: unitNotifier,
      builder: (context, selected, _) {
        return RadioListTile<String>(
          contentPadding: EdgeInsets.zero,
          value: value,
          groupValue: selected,
          onChanged: (val) {
            if (val != null) {
              unitNotifier.value = val;
              _notifyChange();
              Navigator.pop(context);
            }
          },
          title: Text(value, style: const TextStyle(fontSize: 14)),
          activeColor: Colors.green,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Volume',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: widget.controller,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  /* inputFormatters: [
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      if (newValue.text.isEmpty) {
                        return newValue;
                      }

                      double? value = double.tryParse(newValue.text);
                      if (value != null && value >= 0) {
                        return newValue;
                      }

                      return oldValue;
                    }),
                  ],*/
                  inputFormatters: [
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      final text = newValue.text;

                      // allow empty
                      if (text.isEmpty) return newValue;

                      // allow only digits + one dot
                      if (!RegExp(r'^\d*\.?\d*$').hasMatch(text)) {
                        return oldValue;
                      }

                      return newValue;
                    }),
                  ],
                  onChanged: (value) {
                    if (value.isEmpty) {
                      Future.delayed(const Duration(milliseconds: 100), () {
                        if (widget.controller.text.isEmpty) {
                          widget.controller.text =
                              widget.minValue.toStringAsFixed(2);
                          _notifyChange();
                        }
                      });
                    } else {
                      _notifyChange();
                    }
                  },
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                  ),
                  cursorWidth: 0.7,
                  cursorHeight: 20,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: UnderlineInputBorder(borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Row(
            children: [
              IconButton(
                icon: const Icon(CupertinoIcons.minus, size: 18),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
                onPressed: _changeVolumeDecrement,
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.add, size: 18),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
                onPressed: _changeVolumeIncrement,
              ),
            ],
          ),
          const SizedBox(width: 15),
          Container(
            height: 25,
            width: 0.5,
            color: Colors.grey,
          ),
          const SizedBox(width: 15),
          GestureDetector(
            onTap: () => _showVolumeUnitSheet(context),
            child: ValueListenableBuilder<String>(
              valueListenable: unitNotifier,
              builder: (context, unit, _) {
                return Container(
                  color: Colors.transparent,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Row(
                    children: [
                      Text(
                        unit,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 30),
                      const Icon(Icons.keyboard_arrow_down_outlined, size: 20),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_notifyChange);
    unitNotifier.dispose();
    super.dispose();
  }
}
