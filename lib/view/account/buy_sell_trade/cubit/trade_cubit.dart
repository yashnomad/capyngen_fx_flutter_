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

  final Map<String, double> _lastKnownPnL = {};
  EquitySnapshot? _lastKnownEquity;

  Timer? _equityWatchdog;
  int _watchdogRetryCount = 0;
  static const int _maxWatchdogRetries = 3;

  String? _lastJwt;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ✅ NEW: Called from didChangeAppLifecycleState on resume
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  void reconnect({
    required String jwt,
    required String userId,
    bool forceNew = false,
  }) {
    if (forceNew) {
      debugPrint('🔌 [TradeCubit] Force reconnect — disposing old socket');

      _equityWatchdog?.cancel();
      _watchdogRetryCount = 0;

      PlaceOrderWS.instance.dispose();

      if (!isClosed) {
        emit(state.copyWith(
          connectionStatus: ConnectionStatus.connecting,
          clearEquity: true,
        ));
      }
    }

    startSocket(jwt: jwt, userId: userId);
  }

  void startSocket({required String jwt, required String userId}) {
    if (_currentUserId != null && _currentUserId != userId) {
      debugPrint('🔄 [TradeCubit] Account switched, clearing cache...');
      _lastKnownPnL.clear();
      _lastKnownEquity = null;
    }

    _currentUserId = userId;
    _lastJwt = jwt;

    _equityWatchdog?.cancel();

    if (!isClosed) {
      emit(state.copyWith(connectionStatus: ConnectionStatus.connecting));
    }

    PlaceOrderWS.instance.ensureConnected(
      jwt: jwt,
      userId: userId,
      onEquity: (equity) {
        if (isClosed) return;

        _equityWatchdog?.cancel();
        _watchdogRetryCount = 0;

        _lastKnownEquity = equity;

        emit(state.copyWith(
          equity: equity,
          connectionStatus: ConnectionStatus.live,
        ));
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
        if (!isClosed) {
          emit(state.copyWith(connectionStatus: ConnectionStatus.disconnected));
        }
      },
      onDisconnect: () {
        if (!isClosed) {
          emit(state.copyWith(connectionStatus: ConnectionStatus.disconnected));
        }
      },
    );

    _startWatchdog(jwt: jwt, userId: userId);
  }

  void _startWatchdog({required String jwt, required String userId}) {
    _equityWatchdog?.cancel();
    _equityWatchdog = Timer(const Duration(seconds: 8), () {
      if (isClosed) return;

      if (!PlaceOrderWS.instance.isConnected) {
        if (_watchdogRetryCount < _maxWatchdogRetries) {
          _watchdogRetryCount++;
          debugPrint(
              '⏰ [Watchdog] No connection after 8s, attempt $_watchdogRetryCount/$_maxWatchdogRetries');

          if (!isClosed) {
            emit(state.copyWith(connectionStatus: ConnectionStatus.connecting));
          }

          PlaceOrderWS.instance.dispose();
          startSocket(jwt: jwt, userId: userId);
        } else {
          debugPrint(
              '❌ [Watchdog] Max retries reached, giving up auto-reconnect');
          if (!isClosed) {
            emit(state.copyWith(
                connectionStatus: ConnectionStatus.disconnected));
          }
        }
      } else {
        debugPrint('✅ [Watchdog] Socket connected, all good');
      }
    });
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

        final Map<String, double> previousPnL = {};
        for (final t in state.activeTrades) {
          if (t.id != null && (t.currentProfit ?? 0) != 0) {
            previousPnL[t.id!] = t.currentProfit!;
          }
        }

        for (int i = 0; i < trades.length; i++) {
          final trade = trades[i];
          double? bestProfit;

          if (state.equity != null) {
            try {
              final lp = state.equity!.liveProfit.firstWhere(
                (element) => element.id == trade.id,
              );
              if (lp.profit != null && lp.profit != 0) {
                bestProfit = lp.profit;
              }
            } catch (_) {}
          }

          if (bestProfit == null || bestProfit == 0) {
            bestProfit = previousPnL[trade.id];
          }

          if (bestProfit == null || bestProfit == 0) {
            bestProfit = _lastKnownPnL[trade.id];
          }

          if (bestProfit != null && bestProfit != 0) {
            trades[i] = trade.copyWith(currentProfit: bestProfit);
          }
        }

        final activeTradeIds = trades.map((t) => t.id).toSet();
        _lastKnownPnL.removeWhere((id, _) => !activeTradeIds.contains(id));

        List<TradeModel> cleanedPending = List.from(state.pendingTrades);
        cleanedPending.removeWhere((t) => activeTradeIds.contains(t.id));

        emit(state.copyWith(
          activeTrades: trades,
          pendingTrades: cleanedPending,
          isLoading: false,
          equity: state.equity ?? _lastKnownEquity,
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
        _lastKnownPnL.remove(trade.id);
        history.insert(0, trade);

        if (!manualClose) {
          autoCloseMessage = "Trade Closed. PnL: ${trade.profitLossAmount}";
        }
        if (trade.tradeAccountId != null) {
          fetchHistoryTrades(trade.tradeAccountId!);
        }
      } else if (status == 'pending') {
        pending.insert(0, trade);
      } else if (status == 'open') {
        if (trade.id != null && _lastKnownPnL.containsKey(trade.id)) {
          trade = trade.copyWith(currentProfit: _lastKnownPnL[trade.id]);
        }
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
      if (lp.id != null && lp.profit != null) {
        _lastKnownPnL[lp.id!] = lp.profit!;
      }

      final index = updatedActiveTrades.indexWhere((t) => t.id == lp.id);
      if (index != -1) {
        var trade = updatedActiveTrades[index];
        if (trade.currentProfit != lp.profit) {
          updatedActiveTrades[index] = trade.copyWith(currentProfit: lp.profit);
          changed = true;
        }
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

      if (lastLivePnL == 0.0) {
        lastLivePnL = _lastKnownPnL[tradeId] ?? 0.0;
      }

      _lastKnownPnL.remove(tradeId);

      final res = await ApiService.stopTrade({"tradeId": tradeId});

      if (res.success) {
        List<TradeModel> currentActive = List.from(state.activeTrades);
        currentActive.removeWhere((t) => t.id == tradeId);

        List<TradeModel> currentHistory = List.from(state.historyTrades);
        String pnlMessage = "Trade Closed";

        if (res.data != null) {
          var rawData = res.data;
          if (rawData is Map<String, dynamic>) {
            if (rawData.containsKey('trade')) {
              rawData = rawData['trade'];
            } else if (rawData.containsKey('result')) {
              rawData = rawData['result'];
            }

            if (rawData != null && rawData is Map<String, dynamic>) {
              final closedTrade =
                  TradeModel.fromJson(rawData as Map<String, dynamic>);
              currentHistory.insert(0, closedTrade);
              double finalPnL = closedTrade.profitLossAmount ?? 0.0;
              if (finalPnL == 0 && lastLivePnL != 0) finalPnL = lastLivePnL;
              pnlMessage = "Trade Closed.";
            }
          }
        }
        emit(state.copyWith(
            activeTrades: currentActive,
            historyTrades: currentHistory,
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

  @override
  Future<void> close() {
    _equityWatchdog?.cancel();
    _lastKnownPnL.clear();
    _lastKnownEquity = null;
    return super.close();
  }
}
