class MasterAccountResponse {
  final bool success;
  final List<MasterAccount> results;
  final Pagination pagination;

  MasterAccountResponse({
    required this.success,
    required this.results,
    required this.pagination,
  });

  factory MasterAccountResponse.fromJson(Map<String, dynamic> json) {
    return MasterAccountResponse(
      success: json['success'] ?? false,
      results: (json['results'] as List? ?? [])
          .map((e) => MasterAccount.fromJson(e))
          .toList(),
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

class MasterAccount {
  final String id;
  final TradeAccount tradeAccount;
  final String brokerId;
  final int followers;
  final String copyMode;
  final String strategyName;
  final String description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  MasterAccount({
    required this.id,
    required this.tradeAccount,
    required this.brokerId,
    required this.followers,
    required this.copyMode,
    required this.strategyName,
    required this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MasterAccount.fromJson(Map<String, dynamic> json) {
    return MasterAccount(
      id: json['_id'] ?? '',
      tradeAccount: TradeAccount.fromJson(json['tradeAccount']),
      brokerId: json['broker_id'] ?? '',
      followers: json['followers'] ?? 0,
      copyMode: json['copyMode'] ?? '',
      strategyName: json['strategyName'] ?? '',
      description: json['description'] ?? '',
      isActive: json['isActive'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class TradeAccount {
  final String id;
  final String accountID;

  TradeAccount({
    required this.id,
    required this.accountID,
  });

  factory TradeAccount.fromJson(Map<String, dynamic>? json) {
    return TradeAccount(
      id: json?['_id'] ?? '',
      accountID: json?['accountID'] ?? '',
    );
  }
}

class Pagination {
  final int total;
  final int pageNumber;
  final int totalPages;
  final int pageSize;
  final bool next;
  final bool previous;

  Pagination({
    required this.total,
    required this.pageNumber,
    required this.totalPages,
    required this.pageSize,
    required this.next,
    required this.previous,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total'] ?? 0,
      pageNumber: json['pageNumber'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      pageSize: json['pageSize'] ?? 0,
      next: json['next'] ?? false,
      previous: json['previous'] ?? false,
    );
  }
}
