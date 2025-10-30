import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class SaldoKlikManager {
  // ✅ User-specific keys
  static String _getSaldoKey(String userLogin) => 'saldo_klik_$userLogin';
  static String _getHistoryKey(String userLogin) => 'saldo_history_$userLogin';
  static String _getIsActiveKey(String userLogin) =>
      'saldo_klik_active_$userLogin';
  static String _getPinKey(String userLogin) => 'saldo_pin_$userLogin'; // ✅ NEW

  // ✅ Helper: Get current user login
  static Future<String?> _getCurrentUserLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('current_user_login');
  }

  // ✅ NEW: Hash PIN untuk keamanan
  static String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // ✅ NEW: Set PIN untuk user
  static Future<bool> setPin(String pin) async {
    if (pin.length != 6) {
      print('❌ [SaldoKlik] PIN must be 6 digits');
      return false;
    }

    final userLogin = await _getCurrentUserLogin();
    if (userLogin == null) {
      print('❌ [SaldoKlik] No user logged in');
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final hashedPin = _hashPin(pin);
    await prefs.setString(_getPinKey(userLogin), hashedPin);

    print('✅ [SaldoKlik] PIN set for $userLogin');
    return true;
  }

  // ✅ NEW: Verify PIN
  static Future<bool> verifyPin(String pin) async {
    final userLogin = await _getCurrentUserLogin();
    if (userLogin == null) {
      print('❌ [SaldoKlik] No user logged in');
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final storedHashedPin = prefs.getString(_getPinKey(userLogin));

    if (storedHashedPin == null) {
      print('❌ [SaldoKlik] No PIN set for $userLogin');
      return false;
    }

    final hashedPin = _hashPin(pin);
    final isValid = hashedPin == storedHashedPin;

    print('🔐 [SaldoKlik] PIN verification for $userLogin: $isValid');
    return isValid;
  }

  // ✅ NEW: Check if PIN is set
  static Future<bool> hasPinSet() async {
    final userLogin = await _getCurrentUserLogin();
    if (userLogin == null) return false;

    final prefs = await SharedPreferences.getInstance();
    final hasPin = prefs.containsKey(_getPinKey(userLogin));

    print('🔍 [SaldoKlik] PIN set for $userLogin: $hasPin');
    return hasPin;
  }

  // ✅ NEW: Change PIN
  static Future<bool> changePin(String oldPin, String newPin) async {
    // Verify old PIN first
    final isOldPinValid = await verifyPin(oldPin);
    if (!isOldPinValid) {
      print('❌ [SaldoKlik] Old PIN is incorrect');
      return false;
    }

    // Set new PIN
    return await setPin(newPin);
  }

  // Cek apakah Saldo Klik sudah diaktifkan untuk user tertentu
  static Future<bool> isActive() async {
    final userLogin = await _getCurrentUserLogin();
    if (userLogin == null) return false;

    final prefs = await SharedPreferences.getInstance();
    final key = _getIsActiveKey(userLogin);
    final isActive = prefs.getBool(key) ?? false;

    print('🔍 [SaldoKlik] Check active for $userLogin: $isActive');
    return isActive;
  }

  // ✅ UPDATED: Aktifkan Saldo Klik (sekarang memerlukan PIN)
  static Future<bool> activate(String pin) async {
    if (pin.length != 6) {
      print('❌ [SaldoKlik] PIN must be 6 digits');
      return false;
    }

    final userLogin = await _getCurrentUserLogin();
    if (userLogin == null) {
      print('❌ [SaldoKlik] No user logged in');
      return false;
    }

    final prefs = await SharedPreferences.getInstance();

    // Set PIN
    final hashedPin = _hashPin(pin);
    await prefs.setString(_getPinKey(userLogin), hashedPin);

    // Activate Saldo Klik
    await prefs.setBool(_getIsActiveKey(userLogin), true);
    await prefs.setDouble(_getSaldoKey(userLogin), 0.0);

    print('✅ [SaldoKlik] Activated for $userLogin with PIN');

    // Tambahkan history aktivasi
    await _addHistory(
      userLogin: userLogin,
      type: 'activation',
      amount: 0,
      description: 'Aktivasi Saldo Klik',
      status: 'success',
    );

    return true;
  }

  // Dapatkan saldo saat ini untuk user tertentu
  static Future<double> getSaldo() async {
    final userLogin = await _getCurrentUserLogin();
    if (userLogin == null) {
      print('❌ [SaldoKlik] No user logged in');
      return 0.0;
    }

    final prefs = await SharedPreferences.getInstance();
    final saldo = prefs.getDouble(_getSaldoKey(userLogin)) ?? 0.0;

    print(
      '💰 [SaldoKlik] Get saldo for $userLogin: Rp ${saldo.toStringAsFixed(0)}',
    );
    return saldo;
  }

  // Top up saldo untuk user tertentu
  // Top up saldo untuk user tertentu
  static Future<bool> topUp(double amount, String paymentMethod) async {
    if (amount <= 0) return false;

    final userLogin = await _getCurrentUserLogin();
    if (userLogin == null) {
      print('❌ [SaldoKlik] No user logged in');
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final currentSaldo = await getSaldo();
    final newSaldo = currentSaldo + amount;

    await prefs.setDouble(_getSaldoKey(userLogin), newSaldo);

    // ✅ Generate transaction ID untuk top-up
    final transactionId = 'TOPUP${DateTime.now().millisecondsSinceEpoch}';

    print(
      '💵 [SaldoKlik] Top up for $userLogin: +Rp ${amount.toStringAsFixed(0)} (New: Rp ${newSaldo.toStringAsFixed(0)})',
    );
    print('   Transaction ID: $transactionId');

    await _addHistory(
      userLogin: userLogin,
      type: 'topup',
      amount: amount,
      description:
          'Isi Saldo via $paymentMethod - $transactionId', // ✅ ADD TRANSACTION ID
      status: 'success',
    );

    return true;
  }

  // ✅ UPDATED: Kurangi saldo dengan verifikasi PIN
  static Future<bool> deductSaldo(
    double amount,
    String description,
    String pin,
  ) async {
    if (amount <= 0) return false;

    // ✅ Verify PIN first
    final isPinValid = await verifyPin(pin);
    if (!isPinValid) {
      print('❌ [SaldoKlik] Invalid PIN');
      return false;
    }

    final userLogin = await _getCurrentUserLogin();
    if (userLogin == null) {
      print('❌ [SaldoKlik] No user logged in');
      return false;
    }

    final currentSaldo = await getSaldo();
    if (currentSaldo < amount) {
      print(
        '❌ [SaldoKlik] Insufficient balance for $userLogin: ${currentSaldo.toStringAsFixed(0)} < ${amount.toStringAsFixed(0)}',
      );
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final newSaldo = currentSaldo - amount;

    await prefs.setDouble(_getSaldoKey(userLogin), newSaldo);

    print(
      '💸 [SaldoKlik] Deduct for $userLogin: -Rp ${amount.toStringAsFixed(0)} (New: Rp ${newSaldo.toStringAsFixed(0)})',
    );

    await _addHistory(
      userLogin: userLogin,
      type: 'payment',
      amount: -amount,
      description: description,
      status: 'success',
    );

    return true;
  }

  // Tarik saldo ke rekening untuk user tertentu
  static Future<bool> withdraw(
    double amount,
    String bankName,
    String accountNumber,
  ) async {
    if (amount <= 0) return false;

    final userLogin = await _getCurrentUserLogin();
    if (userLogin == null) {
      print('❌ [SaldoKlik] No user logged in');
      return false;
    }

    final currentSaldo = await getSaldo();
    if (currentSaldo < amount) {
      print('❌ [SaldoKlik] Insufficient balance for withdraw');
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final newSaldo = currentSaldo - amount;

    await prefs.setDouble(_getSaldoKey(userLogin), newSaldo);

    print(
      '🏦 [SaldoKlik] Withdraw for $userLogin: -Rp ${amount.toStringAsFixed(0)} to $bankName',
    );

    await _addHistory(
      userLogin: userLogin,
      type: 'withdraw',
      amount: -amount,
      description: 'Tarik Saldo ke $bankName - $accountNumber',
      status: 'processing',
    );

    return true;
  }

  // Tambah history transaksi untuk user tertentu
  static Future<void> _addHistory({
    required String userLogin,
    required String type,
    required double amount,
    required String description,
    required String status,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final historyKey = _getHistoryKey(userLogin);
    final historyJson = prefs.getString(historyKey) ?? '[]';
    final List<dynamic> history = jsonDecode(historyJson);

    final currentSaldo = await getSaldo();

    final newTransaction = {
      'id': 'TRX${DateTime.now().millisecondsSinceEpoch}',
      'type': type,
      'amount': amount,
      'description': description,
      'status': status,
      'date': DateTime.now().toIso8601String(),
      'balance_after': currentSaldo,
    };

    history.insert(0, newTransaction);

    await prefs.setString(historyKey, jsonEncode(history));

    print('📝 [SaldoKlik] History added for $userLogin: $type - $description');
  }

  // Dapatkan history transaksi untuk user tertentu
  static Future<List<Map<String, dynamic>>> getHistory() async {
    final userLogin = await _getCurrentUserLogin();
    if (userLogin == null) {
      print('❌ [SaldoKlik] No user logged in');
      return [];
    }

    final prefs = await SharedPreferences.getInstance();
    final historyKey = _getHistoryKey(userLogin);
    final historyJson = prefs.getString(historyKey) ?? '[]';
    final List<dynamic> history = jsonDecode(historyJson);

    print(
      '📜 [SaldoKlik] Get history for $userLogin: ${history.length} transactions',
    );

    return history.cast<Map<String, dynamic>>();
  }

  // Clear semua data untuk user yang sedang login (untuk logout)
  static Future<void> clear() async {
    final userLogin = await _getCurrentUserLogin();
    if (userLogin == null) {
      print('❌ [SaldoKlik] No user logged in');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_getSaldoKey(userLogin));
    await prefs.remove(_getHistoryKey(userLogin));
    await prefs.remove(_getIsActiveKey(userLogin));
    await prefs.remove(_getPinKey(userLogin)); // ✅ NEW

    print('🗑️ [SaldoKlik] Cleared data for $userLogin');
  }

  // Clear all data for specific user
  static Future<void> clearUserData(String userLogin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_getSaldoKey(userLogin));
    await prefs.remove(_getHistoryKey(userLogin));
    await prefs.remove(_getIsActiveKey(userLogin));
    await prefs.remove(_getPinKey(userLogin)); // ✅ NEW

    print('🗑️ [SaldoKlik] Cleared all data for $userLogin');
  }

  // Get all users who have activated Saldo Klik
  static Future<List<String>> getAllActiveUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();
    final activeUsers = <String>[];

    for (var key in allKeys) {
      if (key.startsWith('saldo_klik_active_') && prefs.getBool(key) == true) {
        final userLogin = key.replaceFirst('saldo_klik_active_', '');
        activeUsers.add(userLogin);
      }
    }

    print('👥 [SaldoKlik] Active users: $activeUsers');
    return activeUsers;
  }

  // Get saldo for specific user
  static Future<double> getSaldoForUser(String userLogin) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_getSaldoKey(userLogin)) ?? 0.0;
  }

  // Debug print all saldo data
  static Future<void> debugPrintAllSaldoData() async {
    print('═══════════════════════════════════');
    print('🔍 DEBUG: All Saldo Klik Data');
    print('═══════════════════════════════════');

    final activeUsers = await getAllActiveUsers();

    if (activeUsers.isEmpty) {
      print('❌ No active users found');
      return;
    }

    for (var user in activeUsers) {
      final saldo = await getSaldoForUser(user);
      print('👤 User: $user');
      print('   💰 Saldo: Rp ${saldo.toStringAsFixed(0)}');

      final prefs = await SharedPreferences.getInstance();
      final historyKey = _getHistoryKey(user);
      final historyJson = prefs.getString(historyKey) ?? '[]';
      final List<dynamic> history = jsonDecode(historyJson);
      print('   📜 Transactions: ${history.length}');

      final hasPin = prefs.containsKey(_getPinKey(user));
      print('   🔐 PIN Set: $hasPin');
      print('───────────────────────────────────');
    }

    print('═══════════════════════════════════');
  }
}
