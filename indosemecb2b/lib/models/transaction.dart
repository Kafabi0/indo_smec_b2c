// lib/models/transaction.dart
class Transaction {
  final String id;
  final DateTime date;
  String status; // 'Selesai', 'Dibatalkan', 'Diproses'
  final String deliveryOption; // 'xpress' atau 'xtra'
  final Map<String, dynamic>? alamat;
  final List<TransactionItem> items;
  final double totalPrice;
  final String? catatanPengiriman;
  final String? metodePembayaran;

  // ✅ TAMBAHKAN FIELD VOUCHER
  final String? voucherCode;
  final double? voucherDiscount;

  Transaction({
    required this.id,
    required this.date,
    required this.status,
    required this.deliveryOption,
    this.alamat,
    required this.items,
    required this.totalPrice,
    this.catatanPengiriman,
    this.metodePembayaran,
    this.voucherCode, // ✅ ADD
    this.voucherDiscount, // ✅ ADD
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
      'catatanPengiriman': catatanPengiriman,
      'metodePembayaran': metodePembayaran,
      'voucher_code': voucherCode, // ✅ SIMPAN VOUCHER
      'voucher_discount': voucherDiscount, // ✅ SIMPAN DISKON
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
      catatanPengiriman: map['catatanPengiriman'],
      metodePembayaran: map['metodePembayaran'],
      voucherCode: map['voucher_code'], // ✅ LOAD VOUCHER
      voucherDiscount:
          map['voucher_discount'] != null
              ? (map['voucher_discount'] is int
                  ? (map['voucher_discount'] as int).toDouble()
                  : (map['voucher_discount'] as double))
              : null, // ✅ LOAD DISKON
    );
  }

  // ✅ METHOD UNTUK HITUNG TOTAL SETELAH DISKON
  double get finalTotal {
    final discount = voucherDiscount ?? 0.0;
    return totalPrice - discount;
  }

  // ✅ METHOD UNTUK CEK APAKAH PAKAI VOUCHER
  bool get hasVoucher => voucherCode != null && (voucherDiscount ?? 0) > 0;
}

class TransactionItem {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String? imageUrl;
  final String? category; // ⭐ TAMBAHKAN INI

  TransactionItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
    this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'category': category, // ⭐ TAMBAHKAN INI
    };
  }

  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      productId: map['productId'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
      imageUrl: map['imageUrl'],
      category: map['category'], // ⭐ TAMBAHKAN INI
    );
  }

  double get totalPrice => price * quantity;
}
