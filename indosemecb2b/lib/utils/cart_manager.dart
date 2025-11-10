// lib/utils/cart_manager.dart
import 'package:flutter/foundation.dart';
import 'package:indosemecb2b/utils/user_data_manager.dart';
import 'package:indosemecb2b/models/cart_item.dart';

class CartManager {
  // ✅ NEW: Generate cart key based on alamat
  static Future<String?> _getCartKey() async {
    final userLogin = await UserDataManager.getCurrentUserLogin();
    if (userLogin == null) return null;

    // Get selected alamat
    final alamatList = await UserDataManager.getAlamatList(userLogin);
    final selectedIndex = await UserDataManager.getSelectedAlamatIndex(
      userLogin,
    );

    if (alamatList.isEmpty) return null;

    final selectedAlamat =
        alamatList[selectedIndex < alamatList.length ? selectedIndex : 0];

    // Create unique key: kelurahan_kecamatan_kota
    final kelurahan = (selectedAlamat['kelurahan'] ?? 'unknown')
        .toString()
        .toLowerCase()
        .replaceAll(' ', '_');
    final kecamatan = (selectedAlamat['kecamatan'] ?? 'unknown')
        .toString()
        .toLowerCase()
        .replaceAll(' ', '_');
    final kota = (selectedAlamat['kota'] ?? 'unknown')
        .toString()
        .toLowerCase()
        .replaceAll(' ', '_');

    return '${kelurahan}_${kecamatan}_${kota}';
  }

  // Tambah produk ke keranjang (dengan alamat key)
  static Future<bool> addToCart({
    required String productId,
    required String name,
    required double price,
    double? originalPrice,
    int? discountPercentage,
    String? imageUrl,
    String? category,
    int quantity = 1,
    int? minOrderQty, // ✅ TAMBAH
    String? unit, // ✅ TAMBAH
  }) async {
    try {
      final userLogin = await UserDataManager.getCurrentUserLogin();
      if (userLogin == null) return false;

      final cartKey = await _getCartKey();
      if (cartKey == null) {
        debugPrint('❌ [CART] No valid address selected');
        return false;
      }

      debugPrint('🛒 [CART] Adding to cart with key: $cartKey');

      // Ambil keranjang untuk alamat ini
      final cartData = await UserDataManager.getCartByLocation(
        userLogin,
        cartKey,
      );
      List<CartItem> cartItems =
          cartData.map((item) => CartItem.fromMap(item)).toList();

      // Cek apakah produk sudah ada
      final existingIndex = cartItems.indexWhere(
        (item) => item.productId == productId,
      );

      if (existingIndex != -1) {
        cartItems[existingIndex].quantity += quantity;
      } else {
        cartItems.add(
          CartItem(
            productId: productId,
            name: name,
            price: price,
            originalPrice: originalPrice,
            discountPercentage: discountPercentage,
            imageUrl: imageUrl,
            quantity: quantity,
            category: category,
            minOrderQty: minOrderQty, // ✅ TAMBAH
            unit: unit, // ✅ TAMBAH
          ),
        );
      }

      // Simpan dengan location key
      final cartMaps = cartItems.map((item) => item.toMap()).toList();
      return await UserDataManager.saveCartByLocation(
        userLogin,
        cartKey,
        cartMaps,
      );
    } catch (e) {
      debugPrint('❌ [CART] Error adding to cart: $e');
      return false;
    }
  }

  // Ambil semua item di keranjang (filtered by available products)
  static Future<List<CartItem>> getCartItems({
    List<String>? allowedProductIds,
  }) async {
    try {
      final userLogin = await UserDataManager.getCurrentUserLogin();
      if (userLogin == null) return [];

      final cartKey = await _getCartKey();
      if (cartKey == null) {
        debugPrint('❌ [CART] No valid address selected');
        return [];
      }

      debugPrint('🛒 [CART] Getting cart with key: $cartKey');

      final cartData = await UserDataManager.getCartByLocation(
        userLogin,
        cartKey,
      );
      List<CartItem> cartItems =
          cartData.map((item) => CartItem.fromMap(item)).toList();

      // ✅ Filter by allowed products if provided
      if (allowedProductIds != null && allowedProductIds.isNotEmpty) {
        cartItems =
            cartItems
                .where((item) => allowedProductIds.contains(item.productId))
                .toList();
        debugPrint(
          '🛒 [CART] Filtered cart: ${cartItems.length} items (from ${cartData.length})',
        );
      }

      return cartItems;
    } catch (e) {
      debugPrint('❌ [CART] Error getting cart items: $e');
      return [];
    }
  }

  // Ambil quantity produk tertentu
  static Future<int> getProductQuantity(String productId) async {
    try {
      final userLogin = await UserDataManager.getCurrentUserLogin();
      if (userLogin == null) return 0;

      final cartKey = await _getCartKey();
      if (cartKey == null) return 0;

      final cartData = await UserDataManager.getCartByLocation(
        userLogin,
        cartKey,
      );
      final cartItems = cartData.map((item) => CartItem.fromMap(item)).toList();

      final item = cartItems.firstWhere(
        (item) => item.productId == productId,
        orElse: () => CartItem(productId: '', name: '', price: 0, quantity: 0),
      );

      return item.quantity;
    } catch (e) {
      debugPrint('❌ [CART] Error getting product quantity: $e');
      return 0;
    }
  }

  // Hitung total items
  static Future<int> getCartItemCount() async {
    final items = await getCartItems();
    return items.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  // Hitung total harga
  static Future<double> getCartTotal() async {
    final items = await getCartItems();
    return items.fold<double>(0.0, (sum, item) => sum + item.totalPrice);
  }

  // Update quantity
  static Future<bool> updateQuantity(String productId, int newQuantity) async {
    try {
      final userLogin = await UserDataManager.getCurrentUserLogin();
      if (userLogin == null) return false;

      final cartKey = await _getCartKey();
      if (cartKey == null) return false;

      final cartData = await UserDataManager.getCartByLocation(
        userLogin,
        cartKey,
      );
      List<CartItem> cartItems =
          cartData.map((item) => CartItem.fromMap(item)).toList();

      final index = cartItems.indexWhere((item) => item.productId == productId);
      if (index != -1) {
        if (newQuantity <= 0) {
          cartItems.removeAt(index);
        } else {
          cartItems[index].quantity = newQuantity;
        }

        final cartMaps = cartItems.map((item) => item.toMap()).toList();
        return await UserDataManager.saveCartByLocation(
          userLogin,
          cartKey,
          cartMaps,
        );
      }
      return false;
    } catch (e) {
      debugPrint('❌ [CART] Error updating quantity: $e');
      return false;
    }
  }

  // Hapus item
  static Future<bool> removeFromCart(String productId) async {
    try {
      final userLogin = await UserDataManager.getCurrentUserLogin();
      if (userLogin == null) return false;

      final cartKey = await _getCartKey();
      if (cartKey == null) return false;

      final cartData = await UserDataManager.getCartByLocation(
        userLogin,
        cartKey,
      );
      List<CartItem> cartItems =
          cartData.map((item) => CartItem.fromMap(item)).toList();

      cartItems.removeWhere((item) => item.productId == productId);

      final cartMaps = cartItems.map((item) => item.toMap()).toList();
      return await UserDataManager.saveCartByLocation(
        userLogin,
        cartKey,
        cartMaps,
      );
    } catch (e) {
      debugPrint('❌ [CART] Error removing from cart: $e');
      return false;
    }
  }

  // Clear cart
  static Future<bool> clearCart() async {
    try {
      final userLogin = await UserDataManager.getCurrentUserLogin();
      if (userLogin == null) return false;

      final cartKey = await _getCartKey();
      if (cartKey == null) return false;

      return await UserDataManager.saveCartByLocation(userLogin, cartKey, []);
    } catch (e) {
      debugPrint('❌ [CART] Error clearing cart: $e');
      return false;
    }
  }

  // Cek apakah produk ada di cart
  static Future<bool> isInCart(String productId) async {
    try {
      final quantity = await getProductQuantity(productId);
      return quantity > 0;
    } catch (e) {
      debugPrint('❌ [CART] Error checking if in cart: $e');
      return false;
    }
  }
}
