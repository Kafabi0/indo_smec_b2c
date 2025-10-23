// lib/utils/user_data_manager.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserDataManager {
  static const String _currentUserKey = 'current_user_email';
  
  /// Mendapatkan email user yang sedang login
  static Future<String?> getCurrentUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey);
  }
  
  /// Set user yang sedang login
  static Future<void> setCurrentUser(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, email);
  }
  
  /// Clear current user (untuk logout)
  static Future<void> clearCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }
  
  /// Generate key unik untuk setiap user
  static String _getUserKey(String email, String dataType) {
    // Encode email untuk menghindari karakter special
    final encodedEmail = base64Encode(utf8.encode(email));
    return 'user_${encodedEmail}_$dataType';
  }
  
  // ============ ALAMAT MANAGEMENT ============
  
  /// Simpan alamat untuk user tertentu
  static Future<bool> saveAlamat(String email, Map<String, dynamic> alamatData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getUserKey(email, 'alamat');
      final jsonString = jsonEncode(alamatData);
      return await prefs.setString(key, jsonString);
    } catch (e) {
      print('Error saving alamat: $e');
      return false;
    }
  }
  
  /// Ambil alamat untuk user tertentu
  static Future<Map<String, dynamic>?> getAlamat(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getUserKey(email, 'alamat');
      final jsonString = prefs.getString(key);
      
      if (jsonString == null) return null;
      
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('Error getting alamat: $e');
      return null;
    }
  }
  
  /// Hapus alamat untuk user tertentu
  static Future<bool> deleteAlamat(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getUserKey(email, 'alamat');
      return await prefs.remove(key);
    } catch (e) {
      print('Error deleting alamat: $e');
      return false;
    }
  }
  
  // ============ DAFTAR ALAMAT (Multiple) ============
  
  /// Simpan list alamat untuk user
  static Future<bool> saveAlamatList(String email, List<Map<String, dynamic>> alamatList) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getUserKey(email, 'alamat_list');
      final jsonString = jsonEncode(alamatList);
      return await prefs.setString(key, jsonString);
    } catch (e) {
      print('Error saving alamat list: $e');
      return false;
    }
  }
  
  /// Ambil list alamat untuk user
  static Future<List<Map<String, dynamic>>> getAlamatList(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getUserKey(email, 'alamat_list');
      final jsonString = prefs.getString(key);
      
      if (jsonString == null) return [];
      
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error getting alamat list: $e');
      return [];
    }
  }
  
  /// Tambah alamat baru ke list
  static Future<bool> addAlamatToList(String email, Map<String, dynamic> alamatData) async {
    try {
      final currentList = await getAlamatList(email);
      currentList.add(alamatData);
      return await saveAlamatList(email, currentList);
    } catch (e) {
      print('Error adding alamat: $e');
      return false;
    }
  }
  
  /// Update alamat di list berdasarkan index
  static Future<bool> updateAlamatInList(String email, int index, Map<String, dynamic> alamatData) async {
    try {
      final currentList = await getAlamatList(email);
      if (index < 0 || index >= currentList.length) return false;
      
      currentList[index] = alamatData;
      return await saveAlamatList(email, currentList);
    } catch (e) {
      print('Error updating alamat: $e');
      return false;
    }
  }
  
  /// Hapus alamat dari list berdasarkan index
  static Future<bool> deleteAlamatFromList(String email, int index) async {
    try {
      final currentList = await getAlamatList(email);
      if (index < 0 || index >= currentList.length) return false;
      
      currentList.removeAt(index);
      return await saveAlamatList(email, currentList);
    } catch (e) {
      print('Error deleting alamat: $e');
      return false;
    }
  }
  
  // ============ PROFILE DATA ============
  
  /// Simpan data profil user
  static Future<bool> saveUserProfile(String email, Map<String, dynamic> profileData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getUserKey(email, 'profile');
      final jsonString = jsonEncode(profileData);
      return await prefs.setString(key, jsonString);
    } catch (e) {
      print('Error saving profile: $e');
      return false;
    }
  }
  
  /// Ambil data profil user
  static Future<Map<String, dynamic>?> getUserProfile(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getUserKey(email, 'profile');
      final jsonString = prefs.getString(key);
      
      if (jsonString == null) return null;
      
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('Error getting profile: $e');
      return null;
    }
  }
  
  // ============ KERANJANG ============
  
  /// Simpan keranjang untuk user
  static Future<bool> saveCart(String email, List<Map<String, dynamic>> cartItems) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getUserKey(email, 'cart');
      final jsonString = jsonEncode(cartItems);
      return await prefs.setString(key, jsonString);
    } catch (e) {
      print('Error saving cart: $e');
      return false;
    }
  }
  
  /// Ambil keranjang untuk user
  static Future<List<Map<String, dynamic>>> getCart(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getUserKey(email, 'cart');
      final jsonString = prefs.getString(key);
      
      if (jsonString == null) return [];
      
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error getting cart: $e');
      return [];
    }
  }
  
  // ============ UTILITY ============
  
  /// Hapus semua data untuk user tertentu
  static Future<void> clearUserData(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final encodedEmail = base64Encode(utf8.encode(email));
    
    for (var key in keys) {
      if (key.contains('user_${encodedEmail}_')) {
        await prefs.remove(key);
      }
    }
  }
  
  /// Debug: Print semua keys yang tersimpan
  static Future<void> debugPrintAllKeys() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    print('=== ALL STORED KEYS ===');
    for (var key in keys) {
      print('Key: $key');
    }
    print('======================');
  }
}