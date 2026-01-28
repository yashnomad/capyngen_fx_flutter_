class Register {
  Register({
    required this.message,
    required this.user,
    required this.navigatorPage,
  });

  final String? message;
  final User? user;
  final String? navigatorPage;

  factory Register.fromJson(Map<String, dynamic> json){
    return Register(
      message: json["message"],
      user: json["user"] == null ? null : User.fromJson(json["user"]),
      navigatorPage: json["navigatorPage"],
    );
  }

  Map<String, dynamic> toJson() => {
    "message": message,
    "user": user?.toJson(),
    "navigatorPage": navigatorPage,
  };

  @override
  String toString(){
    return "$message, $user, $navigatorPage, ";
  }
}

class User {
  User({
    required this.fullName,
    required this.accountId,
    required this.email,
    required this.password,
    required this.referedBy,
    required this.referedCode,
    required this.currency,
    required this.isVerified,
    required this.accountStatus,
    required this.kycApprovedBy,
    required this.kycStatus,
    required this.documentType,
    required this.bank,
    required this.loginAt,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  final String? fullName;
  final String? accountId;
  final String? email;
  final String? password;
  final dynamic referedBy;
  final String? referedCode;
  final String? currency;
  final bool? isVerified;
  final String? accountStatus;
  final dynamic kycApprovedBy;
  final String? kycStatus;
  final DocumentType? documentType;
  final Bank? bank;
  final dynamic loginAt;
  final String? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  factory User.fromJson(Map<String, dynamic> json){
    return User(
      fullName: json["fullName"],
      accountId: json["accountId"],
      email: json["email"],
      password: json["password"],
      referedBy: json["refered_by"],
      referedCode: json["refered_code"],
      currency: json["currency"],
      isVerified: json["isVerified"],
      accountStatus: json["account_status"],
      kycApprovedBy: json["kycApprovedBy"],
      kycStatus: json["kycStatus"],
      documentType: json["documentType"] == null ? null : DocumentType.fromJson(json["documentType"]),
      bank: json["bank"] == null ? null : Bank.fromJson(json["bank"]),
      loginAt: json["loginAt"],
      id: json["_id"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      v: json["__v"],
    );
  }

  Map<String, dynamic> toJson() => {
    "fullName": fullName,
    "accountId": accountId,
    "email": email,
    "password": password,
    "refered_by": referedBy,
    "refered_code": referedCode,
    "currency": currency,
    "isVerified": isVerified,
    "account_status": accountStatus,
    "kycApprovedBy": kycApprovedBy,
    "kycStatus": kycStatus,
    "documentType": documentType?.toJson(),
    "bank": bank?.toJson(),
    "loginAt": loginAt,
    "_id": id,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };

  @override
  String toString(){
    return "$fullName, $accountId, $email, $password, $referedBy, $referedCode, $currency, $isVerified, $accountStatus, $kycApprovedBy, $kycStatus, $documentType, $bank, $loginAt, $id, $createdAt, $updatedAt, $v, ";
  }
}

class Bank {
  Bank({
    required this.bankAccountNumber,
    required this.ifscCode,
    required this.status,
  });

  final dynamic bankAccountNumber;
  final dynamic ifscCode;
  final String? status;

  factory Bank.fromJson(Map<String, dynamic> json){
    return Bank(
      bankAccountNumber: json["bankAccountNumber"],
      ifscCode: json["ifscCode"],
      status: json["status"],
    );
  }

  Map<String, dynamic> toJson() => {
    "bankAccountNumber": bankAccountNumber,
    "ifscCode": ifscCode,
    "status": status,
  };

  @override
  String toString(){
    return "$bankAccountNumber, $ifscCode, $status, ";
  }
}

class DocumentType {
  DocumentType({
    required this.status,
  });

  final String? status;

  factory DocumentType.fromJson(Map<String, dynamic> json){
    return DocumentType(
      status: json["status"],
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
  };

  @override
  String toString(){
    return "$status, ";
  }
}
