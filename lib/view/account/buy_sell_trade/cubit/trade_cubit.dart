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
    _socketStarted = true;

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

  void _handleWsTradeUpdate(Map<String, dynamic> data, {required bool isNew}) {
    try {
      final rawData = data.containsKey('trade') ? data['trade'] : data;
      final trade = TradeModel.fromJson(rawData);
      final status = (trade.status ?? '').toLowerCase();

      List<TradeModel> active = List.from(state.activeTrades);
      List<TradeModel> pending = List.from(state.pendingTrades);

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
      debugPrint('WS Update Error: $e');
    }
  }

  void _updateActiveTradesPnL(List<LiveProfit> liveProfits) {
    if (state.activeTrades.isEmpty) return;

    List<TradeModel> updatedActiveTrades = List.from(state.activeTrades);
    bool changed = false;

    for (var lp in liveProfits) {
      final index = updatedActiveTrades.indexWhere((t) => t.id == lp.id);
      if (index != -1) {
        updatedActiveTrades[index] = updatedActiveTrades[index].copyWith(
          currentProfit: lp.profit,
        );
        changed = true;
      }
    }

    if (changed && !isClosed) {
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

      if (!isClosed) {
        emit(state.copyWith(activeTrades: active, pendingTrades: pending));
      }
    } catch (e) {
      debugPrint("Fetch Trades Error: $e");
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
      debugPrint("Fetch History Error: $e");
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
