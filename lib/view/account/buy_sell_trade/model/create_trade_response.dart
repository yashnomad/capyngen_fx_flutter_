enum TradeSide { buy, sell }

enum TradeStatus { open, closed }

class CreateTradeResponse {
  final String id;
  final String symbol;
  final TradeSide side; // Use enum for better type safety
  final double lot;
  final double avg;
  final double? tp; // Target Price
  final double? sl; // Stop Loss
  final double profit;
  final double? currentPrice;  // 🆕 Add this
  final TradeStatus status; // Use enum for better type safety
  final DateTime? openedAt;
  final DateTime? closedAt;

  CreateTradeResponse({
    required this.id,
    required this.symbol,
    required this.side,
    required this.lot,
    required this.avg,
    this.tp,
    this.sl,
    required this.profit,
    this.currentPrice,  // 🆕 Add this

    required this.status,
    this.openedAt,
    this.closedAt,
  });

  // Parse JSON with enum conversion
  factory CreateTradeResponse.fromJson(Map<String, dynamic> json) {
    return CreateTradeResponse(
      id: json['_id']?.toString() ?? '',
      symbol: json['symbol']?.toString() ?? '',
      side: _parseTradeSide(json['bs']),
      lot: (json['lot'] as num?)?.toDouble() ?? 0.0,
      avg: (json['avg'] as num?)?.toDouble() ?? 0.0,
      tp: (json['target'] as num?)?.toDouble(),
      sl: (json['exit'] as num?)?.toDouble(),
      profit: (json['profitLossAmount'] as num?)?.toDouble() ?? 0.0,
      status: _parseTradeStatus(json['status']),
      openedAt:
          json['openedAt'] != null ? DateTime.parse(json['openedAt']) : null,
      closedAt:
          json['closedAt'] != null ? DateTime.parse(json['closedAt']) : null,
    );
  }

  // Utility function for parsing the side (buy/sell)
  static TradeSide _parseTradeSide(String? side) {
    switch (side?.toLowerCase()) {
      case 'buy':
        return TradeSide.buy;
      case 'sell':
        return TradeSide.sell;
      default:
        throw ArgumentError('Invalid trade side: $side');
    }
  }

  // Utility function for parsing the status (open/closed)
  static TradeStatus _parseTradeStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'open':
        return TradeStatus.open;
      case 'closed':
        return TradeStatus.closed;
      default:
        throw ArgumentError('Invalid trade status: $status');
    }
  }

  // Add more utility methods (for formatting)
  String get formattedProfit {
    return '\$${profit.toStringAsFixed(2)}';
  }

  String get formattedDate {
    return openedAt != null ? openedAt!.toLocal().toString() : 'N/A';
  }

  // CopyWith method for easier updates
  CreateTradeResponse copyWith({
    double? profit,
    TradeStatus? status,
    double? tp,
    double? sl,
    double? currentPrice,
  }) {
    return CreateTradeResponse(
      id: id,
      symbol: symbol,
      side: side,
      lot: lot,
      avg: avg,
      tp: tp ?? this.tp,
      sl: sl ?? this.sl,
      profit: profit ?? this.profit,
      currentPrice: currentPrice ?? this.currentPrice,
      status: status ?? this.status,
      openedAt: openedAt,
      closedAt: closedAt,
    );
  }

  // Override equality and hashCode for comparisons
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CreateTradeResponse &&
        other.id == id &&
        other.symbol == symbol &&
        other.side == side &&
        other.lot == lot &&
        other.avg == avg &&
        other.tp == tp &&
        other.sl == sl &&
        other.profit == profit &&
        other.status == status &&
        other.openedAt == openedAt &&
        other.closedAt == closedAt;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      symbol.hashCode ^
      side.hashCode ^
      lot.hashCode ^
      avg.hashCode ^
      tp.hashCode ^
      sl.hashCode ^
      profit.hashCode ^
      status.hashCode ^
      openedAt.hashCode ^
      closedAt.hashCode;

  @override
  String toString() {
    return 'TradeResponse(id: $id, symbol: $symbol, side: $side, lot: $lot, avg: $avg, tp: $tp, sl: $sl, profit: $profit, status: $status, openedAt: $openedAt, closedAt: $closedAt)';
  }
}
