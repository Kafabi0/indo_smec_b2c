import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:indosemecb2b/utils/user_data_manager.dart';
import 'package:indosemecb2b/models/transaction.dart';
import 'package:indosemecb2b/models/cart_item.dart';

class TransactionManager {
  // Stream controller untuk notifikasi perubahan status
  static final StreamController<void> _statusController =
      StreamController<void>.broadcast();
  static final ValueNotifier<String> statusNotifier = ValueNotifier<String>('');

  // Stream untuk mendengarkan perubahan status
  static Stream<void> get statusStream => _statusController.stream;

  // ⭐ Helper untuk randomize status
  static String _getRandomStatus() {
    final statuses = ['Diproses'];
    final random = Random();
    return statuses[random.nextInt(statuses.length)];
  }

  // Buat transaksi dari keranjang
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

      // 🆔 Generate ID transaksi unik
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

      // 💰 Hitung total harga + ongkir tetap
      final total =
          cartItems.fold<double>(0.0, (sum, item) => sum + item.totalPrice) +
          5000.0;

      // 🏷️ Tentukan status awal
      final status = initialStatus ?? _getRandomStatus();

      // 💳 Tentukan metode pembayaran
      final finalMetodePembayaran =
          metodePembayaran ?? alamat?['metode_pembayaran'] ?? 'Tidak Diketahui';

      // 🎟️ Voucher (jika ada)
      final voucherCode = alamat?['voucher_code'] as String?;
      final voucherDiscountRaw = alamat?['voucher_discount'];
      final voucherDiscount =
          voucherDiscountRaw != null
              ? (voucherDiscountRaw is int
                  ? voucherDiscountRaw.toDouble()
                  : voucherDiscountRaw as double)
              : null;

      // 🧾 Buat objek transaksi
      final transaction = Transaction(
        id: transactionId,
        date: DateTime.now(),
        status: status,
        deliveryOption: deliveryOption,
        alamat: alamat,
        items: items,
        totalPrice: total,
        catatanPengiriman: catatanPengiriman,
        metodePembayaran: finalMetodePembayaran,
        voucherCode: voucherCode,
        voucherDiscount: voucherDiscount,
      );

      // 📂 Ambil transaksi lama
      final transactions = await getTransactions();
      transactions.insert(0, transaction);

      // 💾 Simpan ke storage
      final saved = await UserDataManager.saveTransactions(
        userLogin,
        transactions.map((t) => t.toMap()).toList(),
      );

      print('💾 Save result: $saved');

      // ✅ Kembalikan transactionId jika berhasil
      if (saved) {
        print('✅ Transaction created successfully with ID: $transactionId');
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

  /// ✅ Simpan transaksi top-up saldo
  static Future<bool> createTopUpTransaction({
    required double amount,
    required String paymentMethod,
    required String transactionId,
  }) async {
    try {
      print('💰 [TransactionManager] Creating top-up transaction...');
      print('   Amount: $amount');
      print('   Method: $paymentMethod');
      print('   ID: $transactionId');

      final userLogin = await UserDataManager.getCurrentUserLogin();
      if (userLogin == null) {
        print('❌ No user logged in');
        return false;
      }

      // Create transaction items for top-up
      final items = [
        TransactionItem(
          productId: transactionId,
          name: 'Top-Up Saldo Klik',
          quantity: 1,
          price: amount,
          imageUrl:
              'https://i.pinimg.com/736x/65/c4/1d/65c41db5a939f1e45c5f1ff1244689f5.jpg', // Wallet icon
        ),
      ];

      // Create transaction object for top-up
      final topUpTransaction = Transaction(
        id: transactionId,
        date: DateTime.now(),
        status: 'Selesai', // Top-up langsung selesai
        items: items,
        deliveryOption: 'topup', // ✅ Special delivery option for top-up
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

      print('✅ Top-up transaction object created');

      // Get existing transactions
      final transactions = await getTransactions();
      print('📋 Existing transactions: ${transactions.length}');

      // Add new top-up transaction at the beginning
      transactions.insert(0, topUpTransaction);
      print(
        '➕ Top-up transaction added to list. New count: ${transactions.length}',
      );

      // Save to storage
      final saved = await UserDataManager.saveTransactions(
        userLogin,
        transactions.map((t) => t.toMap()).toList(),
      );

      print('💾 Save result: $saved');

      // Verify saved data
      if (saved) {
        final verifyTransactions = await UserDataManager.getTransactions(
          userLogin,
        );
        print(
          '✓ Verification - Transactions in storage: ${verifyTransactions.length}',
        );

        final savedTransaction = verifyTransactions.firstWhere(
          (t) => t['id'] == transactionId,
          orElse: () => <String, dynamic>{},
        );
        if (savedTransaction.isNotEmpty) {
          print('✓ Saved top-up transaction ID: ${savedTransaction['id']}');
          print('✓ Saved status: ${savedTransaction['status']}');
          print('✓ Saved amount: ${savedTransaction['totalPrice']}');
          print(
            '✓ Saved metode pembayaran: ${savedTransaction['metodePembayaran']}',
          );
        }

        // Trigger status update notification
        _statusController.add(null);
        statusNotifier.value = DateTime.now().toString();
      }

      print('✅ [TransactionManager] Top-up transaction saved successfully');
      return saved;
    } catch (e, stackTrace) {
      debugPrint('❌ Error creating top-up transaction: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  // Ambil semua transaksi user
  static Future<List<Transaction>> getTransactions() async {
    try {
      final userLogin = await UserDataManager.getCurrentUserLogin();
      print('📖 Getting transactions for user: $userLogin');

      if (userLogin == null) {
        print('❌ No user logged in');
        return [];
      }

      final data = await UserDataManager.getTransactions(userLogin);
      print('📊 Raw data count: ${data.length}');

      if (data.isNotEmpty) {
        print('📊 Sample transaction data: ${data.first}');
        print('📊 Sample status: ${data.first['status']}');
      } else {
        print('⚠️ No transaction data found for user: $userLogin');
      }

      final transactions =
          data.map((item) => Transaction.fromMap(item)).toList();
      print('✅ Parsed transactions: ${transactions.length}');

      if (transactions.isNotEmpty) {
        print('✅ First transaction ID: ${transactions.first.id}');
        print('✅ First transaction status: ${transactions.first.status}');
        print('✅ First transaction items: ${transactions.first.items.length}');
      }

      return transactions;
    } catch (e) {
      debugPrint('❌ Error getting transactions: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  // Filter transaksi berdasarkan status
  static Future<List<Transaction>> getTransactionsByStatus(
    String status,
  ) async {
    final transactions = await getTransactions();
    if (status == 'Semua Status') return transactions;
    return transactions.where((t) => t.status == status).toList();
  }

  // Filter transaksi berdasarkan tanggal
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

  // Filter transaksi berdasarkan kategori (delivery option)
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
      // ✅ ADD
      deliveryOption = 'topup';
    }

    if (deliveryOption == null) return transactions;

    return transactions
        .where((t) => t.deliveryOption == deliveryOption)
        .toList();
  }

  // Ambil transaksi dengan filter gabungan
  static Future<List<Transaction>> getFilteredTransactions({
    String status = 'Semua Status',
    String dateFilter = 'Semua Tanggal',
    String category = 'Semua',
  }) async {
    print(
      '🔍 Filtering transactions - Status: $status, Date: $dateFilter, Category: $category',
    );

    var transactions = await getTransactions();
    print('🔍 Initial transactions: ${transactions.length}');

    // ⭐ Debug: Print status dari setiap transaksi
    for (var t in transactions) {
      print('  - ${t.id}: ${t.status}');
    }

    // Filter status
    if (status != 'Semua Status') {
      transactions = transactions.where((t) => t.status == status).toList();
      print('🔍 After status filter ($status): ${transactions.length}');
    }

    // Filter tanggal
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
      print('🔍 After date filter: ${transactions.length}');
    }

    // Filter kategori
    if (category != 'Semua') {
      String? deliveryOption;
      if (category == 'Xpress') {
        deliveryOption = 'xpress';
      } else if (category == 'Xtra') {
        deliveryOption = 'xtra';
      } else if (category == 'Top-Up') {
        // ✅ ADD
        deliveryOption = 'topup';
      }

      if (deliveryOption != null) {
        transactions =
            transactions
                .where((t) => t.deliveryOption == deliveryOption)
                .toList();
        print('🔍 After category filter: ${transactions.length}');
      }
    }

    print('✅ Final filtered transactions: ${transactions.length}');
    return transactions;
  }

  // Update status transaksi (jika diperlukan manual update)
  static Future<bool> updateTransactionStatus(
    String transactionId,
    String newStatus,
  ) async {
    try {
      print('🔄 Updating transaction $transactionId to status: $newStatus');

      final userLogin = await UserDataManager.getCurrentUserLogin();
      if (userLogin == null) return false;

      final transactions = await getTransactions();
      final index = transactions.indexWhere((t) => t.id == transactionId);

      if (index == -1) {
        print('❌ Transaction not found: $transactionId');
        return false;
      }

      // Update status langsung pada objek
      transactions[index].status = newStatus;
      print('✅ Status updated in memory');

      // Simpan kembali
      final saved = await UserDataManager.saveTransactions(
        userLogin,
        transactions.map((t) => t.toMap()).toList(),
      );

      print('💾 Save result: $saved');

      // Beri tahu bahwa status telah berubah
      _statusController.add(null);
      statusNotifier.value = newStatus;

      return saved;
    } catch (e) {
      debugPrint('❌ Error updating transaction status: $e');
      return false;
    }
  }

  // ⭐ BARU: Konfirmasi pesanan telah diterima dan ubah status menjadi "Selesai"
  static Future<bool> confirmOrderReceived(String transactionId) async {
    try {
      print('✅ Confirming order received for transaction: $transactionId');

      final userLogin = await UserDataManager.getCurrentUserLogin();
      if (userLogin == null) {
        print('❌ No user logged in');
        return false;
      }

      final transactions = await getTransactions();
      final index = transactions.indexWhere((t) => t.id == transactionId);

      if (index == -1) {
        print('❌ Transaction not found: $transactionId');
        return false;
      }

      // Cek apakah status saat ini adalah "Pesanan telah sampai"
      if (transactions[index].status != 'Pesanan telah sampai') {
        print(
          '⚠️ Transaction status is not "Pesanan telah sampai", current: ${transactions[index].status}',
        );
        // Tetap lanjutkan untuk kemudahan testing
      }

      // Update status menjadi "Selesai"
      transactions[index].status = 'Selesai';
      print('✅ Status updated to "Selesai" in memory');

      // Simpan kembali ke storage
      final saved = await UserDataManager.saveTransactions(
        userLogin,
        transactions.map((t) => t.toMap()).toList(),
      );

      print('💾 Save result: $saved');

      if (saved) {
        // Verifikasi status tersimpan
        final verifyTransactions = await UserDataManager.getTransactions(
          userLogin,
        );
        final savedTransaction = verifyTransactions.firstWhere(
          (t) => t['id'] == transactionId,
          orElse: () => <String, dynamic>{},
        );
        if (savedTransaction.isNotEmpty) {
          print('✓ Verified saved status: ${savedTransaction['status']}');
        }

        // Beri tahu bahwa status telah berubah
        _statusController.add(null);
        statusNotifier.value = 'Selesai-$transactionId';

        print('✅ Order confirmed as received successfully!');
      }

      return saved;
    } catch (e) {
      debugPrint('❌ Error confirming order received: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  // Hapus transaksi
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

      // Beri tahu bahwa ada perubahan data
      _statusController.add(null);

      return saved;
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      return false;
    }
  }

  // Hitung total transaksi
  static Future<int> getTransactionCount() async {
    final transactions = await getTransactions();
    return transactions.length;
  }

  // Hitung total pengeluaran
  static Future<double> getTotalSpending() async {
    final transactions = await getTransactions();
    return transactions.fold<double>(0.0, (sum, t) {
      // Gunakan finalTotal yang sudah dikurangi diskon
      return sum + t.finalTotal;
    });
  }

  // ⭐ TAMBAHAN: Hitung total dari transaksi yang selesai saja
  static Future<double> getTotalSpendingCompleted() async {
    final transactions = await getTransactions();
    return transactions.where((t) => t.status == 'Selesai').fold<double>(0.0, (
      sum,
      t,
    ) {
      // Gunakan finalTotal yang sudah dikurangi diskon
      return sum + t.finalTotal;
    });
  }

  // Dispose resources
  static void dispose() {
    _statusController.close();
  }
}
