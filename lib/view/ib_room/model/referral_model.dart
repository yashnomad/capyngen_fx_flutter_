class ReferralModel {
  final String id;
  final String userId;
  final String fullName;
  final String name;
  final String referCode;
  final int level;
  final String referredBy;
  final double totalCommissionAmount;
  final double commission;
  final String country;
  final String city;
  final String userAccountId;
  final String email;
  final DateTime createdAt;
  final String accountStatus;
  final String kycStatus;
  final String tradeAccountId;
  final String accountId;
  final String accountNumber;
  final String accountType;
  final String groupName;
  final double balance;
  final double equity;
  final String currency;
  final String status;
  final double tradingVolume;
  final double volume;

  ReferralModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.name,
    required this.referCode,
    required this.level,
    required this.referredBy,
    required this.totalCommissionAmount,
    required this.commission,
    required this.country,
    required this.city,
    required this.userAccountId,
    required this.email,
    required this.createdAt,
    required this.accountStatus,
    required this.kycStatus,
    required this.tradeAccountId,
    required this.accountId,
    required this.accountNumber,
    required this.accountType,
    required this.groupName,
    required this.balance,
    required this.equity,
    required this.currency,
    required this.status,
    required this.tradingVolume,
    required this.volume,
  });

  factory ReferralModel.fromJson(Map<String, dynamic> json) {
    return ReferralModel(
      id: json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      fullName: json['fullName'] ?? '',
      name: json['name'] ?? '',
      referCode: json['referCode'] ?? '',
      level: json['level'] is int
          ? json['level']
          : int.tryParse('${json['level']}') ?? 0,
      referredBy: json['referredBy'] ?? '',
      totalCommissionAmount: (json['totalCommissionAmount'] ?? 0).toDouble(),
      commission: (json['commission'] ?? 0).toDouble(),
      country: json['country'] ?? 'Not Specified',
      city: json['city'] ?? 'Not Specified',
      userAccountId: json['userAccountId']?.toString() ?? '',
      email: json['email'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      accountStatus: json['account_status'] ?? '',
      kycStatus: json['kycStatus'] ?? '',
      tradeAccountId: json['tradeAccountId'] ?? 'N/A',
      accountId: json['accountId'] ?? 'N/A',
      accountNumber: json['accountNumber'] ?? 'N/A',
      accountType: json['accountType'] ?? 'N/A',
      groupName: json['groupName'] ?? '',
      balance: (json['balance'] ?? 0).toDouble(),
      equity: (json['equity'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      status: json['status'] ?? 'N/A',
      tradingVolume: (json['tradingVolume'] ?? 0).toDouble(),
      volume: (json['volume'] ?? 0).toDouble(),
    );
  }
}

class ReferralSummary {
  final int totalEntries;
  final int uniqueUsers;
  final int totalTradeAccounts;
  final int usersWithoutTradeAccounts;

  ReferralSummary({
    required this.totalEntries,
    required this.uniqueUsers,
    required this.totalTradeAccounts,
    required this.usersWithoutTradeAccounts,
  });

  factory ReferralSummary.fromJson(Map<String, dynamic> json) {
    return ReferralSummary(
      totalEntries: json['totalEntries'] ?? 0,
      uniqueUsers: json['uniqueUsers'] ?? 0,
      totalTradeAccounts: json['totalTradeAccounts'] ?? 0,
      usersWithoutTradeAccounts: json['usersWithoutTradeAccounts'] ?? 0,
    );
  }
}

class ReferralResponse {
  final bool success;
  final List<ReferralModel> data;
  final String message;
  final ReferralSummary summary;

  ReferralResponse({
    required this.success,
    required this.data,
    required this.message,
    required this.summary,
  });

  factory ReferralResponse.fromJson(Map<String, dynamic> json) {
    return ReferralResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => ReferralModel.fromJson(e))
          .toList(),
      message: json['message'] ?? '',
      summary: ReferralSummary.fromJson(json['summary'] ?? {}),
    );
  }
}
