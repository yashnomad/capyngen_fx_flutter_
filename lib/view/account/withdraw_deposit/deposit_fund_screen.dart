import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/view/account/withdraw_deposit/provider/bank_provider.dart';
import 'package:exness_clone/view/trade/bloc/accounts_bloc.dart';
import 'package:exness_clone/widget/shimmer/deposit_fund_shimmer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../network/api_service.dart';
import '../../../services/bank_detail_service.dart';
import '../../../services/switch_account_service.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/common_utils.dart';
import '../../../utils/snack_bar.dart';
import 'package:exness_clone/widget/button/app_button.dart';
import '../../../widget/button/premium_app_button.dart';
import '../../../widget/custom_dropdown.dart';
import '../../investors/bullet_point.dart';
import '../../trade/model/trade_account.dart';
import 'cubit/transaction_cubit.dart';
import 'model/bank_model.dart';

class DepositFundsScreen extends StatefulWidget {
  const DepositFundsScreen({super.key});

  @override
  State<DepositFundsScreen> createState() => _DepositFundsScreenState();
}

class _DepositFundsScreenState extends State<DepositFundsScreen> {
  final _amountController = TextEditingController();
  final _utrController = TextEditingController();
  DepositMethod selectedMethod = DepositMethod.bankTransfer;
  String cryptoGateway = "online";

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<DepositController>(context, listen: false).loadAccounts();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _utrController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionCubit, TransactionState>(
      listener: (context, state) {
        if (state is TransactionSuccess) {
          SnackBarService.showSuccess(state.message);
          context.read<AccountsBloc>().add(RefreshAccounts());
          context.pop();
        } else if (state is TransactionSuccessCrypto) {
          context.push('/cryptoDepositWebview', extra: {
            'url': state.paymentUrl,
            'cryptoId': state.cryptoId,
          });
        } else if (state is TransactionFailure) {
          SnackBarService.showError(state.error);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Deposit Funds"),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
        ),
        body: SwitchAccountService(
          accountBuilder: (context, account) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAccountInfoCard(account, account.isLiveAccount),
                        const SizedBox(height: 20),
                        if (account.isLiveAccount) ...[
                          _buildAmountInputCard(account),
                          const SizedBox(height: 24),
                          _buildPaymentMethodSection(),
                          const SizedBox(height: 16),
                          _getMethodDetailsWidget(context),
                        ],
                        if (account.isDemoAccount) _buildDemoAccountInfoBox(),
                      ],
                    ),
                  ),
                ),
                _buildBottomActionArea(account),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Payment Method",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppFlavorColor.headerText,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _methodTile(
                DepositMethod.bankTransfer, Icons.account_balance, "Bank"),
            const SizedBox(width: 10),
            _methodTile(DepositMethod.upi, Icons.qr_code_scanner, "UPI"),
            const SizedBox(width: 10),
            _methodTile(DepositMethod.crypto, Icons.currency_bitcoin, "Crypto"),
          ],
        ),
      ],
    );
  }

  Widget _methodTile(DepositMethod method, IconData icon, String label) {
    bool isSelected = selectedMethod == method;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedMethod = method),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white
                : AppFlavorColor.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppFlavorColor.primary : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05), blurRadius: 10)
                  ]
                : [],
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: isSelected ? AppFlavorColor.primary : Colors.grey),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppFlavorColor.primary : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getMethodDetailsWidget(BuildContext context) {
    switch (selectedMethod) {
      case DepositMethod.bankTransfer:
        return _buildBankCard(context);
      case DepositMethod.upi:
        return _buildUpiCard(context);
      case DepositMethod.crypto:
        return _buildCryptoSelectionUI();
    }
  }

  Widget _buildCryptoSelectionUI() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _toggleItem("Auto Deposit", Icons.bolt, "online"),
              _toggleItem("Manual Deposit", Icons.pan_tool_alt, "manual"),
            ],
          ),
        ),
        const SizedBox(height: 20),
        cryptoGateway == "manual"
            ? _buildManualCryptoForm()
            : _buildAutoCryptoInstructions(),
      ],
    );
  }

  Widget _toggleItem(String label, IconData icon, String value) {
    bool isSelected = cryptoGateway == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => cryptoGateway = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05), blurRadius: 4)
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18,
                  color: isSelected ? AppFlavorColor.primary : Colors.grey),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppFlavorColor.primary : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManualCryptoForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Instructions:",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: AppFlavorColor.primary)),
          const SizedBox(height: 8),
          const Text(
              "1. Copy the wallet address provided.\n2. Transfer the exact amount.\n3. Copy your Transaction Hash (TxID).\n4. Paste it below to confirm.",
              style: TextStyle(fontSize: 12, height: 1.5)),
          const SizedBox(height: 20),
          const Text("Transaction Hash (TxID) *",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(
            controller: _utrController,
            decoration: InputDecoration(
              hintText: "Enter hash",
              filled: true,
              fillColor: Colors.white,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoCryptoInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.green),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "You will be redirected to a secure crypto gateway to complete your payment.",
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionArea(Account account) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoading) return const DepositFundsShimmer();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5))
            ],
          ),
          child: PremiumAppButton(
            text: account.isDemoAccount
                ? "Add \$10,000 Demo"
                : "Complete Deposit",
            onPressed: () => _handleDeposit(account),
          ),
        );
      },
    );
  }

  void _handleDeposit(Account account) {
    final bool isDemo = account.isDemoAccount;
    if (isDemo) {
      context
          .read<TransactionCubit>()
          .depositDemoFunds(tradingAccount: account);
      return;
    }
    final depositController =
        Provider.of<DepositController>(context, listen: false);

    final selectedAccount = depositController.selected;

    if (selectedMethod == DepositMethod.bankTransfer ||
        selectedMethod == DepositMethod.upi) {
      if (selectedAccount == null) {
        SnackBarService.showError("Please select a merchant account first");
        return;
      }

      if (_utrController.text.isEmpty) {
        SnackBarService.showError("UTR/Transaction ID is required");
        return;
      }
    }

    context.read<TransactionCubit>().depositFunds(
          tradingAccount: account,
          amount: double.tryParse(_amountController.text) ?? 0.0,
          paymentMode: selectedMethod,
          merchantId: selectedAccount?.id,
          utrNumber: _utrController.text.trim(),
          gatewayName:
              selectedMethod == DepositMethod.crypto ? cryptoGateway : null,
        );
  }

  Widget _buildDemoAccountInfoBox() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppFlavorColor.info.withOpacity(0.1),
            AppFlavorColor.info.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppFlavorColor.info.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppFlavorColor.info.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: AppFlavorColor.info,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Demo Account",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppFlavorColor.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Practice trading with virtual funds without any real money risk.",
            style: TextStyle(
              fontSize: 14,
              color: AppColor.greyColor,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildBulletPoint("Deposits in demo accounts are simulated"),
          const SizedBox(height: 8),
          _buildBulletPoint("No real money is involved"),
          const SizedBox(height: 8),
          _buildBulletPoint("Perfect for learning trading strategies"),
        ],
      ),
    );
  }

  Widget _buildBankCard(BuildContext context) {
    final controller = Provider.of<DepositController>(context);
    final selectedAccount = controller.selected;

    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (selectedAccount == null || selectedAccount.bankDetails == null) {
      return const Center(child: Text("No Bank accounts available"));
    }

    final bank = selectedAccount.bankDetails!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Bank Account',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColor.greyColor,
          ),
        ),
        const SizedBox(height: 8),

        // 1. BANK SELECTION DROPDOWN
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: context.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Result>(
              isExpanded: true,
              value: selectedAccount,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: controller.accounts.map((Result account) {
                return DropdownMenuItem<Result>(
                  value: account,
                  child: Text(
                    "${account.bankDetails?.bankName ?? 'Bank'} - ${account.bankDetails?.accountNumber?.substring(account.bankDetails!.accountNumber!.length - 4)}",
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                );
              }).toList(),
              onChanged: (Result? newValue) {
                if (newValue != null) controller.changeAccount(newValue);
              },
            ),
          ),
        ),

        const SizedBox(height: 20),

        // 2. BANK DETAILS DISPLAY CARD
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "TRANSFER TO BANK ACCOUNT",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow("Account Holder", bank.accountHolder ?? "",
                  showCopy: false),
              const Divider(height: 24),
              _buildDetailRow("Bank Name", bank.bankName ?? "",
                  showCopy: false),
              const Divider(height: 24),
              _buildDetailRow("Account Number", bank.accountNumber ?? "",
                  showCopy: true),
              const Divider(height: 24),
              _buildDetailRow("IFSC Code", bank.ifscCode ?? "", showCopy: true),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 3. TRANSACTION ID / UTR INPUT
        RichText(
          text: const TextSpan(
            text: 'Transaction ID / UTR ',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
            children: [
              TextSpan(text: '*', style: TextStyle(color: Colors.red))
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _utrController,
          decoration: InputDecoration(
            hintText: 'Enter 12-digit UTR number',
            hintStyle:
                TextStyle(color: Colors.grey.withOpacity(0.6), fontSize: 14),
            filled: true,
            fillColor: context.backgroundColor,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3))),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

// Helper method to keep UI clean
  Widget _buildDetailRow(String label, String value, {required bool showCopy}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: showCopy
              ? () {
                  Clipboard.setData(ClipboardData(text: value));
                  SnackBarService.showSuccess("$label copied");
                }
              : null,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              if (showCopy)
                Icon(Icons.copy, size: 16, color: Colors.blue.shade600),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpiCard(BuildContext context) {
    final controller = Provider.of<DepositController>(context);
    final selectedAccount = controller.selected;

    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (selectedAccount == null) {
      return const Center(child: Text("No UPI accounts available"));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select UPI Provider',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColor.greyColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: context.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Result>(
              isExpanded: true,
              value: selectedAccount,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: controller.accounts.map((Result account) {
                return DropdownMenuItem<Result>(
                  value: account,
                  child: Text(
                    account.upiDetails?.providerName ?? "UPI",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (Result? newValue) {
                if (newValue != null) {
                  controller.changeAccount(newValue);
                }
              },
            ),
          ),
        ),

        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: Colors.grey.shade300, style: BorderStyle.solid),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "SCAN OR COPY UPI",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // QR Code Section
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: context.backgroundColor,
                      // color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: selectedAccount.upiDetails?.barcodeUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              selectedAccount.upiDetails!.barcodeUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.qr_code_2, size: 40);
                              },
                            ),
                          )
                        : const Icon(Icons.qr_code_2, size: 40),
                  ),
                  const SizedBox(width: 20),

                  // Details Section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // UPI ID Label
                        Text(
                          'UPI ID',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 4),
                        // UPI ID Value with Copy
                        GestureDetector(
                          onTap: () {
                            final upiId = selectedAccount.upiDetails?.upiId;

                            if (upiId == null || upiId.isEmpty) return;

                            Clipboard.setData(ClipboardData(text: upiId));
                            SnackBarService.showSuccess(
                                "UPI ID copied to clipboard");
                          },
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  selectedAccount.upiDetails?.upiId ?? '',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Icon(Icons.copy,
                                  size: 18, color: Colors.blue.shade600),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Provider Label
                        Text(
                          'Provider',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Provider Value
                        Text(
                          selectedAccount.upiDetails?.providerName ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 3. TRANSACTION ID / UTR INPUT
        RichText(
          text: TextSpan(
            text: 'Transaction ID / UTR ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            children: const [
              TextSpan(
                text: '*',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _utrController,
          decoration: InputDecoration(
            hintText: 'Enter transaction reference number',
            hintStyle: TextStyle(
              color: Colors.grey.withOpacity(0.6),
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.blue,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            filled: true,
            fillColor: context.backgroundColor,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountInputCard(Account account) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppFlavorColor.primary.withOpacity(0.05),
            AppFlavorColor.primary.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppFlavorColor.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.attach_money,
                  color: Colors.green,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Deposit Amount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppFlavorColor.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _amountController,
            decoration: InputDecoration(
              labelText: 'Enter amount',
              prefixText: '\$ ',
              prefixStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: context.backgroundColor,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColor.greyColor.withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColor.greyColor.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppFlavorColor.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: context.backgroundColor,

              // fillColor: Colors.white,
            ),
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: AppColor.greyColor,
              ),
              const SizedBox(width: 6),
              Text(
                'Available balance: ${CommonUtils.formatBalance(account.balance?.toDouble())}',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColor.greyColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: AppFlavorColor.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: AppColor.greyColor,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountInfoCard(Account account, bool isLive) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppFlavorColor.primary.withOpacity(0.1),
            AppFlavorColor.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppFlavorColor.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppFlavorColor.buttonGradient,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isLive ? Icons.account_balance : Icons.science_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      account.accountId ?? 'N/A',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppFlavorColor.text,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isLive
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isLive ? Colors.green : Colors.orange,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        isLive ? 'LIVE' : 'DEMO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isLive ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Balance: ${CommonUtils.formatBalance(account.balance?.toDouble())}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppFlavorColor.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/*
import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/view/account/withdraw_deposit/provider/bank_provider.dart';
import 'package:exness_clone/view/trade/bloc/accounts_bloc.dart';
import 'package:exness_clone/widget/shimmer/deposit_fund_shimmer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../network/api_service.dart';
import '../../../services/bank_detail_service.dart';
import '../../../services/switch_account_service.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/common_utils.dart';
import '../../../utils/snack_bar.dart';
import 'package:exness_clone/widget/button/app_button.dart';
import '../../../widget/button/premium_app_button.dart';
import '../../../widget/custom_dropdown.dart';
import '../../investors/bullet_point.dart';
import '../../trade/model/trade_account.dart';
import 'cubit/transaction_cubit.dart';
import 'model/bank_model.dart';


class DepositFundsScreen extends StatefulWidget {
  const DepositFundsScreen({super.key});

  @override
  State<DepositFundsScreen> createState() => _DepositFundsScreenState();
}

class _DepositFundsScreenState extends State<DepositFundsScreen> {
  final _amountController = TextEditingController();
  final _upiController = TextEditingController();
  final TextEditingController _utrController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_checkAmount);
    Future.microtask(() {
      Provider.of<DepositController>(context, listen: false).loadAccounts();
    });
  }

  bool _isButtonActive = false;

  void _checkAmount() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    setState(() {
      _isButtonActive = amount >= 30;
    });
  }

  bool _isDepositing = false;

  DepositMethod? selectedMethod = DepositMethod.bankTransfer;

  String getDepositMethodDisplayName(DepositMethod method) {
    switch (method) {
      case DepositMethod.bankTransfer:
        return 'Bank Transfer';
      case DepositMethod.upi:
        return 'UPI';
      case DepositMethod.crypto:
        return 'Crypto';
    }
  }


  Future<void> _depositPayment(Account account) async {
    setState(() => _isDepositing = true);

    try {
      debugPrint("[Deposit] 🔄 Initiating crypto_deposit...");

      final tradeUserId = account.id;
      final amount = double.tryParse(_amountController.text.trim());

      if (tradeUserId == null || amount == null || amount <= 0) {
        debugPrint("[Deposit] ❌ Invalid tradeUserId or amount");
        SnackBarService.showSnackBar(message: "Invalid account or amount");
        return;
      }

      if (selectedMethod == DepositMethod.crypto) {
        final response = await ApiService.depositCrypto({
          'trade_user_id': tradeUserId,
          'amount': amount,
          'currency': "USD",
        });

        if (response.success && response.data != null) {
          final result = response.data!['result'];
          final paymentUrl = result['payment_url'];
          final cryptoId = result['crypto_id'];
          if (!mounted) return;
          debugPrint("➡️ Navigating to /cryptoDepositWebview with $paymentUrl");

          context.push(
            '/cryptoDepositWebview',
            extra: {
              'url': paymentUrl,
              'cryptoId': cryptoId,
            },
          );
        } else {
          SnackBarService.showSnackBar(
              message: response.message ?? "Failed to create deposit");
        }

        return;
      }

      final body = {
        "trade_user_id": tradeUserId,
        "amount": amount,
        "merchant_id": "default_merchant"
      };

      debugPrint("[Deposit] 📤 Sending body: $body");

      final response = await ApiService.deposit(body);

      debugPrint("[Deposit] ✅ Response received: ${response.toString()}");

      if (response.success) {
        debugPrint("[Deposit] 🎉 Deposit successful");
        setState(() {
          _amountController.clear();
        });
        SnackBarService.showSnackBar(
            message: response.data?['message'] ?? "Deposit successful");
      } else {
        SnackBarService.showSnackBar(
            message: response.message ?? "Deposit failed");
      }
    } catch (e, stackTrace) {
      debugPrint("[Deposit] ❌ Exception during crypto_deposit: $e");
      debugPrint("[Deposit] 🧵 Stack trace: $stackTrace");
      SnackBarService.showSnackBar(
          message: "An error occurred during crypto_deposit.");
    } finally {
      setState(() => _isDepositing = false);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Deposit Funds"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SwitchAccountService(
        accountBuilder: (context, account) {
          final isLive = account.isLiveAccount;
          final isDemo = account.isDemoAccount;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Account Info Card
                      _buildAccountInfoCard(account, isLive),

                      const SizedBox(height: 20),

                      if (isLive) ...[
                        // Amount Input Card
                        _buildAmountInputCard(account),

                        const SizedBox(height: 20),

                        // Deposit Method Section
                        _buildDepositMethodSection(),

                        const SizedBox(height: 16),

                        // Method Details Widget
                        _getDepositMethodWidget(context),
                      ],

                      if (isDemo) _buildDemoAccountInfoBox(),
                    ],
                  ),
                ),
              ),

              // Bottom Buttons
              _isDepositing
                  ? DepositFundsShimmer()
                  : _buildBottomButtons(context, account, isDemo),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAccountInfoCard(Account account, bool isLive) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppFlavorColor.primary.withOpacity(0.1),
            AppFlavorColor.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppFlavorColor.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppFlavorColor.buttonGradient,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isLive ? Icons.account_balance : Icons.science_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      account.accountId ?? 'N/A',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppFlavorColor.text,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isLive
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isLive ? Colors.green : Colors.orange,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        isLive ? 'LIVE' : 'DEMO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isLive ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Balance: ${CommonUtils.formatBalance(account.balance?.toDouble())}',
                  // 'Balance: \$${account.balance}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppFlavorColor.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInputCard(Account account) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppFlavorColor.primary.withOpacity(0.05),
            AppFlavorColor.primary.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppFlavorColor.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.attach_money,
                  color: Colors.green,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Deposit Amount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppFlavorColor.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _amountController,
            decoration: InputDecoration(
              labelText: 'Enter amount',
              prefixText: '\$ ',
              prefixStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: context.backgroundColor,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColor.greyColor.withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColor.greyColor.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppFlavorColor.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: context.backgroundColor,

              // fillColor: Colors.white,
            ),
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: AppColor.greyColor,
              ),
              const SizedBox(width: 6),
              Text(
                'Available balance: ${CommonUtils.formatBalance(account.balance?.toDouble())}',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColor.greyColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDepositMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Select Payment Method',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppFlavorColor.headerText,
            ),
          ),
        ),
        CustomStyledDropdown<DepositMethod>(
          items: DepositMethod.values,
          selectedItem: selectedMethod,
          onChanged: (DepositMethod? newValue) {
            setState(() => selectedMethod = newValue);
          },
          itemBuilder: (DepositMethod method) =>
              getDepositMethodDisplayName(method),
          hint: 'Select a deposit method',
        ),
      ],
    );
  }

  Widget _buildDemoAccountInfoBox() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppFlavorColor.info.withOpacity(0.1),
            AppFlavorColor.info.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppFlavorColor.info.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppFlavorColor.info.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: AppFlavorColor.info,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Demo Account",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppFlavorColor.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Practice trading with virtual funds without any real money risk.",
            style: TextStyle(
              fontSize: 14,
              color: AppColor.greyColor,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildBulletPoint("Deposits in demo accounts are simulated"),
          const SizedBox(height: 8),
          _buildBulletPoint("No real money is involved"),
          const SizedBox(height: 8),
          _buildBulletPoint("Perfect for learning trading strategies"),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: AppFlavorColor.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: AppColor.greyColor,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons(
      BuildContext context, Account account, bool isDemo) {
    final bool isDemo = account.isDemoAccount;
    final bool isLive = account.isLiveAccount;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, transactionState) {
          final bool isLoading = transactionState is TransactionLoading;

          final bool effectiveIsButtonActive =
              (isDemo && !isLoading) || (_isButtonActive && !isLoading);
          final String buttonText = isDemo ? 'Deposit \$10,000' : 'Continue';
          return Row(
            children: [
              Expanded(
                child: isDemo
                    ? PremiumAppButton(
                        onPressed: () async {
                          await context
                              .read<TransactionCubit>()
                              .depositDemoFunds(
                                tradingAccount: account,
                                amount: 10000,
                              );
                          if (context.mounted) {
                            context.read<AccountsBloc>().add(RefreshAccounts());
                            context.pop();
                          }
                        },
                        text: 'Add \$10,000',
                      )
                    : Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 24,
                          top: 16,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isLive) _buildRulesText(),
                            const SizedBox(height: 16),
                            PremiumAppButton(
                              text: buttonText,
                              onPressed: effectiveIsButtonActive
                                  ? () {
                                      final amount = isDemo
                                          ? 10000.0
                                          : (double.tryParse(
                                                _amountController.text,
                                              ) ??
                                              0.0);

                                      if (isLive &&
                                          selectedMethod == DepositMethod.upi) {
                                        final bank =
                                            Provider.of<DepositController>(
                                          context,
                                          listen: false,
                                        ).selected;

                                        context
                                            .read<TransactionCubit>()
                                            .depositFunds(
                                              tradingAccount: account,
                                              account: bank!,
                                              amount: amount,
                                              utrNumber:
                                                  _utrController.text.trim(),
                                              method: DepositMethod.upi,
                                              merchantId: bank.id,
                                            );

                                        return;
                                      }

                                      if (isLive &&
                                          selectedMethod ==
                                              DepositMethod.bankTransfer) {
                                        final bank =
                                            Provider.of<DepositController>(
                                          context,
                                          listen: false,
                                        ).selected;

                                        if (bank == null) {
                                          SnackBarService.showSnackBar(
                                            message:
                                                "Please select bank account",
                                          );
                                          return;
                                        }

                                        if (_utrController.text.isEmpty) {
                                          SnackBarService.showSnackBar(
                                            message: "Please enter UTR number",
                                          );
                                          return;
                                        }

                                        context
                                            .read<TransactionCubit>()
                                            .depositFunds(
                                              tradingAccount: account,
                                              account: bank,
                                              amount: amount,
                                              method:
                                                  DepositMethod.bankTransfer,
                                              merchantId: bank.id,
                                              utrNumber: _utrController.text,
                                            );
                                        CommonUtils.debugPrintWithTrace(
                                          'Merchant id: ${account.id}',
                                        );

                                        return;
                                      }

                                      if (isLive &&
                                          selectedMethod ==
                                              DepositMethod.crypto) {
                                        final bank =
                                            Provider.of<DepositController>(
                                          context,
                                          listen: false,
                                        ).selected;
                                        context
                                            .read<TransactionCubit>()
                                            .depositFunds(
                                              tradingAccount: account,
                                              account: bank!,
                                              // account: selectedAccount,
                                              amount: amount,
                                              method: DepositMethod.crypto,
                                            );
                                        return;
                                      }
                                    }
                                  : null,
                              isLoading: isLoading,
                            ),
                          ],
                        )),
                // : PremiumAppButton(
                //     onPressed: () async {
                //       await _validateAndDeposit(account);
                //       if (context.mounted) {
                //         context.read<AccountsBloc>().add(RefreshAccounts());
                //         // context.pop();
                //       }
                //     },
                //     text: 'Deposit Funds',
                //   ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text("Cancel"),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _getDepositMethodWidget(BuildContext context) {
    switch (selectedMethod) {
      case DepositMethod.bankTransfer:
        return const BankDetailService(provideBloc: true);
      case DepositMethod.upi:
        return _buildUpiCard(context);
      case DepositMethod.crypto:
        return _buildCryptoCard();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildRulesText() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(fontSize: 10, color: AppColor.greyColor),
        children: [
          const TextSpan(
            text:
                'By clicking Continue, I agree that I have read and understood the ',
          ),
          TextSpan(
            text: 'Rules and Risks Statement',
            style: TextStyle(
              color: Colors.grey[600],
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.withOpacity(0.08),
            Colors.blue.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.purple.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.currency_bitcoin,
                  color: Colors.purple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Crypto Deposit',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppFlavorColor.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Deposit funds easily using your crypto wallet. Transfers are fast and secure.',
            style: TextStyle(
              fontSize: 14,
              color: AppColor.greyColor,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.orange.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange.shade700,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Ensure you send only supported cryptocurrencies. Transactions cannot be reversed.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade800,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpiCard(BuildContext context) {
    final controller = Provider.of<DepositController>(context);
    final selectedAccount = controller.selected;

    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (selectedAccount == null) {
      return const Center(child: Text("No UPI accounts available"));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select UPI Provider',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColor.greyColor, // Or Colors.grey[700]
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: context.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Result>(
              isExpanded: true,
              value: selectedAccount,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: controller.accounts.map((Result account) {
                return DropdownMenuItem<Result>(
                  value: account,
                  child: Text(
                    account.upiDetails?.providerName ?? "UPI",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (Result? newValue) {
                if (newValue != null) {
                  controller.changeAccount(newValue);
                }
              },
            ),
          ),
        ),

        const SizedBox(height: 20),

        // 2. SCAN OR COPY UPI CARD
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: Colors.grey.shade300,
                style: BorderStyle
                    .solid), // Dashed effect requires custom painter, solid is cleaner
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "SCAN OR COPY UPI",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // QR Code Section
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: context.backgroundColor,
                      // color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: selectedAccount.upiDetails?.barcodeUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              selectedAccount.upiDetails!.barcodeUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.qr_code_2, size: 40);
                              },
                            ),
                          )
                        : const Icon(Icons.qr_code_2, size: 40),
                  ),
                  const SizedBox(width: 20),

                  // Details Section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // UPI ID Label
                        Text(
                          'UPI ID',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 4),
                        // UPI ID Value with Copy
                        GestureDetector(
                          onTap: () {
                            final upiId = selectedAccount.upiDetails?.upiId;

                            if (upiId == null || upiId.isEmpty) return;

                            Clipboard.setData(ClipboardData(text: upiId));
                            SnackBarService.showSuccess(
                                "UPI ID copied to clipboard");
                          },
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  selectedAccount.upiDetails?.upiId ?? '',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Icon(Icons.copy,
                                  size: 18, color: Colors.blue.shade600),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Provider Label
                        Text(
                          'Provider',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Provider Value
                        Text(
                          selectedAccount.upiDetails?.providerName ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 3. TRANSACTION ID / UTR INPUT
        RichText(
          text: TextSpan(
            text: 'Transaction ID / UTR ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            children: const [
              TextSpan(
                text: '*',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _utrController, // UNCOMMENT AND USE YOUR CONTROLLER
          decoration: InputDecoration(
            hintText: 'Enter transaction reference number',
            hintStyle: TextStyle(
              color: Colors.grey.withOpacity(0.6),
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.blue,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            filled: true,
            fillColor: context.backgroundColor,
          ),
        ),
      ],
    );
  }
}
*/
