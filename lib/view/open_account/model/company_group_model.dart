  import 'dart:convert';

  class CompanyGroupResponse {
    final bool success;
    final List<CompanyGroup> results;
    final Pagination pagination;

    CompanyGroupResponse({
      required this.success,
      required this.results,
      required this.pagination,
    });

    factory CompanyGroupResponse.fromJson(Map<String, dynamic> json) {
      return CompanyGroupResponse(
        success: json['success'] ?? false,
        results: (json['results'] as List<dynamic>?)
            ?.map((e) => CompanyGroup.fromJson(e))
            .toList() ??
            [],
        pagination: Pagination.fromJson(json['pagination'] ?? {}),
      );
    }

    Map<String, dynamic> toJson() => {
      'success': success,
      'results': results.map((e) => e.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }

  class CompanyGroup {
    final String id;
    final String groupName;
    final String brokerId;
    final int swapDays;
    final String status;
    final double minDeposit;
    final double maxDeposit;
    final double commision;
    final DateTime createdAt;
    final DateTime updatedAt;

    CompanyGroup({
      required this.id,
      required this.groupName,
      required this.brokerId,
      required this.swapDays,
      required this.status,
      required this.minDeposit,
      required this.maxDeposit,
      required this.commision,
      required this.createdAt,
      required this.updatedAt,
    });

    factory CompanyGroup.fromJson(Map<String, dynamic> json) {
      return CompanyGroup(
        id: json['_id'] ?? '',
        groupName: json['groupName'] ?? '',
        brokerId: json['broker_id'] ?? '',
        swapDays: json['swapDays'] ?? 0,
        status: json['status'] ?? '',
        minDeposit: (json['minDeposit'] ?? 0).toDouble(),
        maxDeposit: (json['maxDeposit'] ?? 0).toDouble(),
        commision: (json['commision'] ?? 0).toDouble(),
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      );
    }

    Map<String, dynamic> toJson() => {
      '_id': id,
      'groupName': groupName,
      'broker_id': brokerId,
      'swapDays': swapDays,
      'status': status,
      'minDeposit': minDeposit,
      'maxDeposit': maxDeposit,
      'commision': commision,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
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
        pageNumber: json['pageNumber'] ?? 0,
        totalPages: json['totalPages'] ?? 0,
        pageSize: json['pageSize'] ?? 0,
        next: json['next'] ?? false,
        previous: json['previous'] ?? false,
      );
    }

    Map<String, dynamic> toJson() => {
      'total': total,
      'pageNumber': pageNumber,
      'totalPages': totalPages,
      'pageSize': pageSize,
      'next': next,
      'previous': previous,
    };
  }
