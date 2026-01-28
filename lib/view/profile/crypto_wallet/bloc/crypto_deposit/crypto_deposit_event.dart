abstract class DepositCryptoEvent {}

class CreateDepositEvent extends DepositCryptoEvent {
  final String tradeUserId;
  final double amount;

  CreateDepositEvent({
    required this.tradeUserId,
    required this.amount,
  });
}

class CheckPaymentStatusEvent extends DepositCryptoEvent {
  final String transactionId;

  CheckPaymentStatusEvent(this.transactionId);
}

class ResetDepositEvent extends DepositCryptoEvent {}