class Bank {
  final String bankAccountNumber;
  final String ifscCode;
  final String bankName;

  Bank({
    required this.bankAccountNumber,
    required this.ifscCode,
    required this.bankName,
  });

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      bankAccountNumber: json['bankAccountNumber'],
      ifscCode: json['ifscCode'],
      bankName: json['bankName'],
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
