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
    
    // Hitung poin dari transaksi selesai
    for (var transaction in transactions) {
      if (transaction['status'] == 'Selesai') {
        final totalPrice = (transaction['totalPrice'] ?? 0.0).toDouble();
        final poinUMKM = (totalPrice / 1000).floor();
        final poinCash = poinUMKM * 10;
        totalPoinCash += poinCash;
      }
    }

    // Bonus member baru
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('poin_welcome_given') ?? false;
    if (!isFirstTime) {
      totalPoinCash += 10000;
    }

    // Kurangi dengan penggunaan poin cash
    final usedPoinCash = await getUsedPoinCash();
    totalPoinCash -= usedPoinCash;

    print('💰 Total Poin Cash: $totalPoinCash (Used: $usedPoinCash)');
    
    return totalPoinCash;
  }

  /// Get total poin cash yang sudah digunakan
  static Future<double> getUsedPoinCash() async {
    final userLogin = await UserDataManager.getCurrentUserLogin();
    if (userLogin == null) return 0.0;

    final prefs = await SharedPreferences.getInstance();
    final key = '${_historyPrefix}$userLogin';
    final historyJson = prefs.getString(key);
    
    if (historyJson == null) return 0.0;

    try {
      final List<dynamic> history = 
          (await UserDataManager.getTransactions(userLogin))
              .where((t) => t['isPoinCashUsage'] == true)
              .toList();
      
      double total = 0.0;
      for (var item in history) {
        total += (item['amount'] ?? 0.0).toDouble();
      }
      
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
      
      // Tambahkan transaksi penggunaan poin cash
      transactions.insert(0, {
        'id': 'POIN_$transactionId',
        'date': DateTime.now().toIso8601String(),
        'status': 'Selesai',
        'isPoinCashUsage': true,
        'amount': amount,
        'transactionId': transactionId,
        'deliveryOption': 'poin_cash_usage',
        'items': [
          {
            'productId': 'poin_cash',
            'name': 'Penggunaan Poin Cash',
            'price': amount,
            'quantity': 1,
            'imageUrl': 'https://i.pinimg.com/736x/65/c4/1d/65c41db5a939f1e45c5f1ff1244689f5.jpg',
          }
        ],
        'totalPrice': amount,
        'alamat': {
          'nama_penerima': 'Potongan Harga',
          'nomor_hp': userLogin,
          'alamat_lengkap': 'Digunakan untuk potongan pembayaran',
          'metode_pembayaran': 'Poin Cash',
        },
        'catatanPengiriman': 'Penggunaan Poin Cash untuk transaksi $transactionId',
        'metodePembayaran': 'Poin Cash',
      });

      await UserDataManager.saveTransactions(
        userLogin,
        transactions,
      );

      print('✅ Poin Cash berhasil digunakan: Rp$amount');
      
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
    
    return transactions
        .where((t) => t['isPoinCashUsage'] == true)
        .toList();
  }
}