// lib/utils/transaction_manager.dart
import 'package:flutter/foundation.dart';
import 'package:indosemecb2b/utils/user_data_manager.dart';
import 'package:indosemecb2b/models/transaction.dart';
import 'package:indosemecb2b/models/cart_item.dart';

class TransactionManager {
  // Buat transaksi dari keranjang
  static Future<bool> createTransaction({
    required List<CartItem> cartItems,
    required String deliveryOption,
    Map<String, dynamic>? alamat,
    String? initialStatus, // ⭐ Tambahkan parameter untuk status awal
    String? catatanPengiriman, // ✅ TAMBAHKAN PARAMETER
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
      final items =
          cartItems.map((cartItem) {
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
      );

      print('💰 Total price: $total');

      // ⭐ Gunakan status yang diberikan atau default 'Diproses'
      final status = initialStatus ?? 'Diproses';
      print('📊 Transaction status: $status');

      // Buat objek transaksi
      final transaction = Transaction(
        id: transactionId,
        date: DateTime.now(),
        status: status, // ⭐ Status dinamis
        deliveryOption: deliveryOption,
        alamat: alamat,
        items: items,
        totalPrice: total,
        catatanPengiriman: catatanPengiriman, // ✅ SIMPAN CATATAN
      );

      print('✅ Transaction object created');
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

      // ⭐ Debug: Print sample data
      if (data.isNotEmpty) {
        print('📊 Sample transaction data: ${data.first}');
      } else {
        print('⚠️ No transaction data found for user: $userLogin');
      }

      final transactions =
          data.map((item) => Transaction.fromMap(item)).toList();
      print('✅ Parsed transactions: ${transactions.length}');

      // ⭐ Debug: Print parsed transactions
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

    // Map kategori ke delivery option
    String? deliveryOption;
    if (category == 'Xpress') {
      deliveryOption = 'xpress';
    } else if (category == 'Xtra') {
      deliveryOption = 'xtra';
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

    // Filter status
    if (status != 'Semua Status') {
      transactions = transactions.where((t) => t.status == status).toList();
      print('🔍 After status filter: ${transactions.length}');
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

  // Update status transaksi
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

      // Buat transaksi baru dengan status yang diupdate
      final updatedTransaction = Transaction(
        id: transactions[index].id,
        date: transactions[index].date,
        status: newStatus,
        deliveryOption: transactions[index].deliveryOption,
        alamat: transactions[index].alamat,
        items: transactions[index].items,
        totalPrice: transactions[index].totalPrice,
      );

      transactions[index] = updatedTransaction;

      return await UserDataManager.saveTransactions(
        userLogin,
        transactions.map((t) => t.toMap()).toList(),
      );
    } catch (e) {
      debugPrint('Error updating transaction status: $e');
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

      return await UserDataManager.saveTransactions(
        userLogin,
        transactions.map((t) => t.toMap()).toList(),
      );
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
}
