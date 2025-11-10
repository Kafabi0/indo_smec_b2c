import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:indosemecb2b/utils/user_data_manager.dart';
import 'package:indosemecb2b/models/transaction.dart';
import 'package:indosemecb2b/models/cart_item.dart';

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

  // ✅ FIXED: Tambahkan parameter untuk voucher dan poin cash
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

      // 🛒 Konversi item keranjang ke item transaksi
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

      // ✅ FIXED: Hitung total SEBELUM diskon dan potongan
      final subtotal = cartItems.fold<double>(
        0.0,
        (sum, item) => sum + item.totalPrice,
      );
      final shipping = 0.0;
      final totalBeforeDiscount = subtotal + shipping;

      // ✅ Ambil data voucher dan poin cash dari alamat
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

      // ✅ FIXED: Total akhir = total - voucher discount - poin cash
      final finalTotal = totalBeforeDiscount - voucherDiscount - poinCashUsed;

      print('💰 Subtotal: $subtotal');
      print('🚚 Shipping: $shipping');
      print('🎟️ Voucher Discount: $voucherDiscount');
      print('💵 Poin Cash Used: $poinCashUsed');
      print('💸 Final Total: $finalTotal');

      final status = initialStatus ?? _getRandomStatus();
      final finalMetodePembayaran =
          metodePembayaran ?? alamat?['metode_pembayaran'] ?? 'Tidak Diketahui';

      // ✅ FIXED: Simpan totalPrice sebagai total SEBELUM diskon
      // Nanti final total dihitung di getter
      final transaction = Transaction(
        id: transactionId,
        date: DateTime.now(),
        status: status,
        deliveryOption: deliveryOption,
        alamat: alamat,
        items: items,
        totalPrice: totalBeforeDiscount, // ✅ Total sebelum diskon
        catatanPengiriman: catatanPengiriman,
        metodePembayaran: finalMetodePembayaran,
        voucherCode: voucherCode,
        voucherDiscount: voucherDiscount,
        poinCashUsed: poinCashUsed, // ✅ TAMBAHKAN
        isUsingPoinCash: isUsingPoinCash, // ✅ TAMBAHKAN
      );

      // 📂 Simpan transaksi
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
      return sum + t.finalTotal; // ✅ Gunakan finalTotal
    });
  }

  static Future<double> getTotalSpendingCompleted() async {
    final transactions = await getTransactions();
    return transactions.where((t) => t.status == 'Selesai').fold<double>(0.0, (
      sum,
      t,
    ) {
      return sum + t.finalTotal; // ✅ Gunakan finalTotal
    });
  }

  static void dispose() {
    _statusController.close();
  }
}
