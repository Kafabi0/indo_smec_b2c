import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:indosemecb2b/models/voucher_model.dart';
import 'package:indosemecb2b/utils/transaction_manager.dart';

class VoucherManager {
  static const String _userVouchersKey = 'user_vouchers';
  static const String _voucherStockKey = 'voucher_stock';
  static const String _poinUsageHistoryKey = 'poin_usage_history';

  // ✅ DAFTAR VOUCHER YANG TERSEDIA
  static final List<Voucher> _availableVouchers = [
    // VOUCHER DISKON NOMINAL
    Voucher(
      id: 'V001',
      code: 'HEMAT10K',
      name: 'Voucher Diskon Rp 10.000',
      description: 'Diskon Rp 10.000 untuk belanja min. Rp 50.000',
      pointCost: 100,
      discountAmount: 10000,
      minPurchase: 50000,
      validUntil: DateTime.now().add(Duration(days: 30)),
      category: 'Semua',
      imageUrl:
          'https://i.pinimg.com/736x/42/a6/42/42a642a8e3e2e8ea9e3e2e8ea9e3e2e8.jpg',
      stock: 100,
    ),
    Voucher(
      id: 'V002',
      code: 'HEMAT25K',
      name: 'Voucher Diskon Rp 25.000',
      description: 'Diskon Rp 25.000 untuk belanja min. Rp 100.000',
      pointCost: 250,
      discountAmount: 25000,
      minPurchase: 100000,
      validUntil: DateTime.now().add(Duration(days: 30)),
      category: 'Semua',
      imageUrl:
          'https://i.pinimg.com/736x/89/3e/1f/893e1f8e3e2e8ea9e3e2e8ea9e3e2e8e.jpg',
      stock: 80,
    ),
    Voucher(
      id: 'V003',
      code: 'HEMAT50K',
      name: 'Voucher Diskon Rp 50.000',
      description: 'Diskon Rp 50.000 untuk belanja min. Rp 200.000',
      pointCost: 500,
      discountAmount: 50000,
      minPurchase: 200000,
      validUntil: DateTime.now().add(Duration(days: 30)),
      category: 'Semua',
      imageUrl:
          'https://i.pinimg.com/736x/d4/5e/2f/d45e2f8e3e2e8ea9e3e2e8ea9e3e2e8e.jpg',
      stock: 50,
    ),

    // VOUCHER KATEGORI FOOD
    Voucher(
      id: 'V004',
      code: 'FOODFEST20',
      name: 'Voucher Food Festival 20%',
      description: 'Diskon 20% untuk kategori Food, max Rp 30.000',
      pointCost: 300,
      discountAmount: 30000,
      discountPercentage: 20,
      minPurchase: 75000,
      validUntil: DateTime.now().add(Duration(days: 14)),
      category: 'Food',
      imageUrl:
          'https://i.pinimg.com/736x/1a/2b/3c/1a2b3c8e3e2e8ea9e3e2e8ea9e3e2e8e.jpg',
      stock: 60,
    ),

    // VOUCHER KATEGORI GROCERY
    Voucher(
      id: 'V005',
      code: 'GROCERYMART15',
      name: 'Voucher Grocery 15%',
      description: 'Diskon 15% untuk kategori Grocery, max Rp 40.000',
      pointCost: 350,
      discountAmount: 40000,
      discountPercentage: 15,
      minPurchase: 100000,
      validUntil: DateTime.now().add(Duration(days: 21)),
      category: 'Grocery',
      imageUrl:
          'https://i.pinimg.com/736x/5f/6e/7d/5f6e7d8e3e2e8ea9e3e2e8ea9e3e2e8e.jpg',
      stock: 70,
    ),

    // VOUCHER KATEGORI FASHION
    Voucher(
      id: 'V006',
      code: 'FASHIONSALE25',
      name: 'Voucher Fashion Sale 25%',
      description: 'Diskon 25% untuk kategori Fashion, max Rp 50.000',
      pointCost: 400,
      discountAmount: 50000,
      discountPercentage: 25,
      minPurchase: 150000,
      validUntil: DateTime.now().add(Duration(days: 30)),
      category: 'Fashion',
      imageUrl:
          'https://i.pinimg.com/736x/8a/9b/0c/8a9b0c8e3e2e8ea9e3e2e8ea9e3e2e8e.jpg',
      stock: 40,
    ),

    // VOUCHER PREMIUM
    Voucher(
      id: 'V007',
      code: 'MEGA100K',
      name: 'Mega Voucher Rp 100.000',
      description: 'Diskon Rp 100.000 untuk belanja min. Rp 500.000',
      pointCost: 1000,
      discountAmount: 100000,
      minPurchase: 500000,
      validUntil: DateTime.now().add(Duration(days: 60)),
      category: 'Semua',
      imageUrl:
          'https://i.pinimg.com/736x/3d/4e/5f/3d4e5f8e3e2e8ea9e3e2e8ea9e3e2e8e.jpg',
      stock: 30,
    ),

    // VOUCHER HERBAL
    Voucher(
      id: 'V008',
      code: 'SEHAT30',
      name: 'Voucher Herbal 30%',
      description: 'Diskon 30% untuk kategori Herbal, max Rp 25.000',
      pointCost: 200,
      discountAmount: 25000,
      discountPercentage: 30,
      minPurchase: 50000,
      validUntil: DateTime.now().add(Duration(days: 30)),
      category: 'Herbal',
      imageUrl:
          'https://i.pinimg.com/736x/6e/7f/8a/6e7f8a8e3e2e8ea9e3e2e8ea9e3e2e8e.jpg',
      stock: 55,
    ),
  ];

  // ✅ GET SEMUA VOUCHER YANG TERSEDIA
  static List<Voucher> getAvailableVouchers() {
    return _availableVouchers.where((v) => v.isAvailable).toList();
  }

  // ✅ GET VOUCHER BY CATEGORY
  static List<Voucher> getVouchersByCategory(String category) {
    if (category == 'Semua') {
      return getAvailableVouchers();
    }
    return _availableVouchers
        .where(
          (v) =>
              v.isAvailable &&
              (v.category == category || v.category == 'Semua'),
        )
        .toList();
  }

  // ✅ GET CURRENT USER POIN UMKM
  static Future<int> getUserPoinUMKM() async {
    final transactions = await TransactionManager.getFilteredTransactions(
      status: 'Selesai',
      dateFilter: 'Semua Tanggal',
      category: 'Semua',
    );

    int poinFromTransactions = 0;

    for (var transaction in transactions) {
      // Skip transaksi penggunaan Poin Cash dan Top-Up
      if (transaction.deliveryOption == 'poin_cash_usage' ||
          transaction.deliveryOption == 'topup') {
        continue;
      }

      // Poin UMKM: Rp 1.000 = 1 Poin
      int poin = (transaction.totalPrice / 1000).floor();
      poinFromTransactions += poin;
    }

    // Bonus poin member baru
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('poin_welcome_given') ?? false;
    if (!isFirstTime) {
      poinFromTransactions += 1000;
      await prefs.setBool('poin_welcome_given', true);
    }

    // Kurangi poin yang sudah digunakan untuk voucher
    final usedPoints = await _getTotalUsedPoints();

    return poinFromTransactions - usedPoints;
  }

  // ✅ GET TOTAL POIN YANG SUDAH DIGUNAKAN
  static Future<int> _getTotalUsedPoints() async {
    final prefs = await SharedPreferences.getInstance();
    final usageHistoryJson = prefs.getStringList(_poinUsageHistoryKey) ?? [];

    int totalUsed = 0;
    for (var json in usageHistoryJson) {
      final usage = jsonDecode(json);
      totalUsed += (usage['pointsUsed'] as int);
    }

    return totalUsed;
  }

  // ✅ SAVE POIN USAGE HISTORY
  static Future<void> _savePoinUsage(String voucherId, int pointsUsed) async {
    final prefs = await SharedPreferences.getInstance();
    final usageHistoryJson = prefs.getStringList(_poinUsageHistoryKey) ?? [];

    final usage = {
      'id': 'PU${DateTime.now().millisecondsSinceEpoch}',
      'voucherId': voucherId,
      'pointsUsed': pointsUsed,
      'date': DateTime.now().toIso8601String(),
    };

    usageHistoryJson.add(jsonEncode(usage));
    await prefs.setStringList(_poinUsageHistoryKey, usageHistoryJson);
  }

  // ✅ TUKAR POIN DENGAN VOUCHER (DENGAN PEMOTONGAN POIN OTOMATIS)
  static Future<Map<String, dynamic>> redeemVoucher(
    String voucherId,
    int userPoints,
  ) async {
    try {
      // Cari voucher
      final voucher = _availableVouchers.firstWhere(
        (v) => v.id == voucherId,
        orElse: () => throw Exception('Voucher tidak ditemukan'),
      );

      // Validasi
      if (!voucher.isAvailable) {
        return {
          'success': false,
          'message': 'Voucher tidak tersedia atau sudah habis',
        };
      }

      if (userPoints < voucher.pointCost) {
        return {
          'success': false,
          'message':
              'Poin tidak cukup. Butuh ${voucher.pointCost} poin, Anda punya $userPoints poin',
        };
      }

      // Buat UserVoucher
      final userVoucher = UserVoucher(
        id: 'UV${DateTime.now().millisecondsSinceEpoch}',
        voucherId: voucher.id,
        code: voucher.code,
        name: voucher.name,
        discountAmount: voucher.discountAmount,
        discountPercentage: voucher.discountPercentage,
        minPurchase: voucher.minPurchase,
        redeemedAt: DateTime.now(),
        validUntil: voucher.validUntil,
        category: voucher.category,
      );

      // Simpan ke user vouchers
      final prefs = await SharedPreferences.getInstance();
      final userVouchersJson = prefs.getStringList(_userVouchersKey) ?? [];
      userVouchersJson.add(jsonEncode(userVoucher.toJson()));
      await prefs.setStringList(_userVouchersKey, userVouchersJson);

      // ✅ POTONG POIN UMKM (SIMPAN KE HISTORY)
      await _savePoinUsage(voucher.id, voucher.pointCost);

      // Kurangi stok voucher
      final stockKey = '${_voucherStockKey}_${voucherId}';
      final currentStock = prefs.getInt(stockKey) ?? voucher.stock;
      await prefs.setInt(stockKey, currentStock - 1);

      return {
        'success': true,
        'message':
            'Voucher berhasil ditukar!\nPoin UMKM Anda dikurangi ${voucher.pointCost}',
        'voucher': userVoucher,
        'pointsUsed': voucher.pointCost,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // ✅ GET USER VOUCHERS (YANG SUDAH DITUKAR)
  static Future<List<UserVoucher>> getUserVouchers({
    bool onlyValid = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userVouchersJson = prefs.getStringList(_userVouchersKey) ?? [];

    final vouchers =
        userVouchersJson
            .map((json) => UserVoucher.fromJson(jsonDecode(json)))
            .toList();

    if (onlyValid) {
      return vouchers.where((v) => v.canBeUsed).toList();
    }

    // Urutkan: yang bisa dipakai dulu, lalu yang terbaru
    vouchers.sort((a, b) {
      if (a.canBeUsed && !b.canBeUsed) return -1;
      if (!a.canBeUsed && b.canBeUsed) return 1;
      return b.redeemedAt.compareTo(a.redeemedAt);
    });

    return vouchers;
  }

  // ✅ USE VOUCHER (PAKAI VOUCHER SAAT CHECKOUT)
  static Future<bool> useVoucher(
    String userVoucherId,
    String transactionId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userVouchersJson = prefs.getStringList(_userVouchersKey) ?? [];

      final vouchers =
          userVouchersJson
              .map((json) => UserVoucher.fromJson(jsonDecode(json)))
              .toList();

      final index = vouchers.indexWhere((v) => v.id == userVoucherId);
      if (index == -1) return false;

      final voucher = vouchers[index];
      if (!voucher.canBeUsed) return false;

      // Update voucher sebagai terpakai
      final updatedVoucher = UserVoucher(
        id: voucher.id,
        voucherId: voucher.voucherId,
        code: voucher.code,
        name: voucher.name,
        discountAmount: voucher.discountAmount,
        discountPercentage: voucher.discountPercentage,
        minPurchase: voucher.minPurchase,
        redeemedAt: voucher.redeemedAt,
        validUntil: voucher.validUntil,
        category: voucher.category,
        isUsed: true,
        usedTransactionId: transactionId,
        usedAt: DateTime.now(),
      );

      vouchers[index] = updatedVoucher;

      // Simpan kembali
      final updatedJson = vouchers.map((v) => jsonEncode(v.toJson())).toList();
      await prefs.setStringList(_userVouchersKey, updatedJson);

      return true;
    } catch (e) {
      print('Error using voucher: $e');
      return false;
    }
  }

  // ✅ CALCULATE DISCOUNT (HITUNG DISKON DARI VOUCHER)
  static int calculateDiscount(UserVoucher voucher, int totalPrice) {
    if (totalPrice < voucher.minPurchase) return 0;

    if (voucher.discountPercentage != null) {
      final percentDiscount =
          (totalPrice * voucher.discountPercentage! / 100).round();
      return percentDiscount > voucher.discountAmount
          ? voucher.discountAmount
          : percentDiscount;
    }

    return voucher.discountAmount;
  }

  // ✅ DELETE EXPIRED VOUCHERS (HAPUS VOUCHER KADALUARSA)
  static Future<void> cleanExpiredVouchers() async {
    final prefs = await SharedPreferences.getInstance();
    final userVouchersJson = prefs.getStringList(_userVouchersKey) ?? [];

    final validVouchers =
        userVouchersJson
            .map((json) => UserVoucher.fromJson(jsonDecode(json)))
            .where((v) => !v.isExpired || v.isUsed)
            .toList();

    final updatedJson =
        validVouchers.map((v) => jsonEncode(v.toJson())).toList();
    await prefs.setStringList(_userVouchersKey, updatedJson);
  }
}
