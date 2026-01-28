import '../../model/crypto_deposit_model.dart';
import '../../model/payment_status_model.dart';

abstract class DepositCryptoState {}

class DepositCryptoInitial extends DepositCryptoState {}

class DepositCryptoLoading extends DepositCryptoState {}

class DepositCryptoSuccess extends DepositCryptoState {
  final CryptoDepositModel deposit;
  DepositCryptoSuccess({required this.deposit});
}

class DepositCryptoError extends DepositCryptoState {
  final String error;
  DepositCryptoError(this.error);
}

class DepositCryptoPaymentPending extends DepositCryptoState {
  final PaymentStatusModel paymentStatus;
  DepositCryptoPaymentPending({required this.paymentStatus});
}

class DepositCryptoPaymentCompleted extends DepositCryptoState {
  final PaymentStatusModel paymentStatus;
  DepositCryptoPaymentCompleted({required this.paymentStatus});
}

class DepositCryptoPaymentFailed extends DepositCryptoState {
  final PaymentStatusModel paymentStatus;
  DepositCryptoPaymentFailed({required this.paymentStatus});
}
