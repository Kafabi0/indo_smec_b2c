import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:indosemecb2b/models/tracking.dart';
import 'package:indosemecb2b/utils/user_data_manager.dart';
import 'package:indosemecb2b/models/transaction.dart';
import 'package:indosemecb2b/models/cart_item.dart';
import 'package:latlong2/latlong.dart';

class TransactionManager {
  static final StreamController<void> _statusController =
      StreamController<void>.broadcast();
  static final ValueNotifier<String> statusNotifier = ValueNotifier<String>('');

  static Stream<void> get statusStream => _statusController.stream;

  static String _getRandomStatus() {
    final statuses = ['Diproses'];
    final random = Random();
    return statuses[random.nextInt(statuses.length)];
  }

  // ⭐ BARU: Simpan tracking data
  static Future<bool> saveTrackingData({
    required String transactionId,
    required String koperasiId,
    required String koperasiName,
    required double koperasiLatitude,
    required double koperasiLongitude,
    required double deliveryLatitude,
    required double deliveryLongitude,
    required Map<String, dynamic> deliveryAddress,
  }) async {
    try {
      final userLogin = await UserDataManager.getCurrentUserLogin();
      if (userLogin == null) return false;

      final trackingData = {
        'transaction_id': transactionId,
        'koperasi_id': koperasiId,
        'koperasi_name': koperasiName,
        'koperasi_lat': koperasiLatitude,
        'koperasi_lon': koperasiLongitude,
        'delivery_lat': deliveryLatitude,
        'delivery_lon': deliveryLongitude,
        'delivery_address': deliveryAddress,
        'created_at': DateTime.now().toIso8601String(),
      };

      return await UserDataManager.saveTrackingData(
        userLogin,
        transactionId,
        trackingData,
      );
    } catch (e) {
      debugPrint('❌ Error saving tracking data: $e');
      return false;
    }
  }

  // ⭐ BARU: Ambil tracking data
  static Future<Map<String, dynamic>?> getTrackingData(
    String transactionId,
  ) async {
    try {
      final userLogin = await UserDataManager.getCurrentUserLogin();
      if (userLogin == null) return null;

      return await UserDataManager.getTrackingData(userLogin, transactionId);
    } catch (e) {
      debugPrint('❌ Error getting tracking data: $e');
      return null;
    }
  }

  // ⭐ BARU: Buat OrderTrackingModel dari transaction
  static Future<OrderTrackingModel?> getOrderTrackingModel(
    String transactionId,
  ) async {
    try {
      final transactions = await getTransactions();
      final transaction = transactions.firstWhere(
        (t) => t.id == transactionId,
        orElse: () => throw Exception('Transaction not found'),
      );

      final trackingData = await getTrackingData(transactionId);

      return OrderTrackingModel(
        transactionId: transactionId,
        orderId: transactionId,
        courierName: "Tryan Gumilar",
        courierId: "D 4563 ADP",
        statusMessage: transaction.status,
        statusDesc: _getStatusDescription(transaction.status),
        updatedAt: transaction.date,
        // ⭐ Data dari tracking
        koperasiId: trackingData?['koperasi_id'],
        koperasiName: trackingData?['koperasi_name'],
        koperasiLocation:
            trackingData != null
                ? LatLng(
                  trackingData['koperasi_lat'],
                  trackingData['koperasi_lon'],
                )
                : null,
        deliveryLocation:
            trackingData != null
                ? LatLng(
                  trackingData['delivery_lat'],
                  trackingData['delivery_lon'],
                )
                : null,
        deliveryAddress: trackingData?['delivery_address'],
      );
    } catch (e) {
      debugPrint('❌ Error getting order tracking model: $e');
      return null;
    }
  }

  static String _getStatusDescription(String status) {
    switch (status) {
      case 'Diproses':
        return 'Pesanan sedang diproses';
      case 'Sedang dikirim':
        return 'Kurir sedang dalam perjalanan';
      case 'Hampir sampai':
        return 'Kurir sebentar lagi tiba';
      case 'Pesanan telah sampai':
        return 'Pesanan sudah tiba di lokasi';
      case 'Selesai':
        return 'Pesanan telah selesai';
      case 'Dibatalkan':
        return 'Pesanan telah dibatalkan';
      default:
        return 'Status tidak diketahui';
    }
  }

  static Future<String?> createTransaction({
    required List<CartItem> cartItems,
    required String deliveryOption,
    Map<String, dynamic>? alamat,
    String? initialStatus,
    String? catatanPengiriman,
    String? metodePembayaran,
  }) async {
    try {
      print('📦 Creating transaction...');

      final userLogin = await UserDataManager.getCurrentUserLogin();
      if (userLogin == null) {
        print('❌ No user logged in');
        return null;
      }

      final transactionId = 'TRX${DateTime.now().millisecondsSinceEpoch}';
      print('🆔 Transaction ID: $transactionId');

      final items =
          cartItems.map((cartItem) {
            return TransactionItem(
              productId: cartItem.productId,
              name: cartItem.name,
              price: cartItem.price,
              quantity: cartItem.quantity,
              imageUrl: cartItem.imageUrl,
              category: cartItem.category,
            );
          }).toList();

      final subtotal = cartItems.fold<double>(
        0.0,
        (sum, item) => sum + item.totalPrice,
      );
      final shipping = 0.0;
      final totalBeforeDiscount = subtotal + shipping;

      final voucherCode = alamat?['voucher_code'] as String?;
      final voucherDiscountRaw = alamat?['voucher_discount'];
      final voucherDiscount =
          voucherDiscountRaw != null
              ? (voucherDiscountRaw is int
                  ? voucherDiscountRaw.toDouble()
                  : voucherDiscountRaw as double)
              : 0.0;

      final poinCashUsedRaw = alamat?['poin_cash_used'];
      final poinCashUsed =
          poinCashUsedRaw != null
              ? (poinCashUsedRaw is int
                  ? poinCashUsedRaw.toDouble()
                  : poinCashUsedRaw as double)
              : 0.0;

      final isUsingPoinCash = alamat?['is_using_poin_cash'] == true;

      final finalTotal = totalBeforeDiscount - voucherDiscount - poinCashUsed;

      print('💰 Subtotal: $subtotal');
      print('🚚 Shipping: $shipping');
      print('🎟️ Voucher Discount: $voucherDiscount');
      print('💵 Poin Cash Used: $poinCashUsed');
      print('💸 Final Total: $finalTotal');

      final status = initialStatus ?? _getRandomStatus();
      final finalMetodePembayaran =
          metodePembayaran ?? alamat?['metode_pembayaran'] ?? 'Tidak Diketahui';

      final transaction = Transaction(
        id: transactionId,
        date: DateTime.now(),
        status: status,
        deliveryOption: deliveryOption,
        alamat: alamat,
        items: items,
        totalPrice: totalBeforeDiscount,
        catatanPengiriman: catatanPengiriman,
        metodePembayaran: finalMetodePembayaran,
        voucherCode: voucherCode,
        voucherDiscount: voucherDiscount,
        poinCashUsed: poinCashUsed,
        isUsingPoinCash: isUsingPoinCash,
      );

      final transactions = await getTransactions();
      transactions.insert(0, transaction);

      final saved = await UserDataManager.saveTransactions(
        userLogin,
        transactions.map((t) => t.toMap()).toList(),
      );

      print('💾 Save result: $saved');

      if (saved) {
        print('✅ Transaction created successfully with ID: $transactionId');
        print('   - Total Before Discount: $totalBeforeDiscount');
        print('   - Voucher Discount: $voucherDiscount');
        print('   - Poin Cash Used: $poinCashUsed');
        print('   - Final Total: $finalTotal');
        return transactionId;
      } else {
        print('❌ Failed to save transaction');
        return null;
      }
    } catch (e, st) {
      debugPrint('❌ Error creating transaction: $e');
      debugPrint('Stack trace: $st');
      return null;
    }
  }

  static Future<bool> createTopUpTransaction({
    required double amount,
    required String paymentMethod,
    required String transactionId,
  }) async {
    try {
      print('💰 [TransactionManager] Creating top-up transaction...');

      final userLogin = await UserDataManager.getCurrentUserLogin();
      if (userLogin == null) {
        print('❌ No user logged in');
        return false;
      }

      final items = [
        TransactionItem(
          productId: transactionId,
          name: 'Top-Up Saldo Klik',
          quantity: 1,
          price: amount,
          imageUrl:
              'https://i.pinimg.com/736x/65/c4/1d/65c41db5a939f1e45c5f1ff1244689f5.jpg',
        ),
      ];

      final topUpTransaction = Transaction(
        id: transactionId,
        date: DateTime.now(),
        status: 'Selesai',
        items: items,
        deliveryOption: 'topup',
        alamat: {
          'nama_penerima': 'Top-Up Saldo',
          'nomor_hp': userLogin,
          'alamat_lengkap': 'Saldo Klik',
          'metode_pembayaran': paymentMethod,
        },
        totalPrice: amount,
        catatanPengiriman: 'Isi Saldo via $paymentMethod',
        metodePembayaran: paymentMethod,
      );

      final transactions = await getTransactions();
      transactions.insert(0, topUpTransaction);

      final saved = await UserDataManager.saveTransactions(
        userLogin,
        transactions.map((t) => t.toMap()).toList(),
      );

      if (saved) {
        _statusController.add(null);
        statusNotifier.value = DateTime.now().toString();
      }

      return saved;
    } catch (e, stackTrace) {
      debugPrint('❌ Error creating top-up transaction: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  static Future<List<Transaction>> getTransactions() async {
    try {
      final userLogin = await UserDataManager.getCurrentUserLogin();
      if (userLogin == null) return [];

      final data = await UserDataManager.getTransactions(userLogin);
      final transactions =
          data.map((item) => Transaction.fromMap(item)).toList();

      return transactions;
    } catch (e) {
      debugPrint('❌ Error getting transactions: $e');
      return [];
    }
  }

  static Future<List<Transaction>> getTransactionsByStatus(
    String status,
  ) async {
    final transactions = await getTransactions();
    if (status == 'Semua Status') return transactions;
    return transactions.where((t) => t.status == status).toList();
  }

  static Future<List<Transaction>> getTransactionsByDate(
    String dateFilter,
  ) async {
    final transactions = await getTransactions();
    if (dateFilter == 'Semua Tanggal') return transactions;

    final now = DateTime.now();
    DateTime startDate;

    if (dateFilter == '7 Hari Terakhir') {
      startDate = now.subtract(const Duration(days: 7));
    } else if (dateFilter == '30 Hari Terakhir') {
      startDate = now.subtract(const Duration(days: 30));
    } else {
      return transactions;
    }

    return transactions.where((t) => t.date.isAfter(startDate)).toList();
  }

  static Future<List<Transaction>> getTransactionsByCategory(
    String category,
  ) async {
    final transactions = await getTransactions();
    if (category == 'Semua') return transactions;

    String? deliveryOption;
    if (category == 'Xpress') {
      deliveryOption = 'xpress';
    } else if (category == 'Xtra') {
      deliveryOption = 'xtra';
    } else if (category == 'Top-Up') {
      deliveryOption = 'topup';
    }

    if (deliveryOption == null) return transactions;

    return transactions
        .where((t) => t.deliveryOption == deliveryOption)
        .toList();
  }

  static Future<List<Transaction>> getFilteredTransactions({
    String status = 'Semua Status',
    String dateFilter = 'Semua Tanggal',
    String category = 'Semua',
  }) async {
    var transactions = await getTransactions();

    if (status != 'Semua Status') {
      transactions = transactions.where((t) => t.status == status).toList();
    }

    if (dateFilter != 'Semua Tanggal') {
      final now = DateTime.now();
      DateTime startDate;

      if (dateFilter == '7 Hari Terakhir') {
        startDate = now.subtract(const Duration(days: 7));
      } else if (dateFilter == '30 Hari Terakhir') {
        startDate = now.subtract(const Duration(days: 30));
      } else {
        startDate = DateTime(1970);
      }

      transactions =
          transactions.where((t) => t.date.isAfter(startDate)).toList();
    }

    if (category != 'Semua') {
      String? deliveryOption;
      if (category == 'Xpress') {
        deliveryOption = 'xpress';
      } else if (category == 'Xtra') {
        deliveryOption = 'xtra';
      } else if (category == 'Top-Up') {
        deliveryOption = 'topup';
      }

      if (deliveryOption != null) {
        transactions =
            transactions
                .where((t) => t.deliveryOption == deliveryOption)
                .toList();
      }
    }

    return transactions;
  }

  static Future<bool> updateTransactionStatus(
    String transactionId,
    String newStatus,
  ) async {
    try {
      final userLogin = await UserDataManager.getCurrentUserLogin();
      if (userLogin == null) return false;

      final transactions = await getTransactions();
      final index = transactions.indexWhere((t) => t.id == transactionId);

      if (index == -1) return false;

      transactions[index].status = newStatus;

      final saved = await UserDataManager.saveTransactions(
        userLogin,
        transactions.map((t) => t.toMap()).toList(),
      );

      _statusController.add(null);
      statusNotifier.value = newStatus;

      return saved;
    } catch (e) {
      debugPrint('❌ Error updating transaction status: $e');
      return false;
    }
  }

  static Future<bool> confirmOrderReceived(String transactionId) async {
    try {
      final userLogin = await UserDataManager.getCurrentUserLogin();
      if (userLogin == null) return false;

      final transactions = await getTransactions();
      final index = transactions.indexWhere((t) => t.id == transactionId);

      if (index == -1) return false;

      transactions[index].status = 'Selesai';

      final saved = await UserDataManager.saveTransactions(
        userLogin,
        transactions.map((t) => t.toMap()).toList(),
      );

      if (saved) {
        _statusController.add(null);
        statusNotifier.value = 'Selesai-$transactionId';
      }

      return saved;
    } catch (e) {
      debugPrint('❌ Error confirming order received: $e');
      return false;
    }
  }

  static Future<bool> deleteTransaction(String transactionId) async {
    try {
      final userLogin = await UserDataManager.getCurrentUserLogin();
      if (userLogin == null) return false;

      final transactions = await getTransactions();
      transactions.removeWhere((t) => t.id == transactionId);

      final saved = await UserDataManager.saveTransactions(
        userLogin,
        transactions.map((t) => t.toMap()).toList(),
      );

      _statusController.add(null);

      return saved;
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      return false;
    }
  }

  static Future<int> getTransactionCount() async {
    final transactions = await getTransactions();
    return transactions.length;
  }

  static Future<double> getTotalSpending() async {
    final transactions = await getTransactions();
    return transactions.fold<double>(0.0, (sum, t) {
      return sum + t.finalTotal;
    });
  }

  static Future<double> getTotalSpendingCompleted() async {
    final transactions = await getTransactions();
    return transactions.where((t) => t.status == 'Selesai').fold<double>(0.0, (
      sum,
      t,
    ) {
      return sum + t.finalTotal;
    });
  }

  static void dispose() {
    _statusController.close();
  }
}

// ⭐ TAMBAHKAN MODEL INI
// class OrderTrackingModel {
//   final String? transactionId;
//   final String? orderId;
//   final String? courierName;
//   final String? courierId;
//   final String? statusMessage;
//   final String? statusDesc;
//   final DateTime? updatedAt;
//   final String? koperasiId;
//   final String? koperasiName;
//   final LatLng? koperasiLocation;
//   final LatLng? deliveryLocation;
//   final Map<String, dynamic>? deliveryAddress;

//   OrderTrackingModel({
//     this.transactionId,
//     this.orderId,
//     this.courierName,
//     this.courierId,
//     this.statusMessage,
//     this.statusDesc,
//     this.updatedAt,
//     this.koperasiId,
//     this.koperasiName,
//     this.koperasiLocation,
//     this.deliveryLocation,
//     this.deliveryAddress,
//   });
// }
