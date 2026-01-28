import 'package:flutter/cupertino.dart';

import '../../../../network/api_service.dart';
import '../model/transaction_history_models.dart';

class TransactionService {
  static Future<List<Transaction>> fetchTransactionHistory({
    required String tradeUserId,
    required int pageNumber,
    required int pageSize,
    TransactionFilter? filter,
  }) async {
    List<Transaction> allTransactions = [];

    try {
      // Determine which endpoints to call based on filter
      bool shouldFetchDeposits = filter?.transactionType == 'All' ||
          filter?.transactionType == 'Deposit' ||
          filter?.transactionType == null;

      bool shouldFetchWithdrawals = filter?.transactionType == 'All' ||
          filter?.transactionType == 'Withdrawal' ||
          filter?.transactionType == null;

      // Fetch deposits if needed
      if (shouldFetchDeposits) {
        try {
          final depositResponse = await ApiService.getDepositList(
            tradeUserId: tradeUserId,
            pageSize: pageSize,
            pageNumber: pageNumber,
          );

          if (depositResponse.success && depositResponse.data != null) {
            final deposits = _parseTransactionsFromResponse(
              depositResponse.data!,
              'crypto_deposit',
            );
            allTransactions.addAll(deposits);
          }
        } catch (e) {
          debugPrint('Error fetching deposits: $e');
          // Continue with other transaction types even if one fails
        }
      }

      // Fetch withdrawals if needed
      if (shouldFetchWithdrawals) {
        try {
          final withdrawResponse = await ApiService.getWithdrawList(
            tradeUserId: tradeUserId,
            pageSize: pageSize,
            pageNumber: pageNumber,
          );

          if (withdrawResponse.success && withdrawResponse.data != null) {
            final withdrawals = _parseTransactionsFromResponse(
              withdrawResponse.data!,
              'withdrawal',
            );
            allTransactions.addAll(withdrawals);
          }
        } catch (e) {
          debugPrint('Error fetching withdrawals: $e');
          // Continue even if withdrawal fetch fails
        }
      }

      // Apply additional filters
      if (filter != null) {
        allTransactions = _applyFilters(allTransactions, filter);
      }

      // Sort by date (newest first)
      allTransactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return allTransactions;
    } catch (error) {
      throw Exception('Failed to fetch transaction history: $error');
    }
  }

  static List<Transaction> _parseTransactionsFromResponse(
      Map<String, dynamic> responseData,
      String defaultType,
      ) {
    List<Transaction> transactions = [];

    try {
      // Handle the 'results' field from your API response
      if (responseData.containsKey('results')) {
        final resultsList = responseData['results'] as List?;
        if (resultsList != null) {
          for (var item in resultsList) {
            if (item is Map<String, dynamic>) {
              try {
                // Use the existing Transaction.fromJson method
                final transaction = Transaction.fromJson(item);
                transactions.add(transaction);
              } catch (e) {
                debugPrint('Error parsing individual transaction: $e');
                debugPrint('Transaction data: $item');
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error parsing transactions: $e');
    }

    return transactions;
  }

  static List<Transaction> _applyFilters(
      List<Transaction> transactions,
      TransactionFilter filter,
      ) {
    return transactions.where((transaction) {
      // Filter by status
      if (filter.status != 'All' &&
          transaction.displayStatus != filter.status) {
        return false;
      }

      // Filter by transaction type (already handled in API calls, but double-check)
      if (filter.transactionType != 'All' &&
          transaction.displayType != filter.transactionType) {
        return false;
      }

      // Filter by date range
      if (filter.startDate != null && transaction.createdAt.isBefore(filter.startDate!)) {
        return false;
      }

      if (filter.endDate != null && transaction.createdAt.isAfter(filter.endDate!)) {
        return false;
      }

      // Add more filter logic as needed
      return true;
    }).toList();
  }

  // Helper method to get date range based on selected range
  static Map<String, DateTime?> getDateRangeForFilter(String dateRange) {
    final now = DateTime.now();
    DateTime? startDate;
    DateTime? endDate = now;

    switch (dateRange) {
      case 'Last 3 days':
        startDate = now.subtract(Duration(days: 3));
        break;
      case 'Last 7 days':
        startDate = now.subtract(Duration(days: 7));
        break;
      case 'Last 30 days':
        startDate = now.subtract(Duration(days: 30));
        break;
      case 'Last 3 months':
        startDate = DateTime(now.year, now.month - 3, now.day);
        break;
      default:
        startDate = null;
        endDate = null;
    }

    return {
      'startDate': startDate,
      'endDate': endDate,
    };
  }

  // Helper method to create TransactionFilter with date range
  static TransactionFilter createFilterWithDateRange({
    String transactionType = 'All',
    String status = 'All',
    String account = 'All',
    String dateRange = 'Last 7 days',
  }) {
    final dateRangeMap = getDateRangeForFilter(dateRange);

    return TransactionFilter(
      transactionType: transactionType,
      status: status,
      account: account,
      dateRange: dateRange,
      startDate: dateRangeMap['startDate'],
      endDate: dateRangeMap['endDate'],
    );
  }
}
