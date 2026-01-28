import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class Transaction {
  final String? id;
  final String transactionId;
  final String user;
  final double amount;
  final String paymentMode;
  final String status;
  final double closingBalance;
  final String? remark;
  final String type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? actionBy;
  final BankDetails? bankDetails;
  final String? currency;
  final String? description;
  final String? merchantId;
  final String? referenceId; // Added this field
  final Map<String, dynamic>? metadata; // Added this field

  Transaction({
    this.id,
    required this.transactionId,
    required this.user,
    required this.amount,
    required this.paymentMode,
    required this.status,
    required this.closingBalance,
    this.remark,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.actionBy,
    this.bankDetails,
    this.currency,
    this.description,
    this.merchantId,
    this.referenceId, // Added this parameter
    this.metadata, // Added this parameter
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['_id'],
      transactionId: json['transactionId'] ?? '',
      user: json['user'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      paymentMode: json['paymentMode'] ?? '',
      status: json['status'] ?? '',
      closingBalance: (json['closingBalance'] ?? 0).toDouble(),
      remark: json['remark'],
      type: json['type'] ?? '',
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      actionBy: json['actionBy'],
      bankDetails: json['bank_details'] != null
          ? BankDetails.fromJson(json['bank_details'])
          : null,
      currency: json['currency'] ?? json['currency_code'],
      description: json['remark'],
      merchantId: json['merchant_id'],
      referenceId: json['referenceId'] ?? json['reference_id'] ?? json['transactionId'],
      metadata: json['metadata'] ?? json['extra_data'],
    );
  }

  // Helper method to parse different date formats
  static DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();

    String dateString = dateValue.toString();

    try {
      // Try ISO format first (withdrawal API format)
      if (dateString.contains('T') && dateString.contains('Z')) {
        return DateTime.parse(dateString);
      }

      // Try custom format (crypto_deposit API format): "05/07/2025, 03:11:35 pm"
      if (dateString.contains('/') && dateString.contains(',')) {
        // Parse format: "05/07/2025, 03:11:35 pm"
        final formatter = DateFormat('dd/MM/yyyy, hh:mm:ss a');
        return formatter.parse(dateString);
      }

      // Try other common formats
      if (dateString.contains('-')) {
        return DateTime.parse(dateString);
      }

      // If all else fails, return current time
      debugPrint("=== Could not parse date: $dateString, using current time ===");
      return DateTime.now();

    } catch (e) {
      debugPrint("=== Error parsing date '$dateString': $e ===");
      return DateTime.now();
    }
  }

  String get displayType {
    switch (type.toLowerCase()) {
      case 'user_withdrawal':
        return 'Withdrawal';
      case 'user_deposit':
        return 'Deposit';
      case 'user_transfer':
        return 'Transfer';
      case 'user_refund':
        return 'Refund';
      case 'user_reward':
        return 'Reward';
      case 'user_rebate':
        return 'Rebate';
      case 'user_investment':
        return 'Investment';
      case 'agent_commission':
        return 'Agent Commission';
      default:
        return type
            .replaceAll('_', ' ')
            .split(' ')
            .map((word) => word.isNotEmpty
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : '')
            .join(' ');
    }
  }

  String get displayStatus {
    switch (status.toLowerCase()) {
      case 'success':
        return 'Done';
      case 'pending':
        return 'Processing';
      case 'failed':
        return 'Rejected';
      default:
        return status[0].toUpperCase() + status.substring(1).toLowerCase();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'transactionId': transactionId,
      'user': user,
      'amount': amount,
      'paymentMode': paymentMode,
      'status': status,
      'closingBalance': closingBalance,
      'remark': remark,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'actionBy': actionBy,
      'bank_details': bankDetails?.toJson(),
      'merchant_id': merchantId,
      'referenceId': referenceId,
      'metadata': metadata,
    };
  }
}

class BankDetails {
  final String bankAccountNumber;
  final String ifscCode;
  final String bankName;

  BankDetails({
    required this.bankAccountNumber,
    required this.ifscCode,
    required this.bankName,
  });

  factory BankDetails.fromJson(Map<String, dynamic> json) {
    return BankDetails(
      bankAccountNumber: json['bankAccountNumber']?.toString() ?? '',
      ifscCode: json['ifscCode'] ?? '',
      bankName: json['bankName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bankAccountNumber': bankAccountNumber,
      'ifscCode': ifscCode,
      'bankName': bankName,
    };
  }
}

class TransactionHistoryResponse {
  final bool success;
  final TransactionHistoryData data;
  final PaginationInfo pagination;

  TransactionHistoryResponse({
    required this.success,
    required this.data,
    required this.pagination,
  });

  factory TransactionHistoryResponse.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryResponse(
      success: json['success'] ?? false,
      data: TransactionHistoryData.fromJson(json),
      pagination: PaginationInfo.fromJson(json['pagination'] ?? {}),
    );
  }
}

class TransactionHistoryData {
  final List<Transaction> transactions;

  TransactionHistoryData({required this.transactions});

  factory TransactionHistoryData.fromJson(Map<String, dynamic> json) {
    final results = json['results'] as List? ?? [];
    return TransactionHistoryData(
      transactions: results.map((item) => Transaction.fromJson(item)).toList(),
    );
  }
}

class PaginationInfo {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int pageSize;
  final bool hasNextPage;
  final bool hasPreviousPage;

  PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.pageSize,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['pageNumber'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      totalItems: json['total'] ?? 0,
      pageSize: json['pageSize'] ?? 10,
      hasNextPage: json['next'] ?? false,
      hasPreviousPage: json['previous'] ?? false,
    );
  }
}

class TransactionFilter {
  final String transactionType;
  final String status;
  final String account;
  final String dateRange;
  final DateTime? startDate; // Added this field
  final DateTime? endDate; // Added this field

  TransactionFilter({
    this.transactionType = 'All',
    this.status = 'All',
    this.account = 'All',
    this.dateRange = 'Last 7 days',
    this.startDate, // Added this parameter
    this.endDate, // Added this parameter
  });

  TransactionFilter copyWith({
    String? transactionType,
    String? status,
    String? account,
    String? dateRange,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return TransactionFilter(
      transactionType: transactionType ?? this.transactionType,
      status: status ?? this.status,
      account: account ?? this.account,
      dateRange: dateRange ?? this.dateRange,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}
