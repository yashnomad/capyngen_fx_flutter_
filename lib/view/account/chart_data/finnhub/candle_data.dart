class CandleData {
  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  CandleData({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  factory CandleData.fromJson(Map<String, dynamic> json) {
    return CandleData(
      time: DateTime.fromMillisecondsSinceEpoch(json['t'] * 1000),
      open: json['o'].toDouble(),
      high: json['h'].toDouble(),
      low: json['l'].toDouble(),
      close: json['c'].toDouble(),
      volume: json['v'].toDouble(),
    );
  }
}