import 'package:equatable/equatable.dart';

import '../model/market_data.dart';

// States
abstract class MarketDataState extends Equatable {
  const MarketDataState();

  @override
  List<Object?> get props => [];
}

class MarketDataInitial extends MarketDataState {}

class MarketDataLoading extends MarketDataState {}

class MarketDataLoaded extends MarketDataState {
  final List<MarketData> marketData;
  final bool isUpdating;
  final String? warning;
  final DateTime lastUpdateTime;

  const MarketDataLoaded({
    required this.marketData,
    this.isUpdating = false,
    this.warning,
    required this.lastUpdateTime,
  });

  @override
  List<Object?> get props => [marketData, isUpdating, warning, lastUpdateTime];

  MarketDataLoaded copyWith({
    List<MarketData>? marketData,
    bool? isUpdating,
    String? warning,
    DateTime? lastUpdateTime,
  }) {
    return MarketDataLoaded(
      marketData: marketData ?? this.marketData,
      isUpdating: isUpdating ?? this.isUpdating,
      warning: warning,
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
    );
  }
}

class MarketDataError extends MarketDataState {
  final String message;
  final List<MarketData>? previousData;

  const MarketDataError({
    required this.message,
    this.previousData,
  });

  @override
  List<Object?> get props => [message, previousData];
}