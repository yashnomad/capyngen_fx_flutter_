import '../model/leaderboard_model.dart';

abstract class LeaderboardState {}

class LeaderboardInitial extends LeaderboardState {}
class LeaderboardLoading extends LeaderboardState {}
class LeaderboardLoaded extends LeaderboardState {
  final List<LeaderBoardModel> traders;
  LeaderboardLoaded(this.traders);
}
class LeaderboardError extends LeaderboardState {
  final String message;
  LeaderboardError(this.message);
}