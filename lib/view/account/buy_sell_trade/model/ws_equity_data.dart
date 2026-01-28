/*



import 'dart:convert';

class EquitySnapshot {
  final String balance;
  final String equity;
  final String freeMargin;
  final String pnl;
  final String usedMargin;
  final UserAssets userAssets;
  final List<LiveProfit> liveProfit;

  EquitySnapshot({
    required this.balance,
    required this.equity,
    required this.freeMargin,
    required this.pnl,
    required this.usedMargin,
    required this.userAssets,
    required this.liveProfit,
  });

  factory EquitySnapshot.fromJson(Map<String, dynamic> json) {
    return EquitySnapshot(
      balance: _parseString(json['balance']),
      equity: _parseString(json['equity']),
      freeMargin: _parseString(json['freeMargin']),
      pnl: _parseString(json['PNL']),
      usedMargin: _parseString(json['usedMargin']),
      userAssets: UserAssets.fromJson(
        json['userAssets'] is String
            ? jsonDecode(json['userAssets'])
            : json['userAssets'] ?? {},
      ),
      liveProfit: _parseLiveProfitList(json['liveprofit']),
    );
  }


  static String _parseString(dynamic value) {
    return value?.toString() ?? '0.00';
  }

  static List<LiveProfit> _parseLiveProfitList(List<dynamic>? jsonList) {
    return jsonList?.map((e) => LiveProfit.fromJson(e)).toList() ?? [];
  }
}

class UserAssets {
  final String balance;
  final String fund;
  final String credit;

  UserAssets({
    required this.balance,
    required this.fund,
    required this.credit,
  });

  factory UserAssets.fromJson(Map<String, dynamic> json) {
    return UserAssets(
      balance: _parseString(json['balance']),
      fund: _parseString(json['fund']),
      credit: _parseString(json['credit']),
    );
  }

  static String _parseString(dynamic value) {
    return value?.toString() ?? '0.00';
  }
}

class LiveProfit {
  final String id;
  final double profit;

  LiveProfit({required this.id, required this.profit});

  factory LiveProfit.fromJson(Map<String, dynamic> json) {
    return LiveProfit(
      id: json['_id']?.toString() ?? '',
      profit: _parseProfit(json['profit']),
    );
  }

  static double _parseProfit(dynamic value) {
    if (value is num) {
      return value.toDouble();
    } else if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
}
*/

import 'dart:convert';

class EquitySnapshot {
  final String balance;
  final String equity;
  final String freeMargin;
  final String pnl;
  final String usedMargin;
  final UserAssets userAssets;
  final List<LiveProfit> liveProfit;

  EquitySnapshot({
    required this.balance,
    required this.equity,
    required this.freeMargin,
    required this.pnl,
    required this.usedMargin,
    required this.userAssets,
    required this.liveProfit,
  });

  factory EquitySnapshot.fromJson(Map<String, dynamic> json) {
    return EquitySnapshot(
      balance: _parseString(json['balance']),
      equity: _parseString(json['equity']),
      freeMargin: _parseString(json['freeMargin']),
      pnl: _parseString(json['PNL']), // Note: Log uses "PNL" uppercase
      usedMargin: _parseString(json['usedMargin']),
      userAssets: UserAssets.fromJson(
        json['userAssets'] is String
            ? jsonDecode(json['userAssets'])
            : json['userAssets'] ?? {},
      ),
      liveProfit: _parseLiveProfitList(json['liveprofit']),
    );
  }

  static String _parseString(dynamic value) {
    return value?.toString() ?? '0.00';
  }

  static List<LiveProfit> _parseLiveProfitList(List<dynamic>? jsonList) {
    return jsonList?.map((e) => LiveProfit.fromJson(e)).toList() ?? [];
  }
}

class UserAssets {
  final String balance;
  final String fund;
  final String credit;

  UserAssets({
    required this.balance,
    required this.fund,
    required this.credit,
  });

  factory UserAssets.fromJson(Map<String, dynamic> json) {
    return UserAssets(
      balance: _parseString(json['balance']),
      fund: _parseString(json['fund']),
      credit: _parseString(json['credit']),
    );
  }

  static String _parseString(dynamic value) {
    return value?.toString() ?? '0.00';
  }
}

class LiveProfit {
  final String id;
  final double profit;
  final String? symbol;
  final double? price; // Live Current Price
  final double? avg;   // Entry Price
  final double? lot;
  final String? bs;

  LiveProfit({
    required this.id,
    required this.profit,
    this.symbol,
    this.price,
    this.avg,
    this.lot,
    this.bs,
  });

  factory LiveProfit.fromJson(Map<String, dynamic> json) {
    return LiveProfit(
      id: json['trade_id']?.toString() ?? '',
      profit: _parseDouble(json['pnl']), // Log uses "pnl" lowercase here
      symbol: json['symbol']?.toString(),
      price: _parseDouble(json['price']),
      avg: _parseDouble(json['avg']),
      lot: _parseDouble(json['lot']),
      bs: json['bs']?.toString(),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    } else if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
}
