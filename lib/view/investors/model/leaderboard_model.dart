class LeaderBoardModel {
  final String id;
  final String strategyName;
  final int followers;
  final num sevenDayReturn;
  final num currentMonthReturn;
  final num aum;

  LeaderBoardModel({
    required this.id,
    required this.strategyName,
    required this.followers,
    required this.sevenDayReturn,
    required this.currentMonthReturn,
    required this.aum,
  });

  factory LeaderBoardModel.fromJson(Map<String, dynamic> json) {
    return LeaderBoardModel(
      id: json['_id'] ?? '',
      strategyName: json['strategyName'] ?? 'Unknown',
      followers: json['followers'] ?? 0,
      sevenDayReturn: json['seven_day_return'] ?? 0,
      currentMonthReturn: json['current_month_return'] ?? 0,
      aum: json['aum'] ?? 0,
    );
  }
}
