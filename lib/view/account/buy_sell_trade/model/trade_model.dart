class TradeModel {
  final String id;
  final String? tradeAccountId; // 🔹 ADDED: To store "user" from JSON
  final String? transactionId;
  final String? symbol;
  final String? bs;
  final double? lot;
  final double? avg;
  final double? exit;
  final double? profitLossAmount;
  final String? status;
  final String? openedAt;
  final String? closedAt;
  final double? sl;
  final double? target;
  final double? margin;
  final int? leverage;
  final double? currentProfit;

  TradeModel({
    required this.id,
    this.tradeAccountId, // 🔹 ADDED
    this.transactionId,
    this.symbol,
    this.bs,
    this.lot,
    this.avg,
    this.exit,
    this.profitLossAmount,
    this.status,
    this.openedAt,
    this.closedAt,
    this.sl,
    this.target,
    this.margin,
    this.leverage,
    this.currentProfit,
  });

  factory TradeModel.fromJson(Map<String, dynamic> json) {
    return TradeModel(
      id: json['_id']?.toString() ?? '',
      // 🔹 UPDATE HERE: Map 'user' from JSON to 'tradeAccountId'
      tradeAccountId: json['user']?.toString() ?? json['tradeAccountId']?.toString(),
      transactionId: json['transactionId'],
      symbol: json['symbol'],
      bs: json['bs'],
      lot: (json['lot'] as num?)?.toDouble(),
      avg: (json['avg'] as num?)?.toDouble(),
      exit: (json['exit'] as num?)?.toDouble(),
      profitLossAmount: (json['profitLossAmount'] as num?)?.toDouble(),
      status: json['status'],
      openedAt: json['openedAt'],
      closedAt: json['closedAt'],
      sl: (json['sl'] as num?)?.toDouble(),
      target: (json['target'] as num?)?.toDouble(),
      margin: (json['margin'] as num?)?.toDouble(),
      leverage: (json['leverage'] as num?)?.toInt(),
      currentProfit: (json['profitLossAmount'] as num?)?.toDouble(),
    );
  }

  // CopyWith for updating state
  TradeModel copyWith({
    String? status,
    double? currentProfit,
    double? sl,
    double? target,
    double? exit,
    String? tradeAccountId, // 🔹 ADDED
  }) {
    return TradeModel(
      id: id,
      tradeAccountId: tradeAccountId ?? this.tradeAccountId, // 🔹 ADDED
      transactionId: transactionId,
      symbol: symbol,
      bs: bs,
      lot: lot,
      avg: avg,
      exit: exit ?? this.exit,
      profitLossAmount: currentProfit ?? profitLossAmount,
      status: status ?? this.status,
      openedAt: openedAt,
      closedAt: closedAt,
      sl: sl ?? this.sl,
      target: target ?? this.target,
      margin: margin,
      leverage: leverage,
      currentProfit: currentProfit ?? this.currentProfit,
    );
  }
}

/*
class TradeModel {
  final String id;
  final String? transactionId;
  final String? symbol;
  final String? bs;
  final double? lot;
  final double? avg; // Entry Price
  final double? exit; // Exit Price
  final double? profitLossAmount;
  final String? status; // "open", "closed", "pending"
  final String? openedAt;
  final String? closedAt;
  final double? sl;
  final double? target; // Take Profit
  final double? margin;
  final int? leverage;
  final double? currentProfit; // For WebSocket updates

  TradeModel({
    required this.id,
    this.transactionId,
    this.symbol,
    this.bs,
    this.lot,
    this.avg,
    this.exit,
    this.profitLossAmount,
    this.status,
    this.openedAt,
    this.closedAt,
    this.sl,
    this.target,
    this.margin,
    this.leverage,
    this.currentProfit,
  });

  factory TradeModel.fromJson(Map<String, dynamic> json) {
    return TradeModel(
      id: json['_id']?.toString() ?? '',
      transactionId: json['transactionId'],
      symbol: json['symbol'],
      bs: json['bs'],
      lot: (json['lot'] as num?)?.toDouble(),
      avg: (json['avg'] as num?)?.toDouble(),
      exit: (json['exit'] as num?)?.toDouble(),
      profitLossAmount: (json['profitLossAmount'] as num?)?.toDouble(),
      status: json['status'],
      openedAt: json['openedAt'],
      closedAt: json['closedAt'],
      sl: (json['sl'] as num?)?.toDouble(),
      target: (json['target'] as num?)?.toDouble(),
      margin: (json['margin'] as num?)?.toDouble(),
      leverage: (json['leverage'] as num?)?.toInt(),
      currentProfit: (json['profitLossAmount'] as num?)?.toDouble(),
    );
  }

  // CopyWith for updating state (e.g., from WebSocket)
  TradeModel copyWith({
    String? status,
    double? currentProfit,
    double? sl,
    double? target,
    double? exit,
  }) {
    return TradeModel(
      id: id,
      transactionId: transactionId,
      symbol: symbol,
      bs: bs,
      lot: lot,
      avg: avg,
      exit: exit ?? this.exit,
      profitLossAmount: currentProfit ?? profitLossAmount,
      status: status ?? this.status,
      openedAt: openedAt,
      closedAt: closedAt,
      sl: sl ?? this.sl,
      target: target ?? this.target,
      margin: margin,
      leverage: leverage,
      currentProfit: currentProfit ?? this.currentProfit,
    );
  }
}
*/
