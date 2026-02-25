class UserProfile {
  final bool? success;
  final Profile? profile;

  UserProfile({
    this.success,
    this.profile,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      success: json['success'],
      profile:
          json['profile'] == null ? null : Profile.fromJson(json['profile']),
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'profile': profile?.toJson(),
      };
}

class Profile {
  final DocumentType? documentType;
  final Bank? bank;
  final UpiDetails? upiDetails;

  final String? id;
  final String? fullName;
  final String? accountId;
  final String? email;
  final dynamic referedBy;
  final String? referedCode;
  final String? currency;
  final bool? isVerified;
  final String? accountStatus;
  final String? brokerId;
  final dynamic kycApprovedBy;
  final String? kycStatus;
  final String? country;
  final String? city;
  final DateTime? loginAt;
  final String? activeTradeAccount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;
  final bool? verificationStatus;
  final String? navigatorPage;

  Profile({
    this.documentType,
    this.bank,
    this.upiDetails,
    this.id,
    this.fullName,
    this.accountId,
    this.email,
    this.referedBy,
    this.referedCode,
    this.currency,
    this.isVerified,
    this.accountStatus,
    this.brokerId,
    this.kycApprovedBy,
    this.kycStatus,
    this.country,
    this.city,
    this.loginAt,
    this.activeTradeAccount,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.verificationStatus,
    this.navigatorPage,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      documentType: json['documentType'] == null
          ? null
          : DocumentType.fromJson(json['documentType']),
      bank: json['bank'] == null ? null : Bank.fromJson(json['bank']),
      upiDetails: json['upi_details'] == null
          ? null
          : UpiDetails.fromJson(json['upi_details']),
      id: json['_id'],
      fullName: json['fullName'],
      accountId: json['accountId'],
      email: json['email'],
      referedBy: json['refered_by'],
      referedCode: json['refered_code'],
      currency: json['currency'],
      isVerified: json['isVerified'],
      accountStatus: json['account_status'],
      brokerId: json['broker_id'],
      kycApprovedBy: json['kycApprovedBy'],
      kycStatus: json['kycStatus'],
      country: json['country'],
      city: json['city'],
      loginAt: DateTime.tryParse(json['loginAt'] ?? ''),
      activeTradeAccount: json['activeTradeAccount'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? ''),
      v: json['__v'],
      verificationStatus: json['verification_status'],
      navigatorPage: json['navigatorPage'],
    );
  }

  Map<String, dynamic> toJson() => {
        'documentType': documentType?.toJson(),
        'bank': bank?.toJson(),
        'upi_details': upiDetails?.toJson(),
        '_id': id,
        'fullName': fullName,
        'accountId': accountId,
        'email': email,
        'refered_by': referedBy,
        'refered_code': referedCode,
        'currency': currency,
        'isVerified': isVerified,
        'account_status': accountStatus,
        'broker_id': brokerId,
        'kycApprovedBy': kycApprovedBy,
        'kycStatus': kycStatus,
        'country': country,
        'city': city,
        'loginAt': loginAt?.toIso8601String(),
        'activeTradeAccount': activeTradeAccount,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        '__v': v,
        'verification_status': verificationStatus,
        'navigatorPage': navigatorPage,
      };
}

class DocumentType {
  final String? status;
  final String? value;
  final String? frontImageUrl;
  final String? backImageUrl;
  final String? submittedAt;
  final String? approvedAt;
  final String? rejectedAt;

  DocumentType({
    this.status,
    this.value,
    this.frontImageUrl,
    this.backImageUrl,
    this.submittedAt,
    this.approvedAt,
    this.rejectedAt,
  });

  factory DocumentType.fromJson(Map<String, dynamic> json) {
    return DocumentType(
      status: json['status'],
      value: json['value'],
      frontImageUrl: json['frontImageUrl'],
      backImageUrl: json['backImageUrl'],
      submittedAt: _stripTime(json['submittedAt']),
      approvedAt: _stripTime(json['approvedAt']),
      rejectedAt: _stripTime(json['rejectedAt']),
    );
  }

  static String? _stripTime(dynamic val) {
    if (val == null) return null;
    final str = val.toString();
    return str.contains(',') ? str.split(',').first.trim() : str;
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'value': value,
        'frontImageUrl': frontImageUrl,
        'backImageUrl': backImageUrl,
        'submittedAt': submittedAt,
        'approvedAt': approvedAt,
        'rejectedAt': rejectedAt,
      };
}

class Bank {
  final String? bankAccountNumber;
  final String? ifscCode;
  final String? bankName;

  Bank({
    this.bankAccountNumber,
    this.ifscCode,
    this.bankName,
  });

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      bankAccountNumber: json['bankAccountNumber'],
      ifscCode: json['ifscCode'],
      bankName: json['bankName'],
    );
  }

  Map<String, dynamic> toJson() => {
        'bankAccountNumber': bankAccountNumber,
        'ifscCode': ifscCode,
        'bankName': bankName,
      };
}

class UpiDetails {
  final String? upiId;
  final String? providerName;

  UpiDetails({
    this.upiId,
    this.providerName,
  });

  factory UpiDetails.fromJson(Map<String, dynamic> json) {
    return UpiDetails(
      upiId: json['upi_id'],
      providerName: json['provider_name'],
    );
  }

  Map<String, dynamic> toJson() => {
        'upi_id': upiId,
        'provider_name': providerName,
      };
}

/*
class UserProfile {
  UserProfile({
    required this.success,
    required this.profile,
  });

  final bool? success;
  final Profile? profile;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      success: json["success"],
      profile:
          json["profile"] == null ? null : Profile.fromJson(json["profile"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "success": success,
        "profile": profile?.toJson(),
      };

  @override
  String toString() {
    return "$success, $profile, ";
  }
}

class Profile {
  Profile({
    required this.documentType,
    required this.bank,
    required this.id,
    required this.fullName,
    required this.accountId,
    required this.email,
    required this.referedBy,
    required this.referedCode,
    required this.currency,
    required this.isVerified,
    required this.accountStatus,
    required this.kycApprovedBy,
    required this.kycStatus,
    required this.loginAt,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.verificationStatus,
    required this.navigatorPage,
    required this.brokerId,
    required this.country,
    required this.city,
    required this.activeTradeAccount,
  });

  final DocumentType? documentType;
  final Bank? bank;
  final String? id;
  final String? fullName;
  final String? accountId;
  final String? email;
  final dynamic referedBy;
  final String? referedCode;
  final String? currency;
  final bool? isVerified;
  final String? accountStatus;
  final dynamic kycApprovedBy;
  final String? kycStatus;
  final DateTime? loginAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;
  final bool? verificationStatus;
  final String? navigatorPage;

  // 🔥 Newly added
  final String? brokerId;
  final String? country;
  final String? city;
  final String? activeTradeAccount;

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      documentType: json["documentType"] == null
          ? null
          : DocumentType.fromJson(json["documentType"]),
      bank: json["bank"] == null ? null : Bank.fromJson(json["bank"]),
      id: json["_id"],
      fullName: json["fullName"],
      accountId: json["accountId"],
      email: json["email"],
      referedBy: json["refered_by"],
      referedCode: json["refered_code"],
      currency: json["currency"],
      isVerified: json["isVerified"],
      accountStatus: json["account_status"],
      kycApprovedBy: json["kycApprovedBy"],
      kycStatus: json["kycStatus"],
      loginAt: DateTime.tryParse(json["loginAt"] ?? ""),
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      v: json["__v"],
      verificationStatus: json["verification_status"],
      navigatorPage: json["navigatorPage"],

      // 🔥 map new fields
      brokerId: json["broker_id"],
      country: json["country"],
      city: json["city"],
      activeTradeAccount: json["activeTradeAccount"],
    );
  }

  Map<String, dynamic> toJson() => {
        "documentType": documentType?.toJson(),
        "bank": bank?.toJson(),
        "_id": id,
        "fullName": fullName,
        "accountId": accountId,
        "email": email,
        "refered_by": referedBy,
        "refered_code": referedCode,
        "currency": currency,
        "isVerified": isVerified,
        "account_status": accountStatus,
        "kycApprovedBy": kycApprovedBy,
        "kycStatus": kycStatus,
        "loginAt": loginAt?.toIso8601String(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "verification_status": verificationStatus,
        "navigatorPage": navigatorPage,

        // 🔥 include new fields
        "broker_id": brokerId,
        "country": country,
        "city": city,
        "activeTradeAccount": activeTradeAccount,
      };

  @override
  String toString() {
    return "$documentType, $bank, $id, $fullName, $accountId, $email, $referedBy, $referedCode, $currency, $isVerified, $accountStatus, $kycApprovedBy, $kycStatus, $loginAt, $createdAt, $updatedAt, $v, $verificationStatus, $navigatorPage, $brokerId, $country, $city, $activeTradeAccount, ";
  }
}

class Bank {
  final String? bankAccountNumber;
  final String? ifscCode;
  final String? bankName;
  final String status;

  Bank({
    this.bankAccountNumber,
    this.ifscCode,
    this.bankName,
    required this.status,
  });

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      bankAccountNumber: json['bankAccountNumber'],
      ifscCode: json['ifscCode'],
      bankName: json['bankName'],
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bankAccountNumber': bankAccountNumber,
      'ifscCode': ifscCode,
      'bankName': bankName,
      'status': status,
    };
  }

  Bank copyWith({
    String? bankAccountNumber,
    String? ifscCode,
    String? bankName,
    String? status,
  }) {
    return Bank(
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      bankName: bankName ?? this.bankName,
      status: status ?? this.status,
    );
  }
}

class DocumentType {
  DocumentType({
    required this.frontImageUrl,
    required this.backImageUrl,
    required this.value,
    required this.status,
    required this.submittedAt,
  });

  final String? frontImageUrl;
  final String? backImageUrl;
  final String? value;
  final String? status;
  final String? submittedAt;

  factory DocumentType.fromJson(Map<String, dynamic> json) {
    return DocumentType(
      frontImageUrl: json["frontImageUrl"],
      backImageUrl: json["backImageUrl"],
      value: json["value"],
      status: json["status"],
      submittedAt: json["submittedAt"],
    );
  }

  Map<String, dynamic> toJson() => {
        "frontImageUrl": frontImageUrl,
        "backImageUrl": backImageUrl,
        "value": value,
        "status": status,
        "submittedAt": submittedAt,
      };

  @override
  String toString() {
    return "$frontImageUrl, $backImageUrl, $value, $status, $submittedAt, ";
  }
}
*/
