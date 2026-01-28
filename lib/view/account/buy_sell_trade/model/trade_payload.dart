class TradePayload {
  final String tradeAccountId;
  final String symbol; // This seems to be the Symbol ID based on your curl
  final double lot;
  final String bs; // "Buy" or "Sell"
  final double avg;
  final String executionType; // "market" or "limit"
  final double? sl;
  final double? target; // Changed from 'tp' to 'target' based on curl

  TradePayload({
    required this.tradeAccountId,
    required this.symbol,
    required this.lot,
    required this.bs,
    required this.avg,
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
      "avg": avg,
      "executionType": executionType,
    };
    if (sl != null) data["sl"] = sl;
    if (target != null) data["target"] = target;
    return data;
  }
}