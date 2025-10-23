import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/product_model.dart';
import '../utils/user_data_manager.dart';

class FavoriteService {
  // Singleton pattern
  static final FavoriteService _instance = FavoriteService._internal();
  factory FavoriteService() => _instance;
  FavoriteService._internal();

  // ========== HELPER: Get Current User ==========
  Future<String?> _getCurrentUser() async {
    return await UserDataManager.getCurrentUserLogin();
  }

  // Generate key unik untuk favorit per user
  String _getUserFavoriteKey(String loginValue) {
    final encoded = base64Encode(utf8.encode(loginValue));
    return 'user_${encoded}_favorites';
  }

  // ========== SAVE & GET FAVORITE IDS ==========

  /// Simpan list product IDs ke SharedPreferences untuk user tertentu
  Future<void> _saveFavoriteIds(String loginValue, List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getUserFavoriteKey(loginValue);
    await prefs.setStringList(key, ids);
  }

  /// Ambil list product IDs dari SharedPreferences untuk user tertentu
  Future<List<String>> _getFavoriteIds(String loginValue) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getUserFavoriteKey(loginValue);
    return prefs.getStringList(key) ?? [];
  }

  // ========== PUBLIC METHODS ==========

  /// Toggle favorit (tambah atau hapus) untuk user yang sedang login
  Future<bool> toggleFavorite(String productId) async {
    final currentUser = await _getCurrentUser();
    if (currentUser == null) {
      // Jika belum login, gunakan key guest
      return await _toggleFavoriteGuest(productId);
    }

    final ids = await _getFavoriteIds(currentUser);

    if (ids.contains(productId)) {
      ids.remove(productId);
      await _saveFavoriteIds(currentUser, ids);
      return false; // Product dihapus dari favorit
    } else {
      ids.add(productId);
      await _saveFavoriteIds(currentUser, ids);
      return true; // Product ditambahkan ke favorit
    }
  }

  /// Toggle favorit untuk user guest (belum login)
  Future<bool> _toggleFavoriteGuest(String productId) async {
    const guestKey = 'guest_favorites';
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(guestKey) ?? [];

    if (ids.contains(productId)) {
      ids.remove(productId);
      await prefs.setStringList(guestKey, ids);
      return false;
    } else {
      ids.add(productId);
      await prefs.setStringList(guestKey, ids);
      return true;
    }
  }

  /// Cek apakah produk sudah difavoritkan oleh user yang sedang login
  Future<bool> isFavorite(String productId) async {
    final currentUser = await _getCurrentUser();
    if (currentUser == null) {
      // Guest mode
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList('guest_favorites') ?? [];
      return ids.contains(productId);
    }

    final ids = await _getFavoriteIds(currentUser);
    return ids.contains(productId);
  }

  /// Ambil semua product IDs yang difavoritkan oleh user yang sedang login
  Future<List<String>> getAllFavoriteIds() async {
    final currentUser = await _getCurrentUser();
    if (currentUser == null) {
      // Guest mode
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList('guest_favorites') ?? [];
    }

    return await _getFavoriteIds(currentUser);
  }

  /// Hapus semua favorit user yang sedang login
  Future<void> clearAllFavorites() async {
    final currentUser = await _getCurrentUser();
    if (currentUser == null) {
      // Guest mode
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('guest_favorites');
      return;
    }

    await _saveFavoriteIds(currentUser, []);
  }

  /// Hapus satu produk dari favorit user yang sedang login
  Future<void> removeFavorite(String productId) async {
    final currentUser = await _getCurrentUser();
    if (currentUser == null) {
      // Guest mode
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList('guest_favorites') ?? [];
      ids.remove(productId);
      await prefs.setStringList('guest_favorites', ids);
      return;
    }

    final ids = await _getFavoriteIds(currentUser);
    ids.remove(productId);
    await _saveFavoriteIds(currentUser, ids);
  }

  // ========== MIGRATION UTILITY ==========

  /// Migrasi favorit dari guest ke user setelah login
  Future<void> migrateGuestFavoritesToUser(String loginValue) async {
    final prefs = await SharedPreferences.getInstance();
    final guestFavorites = prefs.getStringList('guest_favorites') ?? [];

    if (guestFavorites.isEmpty) return;

    // Ambil favorit user yang sudah ada
    final userFavorites = await _getFavoriteIds(loginValue);

    // Gabungkan dengan favorit guest (hindari duplikat)
    final mergedFavorites = {...userFavorites, ...guestFavorites}.toList();

    // Simpan ke akun user
    await _saveFavoriteIds(loginValue, mergedFavorites);

    // Hapus favorit guest
    await prefs.remove('guest_favorites');

    print(
      '✅ Migrasi ${guestFavorites.length} favorit dari guest ke user $loginValue',
    );
  }

  /// Hapus semua data favorit untuk user tertentu (untuk logout/delete account)
  Future<void> clearUserFavorites(String loginValue) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getUserFavoriteKey(loginValue);
    await prefs.remove(key);
  }

  // ========== DEBUG ==========

  /// Debug: Print semua favorit key yang tersimpan
  Future<void> debugPrintAllFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    print('=== ALL FAVORITE KEYS ===');
    for (var key in prefs.getKeys()) {
      if (key.contains('favorites')) {
        final value = prefs.get(key);
        print('$key: $value');
      }
    }
    print('========================');
  }
}
