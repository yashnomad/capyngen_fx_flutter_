class User {
  final String id;
  final String fullName;
  final String accountId;
  final String email;
  final String password;
  final String? referedBy;
  final String referedCode;
  final String currency;
  final bool isVerified;
  final String accountStatus;
  final String? kycApprovedBy;
  final String kycStatus;
  final DateTime? loginAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final DocumentType documentType;
  final Bank bank;

  User({
    required this.id,
    required this.fullName,
    required this.accountId,
    required this.email,
    required this.password,
    this.referedBy,
    required this.referedCode,
    required this.currency,
    required this.isVerified,
    required this.accountStatus,
    this.kycApprovedBy,
    required this.kycStatus,
    this.loginAt,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    required this.documentType,
    required this.bank,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      accountId: json['accountId'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      referedBy: json['refered_by'],
      referedCode: json['refered_code'] ?? '',
      currency: json['currency'] ?? 'USD',
      isVerified: json['isVerified'] ?? false,
      accountStatus: json['account_status'] ?? '',
      kycApprovedBy: json['kycApprovedBy'],
      kycStatus: json['kycStatus'] ?? '',
      loginAt: json['loginAt'] != null ? DateTime.parse(json['loginAt']) : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      version: json['__v'] ?? 0,
      documentType: DocumentType.fromJson(json['documentType'] ?? {}),
      bank: Bank.fromJson(json['bank'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'accountId': accountId,
      'email': email,
      'password': password,
      'refered_by': referedBy,
      'refered_code': referedCode,
      'currency': currency,
      'isVerified': isVerified,
      'account_status': accountStatus,
      'kycApprovedBy': kycApprovedBy,
      'kycStatus': kycStatus,
      'loginAt': loginAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
      'documentType': documentType.toJson(),
      'bank': bank.toJson(),
    };
  }

  User copyWith({
    String? id,
    String? fullName,
    String? accountId,
    String? email,
    String? password,
    String? referedBy,
    String? referedCode,
    String? currency,
    bool? isVerified,
    String? accountStatus,
    String? kycApprovedBy,
    String? kycStatus,
    DateTime? loginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    DocumentType? documentType,
    Bank? bank,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      accountId: accountId ?? this.accountId,
      email: email ?? this.email,
      password: password ?? this.password,
      referedBy: referedBy ?? this.referedBy,
      referedCode: referedCode ?? this.referedCode,
      currency: currency ?? this.currency,
      isVerified: isVerified ?? this.isVerified,
      accountStatus: accountStatus ?? this.accountStatus,
      kycApprovedBy: kycApprovedBy ?? this.kycApprovedBy,
      kycStatus: kycStatus ?? this.kycStatus,
      loginAt: loginAt ?? this.loginAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      documentType: documentType ?? this.documentType,
      bank: bank ?? this.bank,
    );
  }
}

class DocumentType {
  final String status;
  final String? backImageUrl;
  final String? frontImageUrl;
  final DateTime? submittedAt;
  final String? value;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;

  DocumentType({
    required this.status,
    this.backImageUrl,
    this.frontImageUrl,
    this.submittedAt,
    this.value,
    this.approvedAt,
    this.rejectedAt,
  });

  factory DocumentType.fromJson(Map<String, dynamic> json) {
    return DocumentType(
      status: json['status'] ?? 'pending',
      backImageUrl: json['backImageUrl'],
      frontImageUrl: json['frontImageUrl'],
      submittedAt: json['submittedAt'] != null ? DateTime.parse(json['submittedAt']) : null,
      value: json['value'],
      approvedAt: json['approvedAt'] != null ? DateTime.parse(json['approvedAt']) : null,
      rejectedAt: json['rejectedAt'] != null ? DateTime.parse(json['rejectedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'backImageUrl': backImageUrl,
      'frontImageUrl': frontImageUrl,
      'submittedAt': submittedAt?.toIso8601String(),
      'value': value,
      'approvedAt': approvedAt?.toIso8601String(),
      'rejectedAt': rejectedAt?.toIso8601String(),
    };
  }

  DocumentType copyWith({
    String? status,
    String? backImageUrl,
    String? frontImageUrl,
    DateTime? submittedAt,
    String? value,
    DateTime? approvedAt,
    DateTime? rejectedAt,
  }) {
    return DocumentType(
      status: status ?? this.status,
      backImageUrl: backImageUrl ?? this.backImageUrl,
      frontImageUrl: frontImageUrl ?? this.frontImageUrl,
      submittedAt: submittedAt ?? this.submittedAt,
      value: value ?? this.value,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectedAt: rejectedAt ?? this.rejectedAt,
    );
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

// Login Response Model
class LoginResponse {
  final String message;
  final String token;
  final User user;
  final bool verificationStatus;
  final String navigatorPage;

  LoginResponse({
    required this.message,
    required this.token,
    required this.user,
    required this.verificationStatus,
    required this.navigatorPage,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'] ?? '',
      token: json['token'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
      verificationStatus: json['verification_status'] ?? false,
      navigatorPage: json['navigatorPage'] ?? '/dashboard',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'token': token,
      'user': user.toJson(),
      'verification_status': verificationStatus,
      'navigatorPage': navigatorPage,
    };
  }
}