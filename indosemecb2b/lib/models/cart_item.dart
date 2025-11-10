// lib/models/cart_item.dart
class CartItem {
  final String productId;
  final String name;
  final double price;
  final double? originalPrice;
  final int? discountPercentage;
  final String? imageUrl;
  int quantity;
  final String? category; // ✅ TAMBAHKAN FIELD INI
  final int? minOrderQty; // ✅ TAMBAH
  final String? unit; // ✅ TAMBAH

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    this.originalPrice,
    this.discountPercentage,
    this.imageUrl,
    this.quantity = 1,
    this.category,
    this.minOrderQty, // ✅ TAMBAH
    this.unit = 'pcs', // ✅ TAMBAH
  });
  bool get meetsMinimumOrder {
    if (minOrderQty == null || minOrderQty! <= 0) return true;
    return quantity >= minOrderQty!;
  }

  // ✅ GETTER: Sisa quantity untuk memenuhi minimum
  int get remainingToMeetMinimum {
    if (minOrderQty == null || quantity >= minOrderQty!) return 0;
    return minOrderQty! - quantity;
  }

  // Convert to Map untuk disimpan di SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'originalPrice': originalPrice,
      'discountPercentage': discountPercentage,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'category': category, // ✅ SIMPAN CATEGORY
      'minOrderQty': minOrderQty, // ✅ TAMBAH
      'unit': unit, // ✅ TAMBAH
    };
  }

  // Convert dari Map
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      productId: map['productId'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      originalPrice: map['originalPrice']?.toDouble(),
      discountPercentage: map['discountPercentage'],
      imageUrl: map['imageUrl'],
      quantity: map['quantity'] ?? 1,
      category: map['category'],
      minOrderQty: map['minOrderQty'], // ✅ TAMBAH
      unit: map['unit'] ?? 'pcs', // ✅ TAMBAH
    );
  }

  // Hitung total harga untuk item ini
  double get totalPrice => price * quantity;
}
