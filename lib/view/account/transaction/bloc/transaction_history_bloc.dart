import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../network/api_service.dart';
import '../model/transaction_history_models.dart';
import 'transaction_history_event.dart';
import 'transaction_history_state.dart';

class TransactionHistoryBloc extends Bloc<TransactionHistoryEvent, TransactionHistoryState> {
  final String tradeUserId;
  final int pageSize;
  List<Transaction> _allTransactions = [];
  int _currentPage = 1;
  TransactionFilter _currentFilter = TransactionFilter();

  TransactionHistoryBloc({
    required this.tradeUserId,
    this.pageSize = 10,
  }) : super(TransactionHistoryInitial()) {
    on<LoadTransactionHistory>(_onLoadTransactionHistory);
    on<LoadMoreTransactions>(_onLoadMoreTransactions);
    on<FilterTransactions>(_onFilterTransactions);
    on<ResetFilters>(_onResetFilters);
    on<RefreshTransactionHistory>(_onRefreshTransactionHistory);
  }

  Future<void> _onLoadTransactionHistory(
      LoadTransactionHistory event,
      Emitter<TransactionHistoryState> emit,
      ) async {
    if (event.isRefresh) {
      _currentPage = 1;
      _allTransactions.clear();
    }

    if (event.filter != null) {
      _currentFilter = event.filter!;
      _currentPage = 1;
      _allTransactions.clear();
    }

    emit(TransactionHistoryLoading());

    try {
      final transactions = await _fetchTransactions(_currentPage);

      debugPrint("=== Fetched ${transactions.length} transactions ===");

      if (transactions.isEmpty) {
        emit(TransactionHistoryEmpty(currentFilter: _currentFilter));
        return;
      }

      _allTransactions = transactions;
      _currentPage = 2; // Next page to load

      emit(TransactionHistoryLoaded(
        transactions: _allTransactions,
        pagination: PaginationInfo(
          currentPage: 1,
          totalPages: 10, // This should come from API response
          totalItems: transactions.length,
          pageSize: pageSize,
          hasNextPage: transactions.length >= pageSize,
          hasPreviousPage: false,
        ),
        currentFilter: _currentFilter,
        hasReachedMax: transactions.length < pageSize,
      ));
    } catch (error) {
      debugPrint("=== Error in _onLoadTransactionHistory: $error ===");
      emit(TransactionHistoryError(
        message: error.toString(),
        currentFilter: _currentFilter,
      ));
    }
  }

  Future<void> _onLoadMoreTransactions(
      LoadMoreTransactions event,
      Emitter<TransactionHistoryState> emit,
      ) async {
    final currentState = state;
    if (currentState is! TransactionHistoryLoaded || currentState.hasReachedMax) {
      return;
    }

    emit(TransactionHistoryLoadingMore(
      currentTransactions: currentState.transactions,
      currentFilter: currentState.currentFilter,
    ));

    try {
      final newTransactions = await _fetchTransactions(_currentPage);

      if (newTransactions.isEmpty) {
        emit(currentState.copyWith(hasReachedMax: true));
        return;
      }

      _allTransactions.addAll(newTransactions);
      _currentPage++;

      emit(TransactionHistoryLoaded(
        transactions: _allTransactions,
        pagination: currentState.pagination.copyWith(
          currentPage: _currentPage - 1,
          hasNextPage: newTransactions.length >= pageSize,
        ),
        currentFilter: _currentFilter,
        hasReachedMax: newTransactions.length < pageSize,
      ));
    } catch (error) {
      emit(TransactionHistoryError(
        message: error.toString(),
        currentFilter: _currentFilter,
      ));
    }
  }

  Future<void> _onFilterTransactions(
      FilterTransactions event,
      Emitter<TransactionHistoryState> emit,
      ) async {
    _currentFilter = event.filter;
    _currentPage = 1;
    _allTransactions.clear();
    add(LoadTransactionHistory(filter: event.filter));
  }

  Future<void> _onResetFilters(
      ResetFilters event,
      Emitter<TransactionHistoryState> emit,
      ) async {
    _currentFilter = TransactionFilter();
    _currentPage = 1;
    _allTransactions.clear();
    add(LoadTransactionHistory());
  }

  Future<void> _onRefreshTransactionHistory(
      RefreshTransactionHistory event,
      Emitter<TransactionHistoryState> emit,
      ) async {
    add(LoadTransactionHistory(isRefresh: true));
  }

  Future<List<Transaction>> _fetchTransactions(int page) async {
    List<Transaction> allTransactions = [];

    try {
      debugPrint("=== Fetching transactions for page: $page ===");
      debugPrint("=== Current filter: ${_currentFilter.transactionType} ===");

      // Fetch deposits and withdrawals based on filter
      if (_currentFilter.transactionType == 'All' ||
          _currentFilter.transactionType == 'Deposit') {
        debugPrint("=== Fetching deposits ===");
        final depositResponse = await ApiService.getDepositList(
          tradeUserId: tradeUserId,
          pageSize: pageSize,
          pageNumber: page,
        );

        debugPrint("=== Deposit response success: ${depositResponse.success} ===");
        if (depositResponse.success && depositResponse.data != null) {
          // Parse the response correctly based on your API structure
          final responseData = depositResponse.data!;
          debugPrint("=== Deposit response data keys: ${responseData.keys} ===");

          // Check if the response has 'results' field (as shown in your API response)
          if (responseData.containsKey('results')) {
            final results = responseData['results'] as List;
            debugPrint("=== Found ${results.length} crypto_deposit results ===");

            // Convert each result to Transaction object
            for (var result in results) {
              try {
                final transaction = Transaction.fromJson(result);
                allTransactions.add(transaction);
                debugPrint("=== Added crypto_deposit transaction: ${transaction.id} ===");
              } catch (e) {
                debugPrint("=== Error parsing crypto_deposit transaction: $e ===");
                debugPrint("=== Transaction data: $result ===");
              }
            }
          }
        }
      }

      if (_currentFilter.transactionType == 'All' ||
          _currentFilter.transactionType == 'Withdrawal') {
        debugPrint("=== Fetching withdrawals ===");
        final withdrawResponse = await ApiService.getWithdrawList(
          tradeUserId: tradeUserId,
          pageSize: pageSize,
          pageNumber: page,
        );

        debugPrint("=== Withdraw response success: ${withdrawResponse.success} ===");
        if (withdrawResponse.success && withdrawResponse.data != null) {
          // Parse the response correctly based on your API structure
          final responseData = withdrawResponse.data!;
          debugPrint("=== Withdraw response data keys: ${responseData.keys} ===");

          // Check if the response has 'results' field (as shown in your API response)
          if (responseData.containsKey('results')) {
            final results = responseData['results'] as List;
            debugPrint("=== Found ${results.length} withdrawal results ===");

            // Convert each result to Transaction object
            for (var result in results) {
              try {
                final transaction = Transaction.fromJson(result);
                allTransactions.add(transaction);
                debugPrint("=== Added withdrawal transaction: ${transaction.id} ===");
              } catch (e) {
                debugPrint("=== Error parsing withdrawal transaction: $e ===");
                debugPrint("=== Transaction data: $result ===");
              }
            }
          }
        }
      }

      debugPrint("=== Total transactions before filtering: ${allTransactions.length} ===");

      // Apply additional filters
      allTransactions = _applyFilters(allTransactions);

      debugPrint("=== Total transactions after filtering: ${allTransactions.length} ===");

      // Sort by date (newest first)
      allTransactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return allTransactions;
    } catch (error) {
      debugPrint("=== Error in _fetchTransactions: $error ===");
      throw Exception('Failed to fetch transactions: $error');
    }
  }

  List<Transaction> _applyFilters(List<Transaction> transactions) {
    return transactions.where((transaction) {
      // Filter by status
      if (_currentFilter.status != 'All' &&
          transaction.displayStatus != _currentFilter.status) {
        return false;
      }

      // Filter by transaction type
      if (_currentFilter.transactionType != 'All' &&
          transaction.displayType != _currentFilter.transactionType) {
        return false;
      }

      // Add date range filtering here if needed
      // You can implement date range logic based on _currentFilter.dateRange

      return true;
    }).toList();
  }
}

extension PaginationInfoExtension on PaginationInfo {
  PaginationInfo copyWith({
    int? currentPage,
    int? totalPages,
    int? totalItems,
    int? pageSize,
    bool? hasNextPage,
    bool? hasPreviousPage,
  }) {
    return PaginationInfo(
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      pageSize: pageSize ?? this.pageSize,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      hasPreviousPage: hasPreviousPage ?? this.hasPreviousPage,
    );
  }
}
