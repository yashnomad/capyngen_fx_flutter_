
/*

class DepositCryptoScreen extends StatefulWidget {
  const DepositCryptoScreen({super.key});

  @override
  State<DepositCryptoScreen> createState() => _DepositCryptoScreenState();
}

class _DepositCryptoScreenState extends State<DepositCryptoScreen> {
  final amountController = TextEditingController();
  String? tradeUserId;

  @override
  void initState() {
    super.initState();
    // Load wallet balance when screen initializes
    // context.read<WalletBalanceCubit>().loadBalance();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  Future<void> _launchPaymentUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      SnackBarService.showError('Could not launch payment URL');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Deposit Funds")),
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
            const SizedBox(height: 8),
            */
/* BlocBuilder<WalletBalanceCubit, WalletBalanceState>(
              builder: (context, state) {
                if (state is WalletBalanceLoading) {
                  return const Text(
                    'Loading balance...',
                    style: TextStyle(color: Colors.blue),
                  );
                } else if (state is WalletBalanceLoaded) {
                  return Text(
                    'Available balance: \$${state.balance.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.blue),
                  );
                } else if (state is WalletBalanceError) {
                  return Text(
                    'Error loading balance: ${state.error}',
                    style: const TextStyle(color: Colors.red),
                  );
                }
                return const Text(
                  'Available balance: \$0.00',
                  style: TextStyle(color: Colors.blue),
                );
              },
            ),*/ /*

            const SizedBox(height: 24),

            // BLoC Builder for deposit status
            BlocConsumer<DepositCryptoCubit, DepositCryptoState>(
              listener: (context, state) {
                if (state is DepositCryptoError) {
                  SnackBarService.showError(state.error);
                } else if (state is DepositCryptoPaymentCompleted) {
                  SnackBarService.showSuccess(
                      'Payment completed successfully!');
                  // Update wallet balance
                  // context.read<WalletBalanceCubit>().updateBalance(state.closingBalance);
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
                                Text('Transaction ID: ${state.transactionId}'),
                                Text(
                                    'Amount: \$${state.amount.toStringAsFixed(2)}'),
                                Text('Status: ${state.status.toUpperCase()}'),
                                Text('Created: ${state.createdAt.toString()}'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          onPressed: () => _launchPaymentUrl(state.paymentUrl),
                          text: 'Pay Now',
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            context
                                .read<DepositCryptoCubit>()
                                .checkPaymentStatus(state.transactionId);
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
                                Text('Transaction ID: ${state.transactionId}'),
                                Text(
                                    'Amount: \$${state.amount.toStringAsFixed(2)}'),
                                Text('Status: ${state.status.toUpperCase()}'),
                                Text(
                                    'New Balance: \$${state.closingBalance.toStringAsFixed(2)}'),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // const Spacer(),
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
    );
  }
}
*/