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

  bool _socketStarted = false;
  String? _currentAccount;
  void _handleEquity(EquitySnapshot equity) {
    // ✅ Always create a NEW equity reference
    final newEquity = EquitySnapshot(
      balance: equity.balance,
      equity: equity.equity,
      freeMargin: equity.freeMargin,
      pnl: equity.pnl,
      usedMargin: equity.usedMargin,
      userAssets: equity.userAssets,
      liveProfit: List<LiveProfit>.from(equity.liveProfit),
    );

    final updatedActiveTrades = _mapActiveTradesWithPnL(
      state.activeTrades,
      newEquity.liveProfit,
    );

    emit(
      state.copyWith(
        equity: newEquity,
        activeTrades: updatedActiveTrades,
      ),
    );
  }

  void startSocket({required String jwt, required String userId}) {
    if (_currentAccount == userId && _socketStarted) return;

    stopSocket();
    _currentAccount = userId;
    _socketStarted = true;

    PlaceOrderWS().connect(
      jwt: jwt,
      userId: userId,
      onEquity: _handleEquity,
    );
  }

  void startSockets({required String jwt, required String userId}) {
    if (_socketStarted) return;
    _socketStarted = true;

    PlaceOrderWS().connect(
      jwt: jwt,
      userId: userId,
      onEquity: (equity) {
        final updatedActiveTrades = _mapActiveTradesWithPnL(
          state.activeTrades,
          equity.liveProfit,
        );

        emit(
          state.copyWith(
            equity: equity,
            activeTrades: updatedActiveTrades,
          ),
        );
      },
    );
  }

  void stopSocket() {
    PlaceOrderWS().dispose();
    _socketStarted = false;
  }

  void _handleWsTradeUpdate(Map<String, dynamic> data, {required bool isNew}) {
    try {
      final rawData = data.containsKey('trade') ? data['trade'] : data;
      final trade = TradeModel.fromJson(rawData);
      final status = (trade.status ?? '').toLowerCase();

      List<TradeModel> active = List.from(state.activeTrades);
      List<TradeModel> pending = List.from(state.pendingTrades);

      // 1. Remove from both lists first to avoid duplicates or when status changes
      active.removeWhere((t) => t.id == trade.id);
      pending.removeWhere((t) => t.id == trade.id);

      if (status == 'close') {
        if (trade.tradeAccountId != null) {
          fetchHistoryTrades(trade.tradeAccountId!);
        }
      } else if (status == 'pending') {
        pending.insert(0, trade);
      } else if (status == 'open') {
        active.insert(0, trade);
      }

      emit(state.copyWith(activeTrades: active, pendingTrades: pending));
    } catch (e) {
      debugPrint('WS Parse Error: $e');
    }
  }

  // void _updateActiveTradesPnL(List<LiveProfit> liveProfits) {
  //   if (state.activeTrades.isEmpty) return;
  //
  //   List<TradeModel> updatedTrades = List.from(state.activeTrades);
  //   bool changed = false;
  //
  //   for (var lp in liveProfits) {
  //     final index = updatedTrades.indexWhere((t) => t.id == lp.id);
  //     if (index != -1) {
  //       updatedTrades[index] =
  //           updatedTrades[index].copyWith(currentProfit: lp.profit);
  //       changed = true;
  //     }
  //   }
  //
  //   if (changed) {
  //     emit(state.copyWith(activeTrades: updatedTrades));
  //   }
  // }

  List<TradeModel> _mapActiveTradesWithPnL(
    List<TradeModel> activeTrades,
    List<LiveProfit> liveProfits,
  ) {
    if (activeTrades.isEmpty) return List.from(activeTrades);

    final updated = List<TradeModel>.from(activeTrades);

    for (final lp in liveProfits) {
      final index = updated.indexWhere((t) => t.id == lp.id);
      if (index != -1) {
        updated[index] = updated[index].copyWith(
          currentProfit: lp.profit,
        );
      }
    }

    return updated;
  }

  void _updateActiveTradesPnL(List<LiveProfit> liveProfits) {
    // Agar active trades khali hain, toh profit update karne ki zaroorat nahi
    if (state.activeTrades.isEmpty) return;

    List<TradeModel> updatedActiveTrades = List.from(state.activeTrades);
    bool changed = false;

    for (var lp in liveProfits) {
      // Sirf active list mein search karein
      final index = updatedActiveTrades.indexWhere((t) => t.id == lp.id);
      if (index != -1) {
        updatedActiveTrades[index] = updatedActiveTrades[index].copyWith(
          currentProfit: lp.profit,
          // Yahan aap current price bhi update kar sakte hain agar model support kare
        );
        changed = true;
      }
    }

    if (changed) {
      emit(state.copyWith(activeTrades: updatedActiveTrades));
    }
  }

  Future<void> fetchOpenTrades(String accountId) async {
    try {
      final results = await Future.wait([
        ApiService.getTradesByStatus(accountId, 'open'),
        ApiService.getTradesByStatus(accountId, 'pending'),
      ]);

      List<TradeModel> active = [];
      List<TradeModel> pending = [];

      if (results[0].success && results[0].data?['results'] != null) {
        active = (results[0].data!['results'] as List)
            .map((e) => TradeModel.fromJson(e))
            .toList();
      }

      if (results[1].success && results[1].data?['results'] != null) {
        pending = (results[1].data!['results'] as List)
            .map((e) => TradeModel.fromJson(e))
            .toList();
      }

      emit(state.copyWith(activeTrades: active, pendingTrades: pending));
    } catch (e) {
      debugPrint("Fetch error: $e");
    }
  }

  Future<void> fetchHistoryTrades(String accountId) async {
    try {
      final res = await ApiService.getTradeHistory(accountId: accountId);
      if (res.success && res.data != null && res.data!['results'] != null) {
        final List<dynamic> list = res.data!['results'];
        final trades = list.map((e) => TradeModel.fromJson(e)).toList();
        emit(state.copyWith(historyTrades: trades));
      }
    } catch (e) {
      debugPrint("Fetch history error: $e");
    }
  }

  Future<void> createTrade({
    required TradePayload payload,
    required String jwt,
  }) async {
    emit(state.copyWith(isLoading: true));
    try {
      final res = await ApiService.createTrade(payload.toJson());

      if (res.success) {
        if (res.data != null && res.data!['trade'] != null) {
          final newTrade = TradeModel.fromJson(res.data!['trade']);
          final status = (newTrade.status ?? '').toLowerCase();

          if (status == 'pending') {
            final updatedPending = [newTrade, ...state.pendingTrades];
            emit(state.copyWith(
                pendingTrades: updatedPending, isLoading: false));
          } else {
            final updatedActive = [newTrade, ...state.activeTrades];
            emit(state.copyWith(activeTrades: updatedActive, isLoading: false));
          }
        } else {
          await fetchOpenTrades(payload.tradeAccountId);
        }

        emit(state.copyWith(
            successMessage: res.message ?? "Trade Placed", isLoading: false));
        startSocket(jwt: jwt, userId: payload.tradeAccountId);
      } else {
        emit(state.copyWith(
            isLoading: false, errorMessage: res.message ?? "Failed"));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> updateTrade({
    required String tradeId,
    double? sl,
    double? target,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (sl != null) data['sl'] = sl;
      if (target != null) data['target'] = target;
      if (data.isEmpty) return;

      final res = await ApiService.updateTrade(tradeId, data);

      if (res.success) {
        emit(state.copyWith(successMessage: "Trade Updated"));
      } else {
        emit(state.copyWith(errorMessage: res.message ?? "Update Failed"));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: "Update Failed: $e"));
    }
  }

  Future<void> closeTrade(String tradeId, String accountId) async {
    try {
      final res = await ApiService.stopTrade({"tradeId": tradeId});

      if (res.success) {
        final updatedTrades =
            state.activeTrades.where((t) => t.id != tradeId).toList();

        emit(state.copyWith(
          activeTrades: updatedTrades,
          successMessage: "Trade Closed",
        ));

        fetchHistoryTrades(accountId);
      } else {
        emit(state.copyWith(errorMessage: res.message ?? "Close Failed"));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: "Error: $e"));
    }
  }
}

/*
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

  bool _socketStarted = false;


  void startSocket({required String jwt, required String userId}) {
    if (_socketStarted) return;
    _socketStarted = true;

    PlaceOrderWS().connect(
      jwt: jwt,
      userId: userId,
      onEquity: (equity) {
        emit(state.copyWith(equity: equity));
        _updateActiveTradesPnL(equity.liveProfit);
      },
      onTradeUpdate: (data) => _handleWsTradeUpdate(data, isNew: false),
      onNewTrade: (data) => _handleWsTradeUpdate(data, isNew: true),
      onError: (msg) {
        if (msg.contains('handshakeFailed') || msg.contains('invalid Token')) {
          _socketStarted = false;
        }
      },
    );
  }

  void stopSocket() {
    PlaceOrderWS().dispose();
    _socketStarted = false;
  }

  void _updateActiveTradesPnL(List<LiveProfit> liveProfits) {
    if (state.activeTrades.isEmpty) return;

    List<TradeModel> updatedTrades = List.from(state.activeTrades);
    bool changed = false;

    for (var lp in liveProfits) {
      final index = updatedTrades.indexWhere((t) => t.id == lp.id);
      if (index != -1) {
        updatedTrades[index] =
            updatedTrades[index].copyWith(currentProfit: lp.profit);
        changed = true;
      }
    }

    if (changed) {
      emit(state.copyWith(activeTrades: updatedTrades));
    }
  }

  void _handleWsTradeUpdate(Map<String, dynamic> data, {required bool isNew}) {
    try {
      final rawData = data.containsKey('trade') ? data['trade'] : data;
      final trade = TradeModel.fromJson(rawData);

      List<TradeModel> currentTrades = List.from(state.activeTrades);
      final index = currentTrades.indexWhere((t) => t.id == trade.id);

      if (index != -1) {
        currentTrades[index] = trade;
      } else if (isNew) {
        currentTrades.insert(0, trade);
      }

      emit(state.copyWith(activeTrades: currentTrades));
    } catch (e) {
      debugPrint('WS Parse Error: $e');
    }
  }


  Future<void> fetchOpenTrades(String accountId) async {
    try {
      final res = await ApiService.getOpenTrades(accountId);

      // FIX: Check map key safely and parse list
      if (res.success && res.data != null && res.data!['results'] != null) {
        final List<dynamic> list = res.data!['results'];
        final trades = list.map((e) => TradeModel.fromJson(e)).toList();

        emit(state.copyWith(activeTrades: trades));
      }
    } catch (e) {
      debugPrint("Fetch open error: $e");
    }
  }

  Future<void> fetchHistoryTrades(String accountId) async {
    try {
      final res = await ApiService.getTradeHistory(accountId: accountId);

      // FIX: Check map key safely and parse list
      if (res.success && res.data != null && res.data!['results'] != null) {
        final List<dynamic> list = res.data!['results'];
        final trades = list.map((e) => TradeModel.fromJson(e)).toList();

        emit(state.copyWith(historyTrades: trades));
      }
    } catch (e) {
      debugPrint("Fetch history error: $e");
    }
  }

  Future<void> createTrade({
    required TradePayload payload,
    required String jwt,
  }) async {
    emit(state.copyWith(isLoading: true));
    try {
      final res = await ApiService.createTrade(payload.toJson());

      if (res.success) {
        if (res.data != null && res.data!['trade'] != null) {
          final newTrade = TradeModel.fromJson(res.data!['trade']);
          List<TradeModel> current = List.from(state.activeTrades);
          current.insert(0, newTrade);
          emit(state.copyWith(activeTrades: current));
        } else {
          fetchOpenTrades(payload.tradeAccountId);
        }

        emit(state.copyWith(
            isLoading: false, successMessage: res.message ?? "Trade Placed"));

        startSocket(jwt: jwt, userId: payload.tradeAccountId);
      } else {
        emit(state.copyWith(
            isLoading: false, errorMessage: res.message ?? "Failed"));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> updateTrade({
    required String tradeId,
    double? sl, // Nullable
    double? target, // Nullable
  }) async {
    try {
      final data = <String, dynamic>{};

      // ONLY add to payload if value is NOT null
      if (sl != null) data['sl'] = sl;
      if (target != null) data['target'] = target;

      // STOP if payload is empty (don't hit API)
      if (data.isEmpty) {
        debugPrint("Update Trade Aborted: No values to update.");
        return;
      }

      final res = await ApiService.updateTrade(tradeId, data);

      if (res.success) {
        // Optimistically update local state
        List<TradeModel> updated = state.activeTrades.map((t) {
          if (t.id == tradeId) {
            return t.copyWith(
              sl: sl ?? t.sl, // Keep old SL if new one is null
              target: target ?? t.target, // Keep old TP if new one is null
            );
          }
          return t;
        }).toList();

        emit(state.copyWith(
            activeTrades: updated, successMessage: "Trade Updated"));
      } else {
        emit(state.copyWith(errorMessage: res.message ?? "Update Failed"));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: "Update Failed: $e"));
    }
  }

  Future<void> closeTrade(String tradeId, String accountId) async {
    try {
      final res = await ApiService.stopTrade({"tradeId": tradeId});

      if (res.success) {
        List<TradeModel> current = List.from(state.activeTrades);
        current.removeWhere((t) => t.id == tradeId);

        emit(state.copyWith(
            activeTrades: current, successMessage: "Trade Closed"));

        fetchHistoryTrades(accountId);
      } else {
        emit(state.copyWith(errorMessage: res.message ?? "Close Failed"));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: "Error: $e"));
    }
  }
}
*/
