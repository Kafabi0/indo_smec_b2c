// lib/utils/pin_manager.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class PinManager {
  static const String _pinPrefix = 'user_pin_';
  static const String _pinSetPrefix = 'user_pin_set_';

  /// Hash PIN untuk keamanan
  static String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Cek apakah user sudah set PIN
  static Future<bool> isPinSet(String userLogin) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_pinSetPrefix$userLogin';
    return prefs.getBool(key) ?? false;
  }

  /// Set PIN untuk user (pertama kali atau ubah PIN)
  static Future<bool> setPin(String userLogin, String pin) async {
    if (pin.length != 6) {
      print('❌ PIN harus 6 digit');
      return false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final hashedPin = _hashPin(pin);
      
      final pinKey = '$_pinPrefix$userLogin';
      final setKey = '$_pinSetPrefix$userLogin';
      
      await prefs.setString(pinKey, hashedPin);
      await prefs.setBool(setKey, true);
      
      print('✅ PIN berhasil disimpan untuk $userLogin');
      return true;
    } catch (e) {
      print('❌ Error setting PIN: $e');
      return false;
    }
  }

  /// Verifikasi PIN
  static Future<bool> verifyPin(String userLogin, String pin) async {
    if (pin.length != 6) {
      print('❌ PIN harus 6 digit');
      return false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final pinKey = '$_pinPrefix$userLogin';
      final savedHashedPin = prefs.getString(pinKey);
      
      if (savedHashedPin == null) {
        print('❌ PIN belum diset untuk user: $userLogin');
        return false;
      }
      
      final hashedPin = _hashPin(pin);
      final isValid = hashedPin == savedHashedPin;
      
      if (isValid) {
        print('✅ PIN valid');
      } else {
        print('❌ PIN salah');
      }
      
      return isValid;
    } catch (e) {
      print('❌ Error verifying PIN: $e');
      return false;
    }
  }

  /// Ubah PIN (memerlukan PIN lama)
  static Future<bool> changePin(
    String userLogin,
    String oldPin,
    String newPin,
  ) async {
    // Verifikasi PIN lama
    final isOldPinValid = await verifyPin(userLogin, oldPin);
    if (!isOldPinValid) {
      print('❌ PIN lama salah');
      return false;
    }

    // Set PIN baru
    return await setPin(userLogin, newPin);
  }

  /// Reset PIN (untuk admin atau forgot PIN)
  static Future<bool> resetPin(String userLogin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pinKey = '$_pinPrefix$userLogin';
      final setKey = '$_pinSetPrefix$userLogin';
      
      await prefs.remove(pinKey);
      await prefs.remove(setKey);
      
      print('✅ PIN berhasil direset untuk $userLogin');
      return true;
    } catch (e) {
      print('❌ Error resetting PIN: $e');
      return false;
    }
  }
}