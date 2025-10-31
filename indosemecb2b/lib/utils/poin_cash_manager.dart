// ============================================
// FIXED: poin_cash_manager.dart - Save with Product Data
// ============================================

import 'package:shared_preferences/shared_preferences.dart';
import 'package:indosemecb2b/utils/user_data_manager.dart';
import 'package:indosemecb2b/utils/pin_manager.dart';
import 'package:indosemecb2b/models/cart_item.dart';

class PoinCashManager {
  static const String _historyPrefix = 'poin_cash_history_';

  /// Get total Poin Cash dari transaksi selesai
  static Future<double> getTotalPoinCash() async {
    final userLogin = await UserDataManager.getCurrentUserLogin();
    if (userLogin == null) return 0.0;

    final transactions = await UserDataManager.getTransactions(userLogin);

    double totalPoinCash = 0.0;
    double usedPoinCash = 0.0;

    print('📊 [POIN CASH] Menghitung total Poin Cash...');

    for (var transaction in transactions) {
      // ⏭️ SKIP transaksi Top-Up (tidak memberikan poin cash)
      if (transaction['deliveryOption'] == 'topup') {
        print('   ⏭️ Skip Top-Up: ${transaction['id']}');
        continue;
      }

      // ✅ HITUNG PENGGUNAAN POIN CASH DARI METADATA
      if (transaction['alamat'] != null) {
        final alamat = transaction['alamat'] as Map<String, dynamic>;

        if (alamat['is_using_poin_cash'] == true &&
            alamat['poin_cash_used'] != null) {
          final amount = (alamat['poin_cash_used']).toDouble();
          usedPoinCash += amount;
          print(
            '   💸 Used Poin Cash (from metadata): ${transaction['id']} = -Rp$amount',
          );
        }
      }

      // ✅ HITUNG POIN DARI TRANSAKSI SELESAI
      if (transaction['status'] == 'Selesai') {
        final totalPrice = (transaction['totalPrice'] ?? 0.0).toDouble();
        final voucherDiscount = (transaction['voucher_discount'] ?? 0.0);
        final actualPaid =
            totalPrice -
            (voucherDiscount is int
                ? voucherDiscount.toDouble()
                : voucherDiscount);

        final poinUMKM = (actualPaid / 1000).floor();
        final poinCash = poinUMKM * 10;
        totalPoinCash += poinCash;
        print(
          '   ➕ ${transaction['id']}: +Rp$poinCash poin cash (dari Rp${actualPaid.toInt()} setelah diskon)',
        );
      }
    }

    // Bonus member baru
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('poin_welcome_given') ?? false;
    if (!isFirstTime) {
      totalPoinCash += 10000;
      await prefs.setBool('poin_welcome_given', true);
      print('   🎁 Welcome bonus: +Rp10,000 poin cash');
    }

    final availablePoinCash = totalPoinCash - usedPoinCash;

    print('═══════════════════════════════════════');
    print('💰 [POIN CASH] Total Earned: Rp$totalPoinCash');
    print('💸 [POIN CASH] Total Used: Rp$usedPoinCash');
    print('✅ [POIN CASH] Available: Rp$availablePoinCash');
    print('═══════════════════════════════════════');

    return availablePoinCash < 0 ? 0.0 : availablePoinCash;
  }

  /// ✅ SIMPLIFIED: Hanya validasi PIN & saldo
  /// Actual transaction save akan dilakukan di checkout.dart
  static Future<Map<String, dynamic>> validatePoinCashUsage({
    required double amount,
    required String pin,
  }) async {
    final userLogin = await UserDataManager.getCurrentUserLogin();
    if (userLogin == null) {
      return {'success': false, 'message': 'User tidak login'};
    }

    print('═══════════════════════════════════════');
    print('💳 [VALIDATE POIN CASH] Memvalidasi...');
    print('   Amount to use: Rp$amount');
    print('═══════════════════════════════════════');

    // 1. Verifikasi PIN
    final isPinValid = await PinManager.verifyPin(userLogin, pin);
    if (!isPinValid) {
      print('❌ PIN salah');
      return {'success': false, 'message': 'PIN salah'};
    }
    print('✅ PIN verified');

    // 2. Cek saldo poin cash
    final availablePoinCash = await getTotalPoinCash();
    print('📊 Available Poin Cash: Rp$availablePoinCash');

    if (availablePoinCash < amount) {
      print('❌ Insufficient Poin Cash');
      return {
        'success': false,
        'message':
            'Poin Cash tidak mencukupi (Tersedia: Rp${availablePoinCash.toInt()})',
      };
    }

    final remainingPoinCash = availablePoinCash - amount;

    print('═══════════════════════════════════════');
    print('✅ [SUCCESS] Validasi berhasil!');
    print('   Will use: Rp${amount.toInt()}');
    print('   Will remain: Rp${remainingPoinCash.toInt()}');
    print('   Note: Transaction will be saved by checkout.dart');
    print('═══════════════════════════════════════');

    return {
      'success': true,
      'message': 'Validasi berhasil',
      'remainingPoinCash': remainingPoinCash,
    };
  }

  /// ✅ FIXED: Gunakan Poin Cash dengan menyimpan data produk yang dibeli
  static Future<Map<String, dynamic>> usePoinCash({
    required double amount,
    required String pin,
    required String transactionId,
    required List<CartItem> cartItems, // ✅ TAMBAH PARAMETER INI
    Map<String, dynamic>? alamat, // ✅ TAMBAH PARAMETER INI
  }) async {
    final userLogin = await UserDataManager.getCurrentUserLogin();
    if (userLogin == null) {
      return {'success': false, 'message': 'User tidak login'};
    }

    print('═══════════════════════════════════════');
    print('💳 [USE POIN CASH] Memproses...');
    print('   Amount to use: Rp$amount');
    print('   Transaction ID: $transactionId');
    print('   Cart Items: ${cartItems.length}');
    print('═══════════════════════════════════════');

    // 1. Verifikasi PIN
    final isPinValid = await PinManager.verifyPin(userLogin, pin);
    if (!isPinValid) {
      print('❌ PIN salah');
      return {'success': false, 'message': 'PIN salah'};
    }
    print('✅ PIN verified');

    // 2. Cek saldo poin cash
    final availablePoinCash = await getTotalPoinCash();
    print('📊 Available Poin Cash: Rp$availablePoinCash');

    if (availablePoinCash < amount) {
      print('❌ Insufficient Poin Cash');
      return {
        'success': false,
        'message':
            'Poin Cash tidak mencukupi (Tersedia: Rp${availablePoinCash.toInt()})',
      };
    }

    // 3. Simpan riwayat penggunaan dengan data produk
    try {
      final transactions = await UserDataManager.getTransactions(userLogin);

      // ✅ CONVERT CART ITEMS KE FORMAT YANG BENAR
      final itemsData =
          cartItems
              .map(
                (item) => {
                  'productId': item.productId,
                  'name': item.name,
                  'price': item.price,
                  'quantity': item.quantity,
                  'imageUrl':
                      item.imageUrl ??
                      'https://i.pinimg.com/736x/65/c4/1d/65c41db5a939f1e45c5f1ff1244689f5.jpg',
                },
              )
              .toList();

      print('📦 Items data prepared: ${itemsData.length} items');
      for (var item in itemsData) {
        print('   - ${item['name']} x${item['quantity']}');
      }

      // ✅ BUAT TRANSAKSI PENGGUNAAN DENGAN DATA PRODUK LENGKAP
      final usageTransaction = {
        'id': 'POIN_$transactionId',
        'date': DateTime.now().toIso8601String(),
        'status': 'Selesai',

        // ⭐ FLAGS PENTING
        'isPoinCashUsage': true,
        'amount': amount,
        'deliveryOption': 'poin_cash_usage',

        // ✅ DATA PRODUK YANG DIBELI
        'items': itemsData,
        'totalPrice': amount,

        // ✅ ALAMAT PENGIRIMAN (jika ada)
        'alamat':
            alamat ??
            {
              'nama_penerima': 'Potongan Harga',
              'nomor_hp': userLogin,
              'alamat_lengkap': 'Digunakan untuk potongan pembayaran',
              'metode_pembayaran': 'Poin Cash',
            },

        'catatanPengiriman':
            'Penggunaan Poin Cash untuk transaksi $transactionId',
        'metodePembayaran': 'Poin Cash',
        'transactionId': transactionId,
      };

      print('💾 [SAVE] Menyimpan transaksi penggunaan...');
      print('   ID: ${usageTransaction['id']}');
      print('   isPoinCashUsage: ${usageTransaction['isPoinCashUsage']}');
      print('   amount: Rp${usageTransaction['amount']}');
      print('   items count: ${(usageTransaction['items'] as List).length}');

      // Tambahkan transaksi penggunaan poin cash
      transactions.insert(0, usageTransaction);

      final saved = await UserDataManager.saveTransactions(
        userLogin,
        transactions,
      );

      if (!saved) {
        print('❌ Gagal menyimpan ke storage');
        return {
          'success': false,
          'message': 'Gagal menyimpan riwayat penggunaan',
        };
      }

      print('✅ Transaksi usage berhasil disimpan');

      // Verifikasi data tersimpan
      final verifyTransactions = await UserDataManager.getTransactions(
        userLogin,
      );
      final savedTx = verifyTransactions.firstWhere(
        (t) => t['id'] == 'POIN_$transactionId',
        orElse: () => {},
      );

      if (savedTx.isNotEmpty) {
        print('✓ Verification successful:');
        print('  - ID: ${savedTx['id']}');
        print('  - isPoinCashUsage: ${savedTx['isPoinCashUsage']}');
        print('  - amount: ${savedTx['amount']}');
        print('  - items: ${(savedTx['items'] as List?)?.length ?? 0}');
      } else {
        print('⚠️ Warning: Transaksi tidak ditemukan setelah save!');
      }

      final remainingPoinCash = availablePoinCash - amount;

      print('═══════════════════════════════════════');
      print('✅ [SUCCESS] Poin Cash berhasil digunakan!');
      print('   Used: Rp${amount.toInt()}');
      print('   Remaining: Rp${remainingPoinCash.toInt()}');
      print('═══════════════════════════════════════');

      return {
        'success': true,
        'message': 'Poin Cash berhasil digunakan',
        'remainingPoinCash': remainingPoinCash,
      };
    } catch (e, stackTrace) {
      print('❌ Error using poin cash: $e');
      print('Stack trace: $stackTrace');
      return {'success': false, 'message': 'Gagal menggunakan Poin Cash: $e'};
    }
  }

  /// Get riwayat penggunaan Poin Cash
  static Future<List<Map<String, dynamic>>> getPoinCashHistory() async {
    final userLogin = await UserDataManager.getCurrentUserLogin();
    if (userLogin == null) return [];

    final transactions = await UserDataManager.getTransactions(userLogin);
    return transactions.where((t) => t['isPoinCashUsage'] == true).toList();
  }
}
