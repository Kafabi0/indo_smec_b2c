import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SaldoKlikManager {
  static const String _saldoKey = 'saldo_klik';
  static const String _historyKey = 'saldo_history';
  static const String _isActiveKey = 'saldo_klik_active';

  // Cek apakah Saldo Klik sudah diaktifkan
  static Future<bool> isActive() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isActiveKey) ?? false;
  }

  // Aktifkan Saldo Klik
  static Future<bool> activate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isActiveKey, true);
    // Set saldo awal Rp 0
    await prefs.setDouble(_saldoKey, 0.0);
    
    // Tambahkan history aktivasi
    await _addHistory(
      type: 'activation',
      amount: 0,
      description: 'Aktivasi Saldo Klik',
      status: 'success',
    );
    
    return true;
  }

  // Dapatkan saldo saat ini
  static Future<double> getSaldo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_saldoKey) ?? 0.0;
  }

  // Top up saldo
  static Future<bool> topUp(double amount, String paymentMethod) async {
    if (amount <= 0) return false;
    
    final prefs = await SharedPreferences.getInstance();
    final currentSaldo = await getSaldo();
    final newSaldo = currentSaldo + amount;
    
    await prefs.setDouble(_saldoKey, newSaldo);
    
    await _addHistory(
      type: 'topup',
      amount: amount,
      description: 'Isi Saldo via $paymentMethod',
      status: 'success',
    );
    
    return true;
  }

  // Kurangi saldo (untuk pembayaran)
  static Future<bool> deductSaldo(double amount, String description) async {
    if (amount <= 0) return false;
    
    final currentSaldo = await getSaldo();
    if (currentSaldo < amount) return false; // Saldo tidak cukup
    
    final prefs = await SharedPreferences.getInstance();
    final newSaldo = currentSaldo - amount;
    
    await prefs.setDouble(_saldoKey, newSaldo);
    
    await _addHistory(
      type: 'payment',
      amount: -amount,
      description: description,
      status: 'success',
    );
    
    return true;
  }

  // Tarik saldo ke rekening
  static Future<bool> withdraw(double amount, String bankName, String accountNumber) async {
    if (amount <= 0) return false;
    
    final currentSaldo = await getSaldo();
    if (currentSaldo < amount) return false; // Saldo tidak cukup
    
    final prefs = await SharedPreferences.getInstance();
    final newSaldo = currentSaldo - amount;
    
    await prefs.setDouble(_saldoKey, newSaldo);
    
    await _addHistory(
      type: 'withdraw',
      amount: -amount,
      description: 'Tarik Saldo ke $bankName - $accountNumber',
      status: 'processing',
    );
    
    return true;
  }

  // Tambah history transaksi
  static Future<void> _addHistory({
    required String type,
    required double amount,
    required String description,
    required String status,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_historyKey) ?? '[]';
    final List<dynamic> history = jsonDecode(historyJson);
    
    final newTransaction = {
      'id': 'TRX${DateTime.now().millisecondsSinceEpoch}',
      'type': type, // topup, payment, withdraw, activation
      'amount': amount,
      'description': description,
      'status': status, // success, processing, failed
      'date': DateTime.now().toIso8601String(),
      'balance_after': await getSaldo(),
    };
    
    history.insert(0, newTransaction); // Tambahkan di awal list
    
    await prefs.setString(_historyKey, jsonEncode(history));
  }

  // Dapatkan history transaksi
  static Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_historyKey) ?? '[]';
    final List<dynamic> history = jsonDecode(historyJson);
    
    return history.cast<Map<String, dynamic>>();
  }

  // Clear semua data (untuk logout)
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_saldoKey);
    await prefs.remove(_historyKey);
    await prefs.remove(_isActiveKey);
  }
}