// bloc/transaction_history_state.dart

import '../model/transaction_history_models.dart';

abstract class TransactionHistoryState {}

class TransactionHistoryInitial extends TransactionHistoryState {}

class TransactionHistoryLoading extends TransactionHistoryState {}

class TransactionHistoryLoadingMore extends TransactionHistoryState {
  final List<Transaction> currentTransactions;
  final TransactionFilter currentFilter;

  TransactionHistoryLoadingMore({
    required this.currentTransactions,
    required this.currentFilter,
  });
}

class TransactionHistoryLoaded extends TransactionHistoryState {
  final List<Transaction> transactions;
  final PaginationInfo pagination;
  final TransactionFilter currentFilter;
  final bool hasReachedMax;

  TransactionHistoryLoaded({
    required this.transactions,
    required this.pagination,
    required this.currentFilter,
    this.hasReachedMax = false,
  });

  TransactionHistoryLoaded copyWith({
    List<Transaction>? transactions,
    PaginationInfo? pagination,
    TransactionFilter? currentFilter,
    bool? hasReachedMax,
  }) {
    return TransactionHistoryLoaded(
      transactions: transactions ?? this.transactions,
      pagination: pagination ?? this.pagination,
      currentFilter: currentFilter ?? this.currentFilter,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class TransactionHistoryEmpty extends TransactionHistoryState {
  final TransactionFilter currentFilter;

  TransactionHistoryEmpty({required this.currentFilter});
}

class TransactionHistoryError extends TransactionHistoryState {
  final String message;
  final TransactionFilter currentFilter;

  TransactionHistoryError({
    required this.message,
    required this.currentFilter,
  });
}