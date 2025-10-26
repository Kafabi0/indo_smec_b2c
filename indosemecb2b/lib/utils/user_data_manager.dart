// lib/utils/user_data_manager.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserDataManager {
  // Ganti nama key supaya bisa menampung email / no telepon
  static const String _currentUserKey = 'current_user_login';

  /// Mendapatkan user yang sedang login (email atau no telepon)
  static Future<String?> getCurrentUserLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey);
  }

  /// Set user yang sedang login (email atau no telepon)
  static Future<void> setCurrentUser(String loginValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, loginValue);
  }

  /// Clear current user (untuk logout)
  static Future<void> clearCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  /// Generate key unik untuk setiap user
  static String _getUserKey(String loginValue, String dataType) {
    // Encode supaya karakter aman
    final encoded = base64Encode(utf8.encode(loginValue));
    return 'user_${encoded}_$dataType';
  }

  // ==================== ALAMAT ====================
  static Future<bool> saveAlamat(
    String loginValue,
    Map<String, dynamic> alamatData,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getUserKey(loginValue, 'alamat');
      return await prefs.setString(key, jsonEncode(alamatData));
    } catch (e) {
      print('Error saving alamat: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getAlamat(String loginValue) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getUserKey(loginValue, 'alamat');
      final jsonString = prefs.getString(key);
      if (jsonString == null) return null;
      return jsonDecode(jsonString);
    } catch (e) {
      print('Error getting alamat: $e');
      return null;
    }
  }

  // ==================== ALAMAT LIST ====================
  static Future<bool> saveAlamatList(
    String loginValue,
    List<Map<String, dynamic>> alamatList,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getUserKey(loginValue, 'alamat_list');
      return await prefs.setString(key, jsonEncode(alamatList));
    } catch (e) {
      print('Error saving alamat list: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getAlamatList(
    String loginValue,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getUserKey(loginValue, 'alamat_list');
      final jsonString = prefs.getString(key);
      if (jsonString == null) return [];
      final List decoded = jsonDecode(jsonString);
      return decoded.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error getting alamat list: $e');
      return [];
    }
  }

  // ==================== PROFILE ====================
  static Future<bool> saveUserProfile(
    String loginValue,
    Map<String, dynamic> profileData,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getUserKey(loginValue, 'profile');
      return await prefs.setString(key, jsonEncode(profileData));
    } catch (e) {
      print('Error saving profile: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getUserProfile(String loginValue) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getUserKey(loginValue, 'profile');
      final jsonString = prefs.getString(key);
      if (jsonString == null) return null;
      return jsonDecode(jsonString);
    } catch (e) {
      print('Error getting profile: $e');
      return null;
    }
  }

  // ==================== KERANJANG ====================
  static Future<bool> saveCart(
    String loginValue,
    List<Map<String, dynamic>> cartItems,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getUserKey(loginValue, 'cart');
      return await prefs.setString(key, jsonEncode(cartItems));
    } catch (e) {
      print('Error saving cart: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getCart(String loginValue) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getUserKey(loginValue, 'cart');
      final jsonString = prefs.getString(key);
      if (jsonString == null) return [];
      final List decoded = jsonDecode(jsonString);
      return decoded.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error getting cart: $e');
      return [];
    }
  }

  // ==================== TRANSAKSI ====================
  static Future<bool> saveTransactions(
    String loginValue,
    List<Map<String, dynamic>> transactions,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getUserKey(loginValue, 'transactions');
      return await prefs.setString(key, jsonEncode(transactions));
    } catch (e) {
      print('Error saving transactions: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getTransactions(
    String loginValue,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getUserKey(loginValue, 'transactions');
      final jsonString = prefs.getString(key);
      if (jsonString == null) return [];
      final List decoded = jsonDecode(jsonString);
      return decoded.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error getting transactions: $e');
      return [];
    }
  }

  // ==================== UTILITY ====================
  static Future<void> clearUserData(String loginValue) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final encoded = base64Encode(utf8.encode(loginValue));
    for (var key in keys) {
      if (key.contains('user_${encoded}_')) {
        await prefs.remove(key);
      }
    }
  }

  static Future<void> debugPrintAllKeys() async {
    final prefs = await SharedPreferences.getInstance();
    print('=== ALL STORED KEYS ===');
    for (var key in prefs.getKeys()) {
      print(key);
    }
    print('======================');
  }
}
