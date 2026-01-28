// bloc/transaction_history_event.dart

import '../model/transaction_history_models.dart';

abstract class TransactionHistoryEvent {}

class LoadTransactionHistory extends TransactionHistoryEvent {
  final bool isRefresh;
  final TransactionFilter? filter;

  LoadTransactionHistory({
    this.isRefresh = false,
    this.filter,
  });
}

class LoadMoreTransactions extends TransactionHistoryEvent {}

class FilterTransactions extends TransactionHistoryEvent {
  final TransactionFilter filter;

  FilterTransactions({required this.filter});
}

class ResetFilters extends TransactionHistoryEvent {}

class RefreshTransactionHistory extends TransactionHistoryEvent {}