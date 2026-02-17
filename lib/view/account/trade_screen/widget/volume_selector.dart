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
  final ValueNotifier<bool> _isValidNotifier = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    unitNotifier = ValueNotifier(widget.initialUnit);

    // Initial validation
    _validate();
    widget.controller.addListener(_validate);
  }

  void _validate() {
    final text = widget.controller.text;
    final value = double.tryParse(text);
    // Invalid if empty, null, or strictly 0 (or less than 0 which shouldn't happen with keyboard type)
    // User requested "0 nhi hona chahea", so we check <= 0.
    // However, we typically want to respect minValue.
    // Let's stick to: invalid if empty or == 0.
    if (text.isEmpty || value == null || value == 0) {
      _isValidNotifier.value = false;
    } else {
      _isValidNotifier.value = true;
    }

    // Notify parent if needed about valid changes
    if (value != null) {
      widget.onChanged?.call(value, unitNotifier.value);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_validate);
    unitNotifier.dispose();
    _isValidNotifier.dispose();
    super.dispose();
  }

  // Helper to get current value safely
  double _getCurrentValue() {
    return double.tryParse(widget.controller.text) ?? 0.0;
  }

  void _changeVolumeIncrement() {
    double current = _getCurrentValue();
    // If current is less than min (e.g. 0 or empty), start from minValue
    if (current < widget.minValue) {
      widget.controller.text = widget.minValue.toString();
      return; // Listener handles validation
    }

    // Smart increment logic
    double newValue;
    if (current < 1.0) {
      // From 0.01 to 0.99, add 0.01? Or 0.1? Code roughly added 0.1 before.
      // Previous logic: if decimal >= 0.9 -> next int. else +0.1
      // Let's preserve the "smart" logic but safe wrap it.
      int wholePart = current.floor();
      double decimalPart =
          double.parse((current - wholePart).toStringAsFixed(2));
      if (decimalPart >= 0.9) {
        newValue = (wholePart + 1).toDouble();
      } else {
        newValue = double.parse((current + 0.1).toStringAsFixed(2));
      }
    } else {
      // If >= 1.0, step is 1? Or 0.1?
      // Previous logic:
      // if (value < 1.0) -> return 1.0 in one branch?
      // The previous _smartIncrement was:
      // if (value < 1.0) return 1.0 ??? That seems aggressive if we are at 0.1
      // Wait, let's look at previous _smartIncrement:
      // if (value < 1.0) { return 1.0; } -> This means 0.1 -> 1.0 jumps.
      // Maybe that's desired behavior? Users heavily use volume 0.01 etc.
      // Let's stick to simple +0.01 or +0.1 logic if that's what's expected,
      // OR re-implement the exact previous smart logic but safe.

      // Let's try a standard step of 0.01 if < 1, and 0.1 or 1 if > 1?
      // Actually, standard MetaTrader/Exness behavior:
      // 0.01 -> 0.02 increment?
      // The user code had `_changeVolumeIncrement` calling `current + 0.1`.
      // But `_smartIncrement` was unused in `_changeVolumeIncrement` in the original code!
      // In original code:
      // void _changeVolumeIncrement() {
      //   double current = ...
      //   double newValue = double.parse((current + 0.1).toStringAsFixed(2));
      //   widget.controller.text = newValue.toString();
      //   _notifyChange();
      // }
      // The `_smartIncrement` function was defined but NOT USED in `_changeVolumeIncrement`.
      // I will stick to the used logic: +0.1.

      newValue = double.parse((current + 0.1).toStringAsFixed(2));
    }

    widget.controller.text = newValue.toString();
  }

  void _changeVolumeDecrement() {
    double current = _getCurrentValue();
    if (current <= widget.minValue) {
      // Can't go lower, just ensure it's min value if it was 0/empty
      if (current < widget.minValue) {
        widget.controller.text = widget.minValue.toString();
      }
      return;
    }

    double newValue = double.parse((current - 0.1).toStringAsFixed(2));
    if (newValue < widget.minValue) {
      newValue = widget.minValue;
    }
    widget.controller.text = newValue.toString();
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
              // widget.onChanged?.call(...) handled by listener
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
    return ValueListenableBuilder<bool>(
      valueListenable: _isValidNotifier,
      builder: (context, isValid, child) {
        return Container(
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: isValid ? null : Border.all(color: Colors.red, width: 1.5),
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
                      inputFormatters: [
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          final text = newValue.text;
                          if (text.isEmpty) return newValue;
                          // allow only digits + one dot
                          if (!RegExp(r'^\d*\.?\d*$').hasMatch(text)) {
                            return oldValue;
                          }
                          return newValue;
                        }),
                      ],
                      // Removed onChanged logic causing resets
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
                        border:
                            UnderlineInputBorder(borderSide: BorderSide.none),
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
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      child: Row(
                        children: [
                          Text(
                            unit,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 30),
                          const Icon(Icons.keyboard_arrow_down_outlined,
                              size: 20),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
