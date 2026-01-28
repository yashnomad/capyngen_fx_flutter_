class MarketData {
  final String symbol;
  final double price;
  final double percentChange;
  final List<double> chartData;

  MarketData({
    required this.symbol,
    required this.price,
    required this.percentChange,
    required this.chartData,
  });

  factory MarketData.fromJson(Map<String, dynamic> json) {
    return MarketData(
      symbol: json['symbol'] ?? 'N/A',
      price: double.tryParse(json['price'] ?? '') ?? 0.0,
      percentChange: double.tryParse(json['percent_change'] ?? '') ?? 0.0,
      chartData: (json['values'] as List<dynamic>?)
          ?.map((e) => double.tryParse(e['close'] ?? '') ?? 0.0)
          .toList()
          .reversed
          .toList() ??
          [],
    );
  }
}
