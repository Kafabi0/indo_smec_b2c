import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:indosemecb2b/utils/user_data_manager.dart';
import 'package:indosemecb2b/models/transaction.dart';
import 'package:indosemecb2b/models/cart_item.dart';

class TransactionManager {
  // Stream controller untuk notifikasi perubahan status
  static final StreamController<void> _statusController = StreamController<void>.broadcast();
  static final ValueNotifier<String> statusNotifier = ValueNotifier<String>('');
  
  // Stream untuk mendengarkan perubahan status
  static Stream<void> get statusStream => _statusController.stream;

  // ⭐ Helper untuk randomize status
  static String _getRandomStatus() {
    final statuses = ['Diproses',];
    final random = Random();
    return statuses[random.nextInt(statuses.length)];
  }

  // Buat transaksi dari keranjang
  static Future<bool> createTransaction({
    required List<CartItem> cartItems,
    required String deliveryOption,
    Map<String, dynamic>? alamat,
    String? initialStatus, // Parameter opsional untuk override
    String? catatanPengiriman,
  }) async {
    try {
      print('📦 Creating transaction...');

      final userLogin = await UserDataManager.getCurrentUserLogin();
      print('👤 User login: $userLogin');

      if (userLogin == null) {
        print('❌ No user logged in');
        return false;
      }

      // Generate ID transaksi unik
      final transactionId = 'TRX${DateTime.now().millisecondsSinceEpoch}';
      print('🆔 Transaction ID: $transactionId');

      // Convert CartItem ke TransactionItem
      final items = cartItems.map((cartItem) {
        return TransactionItem(
          productId: cartItem.productId,
          name: cartItem.name,
          price: cartItem.price,
          quantity: cartItem.quantity,
          imageUrl: cartItem.imageUrl,
        );
      }).toList();

      print('📦 Items count: ${items.length}');

      // Hitung total
      final total = cartItems.fold<double>(
        0.0,
        (sum, item) => sum + item.totalPrice,
      ) + 5000.0; 

      print('💰 Total price: $total');

      // ⭐ RANDOMIZE STATUS (jika tidak ada initialStatus)
      final status = initialStatus ?? _getRandomStatus();
      print('📊 Transaction status (randomized): $status');

      // Buat objek transaksi
      final transaction = Transaction(
        id: transactionId,
        date: DateTime.now(),
        status: status, // ⭐ Status sudah dirandomize
        deliveryOption: deliveryOption,
        alamat: alamat,
        items: items,
        totalPrice: total,
        catatanPengiriman: catatanPengiriman,
      );

      print('✅ Transaction object created with status: $status');
      if (catatanPengiriman != null && catatanPengiriman.isNotEmpty) {
        print('📝 Catatan pengiriman: $catatanPengiriman');
      }

      // Ambil daftar transaksi yang sudah ada
      final transactions = await getTransactions();
      print('📋 Existing transactions: ${transactions.length}');

      // Tambahkan transaksi baru di awal list
      transactions.insert(0, transaction);
      print('➕ Transaction added to list. New count: ${transactions.length}');

      // Simpan ke storage
      final saved = await UserDataManager.saveTransactions(
        userLogin,
        transactions.map((t) => t.toMap()).toList(),
      );

      print('💾 Save result: $saved');

      // Verifikasi data tersimpan
      if (saved) {
        final verifyTransactions = await UserDataManager.getTransactions(
          userLogin,
        );
        print(
          '✓ Verification - Transactions in storage: ${verifyTransactions.length}',
        );
        
        // ⭐ Verifikasi status tersimpan
        final savedTransaction = verifyTransactions.firstWhere(
          (t) => t['id'] == transactionId,
          orElse: () => <String, dynamic>{},
        );
        if (savedTransaction.isNotEmpty) {
          print('✓ Saved transaction status: ${savedTransaction['status']}');
        }
      }

      return saved;
    } catch (e) {
      debugPrint('❌ Error creating transaction: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
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

      final transactions = data.map((item) => Transaction.fromMap(item)).toList();
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
  static Future<List<Transaction>> getTransactionsByStatus(String status) async {
    final transactions = await getTransactions();
    if (status == 'Semua Status') return transactions;
    return transactions.where((t) => t.status == status).toList();
  }

  // Filter transaksi berdasarkan tanggal
  static Future<List<Transaction>> getTransactionsByDate(String dateFilter) async {
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
  static Future<List<Transaction>> getTransactionsByCategory(String category) async {
    final transactions = await getTransactions();
    if (category == 'Semua') return transactions;

    String? deliveryOption;
    if (category == 'Xpress') {
      deliveryOption = 'xpress';
    } else if (category == 'Xtra') {
      deliveryOption = 'xtra';
    }

    if (deliveryOption == null) return transactions;

    return transactions.where((t) => t.deliveryOption == deliveryOption).toList();
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

      transactions = transactions.where((t) => t.date.isAfter(startDate)).toList();
      print('🔍 After date filter: ${transactions.length}');
    }

    // Filter kategori
    if (category != 'Semua') {
      String? deliveryOption;
      if (category == 'Xpress') {
        deliveryOption = 'xpress';
      } else if (category == 'Xtra') {
        deliveryOption = 'xtra';
      }

      if (deliveryOption != null) {
        transactions = transactions
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
    return transactions.fold<double>(0.0, (sum, t) => sum + t.totalPrice);
  }

  // ⭐ TAMBAHAN: Hitung total dari transaksi yang selesai saja
  static Future<double> getTotalSpendingCompleted() async {
    final transactions = await getTransactions();
    return transactions
        .where((t) => t.status == 'Selesai')
        .fold<double>(0.0, (sum, t) => sum + t.totalPrice);
  }
  
  // Dispose resources
  static void dispose() {
    _statusController.close();
  }
}