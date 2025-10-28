import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationProvider with ChangeNotifier {
  List<AppNotification> _notifications = [];

  List<AppNotification> get notifications => _notifications;

  List<AppNotification> getTransaksiNotifs() {
    return _notifications.where((n) => n.type == NotifType.transaksi).toList();
  }

  List<AppNotification> getInfoNotifs() {
    return _notifications.where((n) => n.type == NotifType.informasi).toList();
  }

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationProvider() {
    _loadNotifications();
  }

  // Load notifikasi dari SharedPreferences
  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? notifJson = prefs.getString('notifications');

      if (notifJson != null) {
        final List<dynamic> decoded = json.decode(notifJson);
        _notifications =
            decoded.map((item) => AppNotification.fromJson(item)).toList();

        // Sort by date (terbaru di atas)
        _notifications.sort((a, b) => b.date.compareTo(a.date));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  // Simpan notifikasi ke SharedPreferences
  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = json.encode(
        _notifications.map((n) => n.toJson()).toList(),
      );
      await prefs.setString('notifications', encoded);
    } catch (e) {
      debugPrint('Error saving notifications: $e');
    }
  }

  // Tambah notifikasi baru
  Future<void> addNotification(AppNotification notification) async {
    _notifications.insert(0, notification); // Add di awal list
    await _saveNotifications();
    notifyListeners();
  }

  // Tambah notifikasi pembayaran berhasil
  Future<void> addPaymentSuccessNotification({
    required String orderId,
    required String paymentMethod,
    required double total,
    String? productImage,
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
    );

    await addNotification(notification);
  }

  // Tambah notifikasi pesanan dikirim
  Future<void> addOrderShippedNotification({
    required String orderId,
    required String deliveryTime,
    String? productImage,
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
