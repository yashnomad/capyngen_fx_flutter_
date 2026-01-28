  class TradeAccount {
    TradeAccount({
      required this.success,
      required this.count,
      required this.accounts,
      required this.summary,
    });

    final bool? success;
    final int? count;
    final List<Account> accounts;
    final Summary? summary;

    factory TradeAccount.fromJson(Map<String, dynamic> json) {
      return TradeAccount(
        success: json["success"],
        count: json["count"],
        accounts: json["accounts"] == null
            ? []
            : List<Account>.from(
                json["accounts"].map((x) => Account.fromJson(x)),
              ),
        summary:
            json["summary"] == null ? null : Summary.fromJson(json["summary"]),
      );
    }

    Map<String, dynamic> toJson() => {
          "success": success,
          "count": count,
          "accounts": accounts.map((x) => x.toJson()).toList(),
          "summary": summary?.toJson(),
        };
  }

  class Account {
    Account({
      required this.id,
      required this.user,
      required this.accountId,
      required this.accountType,
      required this.balance,
      required this.depositTransactionIds,
      required this.currency,
      required this.leverage,
      required this.group,
      required this.equity,
      required this.book,
      required this.status,
      required this.createdAt,
      required this.updatedAt,
      required this.v,
      required this.email,
      required this.pam,
      required this.mam,
      required this.copy,
    });

    final String? id;
    final String? user;
    final String? accountId;
    final String? accountType;
    final num? balance;
    final List<String> depositTransactionIds;
    final String? currency;
    final int? leverage;
    final Group? group;
    final num? equity;
    final String? book;
    final String? status;
    final DateTime? createdAt;
    final DateTime? updatedAt;
    final int? v;
    final String? email;

    final Strategy? pam;
    final Strategy? mam;
    final Strategy? copy;

    factory Account.fromJson(Map<String, dynamic> json) {
      return Account(
        id: json["_id"],
        user: json["user"],
        accountId: json["accountID"],
        accountType: json["accountType"],
        balance: json["balance"],
        depositTransactionIds: (json["deposit_transaction_ids"] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        currency: json["currency"],
        leverage: json["leverage"] is int
            ? json["leverage"]
            : int.tryParse(json["leverage"]?.toString() ?? ""),
        group: json["group"] == null ? null : Group.fromJson(json["group"]),
        equity: json["equity"],
        book: json["book"],
        status: json["status"],
        createdAt: _parseDate(json["createdAt"]),
        updatedAt: _parseDate(json["updatedAt"]),
        v: json["__v"],
        email: json["email"],
        pam: json["pam"] == null ? null : Strategy.fromJson(json["pam"]),
        mam: json["mam"] == null ? null : Strategy.fromJson(json["mam"]),
        copy: json["copy"] == null ? null : Strategy.fromJson(json["copy"]),
      );
    }

    Map<String, dynamic> toJson() => {
          "_id": id,
          "user": user,
          "accountID": accountId,
          "accountType": accountType,
          "balance": balance,
          "deposit_transaction_ids": depositTransactionIds,
          "currency": currency,
          "leverage": leverage,
          "group": group?.toJson(),
          "equity": equity,
          "book": book,
          "status": status,
          "createdAt": createdAt?.toIso8601String(),
          "updatedAt": updatedAt?.toIso8601String(),
          "__v": v,
          "email": email,
          "pam": pam?.toJson(),
          "mam": mam?.toJson(),
          "copy": copy?.toJson(),
        };
  }

  class Strategy {
    Strategy({
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
      required this.v,
    });

    final String? id;
    final String? tradeAccount;
    final String? brokerId;
    final int? followers;
    final String? copyMode;
    final String? strategyName;
    final String? description;
    final bool? isActive;
    final DateTime? createdAt;
    final DateTime? updatedAt;
    final int? v;

    factory Strategy.fromJson(Map<String, dynamic> json) {
      return Strategy(
        id: json["_id"],
        tradeAccount: json["tradeAccount"],
        brokerId: json["broker_id"],
        followers: json["followers"],
        copyMode: json["copyMode"],
        strategyName: json["strategyName"],
        description: json["description"],
        isActive: json["isActive"],
        createdAt: _parseDate(json["createdAt"]),
        updatedAt: _parseDate(json["updatedAt"]),
        v: json["__v"],
      );
    }

    Map<String, dynamic> toJson() => {
          "_id": id,
          "tradeAccount": tradeAccount,
          "broker_id": brokerId,
          "followers": followers,
          "copyMode": copyMode,
          "strategyName": strategyName,
          "description": description,
          "isActive": isActive,
          "createdAt": createdAt?.toIso8601String(),
          "updatedAt": updatedAt?.toIso8601String(),
          "__v": v,
        };
  }

  class Group {
    Group({
      required this.id,
      required this.groupName,
      required this.brokerId,
      required this.swapDays,
      required this.status,
      required this.minDeposit,
      required this.maxDeposit,
      required this.commission,
      required this.v,
      required this.createdAt,
      required this.updatedAt,
    });

    final String? id;
    final String? groupName;
    final String? brokerId;
    final int? swapDays;
    final String? status;
    final num? minDeposit;
    final num? maxDeposit;
    final num? commission;
    final int? v;
    final DateTime? createdAt;
    final DateTime? updatedAt;

    factory Group.fromJson(Map<String, dynamic> json) {
      return Group(
        id: json["_id"],
        groupName: json["groupName"],
        brokerId: json["broker_id"],
        swapDays: json["swapDays"],
        status: json["status"],
        minDeposit: json["minDeposit"],
        maxDeposit: json["maxDeposit"],
        commission: json["commision"],
        v: json["__v"],
        createdAt: _parseDate(json["createdAt"]),
        updatedAt: _parseDate(json["updatedAt"]),
      );
    }

    Map<String, dynamic> toJson() => {
          "_id": id,
          "groupName": groupName,
          "broker_id": brokerId,
          "swapDays": swapDays,
          "status": status,
          "minDeposit": minDeposit,
          "maxDeposit": maxDeposit,
          "commision": commission,
          "__v": v,
          "createdAt": createdAt?.toIso8601String(),
          "updatedAt": updatedAt?.toIso8601String(),
        };
  }

  class Summary {
    Summary({
      required this.totalAccounts,
      required this.liveAccounts,
      required this.demoAccounts,
      required this.activeAccounts,
      required this.totalBalance,
    });

    final int? totalAccounts;
    final int? liveAccounts;
    final int? demoAccounts;
    final int? activeAccounts;
    final num? totalBalance;

    factory Summary.fromJson(Map<String, dynamic> json) {
      return Summary(
        totalAccounts: json["totalAccounts"],
        liveAccounts: json["liveAccounts"],
        demoAccounts: json["demoAccounts"],
        activeAccounts: json["activeAccounts"],
        totalBalance: json["totalBalance"],
      );
    }

    Map<String, dynamic> toJson() => {
          "totalAccounts": totalAccounts,
          "liveAccounts": liveAccounts,
          "demoAccounts": demoAccounts,
          "activeAccounts": activeAccounts,
          "totalBalance": totalBalance,
        };
  }

  extension AccountX on Account {
    bool get isLiveAccount =>
        accountType?.toLowerCase().contains('live') ?? false;

    bool get isDemoAccount =>
        accountType?.toLowerCase().contains('demo') ?? false;

    bool get hasAnyStrategy => pam != null || mam != null || copy != null;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    if (value is String) {
      final iso = DateTime.tryParse(value);
      if (iso != null) return iso;

      try {
        final parts = value.split(',');
        final date = parts[0].split('/');
        final time = parts[1].trim();
        final formatted = "${date[2]}-${date[1]}-${date[0]} $time";
        return DateTime.tryParse(formatted);
      } catch (_) {}
    }
    return null;
  }

/*
class TradeAccount {
  TradeAccount({
    required this.success,
    required this.count,
    required this.accounts,
    required this.summary,
  });

  final bool? success;
  final int? count;
  final List<Account> accounts;
  final Summary? summary;

  factory TradeAccount.fromJson(Map<String, dynamic> json){
    return TradeAccount(
      success: json["success"],
      count: json["count"],
      accounts: json["accounts"] == null
          ? []
          : List<Account>.from(
          json["accounts"]!.map((x) => Account.fromJson(x))),
      summary:
      json["summary"] == null ? null : Summary.fromJson(json["summary"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "count": count,
    "accounts": accounts.map((x) => x.toJson()).toList(),
    "summary": summary?.toJson(),
  };

  @override
  String toString(){
    return "$success, $count, $accounts, $summary";
  }
}

class Account {
  Account({
    required this.id,
    required this.user,
    required this.accountId,
    required this.accountType,
    required this.balance,
    required this.currency,
    required this.leverage,
    required this.group,
    required this.equity,
    required this.book,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  final String? id;
  final String? user;
  final String? accountId;
  final String? accountType;
  final num? balance;
  final String? currency;
  final String? leverage;
  final Group? group;

  final num? equity; // ✅ FIXED (was int?)

  final String? book;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json["_id"],
      user: json["user"],
      accountId: json["accountID"],
      accountType: json["accountType"],
      balance: json["balance"],
      currency: json["currency"],
      leverage: json["leverage"]?.toString(),
      group:
      json["group"] == null ? null : Group.fromJson(json["group"]),
      equity: json["equity"], // ✅ accepts int & double now
      book: json["book"],
      status: json["status"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      v: json["__v"],
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "user": user,
    "accountID": accountId,
    "accountType": accountType,
    "balance": balance,
    "currency": currency,
    "leverage": leverage,
    "group": group?.toJson(),
    "equity": equity,
    "book": book,
    "status": status,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };

  @override
  String toString() {
    return "$id, $user, $accountId, $accountType, $balance, $currency, $leverage, $group, $equity, $book, $status, $createdAt, $updatedAt, $v";
  }
}

class Summary {
  Summary({
    required this.totalAccounts,
    required this.liveAccounts,
    required this.demoAccounts,
    required this.activeAccounts,
    required this.totalBalance,
  });

  final int? totalAccounts;
  final int? liveAccounts;
  final int? demoAccounts;
  final int? activeAccounts;
  final num? totalBalance;

  factory Summary.fromJson(Map<String, dynamic> json){
    return Summary(
      totalAccounts: json["totalAccounts"],
      liveAccounts: json["liveAccounts"],
      demoAccounts: json["demoAccounts"],
      activeAccounts: json["activeAccounts"],
      totalBalance: json["totalBalance"],
    );
  }

  Map<String, dynamic> toJson() => {
    "totalAccounts": totalAccounts,
    "liveAccounts": liveAccounts,
    "demoAccounts": demoAccounts,
    "activeAccounts": activeAccounts,
    "totalBalance": totalBalance,
  };

  @override
  String toString(){
    return "$totalAccounts, $liveAccounts, $demoAccounts, $activeAccounts, $totalBalance";
  }
}

class Group {
  Group({
    required this.id,
    required this.groupName,
    required this.swapDays,
    required this.status,
    required this.v,
    required this.createdAt,
    required this.updatedAt,
  });

  final String? id;
  final String? groupName;
  final int? swapDays;
  final String? status;
  final int? v;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json["_id"],
      groupName: json["groupName"],
      swapDays: json["swapDays"],
      status: json["status"],
      v: json["__v"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "groupName": groupName,
    "swapDays": swapDays,
    "status": status,
    "__v": v,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };

  @override
  String toString() {
    return "$id, $groupName, $swapDays, $status, $v, $createdAt, $updatedAt";
  }
}

extension AccountX on Account {
  bool get isLiveAccount =>
      (accountType?.toLowerCase().contains('live') ?? false);

  bool get isDemoAccount =>
      (accountType?.toLowerCase().contains('demo') ?? false);
}

*/
