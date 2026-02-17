import 'package:exness_clone/provider/datafeed_provider.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/services/data_feed_ws.dart' as feed_ws;
import 'package:exness_clone/view/account/buy_sell_trade/model/trade_model.dart';
import 'package:exness_clone/view/account/buy_sell_trade/model/ws_equity_data.dart'
    as eq_data;
import 'package:exness_clone/view/trade/model/trade_account.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ... (imports remain)

class BinancePositionCard extends StatefulWidget {
  // ... (fields remain)
  final TradeModel trade;
  final eq_data.LiveProfit liveProfit;
  final Account activeAccount;
  final Color cardColor;
  final Color textColor;
  final Color greyText;
  final Color dividerColor;
  final bool isDark;
  final Function(TradeModel) onModify;
  final Function(TradeModel, String) onClose;

  const BinancePositionCard({
    super.key,
    required this.trade,
    required this.liveProfit,
    required this.activeAccount,
    required this.cardColor,
    required this.textColor,
    required this.greyText,
    required this.dividerColor,
    required this.isDark,
    required this.onModify,
    required this.onClose,
  });

  @override
  State<BinancePositionCard> createState() => _BinancePositionCardState();
}

class _BinancePositionCardState extends State<BinancePositionCard> {
  bool _isExpanded = false;

  final Color _binanceGreen = const Color(0xFF0ECB81);
  final Color _binanceRed = const Color(0xFFF6465D);
  final Color _blueColor =
      const Color(0xFF2962FF); // Example blue for "buy" text if needed

  @override
  Widget build(BuildContext context) {
    final isBuy = (widget.trade.bs ?? 'Buy').toLowerCase() == 'buy';
    final sideColor = isBuy ? _blueColor : _binanceRed;

    final pnlVal =
        widget.liveProfit.profit ?? widget.trade.profitLossAmount ?? 0.0;
    final pnlColor = pnlVal >= 0 ? _binanceGreen : _binanceRed;
    final pnlStr = pnlVal.toStringAsFixed(2);

    final lotSize = widget.trade.lot ?? 0.0;
    final entryPrice = widget.trade.avg ?? 0.0;

    final tpStr = widget.trade.target != null
        ? widget.trade.target!.toStringAsFixed(5)
        : "-";
    final slStr =
        widget.trade.sl != null ? widget.trade.sl!.toStringAsFixed(5) : "-";

    final tradeId = "#${widget.trade.id}";
    // Format date if needed, for now keep string
    final openTime = widget.trade.openedAt ?? "--";

    return Column(
      children: [
        Material(
          color: widget.cardColor,
          child: InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Column(
              children: [
                // COLLAPSED VIEW (Always Visible)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 14.0),
                  child: Column(
                    children: [
                      // Top Row: Symbol Info & PNL
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        "${widget.trade.symbol ?? 'Unknown'}, ",
                                    style: TextStyle(
                                      color: widget.textColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      fontFamily:
                                          'Roboto', // Professional font choice if available, or system
                                    ),
                                  ),
                                  TextSpan(
                                    text: "${isBuy ? "buy" : "sell"} ",
                                    style: TextStyle(
                                      color: sideColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  TextSpan(
                                    text: lotSize.toString(),
                                    style: TextStyle(
                                      color: sideColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Text(
                            pnlStr,
                            style: TextStyle(
                              color: pnlColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Bottom Row: Prices
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Selector<DataFeedProvider, feed_ws.LiveProfit?>(
                            selector: (_, provider) =>
                                provider.liveData[widget.trade.symbol] ??
                                provider.liveData[
                                    (widget.trade.symbol ?? "").toUpperCase()],
                            builder: (context, liveData, _) {
                              final currentLivePrice = isBuy
                                  ? (liveData?.bid ?? entryPrice)
                                  : (liveData?.ask ?? entryPrice);

                              return Text(
                                "${entryPrice.toStringAsFixed(5)} → ${currentLivePrice.toStringAsFixed(5)}",
                                style: TextStyle(
                                  color: widget.greyText,
                                  fontSize: 13,
                                  height: 1.2,
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      // Progress/Status indicator (Optional simple line or nothing)
                    ],
                  ),
                ),

                // EXPANDED VIEW
                if (_isExpanded)
                  Container(
                    width: double.infinity,
                    color: widget.isDark
                        ? Colors.black12
                        : const Color(0xFFF5F5F5),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0), // Reduced vertical padding
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SL and TP Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildDetailRow("S / L:", slStr),
                            _buildDetailRow("T / P:", tpStr),
                          ],
                        ),

                        const SizedBox(height: 10), // Compact spacing

                        // Actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _buildActionButton(
                                "Modify",
                                Icons.edit,
                                widget.greyText,
                                () => widget.onModify(widget.trade)),
                            const SizedBox(width: 16),
                            _buildActionButton(
                                "Close", Icons.close, _binanceRed, () {
                              if (widget.activeAccount.id != null) {
                                widget.onClose(
                                    widget.trade, widget.activeAccount.id!);
                              }
                            }),
                          ],
                        )
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        Divider(height: 1, color: widget.dividerColor.withOpacity(0.5)),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool alignRight = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment:
          alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: widget.greyText, fontSize: 12),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style:
              TextStyle(color: widget.textColor.withOpacity(0.7), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: widget.greyText, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                color: widget.textColor,
                fontSize: 12,
                fontWeight: FontWeight.normal)),
      ],
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                  color: color, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
