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
    final sideColor =
        isBuy ? _blueColor : _binanceRed; // Buy is blueish, Sell is red

    // Profit Logic
    final pnlVal =
        widget.liveProfit.profit ?? widget.trade.profitLossAmount ?? 0.0;
    final pnlColor = pnlVal >= 0 ? _binanceGreen : _binanceRed; // PNL Green/Red
    final pnlStr = pnlVal.toStringAsFixed(2);

    final lotSize = widget.trade.lot ?? 0.0;
    final entryPrice = widget.trade.avg ?? 0.0;

    final tpStr = widget.trade.target != null
        ? widget.trade.target!.toStringAsFixed(5)
        : "-";
    final slStr =
        widget.trade.sl != null ? widget.trade.sl!.toStringAsFixed(5) : "-";

    // Formatting ID and Time
    final tradeId = "#${widget.trade.id}"; // Using ID from model
    final openTime = widget.trade.openedAt ?? "--";

    return Column(
      children: [
        Container(
          color: widget.cardColor, // Main background
          child: Column(
            children: [
              // COLLAPSED VIEW (Always Visible)
              InkWell(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Symbol, Side, Lot, PNL
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            "${widget.trade.symbol ?? 'Unknown'}, ",
                            style: TextStyle(
                              color: widget.textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            isBuy ? "buy " : "sell ",
                            style: TextStyle(
                              color: sideColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            lotSize.toString(),
                            style: TextStyle(
                              color: sideColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const Spacer(),
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
                      const SizedBox(height: 4),
                      // Bottom Row: Entry -> Current
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
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // EXPANDED VIEW
              if (_isExpanded)
                Container(
                  width: double.infinity,
                  color: widget.isDark
                      ? Colors.black26
                      : Colors.grey.shade100, // Slightly improved contrast
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ID and Open Time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            tradeId,
                            style:
                                TextStyle(color: widget.greyText, fontSize: 12),
                          ),
                          _buildDetailRow("Open:", openTime),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // SL and Swap
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDetailRow("S / L:", slStr),
                          _buildDetailRow("Swap:",
                              "0.00"), // Placeholder/Logic for swap if available
                        ],
                      ),
                      const SizedBox(height: 8),
                      // TP
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDetailRow("T / P:", tpStr),
                          // Placeholder for alignment or other stats
                        ],
                      ),
                      const SizedBox(height: 16),
                      // ACTIONS: Modify & Delete (Close)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Modify Button
                          TextButton.icon(
                            onPressed: () => widget.onModify(widget.trade),
                            style: TextButton.styleFrom(
                              foregroundColor: widget.greyText,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text("Modify"),
                          ),
                          const SizedBox(width: 8),
                          // Close Button
                          TextButton.icon(
                            onPressed: () {
                              if (widget.activeAccount.id != null) {
                                widget.onClose(
                                    widget.trade, widget.activeAccount.id!);
                              }
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: _binanceRed,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            icon: const Icon(Icons.close, size: 16),
                            label: const Text("Close"),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
            ],
          ),
        ),
        Divider(height: 1, color: widget.dividerColor), // Divider between cards
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(color: widget.greyText, fontSize: 12),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
              color: widget.greyText,
              fontSize:
                  12), // Value same color as label in screenshot? or distinct?
          // Screenshot shows value darker? Let's use greyText for simplicity or slightly darker if needed.
        ),
      ],
    );
  }
}
