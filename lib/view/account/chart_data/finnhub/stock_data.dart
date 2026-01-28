class StockData {
  final String symbol;
  final double price;
  final double change;
  final double changePercent;
  final List<double> chartData;
  final int timestamp;

  StockData({
    required this.symbol,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.chartData,
    required this.timestamp,
  });

  factory StockData.fromJson(Map<String, dynamic> json) {
    return StockData(
      symbol: json['s'] ?? '',
      price: (json['p'] ?? 0.0).toDouble(),
      change: (json['c'] ?? 0.0).toDouble(),
      changePercent: (json['cp'] ?? 0.0).toDouble(),
      chartData: [],
      timestamp: json['t'] ?? 0,
    );
  }

  StockData copyWith({
    String? symbol,
    double? price,
    double? change,
    double? changePercent,
    List<double>? chartData,
    int? timestamp,
  }) {
    return StockData(
      symbol: symbol ?? this.symbol,
      price: price ?? this.price,
      change: change ?? this.change,
      changePercent: changePercent ?? this.changePercent,
      chartData: chartData ?? this.chartData,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}