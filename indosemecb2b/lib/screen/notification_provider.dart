import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../utils/user_data_manager.dart';

class NotificationProvider with ChangeNotifier {
  List<AppNotification> _notifications = [];
  String? _currentUser;

  List<AppNotification> get notifications => _notifications;

  List<AppNotification> getTransaksiNotifs() {
    return _notifications.where((n) => n.type == NotifType.transaksi).toList();
  }

  List<AppNotification> getInfoNotifs() {
    return _notifications.where((n) => n.type == NotifType.informasi).toList();
  }

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationProvider() {
    _initializeForCurrentUser();
  }

  // ⭐ Initialize untuk user yang sedang login
  Future<void> _initializeForCurrentUser() async {
    final user = await UserDataManager.getCurrentUserLogin();
    print('🔔 [NotifProvider] Initialize for user: $user');

    if (user != null) {
      _currentUser = user;
      await _loadNotifications();
    } else {
      print('⚠️ [NotifProvider] No user logged in');
      _notifications = [];
      _currentUser = null;
    }
    notifyListeners();
  }

  // ⭐ Load notifikasi untuk user tertentu
  Future<void> _loadNotifications() async {
    if (_currentUser == null) {
      print('❌ [NotifProvider] Cannot load: no current user');
      return;
    }

    try {
      final notifList = await UserDataManager.getNotifications(_currentUser!);
      _notifications =
          notifList.map((json) => AppNotification.fromJson(json)).toList();

      // Sort by date (newest first)
      _notifications.sort((a, b) => b.date.compareTo(a.date));

      print('✅ [NotifProvider] Loaded ${_notifications.length} notifications');
      notifyListeners();
    } catch (e) {
      print('❌ Error loading notifications: $e');
    }
  }

  // ⭐ Simpan notifikasi untuk user tertentu
  Future<void> _saveNotifications() async {
    if (_currentUser == null) {
      print('❌ [NotifProvider] Cannot save: no current user');
      return;
    }

    try {
      final notifJsonList = _notifications.map((n) => n.toJson()).toList();
      await UserDataManager.saveNotifications(_currentUser!, notifJsonList);
      print('💾 [NotifProvider] Saved ${_notifications.length} notifications');
    } catch (e) {
      print('❌ Error saving notifications: $e');
    }
  }

  // ⭐ PENTING: Reload ketika user login/logout
  Future<void> reloadForCurrentUser() async {
    print('🔄 [NotifProvider] Reloading for current user...');
    await _initializeForCurrentUser();
  }

  // ⭐ Clear ketika logout
  Future<void> clearForLogout() async {
    print('🚪 [NotifProvider] Clearing notifications on logout');
    _notifications = [];
    _currentUser = null;
    notifyListeners();
  }

  // Tambah notifikasi baru
  Future<void> addNotification(AppNotification notification) async {
    if (_currentUser == null) {
      print('❌ Cannot add notification: no user logged in');
      return;
    }

    _notifications.insert(0, notification); // Add di awal list
    await _saveNotifications();
    notifyListeners();
    print('✅ Notification added for user: $_currentUser');
  }

  // Tambah notifikasi pembayaran berhasil
  Future<void> addPaymentSuccessNotification({
    required String orderId,
    required String paymentMethod,
    required double total,
    String? productImage,
    Map<String, dynamic>? transactionData,
  }) async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotifType.transaksi,
      title: 'Pembayaran Berhasil!',
      message:
          'Order #$orderId dengan metode $paymentMethod telah terkonfirmasi',
      date: DateTime.now(),
      isRead: false,
      image: productImage,
      total: total,
      detailButtonText: 'Lihat Detail',
      orderId: orderId,
      transactionData: transactionData,
    );

    await addNotification(notification);
  }

  // Tambah notifikasi pesanan dikirim
  Future<void> addOrderShippedNotification({
    required String orderId,
    required String deliveryTime,
    String? productImage,
    Map<String, dynamic>? transactionData,
  }) async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotifType.transaksi,
      title: 'Pesanan Sedang Dikirim',
      message: 'Order #$orderId akan tiba pada $deliveryTime',
      date: DateTime.now(),
      isRead: false,
      image: productImage,
      detailButtonText: 'Lacak Pesanan',
      orderId: orderId,
      transactionData: transactionData,
    );

    await addNotification(notification);
  }

  // Mark notification as read
  Future<void> markAsRead(String notifId) async {
    final index = _notifications.indexWhere((n) => n.id == notifId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _saveNotifications();
      notifyListeners();
    }
  }

  // Mark all as read
  Future<void> markAllAsRead() async {
    _notifications =
        _notifications.map((n) => n.copyWith(isRead: true)).toList();
    await _saveNotifications();
    notifyListeners();
  }

  // Delete notification
  Future<void> deleteNotification(String notifId) async {
    _notifications.removeWhere((n) => n.id == notifId);
    await _saveNotifications();
    notifyListeners();
  }

  // Clear all notifications
  Future<void> clearAll() async {
    _notifications.clear();
    await _saveNotifications();
    notifyListeners();
  }
}
