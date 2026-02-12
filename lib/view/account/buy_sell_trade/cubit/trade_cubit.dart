import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../network/api_service.dart';
import '../model/trade_payload.dart';
import '../model/trade_model.dart';
import '../model/ws_equity_data.dart';
import '../service/place_order_ws.dart';
import 'trade_state.dart';

class TradeCubit extends Cubit<TradeState> {
  TradeCubit() : super(const TradeState());

  final Set<String> _processingCloseIds = {};
  String? _currentUserId;

  void startSocket({required String jwt, required String userId}) {
    _currentUserId = userId;

    PlaceOrderWS().connect(
      jwt: jwt,
      userId: userId,
      onEquity: (equity) {
        if (isClosed) return;
        emit(state.copyWith(equity: equity));
        _updateActiveTradesPnL(equity.liveProfit);
      },
      onTradeUpdate: (data) {
        if (!isClosed) _handleWsTradeUpdate(data, isNew: false);
      },
      onNewTrade: (data) {
        if (!isClosed) _handleWsTradeUpdate(data, isNew: true);
      },
      onError: (msg) {
        debugPrint("🔴 [TradeCubit] Socket Error: $msg");
      },
    );
  }

  Future<void> fetchOpenTrades(String accountId) async {
    if (state.activeTrades.isEmpty) {
      emit(state.copyWith(isLoading: true));
    }

    try {
      final response = await ApiService.getOpenTrades(accountId);

      if (response.success && response.data != null) {
        List<TradeModel> trades = [];
        if (response.data!['results'] != null) {
          trades = (response.data!['results'] as List)
              .map((e) => TradeModel.fromJson(e))
              .toList();
        }

        emit(state.copyWith(
          activeTrades: trades,
          isLoading: false,
        ));

        if (trades.length == 1) {
          debugPrint("Re-subscribing... Single active trade detected.");
          PlaceOrderWS.instance.reSubscribe();
        }
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } catch (e) {
      debugPrint("Error fetching trades: $e");
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> hardRefresh(String accountId) async {
    emit(state.copyWith(isLoading: true));
    try {
      await fetchOpenTrades(accountId);
      await fetchHistoryTrades(accountId);

      if (state.activeTrades.isEmpty && state.equity != null) {
        // Prepare "Zeroed" snapshot but PRESERVE Balance
        // If no trades, Equity = Balance, Free Margin = Balance
        final currentBalance = state.equity!.balance;

        final zeroEquity = EquitySnapshot(
          balance: currentBalance,
          equity: currentBalance,
          freeMargin: currentBalance,
          pnl: "0.00",
          usedMargin: "0.00",
          userAssets: state.equity!.userAssets,
          liveProfit: [],
        );
        emit(state.copyWith(equity: zeroEquity));
      }

      emit(state.copyWith(
        isLoading: false,
        successMessage: "Trade Refreshed",
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: "Refresh Failed: $e",
      ));
    }
  }

  Future<void> createTrade({
    required TradePayload payload,
    required String jwt,
    double? sl,
    double? target,
  }) async {
    emit(state.copyWith(isLoading: true));

    try {
      final Map<String, dynamic> requestData = Map.from(payload.toJson());
      requestData.remove('Sl');
      requestData.remove('stopLoss');
      requestData.remove('sl');
      if (sl != null) requestData['sl'] = sl;
      if (target != null) requestData['target'] = target;

      debugPrint("📤 [TradeCubit] Placing Trade...");

      final res = await ApiService.createTrade(requestData);

      if (res.success) {
        debugPrint("✅ Trade Placed! Refreshing list...");

        emit(state.copyWith(
            successMessage: res.message ?? "Trade Placed", isLoading: false));

        await fetchOpenTrades(payload.tradeAccountId);
      } else {
        emit(state.copyWith(
            isLoading: false, errorMessage: res.message ?? "Failed"));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _handleWsTradeUpdate(Map<String, dynamic> data, {required bool isNew}) {
    try {
      final rawData = data.containsKey('trade') ? data['trade'] : data;
      var trade = TradeModel.fromJson(rawData);
      final status = (trade.status ?? '').toLowerCase();

      List<TradeModel> active = List.from(state.activeTrades);
      List<TradeModel> pending = List.from(state.pendingTrades);
      List<TradeModel> history = List.from(state.historyTrades);

      active.removeWhere((t) => t.id == trade.id);
      pending.removeWhere((t) => t.id == trade.id);

      String? autoCloseMessage;

      if (status == 'close') {
        bool manualClose = _processingCloseIds.contains(trade.id);
        _processingCloseIds.remove(trade.id);
        history.insert(0, trade);

        if (!manualClose) {
          autoCloseMessage = "Trade Closed. PnL: ${trade.profitLossAmount}";
        }
        if (trade.tradeAccountId != null)
          fetchHistoryTrades(trade.tradeAccountId!);
      } else if (status == 'pending') {
        pending.insert(0, trade);
      } else if (status == 'open') {
        active.insert(0, trade);
      }

      emit(state.copyWith(
          activeTrades: active,
          pendingTrades: pending,
          historyTrades: history,
          successMessage: autoCloseMessage));
    } catch (e) {
      debugPrint("Error handling WS update: $e");
    }
  }

  void _updateActiveTradesPnL(List<LiveProfit> liveProfits) {
    if (state.activeTrades.isEmpty) return;
    List<TradeModel> updatedActiveTrades = List.from(state.activeTrades);
    bool changed = false;

    for (var lp in liveProfits) {
      final index = updatedActiveTrades.indexWhere((t) => t.id == lp.id);
      if (index != -1) {
        var trade = updatedActiveTrades[index];
        updatedActiveTrades[index] = trade.copyWith(currentProfit: lp.profit);
        changed = true;
        if (!_processingCloseIds.contains(trade.id)) {
          _checkAndAutoClose(trade, lp);
        }
      }
    }
    if (changed && !isClosed) {
      emit(state.copyWith(activeTrades: updatedActiveTrades));
    }
  }

  void _checkAndAutoClose(TradeModel trade, LiveProfit lp) {
    double currentPrice = lp.price ?? 0.0;
    if (currentPrice <= 0.0) return;
    bool shouldClose = false;
    double target = trade.target ?? 0.0;
    double sl = trade.sl ?? 0.0;
    String type = (trade.bs ?? '').toUpperCase();

    if (type == 'BUY') {
      if (target > 0 && currentPrice >= target) shouldClose = true;
      if (sl > 0 && currentPrice <= sl) shouldClose = true;
    } else if (type == 'SELL') {
      if (target > 0 && currentPrice <= target) shouldClose = true;
      if (sl > 0 && currentPrice >= sl) shouldClose = true;
    }

    if (shouldClose) {
      _processingCloseIds.add(trade.id);
      closeTrade(trade.id, trade.tradeAccountId ?? '');
    }
  }

  Future<void> fetchHistoryTrades(String accountId) async {
    try {
      final res = await ApiService.getTradeHistory(accountId: accountId);
      if (res.success && res.data != null && res.data!['results'] != null) {
        final List<dynamic> list = res.data!['results'];
        final trades = list.map((e) => TradeModel.fromJson(e)).toList();
        if (!isClosed) emit(state.copyWith(historyTrades: trades));
      }
    } catch (e) {
      debugPrint("Error fetching history: $e");
    }
  }

  Future<void> updateTrade(
      {required String tradeId, double? sl, double? target}) async {
    try {
      final data = <String, dynamic>{};
      if (sl != null) data['sl'] = sl;
      if (target != null) data['target'] = target;
      if (data.isEmpty) return;

      emit(state.copyWith(isLoading: true));
      final res = await ApiService.updateTrade(tradeId, data);

      if (res.success) {
        String? accountId;
        try {
          accountId = state.activeTrades
              .firstWhere((t) => t.id == tradeId)
              .tradeAccountId;
        } catch (_) {}

        if (accountId != null) {
          await fetchOpenTrades(accountId);
        }

        emit(state.copyWith(
            isLoading: false, successMessage: "Trade Updated Successfully"));
      } else {
        emit(state.copyWith(
            isLoading: false, errorMessage: res.message ?? "Update Failed"));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: "Update Failed: $e"));
    }
  }

  Future<void> closeTrade(String tradeId, String accountId) async {
    try {
      double lastLivePnL = 0.0;
      try {
        final existingTrade =
            state.activeTrades.firstWhere((t) => t.id == tradeId);
        lastLivePnL = existingTrade.currentProfit ?? 0.0;
      } catch (_) {}

      final res = await ApiService.stopTrade({"tradeId": tradeId});

      if (res.success) {
        // List<TradeModel> currentActive = List.from(state.activeTrades);
        // currentActive.removeWhere((t) => t.id == tradeId);

        // List<TradeModel> currentHistory = List.from(state.historyTrades);
        // String pnlMessage = "Trade Closed";

        // 1. Refresh History First to get the true final PnL
        await fetchHistoryTrades(accountId);

        // 2. Find the closed trade in the updated history
        double finalPnL = 0.0;
        try {
          // Look for the trade we just closed in the newly fetched history
          final historyTrade =
              state.historyTrades.firstWhere((t) => t.id == tradeId);
          finalPnL = historyTrade.profitLossAmount ?? 0.0;
        } catch (_) {
          // Fallback: Use the response data if not found in history (rare)

          if (res.data != null) {
            var rawData = res.data;
            if (rawData is Map<String, dynamic>) {
              if (rawData.containsKey('trade'))
                rawData = rawData['trade'];
              else if (rawData.containsKey('result'))
                rawData = rawData['result'];

              if (rawData != null && rawData is Map<String, dynamic>) {
                final closedTrade =
                    TradeModel.fromJson(rawData as Map<String, dynamic>);
                finalPnL = closedTrade.profitLossAmount ?? 0.0;
              }
            }
          }
          if (finalPnL == 0 && lastLivePnL != 0) finalPnL = lastLivePnL;
          // pnlMessage = "Trade Closed.";
        }
        String pnlMessage = "Trade Closed. PnL: ${finalPnL.toStringAsFixed(2)}";

        // 3. Update Active List (Optimistic removal)
        List<TradeModel> currentActive = List.from(state.activeTrades);
        currentActive.removeWhere((t) => t.id == tradeId);

        // 4. Zeroing Logic if needed
        EquitySnapshot? updatedEquity = state.equity;
        if (currentActive.isEmpty && state.equity != null) {
          // Calculate new balance: Old Balance + PnL
          double oldBalance = double.tryParse(state.equity!.balance) ?? 0.0;
          double newBalanceVal = oldBalance + finalPnL;
          String newBalance = newBalanceVal.toStringAsFixed(2);

          updatedEquity = EquitySnapshot(
            balance: newBalance,
            equity: newBalance,
            freeMargin: newBalance,
            pnl: "0.00",
            usedMargin: "0.00",
            userAssets:
                state.equity!.userAssets, // Keep existing assets structure
            liveProfit: [],
          );
        }
        // 5. Emit Final State with Message
        emit(state.copyWith(
            activeTrades: currentActive,
            equity: updatedEquity,
            successMessage: pnlMessage));
        fetchHistoryTrades(accountId);
      } else {
        _processingCloseIds.remove(tradeId);
        emit(state.copyWith(errorMessage: res.message ?? "Close Failed"));
      }
    } catch (e) {
      _processingCloseIds.remove(tradeId);
      emit(state.copyWith(errorMessage: "Error: $e"));
    }
  }

  void reset() {
    _processingCloseIds.clear();
    _currentUserId = null;
    emit(const TradeState());
  }
}
