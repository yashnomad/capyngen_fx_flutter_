class CryptoWallet {
  final String currency;
  final String network;
  final String address;
  final String label;
  final bool isDefault;
  final String? id; // Optional: useful if API returns an ID

  CryptoWallet({
    required this.currency,
    required this.network,
    required this.address,
    this.label = '',
    this.isDefault = false,
    this.id,
  });

  // ✅ ADD THIS MISSING FACTORY
  factory CryptoWallet.fromJson(Map<String, dynamic> json) {
    return CryptoWallet(
      currency: json['currency'] ?? '',
      network: json['network'] ?? '',
      address: json['address'] ?? '',
      label: json['label'] ?? '',
      isDefault: json['isDefault'] ?? false,
      id: json['_id'], // MongoDB usually returns _id
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "currency": currency,
      "network": network,
      "address": address,
      "label": label,
      "isDefault": isDefault
    };
  }
}