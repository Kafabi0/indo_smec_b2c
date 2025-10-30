// lib/utils/poin_cash_manager.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:indosemecb2b/utils/user_data_manager.dart';
import 'package:indosemecb2b/utils/pin_manager.dart';

class PoinCashManager {
  static const String _historyPrefix = 'poin_cash_history_';

  /// Get total Poin Cash dari transaksi selesai
  static Future<double> getTotalPoinCash() async {
    final userLogin = await UserDataManager.getCurrentUserLogin();
    if (userLogin == null) return 0.0;

    final transactions = await UserDataManager.getTransactions(userLogin);

    double totalPoinCash = 0.0;

    // ✅ PERBAIKAN: Hitung poin dari transaksi selesai, KECUALI transaksi penggunaan Poin Cash
    for (var transaction in transactions) {
      // ⭐ SKIP transaksi penggunaan Poin Cash
      if (transaction['isPoinCashUsage'] == true) {
        print('⏭️ Skipping Poin Cash usage transaction: ${transaction['id']}');
        continue;
      }

      // ⭐ SKIP transaksi Top-Up (tidak menghasilkan poin)
      if (transaction['deliveryOption'] == 'topup') {
        print('⏭️ Skipping Top-Up transaction: ${transaction['id']}');
        continue;
      }

      if (transaction['status'] == 'Selesai') {
        final totalPrice = (transaction['totalPrice'] ?? 0.0).toDouble();
        final poinUMKM = (totalPrice / 1000).floor();
        final poinCash = poinUMKM * 10;
        totalPoinCash += poinCash;
        print('➕ Transaction ${transaction['id']}: +$poinCash poin cash');
      }
    }

    // Bonus member baru
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('poin_welcome_given') ?? false;
    if (!isFirstTime) {
      totalPoinCash += 10000;
      print('🎁 Welcome bonus: +10000 poin cash');
    }

    // ❌ HAPUS bagian pengurangan di sini - tidak perlu lagi karena sudah skip di loop
    // final usedPoinCash = await getUsedPoinCash();
    // totalPoinCash -= usedPoinCash;

    print('💰 Final Total Poin Cash: $totalPoinCash');

    return totalPoinCash;
  }

  /// Get total poin cash yang sudah digunakan
  static Future<double> getUsedPoinCash() async {
    final userLogin = await UserDataManager.getCurrentUserLogin();
    if (userLogin == null) return 0.0;

    try {
      final transactions = await UserDataManager.getTransactions(userLogin);

      // ✅ Filter hanya transaksi penggunaan Poin Cash
      final usageTransactions =
          transactions.where((t) => t['isPoinCashUsage'] == true).toList();

      double total = 0.0;
      for (var item in usageTransactions) {
        final amount = (item['amount'] ?? 0.0).toDouble();
        total += amount;
        print('💸 Used Poin Cash: ${item['id']} = $amount');
      }

      print('💸 Total Used Poin Cash: $total');
      return total;
    } catch (e) {
      print('❌ Error calculating used poin cash: $e');
      return 0.0;
    }
  }

  /// Gunakan Poin Cash dengan verifikasi PIN
  static Future<Map<String, dynamic>> usePoinCash({
    required double amount,
    required String pin,
    required String transactionId,
  }) async {
    final userLogin = await UserDataManager.getCurrentUserLogin();
    if (userLogin == null) {
      return {'success': false, 'message': 'User tidak login'};
    }

    print('💳 Menggunakan Poin Cash: Rp$amount');

    // 1. Verifikasi PIN
    final isPinValid = await PinManager.verifyPin(userLogin, pin);
    if (!isPinValid) {
      return {'success': false, 'message': 'PIN salah'};
    }

    // 2. Cek saldo poin cash
    final availablePoinCash = await getTotalPoinCash();
    if (availablePoinCash < amount) {
      return {
        'success': false,
        'message': 'Poin Cash tidak mencukupi (Tersedia: Rp$availablePoinCash)',
      };
    }

    // 3. Simpan riwayat penggunaan
    try {
      final transactions = await UserDataManager.getTransactions(userLogin);

      // ✅ PERBAIKAN: Tandai dengan jelas sebagai transaksi penggunaan Poin Cash
      final usageTransaction = {
        'id': 'POIN_$transactionId',
        'date': DateTime.now().toIso8601String(),
        'status': 'Selesai',
        'isPoinCashUsage': true, // ⭐ FLAG PENTING
        'amount': amount,
        'transactionId': transactionId,
        'deliveryOption': 'poin_cash_usage', // ⭐ DELIVERY OPTION KHUSUS
        'items': [
          {
            'productId': 'poin_cash',
            'name': 'Penggunaan Poin Cash',
            'price': amount,
            'quantity': 1,
            'imageUrl':
                'https://i.pinimg.com/736x/65/c4/1d/65c41db5a939f1e45c5f1ff1244689f5.jpg',
          },
        ],
        'totalPrice': amount,
        'alamat': {
          'nama_penerima': 'Potongan Harga',
          'nomor_hp': userLogin,
          'alamat_lengkap': 'Digunakan untuk potongan pembayaran',
          'metode_pembayaran': 'Poin Cash',
        },
        'catatanPengiriman':
            'Penggunaan Poin Cash untuk transaksi $transactionId',
        'metodePembayaran': 'Poin Cash',
      };

      // Tambahkan transaksi penggunaan poin cash
      transactions.insert(0, usageTransaction);

      await UserDataManager.saveTransactions(userLogin, transactions);

      print('✅ Poin Cash berhasil digunakan: Rp$amount');
      print('📊 Sisa Poin Cash: Rp${availablePoinCash - amount}');

      return {
        'success': true,
        'message': 'Poin Cash berhasil digunakan',
        'remainingPoinCash': availablePoinCash - amount,
      };
    } catch (e) {
      print('❌ Error using poin cash: $e');
      return {'success': false, 'message': 'Gagal menggunakan Poin Cash'};
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
