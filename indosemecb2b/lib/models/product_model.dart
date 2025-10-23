class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final String category;
  final double rating;
  final int reviewCount;
  final String? storeName;
  final String? storeDistance;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.category,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.storeName,
    this.storeDistance,
  });

  // Hitung persentase diskon
  int? get discountPercentage {
    if (originalPrice != null && originalPrice! > price) {
      return (((originalPrice! - price) / originalPrice!) * 100).round();
    }
    return null;
  }
}