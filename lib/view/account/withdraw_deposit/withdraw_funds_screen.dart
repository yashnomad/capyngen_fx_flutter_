import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/utils/common_utils.dart';
import 'package:exness_clone/utils/snack_bar.dart';
import 'package:exness_clone/widget/button/app_button.dart';
import 'package:exness_clone/widget/shimmer/deposit_fund_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../theme/app_colors.dart';
import '../../../widget/button/premium_app_button.dart';
import '../../../widget/custom_dropdown.dart';
import '../../profile/banking/cubit/payment_methods_cubit.dart';
import '../../profile/banking/model/crypto_wallet.dart';
import '../../profile/user_profile/bloc/user_profile_bloc.dart';
import '../../trade/bloc/accounts_bloc.dart';
import '../../trade/model/trade_account.dart';
import 'cubit/transaction_cubit.dart';

enum WithdrawMethod { bankTransfer, upi, crypto }

class WithdrawFundsScreen extends StatefulWidget {
  const WithdrawFundsScreen({super.key});

  @override
  State<WithdrawFundsScreen> createState() => _WithdrawFundsScreenState();
}

class _WithdrawFundsScreenState extends State<WithdrawFundsScreen> {
  Account? selectedAccount;
  WithdrawMethod? selectedMethod = WithdrawMethod.bankTransfer;
  CryptoWallet? selectedCryptoWallet;
  int selectedIndex = 0;

  final amountController = TextEditingController();

  String _getMethodApiString(WithdrawMethod method) {
    switch (method) {
      case WithdrawMethod.bankTransfer:
        return 'bank';
      case WithdrawMethod.upi:
        return 'upi';
      case WithdrawMethod.crypto:
        return 'crypto';
    }
  }

  void _onWithdrawPressed(
      BuildContext context, PaymentMethodsState paymentDataState) {
    final text = amountController.text.trim();

    if (selectedAccount == null || text.isEmpty) {
      SnackBarService.showSnackBar(
          message: "Please select account and enter amount");
      return;
    }

    final enteredAmount = double.tryParse(text);
    if (enteredAmount == null || enteredAmount <= 0) {
      SnackBarService.showSnackBar(message: "Invalid amount");
      return;
    }

    if (enteredAmount > (selectedAccount?.balance ?? 0)) {
      SnackBarService.showSnackBar(
          message: "Entered amount exceeds available balance");
      return;
    }

    String? destination;
    String? upiId;

    if (selectedMethod == WithdrawMethod.crypto) {
      if (selectedCryptoWallet == null) {
        SnackBarService.showSnackBar(message: "Please select a crypto wallet");
        return;
      }
      destination = selectedCryptoWallet?.address;
    } else if (selectedMethod == WithdrawMethod.upi) {
      upiId = paymentDataState.withdrawalDetails.upiId;

      if (upiId == null || upiId.isEmpty) {
        SnackBarService.showSnackBar(message: "No UPI ID found in profile");
        return;
      }
    } else if (selectedMethod == WithdrawMethod.bankTransfer) {
      if (paymentDataState.withdrawalDetails.bankAccountNumber == null) {
        SnackBarService.showSnackBar(
            message: "No Bank Details found in profile");
        return;
      }
    }

    context.read<TransactionCubit>().withdrawFunds(
          account: selectedAccount!,
          amount: enteredAmount,
          method: _getMethodApiString(selectedMethod!),
          destinationAddress: destination,
          upiId: upiId,
        );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => TransactionCubit()),
        BlocProvider(create: (context) => AccountsBloc()..add(LoadAccounts())),
        BlocProvider(
          create: (context) => PaymentMethodsCubit(
            userProfileBloc: context.read<UserProfileBloc>(),
          )..loadInitialData(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Withdraw Funds"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocListener<TransactionCubit, TransactionState>(
          listener: (context, state) {
            if (state is TransactionSuccess) {
              SnackBarService.showSnackBar(message: state.message);
              Navigator.pop(context);
            } else if (state is TransactionFailure) {
              SnackBarService.showSnackBar(message: state.error);
            }
          },
          child: BlocBuilder<AccountsBloc, AccountsState>(
            builder: (context, accountState) {
              if (accountState is AccountsLoading) return DepositFundsShimmer();

              if (accountState is AccountsLoaded) {
                return BlocBuilder<PaymentMethodsCubit, PaymentMethodsState>(
                  builder: (context, paymentDataState) {
                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 20),
                              decoration: BoxDecoration(
                                  color: context.withdrawalBoxColor,
                                  // color: context.withdrawalBoxColor,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10.0))),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomStyledDropdown<Account>(
                                    items: accountState.liveAccounts,
                                    selectedItem: selectedAccount,
                                    hint: 'Select Account',
                                    onChanged: (val) =>
                                        setState(() => selectedAccount = val),
                                    itemBuilder: (acc) =>
                                        "${acc.accountId} (LIVE) - ${CommonUtils.formatBalance(acc.balance?.toDouble())}",
                                  ),
                                  const SizedBox(height: 10),
                                  const Text('Withdrawal Method',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 6),
                                  CustomStyledDropdown<WithdrawMethod>(
                                    items: WithdrawMethod.values,
                                    selectedItem: selectedMethod,
                                    onChanged: (val) => setState(() {
                                      selectedMethod = val;
                                      selectedCryptoWallet = null;
                                    }),
                                    itemBuilder: (m) =>
                                        _getMethodDisplayName(m),
                                    hint: 'Select Method',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                            if (selectedMethod == WithdrawMethod.bankTransfer)
                              _buildBankCard(paymentDataState),
                            if (selectedMethod == WithdrawMethod.upi)
                              _buildUpiCard(paymentDataState),
                            if (selectedMethod == WithdrawMethod.crypto)
                              _buildCryptoCard(paymentDataState),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: amountController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Amount',
                                prefixText: '\$ ',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            if (selectedAccount != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                    'Available: ${CommonUtils.formatBalance(selectedAccount!.balance?.toDouble())}',
                                    style:
                                        const TextStyle(color: Colors.green)),
                              ),
                            const SizedBox(height: 24),
                            BlocBuilder<TransactionCubit, TransactionState>(
                              builder: (context, transactionState) {
                                return SizedBox(
                                  width: double.infinity,
                                  child: PremiumAppButton(
                                    isLoading:
                                        transactionState is TransactionLoading,
                                    onPressed: () => _onWithdrawPressed(
                                        context, paymentDataState),
                                    text: 'Withdraw Funds',
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  String _getMethodDisplayName(WithdrawMethod method) {
    switch (method) {
      case WithdrawMethod.bankTransfer:
        return 'Bank Transfer';
      case WithdrawMethod.upi:
        return 'UPI';
      case WithdrawMethod.crypto:
        return 'Crypto';
    }
  }

  Widget _buildBankCard(PaymentMethodsState state) {
    final bank = state.withdrawalDetails;
    return _containerWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header("Bank Details"),
          const SizedBox(height: 16),
          _row("Bank Name", bank.bankName ?? "Not Set"),
          const Divider(),
          _row("Account No", bank.bankAccountNumber ?? "Not Set"),
          const Divider(),
          _row("IFSC", bank.ifscCode ?? "Not Set"),
        ],
      ),
    );
  }

  Widget _buildUpiCard(PaymentMethodsState state) {
    final upi = state.withdrawalDetails.upiId;
    return _containerWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header("UPI Details"),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8)),
            child: Text(
              (upi.isNotEmpty) ? upi : "No UPI ID Linked in Profile",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoCard(PaymentMethodsState state) {
    if (state.cryptoWallets.isNotEmpty && selectedCryptoWallet == null) {
      selectedCryptoWallet = state.cryptoWallets.first;
    }

    return _containerWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header("Crypto Wallet"),
          const SizedBox(height: 16),

          const Text(
            "CURRENCY",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            selectedCryptoWallet?.currency ?? 'N/A',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),

          if (state.cryptoWallets.isEmpty)
            const Text("No crypto wallets found."),
          if (state.cryptoWallets.isNotEmpty)
            const Text(
              "SELECT NETWORK",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(
                state.cryptoWallets.length,
                (index) {
                  final wallet = state.cryptoWallets[index];
                  final isSelected = selectedIndex == index;

                  return ChoiceChip(
                    label: Text(
                      wallet.network ?? '',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppFlavorColor.primary,
                    backgroundColor: Colors.grey.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onSelected: (_) {
                      setState(() {
                        selectedIndex = index;
                        selectedCryptoWallet = wallet;
                      });
                    },
                    checkmarkColor: Colors.white,
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
          if (selectedCryptoWallet != null)
            _destinationWallet(selectedCryptoWallet!),

        ],
      ),
    );
  }

  Widget _destinationWallet(CryptoWallet wallet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "DESTINATION WALLET",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          decoration: BoxDecoration(
            color: context.backgroundColor,
            // color: context.backgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            wallet.address ?? '',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _header(String title) {
    return Row(children: [
      Icon(Icons.account_balance_wallet,
          color: AppFlavorColor.primary, size: 20),
      const SizedBox(width: 12),
      Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
    ]);
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _containerWrapper({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.depositContainerColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: context.depositBoxShadowColor,
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: child,
    );
  }
}

/*
import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/network/api_service.dart';
import 'package:exness_clone/utils/snack_bar.dart';
import 'package:exness_clone/widget/button/app_button.dart';
import 'package:exness_clone/widget/shimmer/deposit_fund_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../services/bank_detail_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widget/button/premium_app_button.dart';
import '../../../widget/custom_dropdown.dart';
import '../../trade/bloc/accounts_bloc.dart';
import '../../trade/model/trade_account.dart';

enum WithdrawMethod {
  bankTransfer,
  upi,
  crypto,
}

class WithdrawFundsScreen extends StatefulWidget {
  const WithdrawFundsScreen({super.key});

  @override
  State<WithdrawFundsScreen> createState() => _WithdrawFundsScreenState();
}

class _WithdrawFundsScreenState extends State<WithdrawFundsScreen> {
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

  WithdrawMethod? selectedMethod = WithdrawMethod.bankTransfer;

  String getWithdrawMethodDisplayName(WithdrawMethod method) {
    switch (method) {
      case WithdrawMethod.bankTransfer:
        return 'Bank Transfer';
      case WithdrawMethod.upi:
        return 'UPI';
      case WithdrawMethod.crypto:
        return 'Crypto';
    }
  }

  Widget _getWithdrawMethodWidget() {
    switch (selectedMethod) {
      case WithdrawMethod.bankTransfer:
        return _buildBank(context);
      case WithdrawMethod.upi:
        return _buildUpiCard();
      case WithdrawMethod.crypto:
        return _buildCryptoCard();
      default:
        return SizedBox.shrink();
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
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          color: context.scaffoldBackgroundColor,
        ),
        title: const Text("Withdraw Funds"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocProvider(
        create: (context) => AccountsBloc()..add(LoadAccounts()),
        child: BlocBuilder<AccountsBloc, AccountsState>(
          builder: (context, state) {
            if (state is AccountsLoading) {
              return DepositFundsShimmer();
            }

            if (state is AccountsLoaded) {
              final liveAccounts = state.liveAccounts;

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 20),
                        decoration: BoxDecoration(
                            color: context.withdrawalBoxColor,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomStyledDropdown<Account>(
                              items: liveAccounts,
                              selectedItem: selectedAccount,
                              hint: 'Select Account',
                              onChanged: (account) {
                                setState(() => selectedAccount = account);
                              },
                              itemBuilder: (Account account) {
                                return "${account.accountId} (LIVE) - \$${account.balance.toString()}";
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            const Text(
                              'Withdrawal Method',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            CustomStyledDropdown<WithdrawMethod>(
                              items: WithdrawMethod.values,
                              selectedItem: selectedMethod,
                              onChanged: (WithdrawMethod? newValue) {
                                setState(() {
                                  selectedMethod = newValue;
                                });
                              },
                              itemBuilder: (WithdrawMethod method) =>
                                  getWithdrawMethodDisplayName(method),
                              hint: 'Select a withdrawal method',
                            ),
                          ],
                        ),
                      ),
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                      SizedBox(
                        height: 15,
                      ),
                      _getWithdrawMethodWidget(),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: amountController,
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          prefixText: '\$ ',
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColor.mediumGrey),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColor.greyColor),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 8),
                      if (selectedAccount != null)
                        Text(
                          'Available balance: \$${selectedAccount!.balance}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: PremiumAppButton(
                          onPressed: () => _validateAndWithdraw(context),
                          text: 'Withdraw Funds',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Container _buildBank(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      decoration: BoxDecoration(
        color: context.depositContainerColor,
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        boxShadow: [
          BoxShadow(
            color: context.depositBoxShadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const BankDetailService(provideBloc: true),
    );
  }

  Container _buildCryptoCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      decoration: BoxDecoration(
        color: context.depositContainerColor,
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        boxShadow: [
          BoxShadow(
            color: context.depositBoxShadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.flash_on,
                  color: Colors.blue[600],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Crypto Wallet Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

            
          Text(
            'Wallet Address',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),

            
          TextField(
            cursorColor: AppColor.blueColor,
            decoration: InputDecoration(
              hintText: 'Enter crypto wallet address',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.blue[500]!,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

            
          Text(
            'Ensure you enter the correct wallet address. Transactions cannot be reversed.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Container _buildUpiCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      decoration: BoxDecoration(
        color: context.depositContainerColor,
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        boxShadow: [
          BoxShadow(
            color: context.depositBoxShadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.flash_on,
                  color: Colors.blue[600],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'UPI Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

            
          Text(
            'UPI ID',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),

            
          TextField(
            cursorColor: AppColor.blueColor,
            decoration: InputDecoration(
              hintText: 'Enter UPI ID (e.g. name@bank)',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.blue[500]!,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              filled: true,
              fillColor: context.depositContainerColor,
            ),
          ),
          const SizedBox(height: 12),

            
          Text(
            'Ensure you enter the correct wallet address. Transactions cannot be reversed.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
*/
