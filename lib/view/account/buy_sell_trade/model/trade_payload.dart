class TradePayload {
  final String tradeAccountId;
  final String symbol;
  final double lot;
  final String bs; // Buy / Sell
  final double? avg; // ✅ nullable
  final String executionType; // market / limit
  final double? sl;
  final double? target;

  TradePayload({
    required this.tradeAccountId,
    required this.symbol,
    required this.lot,
    required this.bs,
    this.avg, // ✅ not required
    required this.executionType,
    this.sl,
    this.target,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      "tradeAccountId": tradeAccountId,
      "symbol": symbol,
      "lot": lot,
      "bs": bs,
      "executionType": executionType,
    };

    // 🔥 avg ONLY for LIMIT
    if (executionType == "limit" && avg != null) {
      data["avg"] = avg;
    }

    if (sl != null) data["sl"] = sl;
    if (target != null) data["target"] = target;

    return data;
  }
}
