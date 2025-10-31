class Voucher {
  final String id;
  final String code;
  final String name;
  final String description;
  final int pointCost; // Harga dalam Poin UMKM
  final int discountAmount; // Nominal diskon dalam Rupiah
  final int? discountPercentage; // Atau persentase diskon (opsional)
  final int minPurchase; // Minimal pembelian untuk pakai voucher
  final DateTime validUntil;
  final String category; // 'Food', 'Grocery', 'Fashion', dll atau 'Semua'
  final String imageUrl;
  final bool isActive;
  final int stock; // Stok voucher yang tersedia
  
  Voucher({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.pointCost,
    required this.discountAmount,
    this.discountPercentage,
    required this.minPurchase,
    required this.validUntil,
    required this.category,
    required this.imageUrl,
    this.isActive = true,
    this.stock = 100,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'pointCost': pointCost,
      'discountAmount': discountAmount,
      'discountPercentage': discountPercentage,
      'minPurchase': minPurchase,
      'validUntil': validUntil.toIso8601String(),
      'category': category,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'stock': stock,
    };
  }

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      description: json['description'],
      pointCost: json['pointCost'],
      discountAmount: json['discountAmount'],
      discountPercentage: json['discountPercentage'],
      minPurchase: json['minPurchase'],
      validUntil: DateTime.parse(json['validUntil']),
      category: json['category'],
      imageUrl: json['imageUrl'],
      isActive: json['isActive'] ?? true,
      stock: json['stock'] ?? 100,
    );
  }

  bool get isExpired => DateTime.now().isAfter(validUntil);
  bool get isAvailable => isActive && stock > 0 && !isExpired;
}

// Model untuk voucher yang sudah ditukarkan user
class UserVoucher {
  final String id;
  final String voucherId;
  final String code;
  final String name;
  final int discountAmount;
  final int? discountPercentage;
  final int minPurchase;
  final DateTime redeemedAt;
  final DateTime validUntil;
  final String category;
  final bool isUsed;
  final String? usedTransactionId;
  final DateTime? usedAt;

  UserVoucher({
    required this.id,
    required this.voucherId,
    required this.code,
    required this.name,
    required this.discountAmount,
    this.discountPercentage,
    required this.minPurchase,
    required this.redeemedAt,
    required this.validUntil,
    required this.category,
    this.isUsed = false,
    this.usedTransactionId,
    this.usedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'voucherId': voucherId,
      'code': code,
      'name': name,
      'discountAmount': discountAmount,
      'discountPercentage': discountPercentage,
      'minPurchase': minPurchase,
      'redeemedAt': redeemedAt.toIso8601String(),
      'validUntil': validUntil.toIso8601String(),
      'category': category,
      'isUsed': isUsed,
      'usedTransactionId': usedTransactionId,
      'usedAt': usedAt?.toIso8601String(),
    };
  }

  factory UserVoucher.fromJson(Map<String, dynamic> json) {
    return UserVoucher(
      id: json['id'],
      voucherId: json['voucherId'],
      code: json['code'],
      name: json['name'],
      discountAmount: json['discountAmount'],
      discountPercentage: json['discountPercentage'],
      minPurchase: json['minPurchase'],
      redeemedAt: DateTime.parse(json['redeemedAt']),
      validUntil: DateTime.parse(json['validUntil']),
      category: json['category'],
      isUsed: json['isUsed'] ?? false,
      usedTransactionId: json['usedTransactionId'],
      usedAt: json['usedAt'] != null ? DateTime.parse(json['usedAt']) : null,
    );
  }

  bool get isExpired => DateTime.now().isAfter(validUntil);
  bool get canBeUsed => !isUsed && !isExpired;
}