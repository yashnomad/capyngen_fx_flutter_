import '../../account/withdraw_deposit/model/bank_model.dart';

class PackageModel {
  final bool success;
  final List<PackageResult> results;
  final Pagination? pagination;

  PackageModel({
    required this.success,
    required this.results,
    this.pagination,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      success: json["success"] ?? false,
      results: json["results"] == null
          ? []
          : List<PackageResult>.from(
          json["results"].map((x) => PackageResult.fromJson(x))),
      pagination: json["pagination"] == null
          ? null
          : Pagination.fromJson(json["pagination"]),
    );
  }
}

class PackageResult {
  final String id;
  final String name;
  final num amount;
  final String roiType;
  final num roiPercentage;
  final bool autoProfitGeneration;
  final num lockInPeriod;

  PackageResult({
    required this.id,
    required this.name,
    required this.amount,
    required this.roiType,
    required this.roiPercentage,
    required this.autoProfitGeneration,
    required this.lockInPeriod,
  });

  factory PackageResult.fromJson(Map<String, dynamic> json) {
    return PackageResult(
      id: json["_id"] ?? "",
      name: json["name"] ?? "",
      amount: json["amount"] ?? 0,
      roiType: json["roiType"] ?? "",
      roiPercentage: json["roiPercentage"] ?? 0,
      autoProfitGeneration: json["autoProfitGeneration"] ?? false,
      lockInPeriod: json["lockInPeriod"] ?? 0,
    );
  }
}
