import 'package:exness_clone/view/account/buy_sell_trade/model/create_trade_response.dart';

class CloseTradeResponse {
  final String message;
  final CreateTradeResponse tradeResponse;
  final double pnl;
  final double updatedBalance;

  CloseTradeResponse({
    required this.message,
    required this.tradeResponse,
    required this.pnl,
    required this.updatedBalance,
  });

  factory CloseTradeResponse.fromJson(Map<String, dynamic> json) {
    return CloseTradeResponse(
      message: json['message']?.toString() ?? '',
      tradeResponse: CreateTradeResponse.fromJson(json['trade'] as Map<String, dynamic>),
      pnl: (json['pnl'] as num?)?.toDouble() ?? 0.0,
      updatedBalance: (json['updatedBalance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
