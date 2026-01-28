import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../profile/crypto_wallet/bloc/crypto_deposit/crypto_deposit_bloc.dart';
import '../../profile/crypto_wallet/bloc/crypto_deposit/crypto_deposit_state.dart';
import '../../profile/crypto_wallet/model/crypto_deposit_model.dart';
import '../../webview/crypto_deposit_webview.dart';

class CryptoPaymentStatusScreen extends StatelessWidget {
  final CryptoDepositModel? deposit;
  const CryptoPaymentStatusScreen({super.key, this.deposit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crypto Payment Status")),
      body: BlocBuilder<DepositCryptoCubit, DepositCryptoState>(
        builder: (context, state) {
          if (state is DepositCryptoPaymentPending) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text("Waiting for payment confirmation..."),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (_) =>
                    //         CryptoDepositWebView(url: deposit?.paymentUrl),
                    //   ),
                    // );
                  },
                  child: const Text("Open Cryptomus Payment Page"),
                ),
              ],
            );
          } else if (state is DepositCryptoPaymentCompleted) {
            Future.microtask(() {
              Navigator.pop(context); // auto close on success
            });
            return const Center(child: Text("Payment Completed ✅"));
          } else if (state is DepositCryptoError) {
            return Center(child: Text('Under development'));
            // return Center(child: Text(state.error));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
