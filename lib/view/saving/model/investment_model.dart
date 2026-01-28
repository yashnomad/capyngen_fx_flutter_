
class UserInvestment {
  final String id;
  final num investedAmount;
  final num roiPercentage;
  final num totalProfitEarned;
  final String investmentStatus;
  final num lockInPeriod;

  UserInvestment({
    required this.id,
    required this.investedAmount,
    required this.roiPercentage,
    required this.totalProfitEarned,
    required this.investmentStatus,
    required this.lockInPeriod,
  });

  factory UserInvestment.fromJson(Map<String, dynamic> json) {
    return UserInvestment(
      id: json["_id"] ?? "",
      investedAmount: json["investedAmount"] ?? 0,
      roiPercentage: json["roiPercentage"] ?? 0,
      totalProfitEarned: json["totalProfitEarned"] ?? 0,
      investmentStatus: json["investmentStatus"] ?? "",
      lockInPeriod: json["lockInPeriod"] ?? 0,
    );
  }
}