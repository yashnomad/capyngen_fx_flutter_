class WithdrawalDetails {
  final String bankName;
  final String bankAccountNumber;
  final String ifscCode;
  final String upiId;
  final String providerName;

  WithdrawalDetails({
    this.bankName = '',
    this.bankAccountNumber = '',
    this.ifscCode = '',
    this.upiId = '',
    this.providerName = '',
  });

  WithdrawalDetails copyWith({
    String? bankName,
    String? bankAccountNumber,
    String? ifscCode,
    String? upiId,
    String? providerName,
  }) {
    return WithdrawalDetails(
      bankName: bankName ?? this.bankName,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      upiId: upiId ?? this.upiId,
      providerName: providerName ?? this.providerName,
    );
  }

  // Converts data to the Flat JSON format your API expects
  Map<String, dynamic> toApiJson() {
    return {
      "bankName": bankName,
      "bankAccountNumber": bankAccountNumber,
      "ifscCode": ifscCode,
      "upi_id": upiId,
      "provider_name": providerName,
    };
  }
}