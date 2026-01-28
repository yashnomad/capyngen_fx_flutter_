class BankAccountModel {
  BankAccountModel({
    required this.success,
    required this.results,
    required this.pagination,
  });

  final bool success;
  final List<Result> results;
  final Pagination? pagination;

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    return BankAccountModel(
      success: json["success"] ?? false,
      results: json["results"] == null
          ? []
          : List<Result>.from(
          json["results"].map((x) => Result.fromJson(x))),
      pagination: json["pagination"] == null
          ? null
          : Pagination.fromJson(json["pagination"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "results": results.map((x) => x.toJson()).toList(),
    "pagination": pagination?.toJson(),
  };
}

class Pagination {
  Pagination({
    required this.total,
    required this.pageNumber,
    required this.totalPages,
    required this.pageSize,
    required this.next,
    required this.previous,
  });

  final num total;
  final num pageNumber;
  final num totalPages;
  final num pageSize;
  final bool next;
  final bool previous;

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json["total"] ?? 0,
      pageNumber: json["pageNumber"] ?? 0,
      totalPages: json["totalPages"] ?? 0,
      pageSize: json["pageSize"] ?? 0,
      next: json["next"] ?? false,
      previous: json["previous"] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    "total": total,
    "pageNumber": pageNumber,
    "totalPages": totalPages,
    "pageSize": pageSize,
    "next": next,
    "previous": previous,
  };
}

class Result {
  Result({
    required this.id,
    required this.brokerId,
    required this.paymentMethod,
    required this.bankDetails,
    required this.upiDetails,
    required this.status,
    required this.minDeposit,
    required this.maxDeposit,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  final String id;
  final String brokerId;
  final String paymentMethod;
  final BankDetails? bankDetails;
  final UpiDetails? upiDetails;
  final String status;
  final num minDeposit;
  final num maxDeposit;
  final String createdAt;
  final String updatedAt;
  final num v;

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      id: json["_id"] ?? "",
      brokerId: json["broker_id"] ?? "",
      paymentMethod: json["paymentMethod"] ?? "",
      bankDetails: json["bank_details"] == null
          ? null
          : BankDetails.fromJson(json["bank_details"]),
      upiDetails: json["upi_details"] == null
          ? null
          : UpiDetails.fromJson(json["upi_details"]),
      status: json["status"] ?? "",
      minDeposit: json["minDeposit"] ?? 0,
      maxDeposit: json["maxDeposit"] ?? 0,
      createdAt: json["createdAt"] ?? "",
      updatedAt: json["updatedAt"] ?? "",
      v: json["__v"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "broker_id": brokerId,
    "paymentMethod": paymentMethod,
    "bank_details": bankDetails?.toJson(),
    "upi_details": upiDetails?.toJson(),
    "status": status,
    "minDeposit": minDeposit,
    "maxDeposit": maxDeposit,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "__v": v,
  };
}

class BankDetails {
  BankDetails({
    this.accountNumber,
    this.ifscCode,
    this.bankName,
    this.accountHolder,
  });

  final String? accountNumber;
  final String? ifscCode;
  final String? bankName;
  final String? accountHolder;

  factory BankDetails.fromJson(Map<String, dynamic> json) {
    return BankDetails(
      accountNumber: json["account_number"],
      ifscCode: json["ifsc_code"],
      bankName: json["bank_name"],
      accountHolder: json["account_holder"],
    );
  }

  Map<String, dynamic> toJson() => {
    "account_number": accountNumber,
    "ifsc_code": ifscCode,
    "bank_name": bankName,
    "account_holder": accountHolder,
  };
}

class UpiDetails {
  UpiDetails({
    this.upiId,
    this.providerName,
    this.barcodeUrl,
  });

  final String? upiId;
  final String? providerName;
  final String? barcodeUrl;

  factory UpiDetails.fromJson(Map<String, dynamic> json) {
    return UpiDetails(
      upiId: json["upi_id"],
      providerName: json["provider_name"],
      barcodeUrl: json["barcodeUrl"],
    );
  }

  Map<String, dynamic> toJson() => {
    "upi_id": upiId,
    "provider_name": providerName,
    "barcodeUrl": barcodeUrl,
  };
}
