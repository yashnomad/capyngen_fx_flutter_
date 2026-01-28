class FollowerSubscriptionResponse {
  final bool success;
  final List<FollowerSubscription> results;
  final Pagination pagination;

  FollowerSubscriptionResponse({
    required this.success,
    required this.results,
    required this.pagination,
  });

  factory FollowerSubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return FollowerSubscriptionResponse(
      success: json['success'] ?? false,
      results: (json['results'] as List? ?? [])
          .map((e) => FollowerSubscription.fromJson(e))
          .toList(),
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

class FollowerSubscription {
  final String id;
  final String masterId;
  final FollowerAccount followerAccount;
  final String type;
  final String allocationType;
  final num allocationValue;
  final String status;
  final DateTime joinedAt;
  final DateTime? stoppedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  FollowerSubscription({
    required this.id,
    required this.masterId,
    required this.followerAccount,
    required this.type,
    required this.allocationType,
    required this.allocationValue,
    required this.status,
    required this.joinedAt,
    required this.stoppedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FollowerSubscription.fromJson(Map<String, dynamic> json) {
    return FollowerSubscription(
      id: json['_id'] ?? '',
      masterId: json['masterId'] ?? '',
      followerAccount:
      FollowerAccount.fromJson(json['followerId']),
      type: json['type'] ?? '',
      allocationType: json['allocationType'] ?? '',
      allocationValue: json['allocationValue'] ?? 0,
      status: json['status'] ?? '',
      joinedAt:
      DateTime.tryParse(json['joinedAt'] ?? '') ?? DateTime.now(),
      stoppedAt: json['stoppedAt'] != null
          ? DateTime.tryParse(json['stoppedAt'])
          : null,
      createdAt:
      DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt:
      DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class FollowerAccount {
  final String id;
  final String accountID;

  FollowerAccount({
    required this.id,
    required this.accountID,
  });

  factory FollowerAccount.fromJson(Map<String, dynamic>? json) {
    return FollowerAccount(
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
