part of 'transaction_cubit.dart';


abstract class TransactionState extends Equatable {
  const TransactionState();
  @override
  List<Object> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionSuccess extends TransactionState {
  final String message;
  const TransactionSuccess(this.message);
  @override
  List<Object> get props => [message];
}

class TransactionSuccessCrypto extends TransactionState {
  final String paymentUrl;
  final String cryptoId;

  const TransactionSuccessCrypto({required this.paymentUrl, required this.cryptoId});
  @override
  List<Object> get props => [paymentUrl, cryptoId];
}

class TransactionFailure extends TransactionState {
  final String error;
  const TransactionFailure(this.error);
  @override
  List<Object> get props => [error];
}