import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../network/api_service.dart';
import '../model/leaderboard_model.dart';
import 'leaderboard_state.dart';

class LeaderboardCubit extends Cubit<LeaderboardState> {
  final String type;

  LeaderboardCubit({required this.type}) : super(LeaderboardInitial()) {
    fetchLeaderboard();
  }

  Future<void> fetchLeaderboard() async {
    try {
      emit(LeaderboardLoading());

      final response = await ApiService.getLeaderboard(type: type);

      if (response.success && response.data != null) {
        final List<dynamic> results = response.data!['results'] ?? [];
        final traders =
            results.map((e) => LeaderBoardModel.fromJson(e)).toList();
        emit(LeaderboardLoaded(traders));
      } else {
        emit(LeaderboardError(response.message ?? "Failed to fetch data"));
      }
    } catch (e) {
      emit(LeaderboardError(e.toString()));
    }
  }

  Future<void> followOrUnfollow(String masterUserId, String tradeUserId) async {
    try {
      final data = {
        'master_user_id': masterUserId,
        'trade_user_id': tradeUserId,
      };

      final response = await ApiService.followTraderAndRemove(data: data);

      if (response.success) {
        fetchLeaderboard();
      } else {
        debugPrint("Follow action failed: ${response.message}");
      }
    } catch (e) {
      debugPrint("Error following: $e");
    }
  }
}
