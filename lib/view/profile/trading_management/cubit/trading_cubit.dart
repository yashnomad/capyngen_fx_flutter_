import 'package:exness_clone/view/profile/trading_management/cubit/trading_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../network/api_service.dart';
import '../model/follower_subscription_model.dart';
import '../model/master_account_model.dart';


class TradingCubit extends Cubit<TradingState> {
  TradingCubit() : super(TradingInitial());

  Future<void> fetchTradingData({
    required String tradeUserId,
    required String masterUserId,
  }) async {
    emit(TradingLoading());

    try {
      final results = await Future.wait([
        ApiService.getMasterAccount(tradeUserId: tradeUserId),
        ApiService.getFollowerList(masterUserId: masterUserId),
      ]);

      final masterRes = results[0];
      final followerRes = results[1];

      List<MasterAccount> mastersList = [];
      if (masterRes.success && masterRes.data != null) {
        final responseObj = MasterAccountResponse.fromJson(masterRes.data!);
        mastersList = responseObj.results;
      }

      List<FollowerSubscription> followersList = [];
      if (followerRes.success && followerRes.data != null) {
        final responseObj = FollowerSubscriptionResponse.fromJson(followerRes.data!);
        followersList = responseObj.results;
      }

      emit(TradingLoaded(mastersList, followersList));
    } catch (e) {
      emit(TradingError("Failed to sync trading data: ${e.toString()}"));
    }
  }
}