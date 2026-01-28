import 'package:exness_clone/network/api_service.dart';
import 'package:exness_clone/utils/snack_bar.dart';
import 'package:exness_clone/widget/button/app_button.dart';
import 'package:exness_clone/widget/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../services/bank_detail_service.dart';
import '../../../trade/bloc/accounts_bloc.dart';
import '../../../trade/model/trade_account.dart';

class DepositFundsPopup extends StatefulWidget {
  const DepositFundsPopup({super.key});

  @override
  State<DepositFundsPopup> createState() => _DepositFundsPopupState();
}

class _DepositFundsPopupState extends State<DepositFundsPopup> {
  Account? selectedAccount;
  final amountController = TextEditingController();

  void _validateAndWithdraw(BuildContext context) async {
    final text = amountController.text.trim();

    if (text.isEmpty) {
      SnackBarService.showSnackBar(
          message: "Please select account and enter amount");
      return;
    }

    await _depositPayment();

    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _depositPayment() async {
    try {
      debugPrint("[Deposit] 🔄 Initiating crypto_deposit...");

      final tradeUserId = selectedAccount?.id;
      final amount = double.tryParse(amountController.text.trim());

      if (tradeUserId == null || amount == null || amount <= 0) {
        debugPrint("[Deposit] ❌ Invalid tradeUserId or amount");
        SnackBarService.showSnackBar(message: "Invalid account or amount");
        return;
      }

      final body = {
        "trade_user_id": tradeUserId,
        "amount": amount,
        "merchant_id": "default_merchant" // Currently I added default merchant
      };

      debugPrint("[Deposit] 📤 Sending body: $body");

      final response = await ApiService.deposit(body);

      debugPrint("[Deposit] ✅ Response received: ${response.toString()}");

      if (response.success) {
        debugPrint("[Deposit] 🎉 Deposit successful");
        debugPrint("Deposit ${response.message}");
        SnackBarService.showSnackBar(
            message: response.data?['message'] ?? "Deposit successful");
      } else {
        debugPrint("[Deposit] ⚠️ Deposit failed: ${response.message}");
        SnackBarService.showSnackBar(
            message: response.message ?? "Deposit failed");
      }
    } catch (e, stackTrace) {
      debugPrint("[Deposit] ❌ Exception during crypto_deposit: $e");
      debugPrint("[Deposit] 🧵 Stack trace: $stackTrace");
      SnackBarService.showSnackBar(
          message: "An error occurred during crypto_deposit.");
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AccountsBloc()..add(LoadAccounts()),
      child: BlocBuilder<AccountsBloc, AccountsState>(
        builder: (context, state) {
          if (state is AccountsLoading) {
            return Loader();
          }

          if (state is AccountsLoaded) {
            final liveAccounts = state.liveAccounts;
            final demoAccounts = state.demoAccounts;
            final allAccounts = [...liveAccounts, ...demoAccounts];

            return AlertDialog(
              title: const Text("Deposit Funds"),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<Account>(
                      decoration: const InputDecoration(labelText: 'Account'),
                      value: selectedAccount,
                      isExpanded: true,
                      items: allAccounts.map((account) {
                        // Determine if it's a live or demo account
                        final isLive = liveAccounts.contains(account);
                        final accountType = isLive ? 'LIVE' : 'DEMO';

                        return DropdownMenuItem<Account>(
                          value: account,
                          child: Text(
                            "${account.accountId} ($accountType) - \$${account.balance}",
                          ),
                        );
                      }).toList(),
                      onChanged: (account) {
                        setState(() => selectedAccount = account);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        prefixText: '\$ ',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    if (selectedAccount != null)
                      Text(
                        'Available balance: \$${selectedAccount!.balance}',
                        style: const TextStyle(color: Colors.blue),
                      ),
                    if (selectedAccount != null &&
                        liveAccounts.contains(selectedAccount)) ...[
                      const SizedBox(height: 24),
                      const BankDetailService(provideBloc: true),
                    ],
                  ],
                ),
              ),
              actions: [
                AppButton(
                  onPressed: () => _validateAndWithdraw(context),
                  text: 'Deposit Funds',
                ),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
