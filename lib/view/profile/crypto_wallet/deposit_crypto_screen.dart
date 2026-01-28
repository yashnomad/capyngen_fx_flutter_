/*
import 'package:exness_clone/utils/common_utils.dart';
import 'package:exness_clone/utils/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:exness_clone/widget/app_button.dart';

import '../../account/withdraw_deposit/bloc/select_account_bloc.dart';
import '../../trade/model/trade_account.dart';
import '../../webview/crypto_deposit_webview.dart';
import 'bloc/crypto_deposit/crypto_deposit_bloc.dart';
import 'bloc/crypto_deposit/crypto_deposit_state.dart';

class DepositCryptoScreen extends StatefulWidget {
  final Account? account;
  final double? amount;

  const DepositCryptoScreen({
    super.key,
    this.account,
    this.amount,
  });

  @override
  State<DepositCryptoScreen> createState() => _DepositCryptoScreenState();
}

class _DepositCryptoScreenState extends State<DepositCryptoScreen> {
  final amountController = TextEditingController();
  bool _isProcessingWebViewResult = false;

  @override
  void initState() {
    super.initState();
    if (widget.amount != null) {
      amountController.text = widget.amount.toString();
    }
    amountController.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    final currentState = context.read<DepositCryptoCubit>().state;
    if (currentState is! DepositCryptoInitial &&
        currentState is! DepositCryptoLoading) {
      context.read<DepositCryptoCubit>().resetDeposit();
    }
  }

  void _handleDeposit() {
    Account? selectedAccount = widget.account;

    // If no account provided via constructor, get from cubit
    if (selectedAccount == null) {
      selectedAccount = context.read<SelectedAccountCubit>().state;
    }

    if (selectedAccount == null) {
      SnackBarService.showSnackBar(message: "Please select an account");
      return;
    }

    final tradeUserId = selectedAccount.id;
    debugPrint("Selected trade $tradeUserId");
    final amount = double.tryParse(amountController.text);

    if (amount != null && amount > 0) {
      context.read<DepositCryptoCubit>().createDeposit(
        tradeUserId: tradeUserId ?? '',
        amount: amount,
      );
    } else {
      SnackBarService.showSnackBar(message: 'Please enter a valid amount');
    }
  }

  Future<void> _navigateToWebView(String paymentUrl, String transactionId, double amount) async {
    if (paymentUrl.isEmpty) {
      SnackBarService.showError('Invalid payment URL');
      return;
    }

    setState(() {
      _isProcessingWebViewResult = true;
    });

    try {
      // Navigate to WebView and wait for result
      final result = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder: (context) => CryptoDepositWebView(
            url: paymentUrl,
            transactionId: transactionId,
            amount: amount,
          ),
        ),
      );

      // Handle the result from WebView
      if (result != null && mounted) {
        await _handleWebViewResult(result);
      }
    } catch (e) {
      debugPrint('Error navigating to WebView: $e');
      SnackBarService.showError('Failed to open payment gateway');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingWebViewResult = false;
        });
      }
    }
  }

  Future<void> _handleWebViewResult(Map<String, dynamic> result) async {
    final status = result['status'] as String?;
    final message = result['message'] as String?;
    final transactionId = result['transactionId'] as String?;

    debugPrint('WebView result: $result');

    switch (status) {
      case 'success':
      // Check payment status with API to confirm
        if (transactionId != null) {
          context.read<DepositCryptoCubit>().checkPaymentStatus(transactionId);
        }
        SnackBarService.showSuccess(message ?? 'Payment completed successfully!');
        break;

      case 'failed':
        SnackBarService.showError(message ?? 'Payment failed. Please try again.');
        context.read<DepositCryptoCubit>().resetDeposit();
        break;

      case 'cancelled':
        SnackBarService.showSnackBar(message: message ?? 'Payment was cancelled by user');
        context.read<DepositCryptoCubit>().resetDeposit();
        break;

      case 'timeout':
        SnackBarService.showError(message ?? 'Payment session expired. Please try again.');
        context.read<DepositCryptoCubit>().resetDeposit();
        break;

      case 'error':
      default:
        SnackBarService.showError(message ?? 'An error occurred during payment');
        context.read<DepositCryptoCubit>().resetDeposit();
        break;
    }
  }

  @override
  void dispose() {
    amountController.removeListener(_onAmountChanged);
    amountController.dispose();
    _resetBlocState();
    super.dispose();
  }

  void _resetBlocState() {
    context.read<DepositCryptoCubit>().resetDeposit();
    amountController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) {
          _resetBlocState();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text("Crypto Deposit"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Amount input section
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.currency_bitcoin,
                              color: Colors.purple[600],
                              size: 24),
                          const SizedBox(width: 8),
                          const Text(
                            'Crypto Deposit Amount',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Amount',
                          prefixText: '\$ ',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Information card
              Card(
                elevation: 1,
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue[600]),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Cryptomus Payment Gateway',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'You will be redirected to Cryptomus payment gateway where you can complete your crypto deposit using QR codes or wallet addresses.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // BLoC Builder for deposit status
              BlocConsumer<DepositCryptoCubit, DepositCryptoState>(
                listener: (context, state) {
                  if (state is DepositCryptoError) {
                    SnackBarService.showError(state.error);
                  } else if (state is DepositCryptoPaymentCompleted) {
                    SnackBarService.showSuccess(
                        'Payment completed successfully!');
                    // Update wallet balance if needed
                    // context.read<WalletBalanceCubit>().updateBalance(state.paymentStatus.closingBalance);
                  }
                },
                builder: (context, state) {
                  if (state is DepositCryptoLoading || _isProcessingWebViewResult) {
                    return const Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Creating deposit...'),
                          ],
                        ),
                      ),
                    );
                  } else if (state is DepositCryptoSuccess) {
                    final deposit = state.deposit;

                    // Automatically navigate to WebView when deposit is created
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!_isProcessingWebViewResult) {
                        _navigateToWebView(
                            deposit.paymentUrl,
                            deposit.transactionId,
                            deposit.amount
                        );
                      }
                    });

                    return Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle,
                              color: Colors.green, size: 64),
                          const SizedBox(height: 16),
                          Text(
                            'Deposit Created Successfully!',
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Transaction ID: ${deposit.transactionId}'),
                                  Text(
                                      'Amount: \$${deposit.amount.toStringAsFixed(2)}'),
                                  Text(
                                      'Status: ${deposit.status.toUpperCase()}'),
                                  Text(
                                      'Created: ${deposit.createdAt.toString()}'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppButton(
                            onPressed: () => _navigateToWebView(
                                deposit.paymentUrl,
                                deposit.transactionId,
                                deposit.amount
                            ),
                            text: 'Complete Payment',
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              context.read<DepositCryptoCubit>().checkPaymentStatus(deposit.transactionId);
                            },
                            child: const Text('Check Payment Status'),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              context.read<DepositCryptoCubit>().resetDeposit();
                              amountController.clear();
                            },
                            child: const Text('Make Another Deposit'),
                          ),
                        ],
                      ),
                    );
                  } else if (state is DepositCryptoPaymentCompleted) {
                    final paymentStatus = state.paymentStatus;
                    return Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.payment,
                              color: Colors.green, size: 64),
                          const SizedBox(height: 16),
                          Text(
                            'Payment Completed!',
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Card(
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Transaction ID: ${paymentStatus.transactionId}'),
                                  Text(
                                      'Amount: \$${paymentStatus.amount.toStringAsFixed(2)}'),
                                  Text(
                                      'Status: ${paymentStatus.status.toUpperCase()}'),
                                  Text(
                                      'New Balance: \$${paymentStatus.closingBalance.toStringAsFixed(2)}'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppButton(
                            onPressed: () {
                              context.read<DepositCryptoCubit>().resetDeposit();
                              amountController.clear();
                            },
                            text: 'Make Another Deposit',
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Back to Deposits'),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      AppButton(
                        onPressed: _handleDeposit,
                        text: 'Create Crypto Deposit',
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

*/
/*
import 'package:exness_clone/utils/common_utils.dart';
import 'package:exness_clone/utils/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:exness_clone/widget/app_button.dart';

import '../../account/withdraw_deposit/bloc/select_account_bloc.dart';
import 'bloc/crypto_deposit/crypto_deposit_bloc.dart';
import 'bloc/crypto_deposit/crypto_deposit_state.dart';

class DepositCryptoScreen extends StatefulWidget {
  const DepositCryptoScreen({super.key});

  @override
  State<DepositCryptoScreen> createState() => _DepositCryptoScreenState();
}

class _DepositCryptoScreenState extends State<DepositCryptoScreen> {
  final amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    amountController.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    final currentState = context.read<DepositCryptoCubit>().state;
    if (currentState is! DepositCryptoInitial &&
        currentState is! DepositCryptoLoading) {
      context.read<DepositCryptoCubit>().resetDeposit();
    }
  }

  void _handleDeposit() {
    final selectedAccount = context.read<SelectedAccountCubit>().state;

    if (selectedAccount == null) {
      SnackBarService.showSnackBar(message: "Please select an account");
      return;
    }

    final tradeUserId = selectedAccount.id;
    debugPrint("Selected trade $tradeUserId");
    final amount = double.tryParse(amountController.text);

    if (amount != null && amount > 0) {
      context.read<DepositCryptoCubit>().createDeposit(
            tradeUserId: tradeUserId ?? '',
            amount: amount,
          );
    } else {
      SnackBarService.showSnackBar(message: 'Please enter a valid amount');
    }
  }

  @override
  void dispose() {
    amountController.removeListener(_onAmountChanged);
    amountController.dispose();
    _resetBlocState();
    super.dispose();
  }

  void _resetBlocState() {
    context.read<DepositCryptoCubit>().resetDeposit();
    amountController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) {
          _resetBlocState();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: const Text("Deposit Crypto")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$ ',
                ),
              ),
              const SizedBox(height: 24),

              // BLoC Builder for deposit status
              BlocConsumer<DepositCryptoCubit, DepositCryptoState>(
                listener: (context, state) {
                  if (state is DepositCryptoError) {
                    SnackBarService.showError(state.error);
                  } else if (state is DepositCryptoPaymentCompleted) {
                    SnackBarService.showSuccess(
                        'Payment completed successfully!');
                    // Update wallet balance if needed
                    // context.read<WalletBalanceCubit>().updateBalance(state.paymentStatus.closingBalance);
                  }
                },
                builder: (context, state) {
                  if (state is DepositCryptoLoading) {
                    return const Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Creating deposit...'),
                          ],
                        ),
                      ),
                    );
                  } else if (state is DepositCryptoSuccess) {
                    final deposit = state.deposit;
                    return Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle,
                              color: Colors.green, size: 64),
                          const SizedBox(height: 16),
                          Text(
                            'Deposit Created Successfully!',
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Transaction ID: ${deposit.transactionId}'),
                                  Text(
                                      'Amount: \$${deposit.amount.toStringAsFixed(2)}'),
                                  Text(
                                      'Status: ${deposit.status.toUpperCase()}'),
                                  Text(
                                      'Created: ${deposit.createdAt.toString()}'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppButton(
                            onPressed: () {
                              debugPrint(
                                  "Payment url ${state.deposit.paymentUrl}");
                              context.push('/cryptoDepositWebview',
                                  extra: state.deposit.paymentUrl);
                            },
                            text: 'Pay Now',
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              // context.read<DepositCryptoCubit>().checkPaymentStatus(deposit.transactionId);
                            },
                            child: const Text('Check Payment Status'),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              context.read<DepositCryptoCubit>().resetDeposit();
                              amountController.clear();
                            },
                            child: const Text('Make Another Deposit'),
                          ),
                        ],
                      ),
                    );
                  } else if (state is DepositCryptoPaymentCompleted) {
                    final paymentStatus = state.paymentStatus;
                    return Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.payment,
                              color: Colors.green, size: 64),
                          const SizedBox(height: 16),
                          Text(
                            'Payment Completed!',
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Transaction ID: ${paymentStatus.transactionId}'),
                                  Text(
                                      'Amount: \$${paymentStatus.amount.toStringAsFixed(2)}'),
                                  Text(
                                      'Status: ${paymentStatus.status.toUpperCase()}'),
                                  Text(
                                      'New Balance: \$${paymentStatus.closingBalance.toStringAsFixed(2)}'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppButton(
                            onPressed: () {
                              context.read<DepositCryptoCubit>().resetDeposit();
                              amountController.clear();
                            },
                            text: 'Make Another Deposit',
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      AppButton(
                        onPressed: _handleDeposit,
                        text: 'Deposit Funds',
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/