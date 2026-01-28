import 'package:flutter/material.dart';
import '../model/bank_model.dart';

class BankAccountSection extends StatelessWidget {
  final Result model;                     // <-- FIXED
  final TextEditingController utrController;

  const BankAccountSection({
    super.key,
    required this.model,
    required this.utrController,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text("Bank Details",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

            const SizedBox(height: 12),

            _item("Bank Name:", model.bankDetails?.bankName ?? ''),
            _item("Account Number:", model.bankDetails?.accountNumber ?? ''),
            _item("Account Holder:", model.bankDetails?.accountHolder ?? ''),
            _item("IFSC Code:", model.bankDetails?.ifscCode ?? ''),
            _item(
              "Deposit Limits:",
              "\$${model.minDeposit} - \$${model.maxDeposit}",
            ),
            const SizedBox(height: 10),
            Text("UTR Number *"),
            const SizedBox(height: 6),
            TextField(
              controller: utrController,
              decoration: InputDecoration(
                hintText: "Enter UTR/Transaction Reference Number",
                filled: true,
                border: OutlineInputBorder(),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _item(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text(title)),
          Expanded(
            flex: 6,
            child: Text(value, style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
