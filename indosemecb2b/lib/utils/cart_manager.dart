// lib/utils/cart_manager.dart
import 'package:flutter/foundation.dart';
import 'package:indosemecb2b/utils/user_data_manager.dart';
import 'package:indosemecb2b/models/cart_item.dart';

class CartManager {
  // Tambah produk ke keranjang
  static Future<bool> addToCart({
    required String productId,
    required String name,
    required double price,
    double? originalPrice,
    int? discountPercentage,
    String? imageUrl,
    int quantity = 1,
  }) async {
    try {
      // Ambil user yang sedang login
      final userLogin = await UserDataManager.getCurrentUserLogin();
      if (userLogin == null) {
        return false;
      }

      // Ambil keranjang yang sudah ada
      final cartData = await UserDataManager.getCart(userLogin);
      List<CartItem> cartItems =
          cartData.map((item) => CartItem.fromMap(item)).toList();

      // Cek apakah produk sudah ada di keranjang
      final existingIndex = cartItems.indexWhere(
        (item) => item.productId == productId,
      );

      if (existingIndex != -1) {
        // Jika sudah ada, tambah quantity
        cartItems[existingIndex].quantity += quantity;
      } else {
        // Jika belum ada, tambah item baru
        cartItems.add(
          CartItem(
            productId: productId,
            name: name,
            price: price,
            originalPrice: originalPrice,
            discountPercentage: discountPercentage,
            imageUrl: imageUrl,
            quantity: quantity,
          ),
        );
      }

      // Simpan kembali ke storage
      final cartMaps = cartItems.map((item) => item.toMap()).toList();
      return await UserDataManager.saveCart(userLogin, cartMaps);
    } catch (e) {
      debugPrint('Error adding to cart: $e');
      return false;
    }
  }

  // Ambil semua item di keranjang
  static Future<List<CartItem>> getCartItems() async {
    try {
      final userLogin = await UserDataManager.getCurrentUserLogin();
      if (userLogin == null) return [];

      final cartData = await UserDataManager.getCart(userLogin);
      return cartData.map((item) => CartItem.fromMap(item)).toList();
    } catch (e) {
      debugPrint('Error getting cart items: $e');
      return [];
    }
  }

  // Hitung total items di keranjang
  static Future<int> getCartItemCount() async {
    final items = await getCartItems();
    return items.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  // Hitung total harga
  static Future<double> getCartTotal() async {
    final items = await getCartItems();
    return items.fold<double>(0.0, (sum, item) => sum + item.totalPrice);
  }

  // Update quantity item
  static Future<bool> updateQuantity(String productId, int newQuantity) async {
    try {
      final userLogin = await UserDataManager.getCurrentUserLogin();
      if (userLogin == null) return false;

      final cartData = await UserDataManager.getCart(userLogin);
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
        return await UserDataManager.saveCart(userLogin, cartMaps);
      }
      return false;
    } catch (e) {
      debugPrint('Error updating quantity: $e');
      return false;
    }
  }

  // Hapus item dari keranjang
  static Future<bool> removeFromCart(String productId) async {
    try {
      final userLogin = await UserDataManager.getCurrentUserLogin();
      if (userLogin == null) return false;

      final cartData = await UserDataManager.getCart(userLogin);
      List<CartItem> cartItems =
          cartData.map((item) => CartItem.fromMap(item)).toList();

      cartItems.removeWhere((item) => item.productId == productId);

      final cartMaps = cartItems.map((item) => item.toMap()).toList();
      return await UserDataManager.saveCart(userLogin, cartMaps);
    } catch (e) {
      debugPrint('Error removing from cart: $e');
      return false;
    }
  }

  // Kosongkan keranjang
  static Future<bool> clearCart() async {
    try {
      final userLogin = await UserDataManager.getCurrentUserLogin();
      if (userLogin == null) return false;

      return await UserDataManager.saveCart(userLogin, []);
    } catch (e) {
      debugPrint('Error clearing cart: $e');
      return false;
    }
  }
}
