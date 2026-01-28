class CryptoDepositModel {
  final String uuid;
  final String transactionId;
  final String paymentUrl;
  final String status;
  final double amount;
  final String cryptoId;
  final String merchantId;
  final DateTime createdAt;
  final double closingBalance;

  CryptoDepositModel({
    required this.uuid,
    required this.transactionId,
    required this.paymentUrl,
    required this.status,
    required this.amount,
    required this.cryptoId,
    required this.merchantId,
    required this.createdAt,
    required this.closingBalance,
  });

  factory CryptoDepositModel.fromJson(Map<String, dynamic> json) {
    return CryptoDepositModel(
      uuid: json['uuid'] ?? '',
      transactionId: json['transactionId'] ?? '',
      paymentUrl: json['payment_url'] ?? '',
      status: json['status'] ?? '',
      amount: _parseToDouble(json['amount']),
      cryptoId: json['crypto_id'] ?? '',
      merchantId: json['merchant_id'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      closingBalance: _parseToDouble(json['closingBalance']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid, // 👈 added
      'transactionId': transactionId,
      'payment_url': paymentUrl,
      'status': status,
      'amount': amount,
      'crypto_id': cryptoId,
      'merchant_id': merchantId,
      'createdAt': createdAt.toIso8601String(),
      'closingBalance': closingBalance,
    };
  }

  CryptoDepositModel copyWith({
    String? uuid, // 👈 added
    String? transactionId,
    String? paymentUrl,
    String? status,
    double? amount,
    String? cryptoId,
    String? merchantId,
    DateTime? createdAt,
    double? closingBalance,
  }) {
    return CryptoDepositModel(
      uuid: uuid ?? this.uuid, // 👈 added
      transactionId: transactionId ?? this.transactionId,
      paymentUrl: paymentUrl ?? this.paymentUrl,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      cryptoId: cryptoId ?? this.cryptoId,
      merchantId: merchantId ?? this.merchantId,
      createdAt: createdAt ?? this.createdAt,
      closingBalance: closingBalance ?? this.closingBalance,
    );
  }

  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return num.tryParse(value)?.toDouble() ?? 0.0;
    return 0.0;
  }
}
