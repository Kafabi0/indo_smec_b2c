// lib/models/cart_item.dart
class CartItem {
  final String productId;
  final String name;
  final double price;
  final double? originalPrice;
  final int? discountPercentage;
  final String? imageUrl;
  int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    this.originalPrice,
    this.discountPercentage,
    this.imageUrl,
    this.quantity = 1,
  });

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
    );
  }

  // Hitung total harga untuk item ini
  double get totalPrice => price * quantity;
}
