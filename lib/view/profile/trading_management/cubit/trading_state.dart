import '../model/follower_subscription_model.dart';
import '../model/master_account_model.dart';

abstract class TradingState {}

class TradingInitial extends TradingState {}

class TradingLoading extends TradingState {}

class TradingLoaded extends TradingState {
  final List<MasterAccount> masters;
  final List<FollowerSubscription> followers;
  TradingLoaded(this.masters, this.followers);
}

class TradingError extends TradingState {
  final String message;
  TradingError(this.message);
}
