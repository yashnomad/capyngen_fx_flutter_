import 'package:equatable/equatable.dart';
import '../model/trade_model.dart';
import '../model/ws_equity_data.dart';

enum ConnectionStatus {
  disconnected,
  connecting,
  live,
}

class TradeState extends Equatable {
  final List<TradeModel> activeTrades;
  final List<TradeModel> pendingTrades;
  final List<TradeModel> historyTrades;
  final EquitySnapshot? equity;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final ConnectionStatus connectionStatus;

  const TradeState({
    this.activeTrades = const [],
    this.pendingTrades = const [],
    this.historyTrades = const [],
    this.equity,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.connectionStatus = ConnectionStatus.disconnected,
  });

  TradeState copyWith({
    List<TradeModel>? activeTrades,
    List<TradeModel>? pendingTrades,
    List<TradeModel>? historyTrades,
    EquitySnapshot? equity,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    ConnectionStatus? connectionStatus,
  }) {
    return TradeState(
      activeTrades: activeTrades ?? this.activeTrades,
      pendingTrades: pendingTrades ?? this.pendingTrades,
      historyTrades: historyTrades ?? this.historyTrades,
      equity: equity ?? this.equity,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      connectionStatus: connectionStatus ?? this.connectionStatus,
    );
  }

  @override
  List<Object?> get props => [
        activeTrades,
        pendingTrades,
        historyTrades,
        equity,
        isLoading,
        errorMessage,
        successMessage,
        connectionStatus,
      ];
}
