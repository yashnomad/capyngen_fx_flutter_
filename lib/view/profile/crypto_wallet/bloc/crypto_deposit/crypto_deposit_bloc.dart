import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../network/api_service.dart';
import '../../model/crypto_deposit_model.dart';
import '../../model/payment_status_model.dart';
import 'crypto_deposit_state.dart';

class DepositCryptoCubit extends Cubit<DepositCryptoState> {
  DepositCryptoCubit() : super(DepositCryptoInitial());

  Future<void> createDeposit({
    required String tradeUserId,
    required double amount,
  }) async {
    try {
      emit(DepositCryptoLoading());

      final response = await ApiService.depositCrypto({
        'trade_user_id': tradeUserId,
        'amount': amount,
        'currency': "USD",
      });

      if (response.success && response.data != null) {
        final result = response.data!['result'];

        final deposit = CryptoDepositModel.fromJson(result);

        emit(DepositCryptoSuccess(deposit: deposit));

        // start checking payment status (optional: you can poll here)
        checkPaymentStatus(deposit.uuid);
      } else {
        emit(
            DepositCryptoError(response.message ?? 'Failed to create deposit'));
      }
    } catch (e) {
      emit(DepositCryptoError('An error occurred: $e'));
    }
  }
/*
  Future<void> checkPaymentStatus(String uuid) async {
    try {
      final response = await ApiService.cryptoPaymentStatus(uuid);

      if (response.success && response.data != null) {
        final paymentJson = response.data!['payment'];
        final payment = PaymentStatusModel.fromJson(paymentJson);

        if (payment.status == "paid" || payment.depositStatus == "completed") {
          emit(DepositCryptoPaymentCompleted(paymentStatus: payment));
        } else if (payment.status == "cancel" ||
            payment.status == "failed" ||
            payment.status == "expired") {
          emit(DepositCryptoPaymentFailed(paymentStatus: payment));
        } else {
          emit(DepositCryptoPaymentPending(paymentStatus: payment));
        }
      } else {
        emit(DepositCryptoError(response.message ?? "Failed to check payment status"));
      }
    } catch (e) {
      emit(DepositCryptoError("An error occurred: $e"));
    }
  }*/

  Future<void> checkPaymentStatus(String uuid) async {
    try {
      final response = await ApiService.cryptoPaymentStatus(uuid);

      if (response.success && response.data != null) {
        final paymentJson = response.data!['payment'];
        final payment = PaymentStatusModel.fromJson(paymentJson);

        if (payment.status == "paid" || payment.depositStatus == "completed") {
          emit(DepositCryptoPaymentCompleted(paymentStatus: payment));
        } else if (payment.status == "cancel" ||
            payment.status == "failed" ||
            payment.status == "expired") {
          emit(DepositCryptoPaymentFailed(paymentStatus: payment));
        } else {
          emit(DepositCryptoPaymentPending(paymentStatus: payment));
        }
      } else {
        emit(DepositCryptoError(
            response.message ?? "Failed to check payment status"));
      }
    } catch (e) {
      emit(DepositCryptoError("An error occurred: $e"));
    }
  }

  void resetDeposit() {
    emit(DepositCryptoInitial());
  }
}
