import 'package:exness_clone/network/api_service.dart';
import 'package:exness_clone/utils/snack_bar.dart';
import 'package:exness_clone/widget/button/app_button.dart';
import 'package:exness_clone/widget/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../services/bank_detail_service.dart';
import '../../../../widget/button/premium_app_button.dart';
import '../../../../widget/custom_dropdown.dart';
import '../../../trade/bloc/accounts_bloc.dart';
import '../../../trade/model/trade_account.dart';

class WithdrawFundsPopup extends StatefulWidget {
  const WithdrawFundsPopup({super.key});

  @override
  State<WithdrawFundsPopup> createState() => _WithdrawFundsPopupState();
}

class _WithdrawFundsPopupState extends State<WithdrawFundsPopup> {
  Account? selectedAccount;
  final amountController = TextEditingController();

  void _validateAndWithdraw(BuildContext context) async {
    final text = amountController.text.trim();

    if (selectedAccount == null || text.isEmpty) {
      SnackBarService.showSnackBar(
          message: "Please select account and enter amount");
      return;
    }

    final enteredAmount = double.tryParse(text);

    if (enteredAmount == null) {
      SnackBarService.showSnackBar(message: "Invalid amount entered");
      return;
    }

    if (enteredAmount <= 0) {
      SnackBarService.showSnackBar(message: "Amount should be greater than 0");
      return;
    }

    if (enteredAmount > (selectedAccount?.balance ?? 0)) {
      SnackBarService.showSnackBar(
        message: "Entered amount exceeds available balance",
      );
      return;
    }
    await _withdrawPayment();

    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  Future<void> _withdrawPayment() async {
    try {
      debugPrint("[Withdraw] 🔄 Initiating withdrawal...");

      final tradeUserId = selectedAccount?.id;
      final amount = double.tryParse(amountController.text.trim());

      if (tradeUserId == null || amount == null || amount <= 0) {
        debugPrint("[Withdraw] ❌ Invalid tradeUserId or amount");
        SnackBarService.showSnackBar(message: "Invalid account or amount");
        return;
      }

      final body = {
        "trade_user_id": tradeUserId,
        "amount": amount,
      };

      debugPrint("[Withdraw] 📤 Sending body: $body");

      final response = await ApiService.withdraw(body);

      debugPrint("[Withdraw] ✅ Response received: ${response.toString()}");
      SnackBarService.showSnackBar(message: response.toString());

      if (response.success) {
        final msg = response.message ?? "Withdraw request submitted";
        SnackBarService.showSnackBar(message: msg);

        final data = response.data;
        if (data is Map<String, dynamic>) {
          final result = data['result'] as Map<String, dynamic>?;
          final status = result?['status'] ?? "unknown";
          final txnId = result?['transactionId'] ?? "N/A";

          debugPrint("✅ Withdraw status: $status, Txn ID: $txnId");

          // Optionally show more details
          SnackBarService.showSnackBar(
            message: "Withdrawal $status\nTxn ID: $txnId",
          );
        }
      } else {
        SnackBarService.showSnackBar(
          message: response.message ?? "Withdrawal failed",
        );
      }
    } catch (e, stackTrace) {
      debugPrint("[Withdraw] ❌ Exception during withdrawal: $e");
      debugPrint("[Withdraw] 🧵 Stack trace: $stackTrace");
    }
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

            return AlertDialog(
              title: const Text("Withdraw Funds"),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomStyledDropdown<Account>(
                      items: liveAccounts,
                      selectedItem: selectedAccount,
                      hint: 'Select Account',
                      label: 'Account',
                      onChanged: (account) {
                        setState(() => selectedAccount = account);
                      },
                      itemBuilder: (Account account) {
                        // Format balance to 2 decimal places
                        String formattedBalance = account.toString();
                        return "${account.accountId} (LIVE) - \$$formattedBalance";
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
                    const SizedBox(height: 24),
                    /* ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Radio(
                        value: true,
                        groupValue: true,
                        onChanged: (_) {},
                      ),
                      title: const Text("Bank Account"),
                      subtitle: const Text(
                        "Withdraw funds directly to your linked bank account",
                      ),
                    ),*/
                    const BankDetailService(provideBloc: true)
                  ],
                ),
              ),
              actions: [
                PremiumAppButton(
                  onPressed: () => _validateAndWithdraw(context),
                  text: 'Withdraw Funds',
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
