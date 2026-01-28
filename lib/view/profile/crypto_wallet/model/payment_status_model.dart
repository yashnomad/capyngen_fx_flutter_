class PaymentStatusModel {
  final String uuid;
  final String status;
  final double amount;
  final String currency;
  final String depositStatus;

  PaymentStatusModel({
    required this.uuid,
    required this.status,
    required this.amount,
    required this.currency,
    required this.depositStatus,
  });

  factory PaymentStatusModel.fromJson(Map<String, dynamic> json) {
    return PaymentStatusModel(
      uuid: json['uuid'] ?? '',
      status: json['status'] ?? '',
      amount: _parseToDouble(json['amount']),
      currency: json['currency'] ?? '',
      depositStatus: json['deposit_status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'status': status,
      'amount': amount,
      'currency': currency,
      'deposit_status': depositStatus,
    };
  }

  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return num.tryParse(value)?.toDouble() ?? 0.0;
    return 0.0;
  }
}
