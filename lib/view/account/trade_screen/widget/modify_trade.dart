import 'package:exness_clone/theme/app_flavor_color.dart'; // or your color file
import 'package:flutter/material.dart';

class ModifyOrderSheet extends StatefulWidget {
  final double avgPrice;
  final double? currentSl;
  final double? currentTp;
  final bool isBuy;
  final Function(double? sl, double? tp) onConfirm;

  const ModifyOrderSheet({
    super.key,
    required this.avgPrice,
    required this.isBuy,
    required this.onConfirm,
    this.currentSl,
    this.currentTp,
  });

  @override
  State<ModifyOrderSheet> createState() => _ModifyOrderSheetState();
}

class _ModifyOrderSheetState extends State<ModifyOrderSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _slController;
  late TextEditingController _tpController;

  @override
  void initState() {
    super.initState();
    // Pre-fill existing values if they exist
    _slController = TextEditingController(
        text: widget.currentSl != null ? widget.currentSl.toString() : '');
    _tpController = TextEditingController(
        text: widget.currentTp != null ? widget.currentTp.toString() : '');
  }

  @override
  void dispose() {
    _slController.dispose();
    _tpController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final typeColor =
        widget.isBuy ? const Color(0xFF00A86B) : const Color(0xFFD32F2F);
    final typeBg =
        widget.isBuy ? const Color(0xFFE6F7EF) : const Color(0xFFFFE5E0);

    return Padding(
      // Handle keyboard covering text fields
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Modify Order",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: typeBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.isBuy ? "BUY" : "SELL",
                  style: TextStyle(
                    color: typeColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// Avg Price Display
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Entry Price", style: TextStyle(color: Colors.grey)),
                Text(
                  widget.avgPrice.toStringAsFixed(5),
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Stop Loss Input
                const Text(
                  "STOP LOSS (SL)",
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _slController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: _inputDecoration("Price (e.g. 1.0500)"),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return null; // Allow empty to remove SL
                    final sl = double.tryParse(value);
                    if (sl == null) return "Invalid number";

                    // Validation Logic
                    if (widget.isBuy && sl >= widget.avgPrice) {
                      return "For Buy, SL must be < ${widget.avgPrice}";
                    }
                    if (!widget.isBuy && sl <= widget.avgPrice) {
                      return "For Sell, SL must be > ${widget.avgPrice}";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                /// Take Profit Input
                const Text(
                  "TAKE PROFIT (TP)",
                  style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _tpController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: _inputDecoration("Price (e.g. 1.0600)"),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return null; // Allow empty
                    final tp = double.tryParse(value);
                    if (tp == null) return "Invalid number";

                    // Validation Logic
                    if (widget.isBuy && tp <= widget.avgPrice) {
                      return "For Buy, TP must be > ${widget.avgPrice}";
                    }
                    if (!widget.isBuy && tp >= widget.avgPrice) {
                      return "For Sell, TP must be < ${widget.avgPrice}";
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          /// Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 45),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Cancel",
                      style: TextStyle(color: Colors.black)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final slText = _slController.text.trim();
                      final tpText = _tpController.text.trim();

                      final double? sl =
                          slText.isEmpty ? null : double.tryParse(slText);
                      final double? tp =
                          tpText.isEmpty ? null : double.tryParse(tpText);

                      widget.onConfirm(sl!, tp!);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 45),
                    backgroundColor: AppFlavorColor.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Confirm Modify",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
