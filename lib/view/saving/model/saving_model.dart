class SavingPackage {
  final String id;
  final String name;
  final num amount;
  final String roiType;
  final num roiPercentage;
  final num lockInPeriod;
  final bool autoProfitGeneration;

  SavingPackage({
    required this.id,
    required this.name,
    required this.amount,
    required this.roiType,
    required this.roiPercentage,
    required this.lockInPeriod,
    required this.autoProfitGeneration,
  });

  factory SavingPackage.fromJson(Map<String, dynamic> json) {
    return SavingPackage(
      id: json["_id"] ?? "",
      name: json["name"] ?? "",
      amount: json["amount"] ?? 0,
      roiType: json["roiType"] ?? "",
      roiPercentage: json["roiPercentage"] ?? 0,
      lockInPeriod: json["lockInPeriod"] ?? 0,
      autoProfitGeneration: json["autoProfitGeneration"] ?? false,
    );
  }
}
