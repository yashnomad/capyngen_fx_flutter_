import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/utils/snack_bar.dart';
import 'package:exness_clone/widget/button/app_button.dart';
import 'package:exness_clone/widget/button/premium_app_button.dart';
import 'package:exness_clone/widget/loader.dart';
import 'package:exness_clone/widget/shimmer/deposit_fund_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../trade/bloc/accounts_bloc.dart';
import '../../../trade/model/trade_account.dart';
import 'bloc/internal_transfer_bloc.dart';

class InternalTransfer extends StatefulWidget {
  const InternalTransfer({super.key});

  @override
  State<InternalTransfer> createState() => _InternalTransferState();
}

class _InternalTransferState extends State<InternalTransfer> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();
  Account? selectedFromAccount;
  Account? selectedToAccount;

  void _validateAndTransfer(BuildContext context) {
    if (selectedFromAccount == null || selectedToAccount == null) {
      SnackBarService.showSnackBar(
          message: "Please select both source and destination accounts");
      return;
    }

    final amountText = amountController.text.trim();
    if (amountText.isEmpty) {
      SnackBarService.showSnackBar(message: "Please enter transfer amount");
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      SnackBarService.showSnackBar(message: "Please enter a valid amount");
      return;
    }

    if (amount > selectedFromAccount!.balance!.toDouble()) {
      SnackBarService.showSnackBar(message: "Insufficient balance");
      return;
    }

    final accountsState = context.read<AccountsBloc>().state;
    if (accountsState is AccountsLoaded) {
      final isFromLive =
          accountsState.liveAccounts.contains(selectedFromAccount);
      final isToLive = accountsState.liveAccounts.contains(selectedToAccount);

      if (isFromLive != isToLive) {
        SnackBarService.showSnackBar(
            message:
                "Transfers can only be made between accounts of the same type (LIVE to LIVE or DEMO to DEMO)");
        return;
      }
    }

    context.read<InternalTransferBloc>().add(
          InitiateInternalTransfer(
            sourceAccount: selectedFromAccount!,
            destinationAccount: selectedToAccount!,
            amount: amount,
            remark: remarkController.text.trim(),
          ),
        );
  }

  void _clearForm() {
    setState(() {
      selectedFromAccount = null;
      selectedToAccount = null;
      amountController.clear();
      remarkController.clear();
    });
  }

  List<Account> _getAvailableToAccounts(
      List<Account> allAccounts, List<Account> liveAccounts) {
    if (selectedFromAccount == null) return [];

    final isFromLive = liveAccounts.contains(selectedFromAccount);

    return allAccounts
        .where((account) =>
            account != selectedFromAccount &&
            liveAccounts.contains(account) == isFromLive)
        .toList();
  }

  String _getAccountTypeLabel(Account account, List<Account> liveAccounts) {
    return liveAccounts.contains(account) ? 'LIVE' : 'DEMO';
  }

  @override
  void dispose() {
    amountController.dispose();
    remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(titleSpacing: 0, title: const Text('Internal Transfer')),
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AccountsBloc()..add(LoadAccounts()),
          ),
          BlocProvider(
            create: (context) => InternalTransferBloc(),
          ),
        ],
        child: MultiBlocListener(
          listeners: [
            BlocListener<InternalTransferBloc, InternalTransferState>(
              listener: (context, state) {
                if (state is InternalTransferSuccess) {
                  SnackBarService.showSnackBar(message: state.message);

                  context.read<AccountsBloc>().add(LoadAccounts());

                  _clearForm();

                  context
                      .read<InternalTransferBloc>()
                      .add(ResetInternalTransfer());
                } else if (state is InternalTransferError) {
                  SnackBarService.showSnackBar(message: state.message);
                }
              },
            ),
          ],
          child: BlocBuilder<AccountsBloc, AccountsState>(
            builder: (context, accountsState) {
              if (accountsState is AccountsLoading) {
                return DepositFundsShimmer();
              }

              if (accountsState is AccountsLoaded) {
                final liveAccounts = accountsState.liveAccounts;
                // final demoAccounts = accountsState.demoAccounts;
                // final allAccounts = [...liveAccounts, ...demoAccounts];
                final allAccounts = [...liveAccounts];

                if (allAccounts.isEmpty) {
                  return const Center(
                    child: Text('No accounts available for transfer'),
                  );
                }

                final availableToAccounts =
                    _getAvailableToAccounts(allAccounts, liveAccounts);

                return BlocBuilder<InternalTransferBloc, InternalTransferState>(
                  builder: (context, transferState) {
                    final isTransferring =
                        transferState is InternalTransferLoading;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Transfer From",
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<Account>(
                            dropdownColor: context.internalDopDownColor,
                            value: selectedFromAccount,
                            isExpanded: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(color: AppColor.lightGrey)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(color: Color(0xFF9AB3FC))),
                            ),
                            items: allAccounts.map((account) {
                              final accountType =
                                  _getAccountTypeLabel(account, liveAccounts);
                              return DropdownMenuItem<Account>(
                                value: account,
                                child: Text(
                                  '$accountType • ${account.accountId} • Balance: \$${account.balance}',
                                  style: TextStyle(fontSize: 14),
                                ),
                              );
                            }).toList(),
                            onChanged: isTransferring
                                ? null
                                : (account) {
                                    setState(() {
                                      selectedFromAccount = account;

                                      selectedToAccount = null;
                                    });
                                  },
                          ),
                          const SizedBox(height: 24),
                          const Text("Transfer To",
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<Account>(
                            dropdownColor: context.internalDopDownColor,
                            value: selectedToAccount,
                            isExpanded: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(color: AppColor.lightGrey)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(color: Color(0xFF9AB3FC))),
                            ),
                            items: availableToAccounts.map((account) {
                              final accountType =
                                  _getAccountTypeLabel(account, liveAccounts);
                              return DropdownMenuItem<Account>(
                                value: account,
                                child: Text(
                                  '${account.accountId} ($accountType) • Balance: \$${account.balance}',
                                  style: TextStyle(fontSize: 14),
                                ),
                              );
                            }).toList(),
                            onChanged: isTransferring
                                ? null
                                : (account) {
                                    setState(() => selectedToAccount = account);
                                  },
                          ),
                          const SizedBox(height: 24),
                          const Text("Transfer Amount",
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: amountController,
                            cursorColor: Color(0xFF9AB3FC),
                            keyboardType: TextInputType.number,
                            enabled: !isTransferring,
                            decoration: InputDecoration(
                                prefixText: '\$ ',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: AppColor.lightGrey)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: Color(0xFF9AB3FC))),
                                hintText: 'Enter amount',
                                hintStyle: TextStyle(fontSize: 14)),
                          ),
                          if (selectedFromAccount != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Available balance: \$${selectedFromAccount!.balance}',
                              style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                          const SizedBox(height: 16),
                          TextFormField(
                            cursorColor: Color(0xFF9AB3FC),
                            controller: remarkController,
                            enabled: !isTransferring,
                            decoration: InputDecoration(
                              hintText:
                                  'Add a note for this transfer (optional)',
                              hintStyle: TextStyle(fontSize: 14),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(color: AppColor.lightGrey)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(color: Color(0xFF9AB3FC))),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white10
                                  : Color(0xFFFFFBE6),
                              borderRadius: BorderRadius.circular(8),
                              border:
                                  Border.all(color: const Color(0xFFFFE58F)),
                            ),
                            child: const Text(
                              "⚠ Important\n\nPlease double-check all information. Transfers can only be made between accounts of the same type (LIVE to LIVE or DEMO to DEMO). Once submitted, the transfer will be processed according to our terms and conditions.",
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(height: 24),
                          PremiumAppButton(
                            onPressed: isTransferring
                                ? null
                                : () => _validateAndTransfer(context),
                            text: isTransferring
                                ? 'Processing Transfer...'
                                : 'Complete Transfer',
                          ),
                          if (transferState is InternalTransferSuccess) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: Colors.green.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "✅ Transfer Successful",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                      "Transaction ID: ${transferState.transactionId}"),
                                  Text(
                                      "Source Balance: \$${transferState.sourceClosingBalance}"),
                                  Text(
                                      "Destination Balance: \$${transferState.destinationClosingBalance}"),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              }

              if (accountsState is AccountsError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${accountsState.message}'),
                      const SizedBox(height: 16),
                      PremiumAppButton(
                        onPressed: () {
                          context.read<AccountsBloc>().add(LoadAccounts());
                        },
                        text: 'Retry',
                      ),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
