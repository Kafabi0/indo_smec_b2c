// lib/models/transaction.dart
class Transaction {
  final String id;
  final DateTime date;
  String status; // 'Selesai', 'Dibatalkan', 'Diproses'
  final String deliveryOption; // 'xpress' atau 'xtra'
  final Map<String, dynamic>? alamat;
  final List<TransactionItem> items;
  final double totalPrice;
  final String? catatanPengiriman; // ✅ TAMBAHKAN FIELD

  Transaction({
    required this.id,
    required this.date,
    required this.status,
    required this.deliveryOption,
    this.alamat,
    required this.items,
    required this.totalPrice,
    this.catatanPengiriman, // ✅ TAMBAHKAN FIELD
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'status': status,
      'deliveryOption': deliveryOption,
      'alamat': alamat,
      'items': items.map((item) => item.toMap()).toList(),
      'totalPrice': totalPrice,
      'catatanPengiriman': catatanPengiriman, // ✅ SIMPAN KE MAP
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] ?? '',
      date: DateTime.parse(map['date']),
      status: map['status'] ?? 'Diproses',
      deliveryOption: map['deliveryOption'] ?? 'xpress',
      alamat: map['alamat'],
      items:
          (map['items'] as List)
              .map((item) => TransactionItem.fromMap(item))
              .toList(),
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      catatanPengiriman: map['catatanPengiriman'], // ✅ LOAD DARI MAP
    );
  }
}

class TransactionItem {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String? imageUrl;

  TransactionItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
    };
  }

  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      productId: map['productId'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
      imageUrl: map['imageUrl'],
    );
  }

  double get totalPrice => price * quantity;
}
