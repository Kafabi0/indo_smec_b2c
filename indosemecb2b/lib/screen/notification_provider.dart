import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../utils/user_data_manager.dart';
import 'package:intl/intl.dart';
import '../services/flash_sale_notification_service.dart';

class NotificationProvider with ChangeNotifier {
  List<AppNotification> _notifications = [];
  String? _currentUser;
  bool _isInitialized = false; // ✅ Track initialization status
  bool _isInitializing = false; // ✅ Prevent concurrent initialization

  List<AppNotification> get notifications => _notifications;

  List<AppNotification> getTransaksiNotifs() {
    return _notifications.where((n) => n.type == NotifType.transaksi).toList();
  }

  List<AppNotification> getInfoNotifs() {
    return _notifications.where((n) => n.type == NotifType.informasi).toList();
  }

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationProvider() {
    // ✅ Call async initialization (tidak perlu await di constructor)
    _initializeForCurrentUser();
  }

  // ⭐ Initialize untuk user yang sedang login
  Future<void> _initializeForCurrentUser() async {
    if (_isInitializing) {
      print('⏳ [NotifProvider] Already initializing, skipping...');
      return;
    }

    _isInitializing = true;

    try {
      final user = await UserDataManager.getCurrentUserLogin();
      print('🔔 [NotifProvider] Initialize for user: $user');

      if (user != null) {
        _currentUser = user;
        await _loadNotifications();
        _isInitialized = true;
        print('✅ [NotifProvider] Initialization complete for: $user');
      } else {
        print('⚠️ [NotifProvider] No user logged in');
        _notifications = [];
        _currentUser = null;
        _isInitialized = false;
      }
      notifyListeners();
    } catch (e) {
      print('❌ [NotifProvider] Initialization error: $e');
      _isInitialized = false;
    } finally {
      _isInitializing = false;
    }
  }

  // ✅ BARU: Ensure user is loaded (dengan timeout protection)
  Future<void> ensureUserLoaded() async {
    if (_isInitialized && _currentUser != null) {
      print('✅ [NotifProvider] User already loaded: $_currentUser');
      return;
    }

    if (_isInitializing) {
      print('⏳ [NotifProvider] Waiting for initialization...');
      // Wait for initialization to complete (max 5 seconds)
      int attempts = 0;
      while (_isInitializing && attempts < 50) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }
    }

    if (_currentUser == null) {
      print('🔄 [NotifProvider] Force reloading user...');
      await _initializeForCurrentUser();
    }
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
    _isInitialized = false;
    await _initializeForCurrentUser();
  }

  // ⭐ Clear ketika logout
  Future<void> clearForLogout() async {
    print('🚪 [NotifProvider] Clearing notifications on logout');
    _notifications = [];
    _currentUser = null;
    _isInitialized = false;
    notifyListeners();
  }

  // ✅ PERBAIKAN: Tambah notifikasi baru dengan auto-load user
  Future<void> addNotification(AppNotification notification) async {
    // ✅ Pastikan user sudah loaded
    await ensureUserLoaded();

    if (_currentUser == null) {
      print('❌ Cannot add notification: no user logged in after ensure');
      return;
    }

    print('✅ [NotifProvider] Adding notification for user: $_currentUser');
    _notifications.insert(0, notification); // Add di awal list
    await _saveNotifications();
    notifyListeners();
    print('✅ Notification added successfully');
  }

  // ✅ PERBAIKAN: Tambah notifikasi pembayaran berhasil
  Future<void> addPaymentSuccessNotification({
    required String orderId,
    required String paymentMethod,
    required double total,
    String? productImage,
    Map<String, dynamic>? transactionData,
  }) async {
    print('💳 [NotifProvider] Creating payment notification...');
    print('   Order ID: $orderId');
    print('   Method: $paymentMethod');
    print('   Total: $total');

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
    print('✅ [NotifProvider] Payment notification added');
  }

  // Tambah notifikasi pesanan dikirim
  // ✅ TAMBAHAN - Notifikasi pesanan sedang dikirim
  Future<void> addOrderShippedNotification({
    required String orderId,
    required String deliveryTime,
    String? productImage,
    Map<String, dynamic>? transactionData,
  }) async {
    print('🚚 [NotifProvider] Creating order shipped notification...');
    print('   Order ID: $orderId');
    print('   Delivery time: $deliveryTime');

    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotifType.transaksi,
      title: '🚚 Pesanan Sedang Dikirim',
      message:
          'Order #$orderId sedang dalam perjalanan. Estimasi tiba: $deliveryTime',
      date: DateTime.now(),
      isRead: false,
      image: productImage,
      detailButtonText: 'Lacak Pesanan',
      orderId: orderId,
      transactionData: {
        'orderId': orderId,
        'deliveryTime': deliveryTime,
        'trackingData': {
          'transaction_id':
              transactionData?['transaction_id'] ??
              'TXN-${DateTime.now().millisecondsSinceEpoch}',
          'order_id': orderId,
          'courier_name': transactionData?['courier_name'] ?? 'Kurir Sistem',
          'courier_id': transactionData?['courier_id'] ?? 'C001',
          'status_message': 'Sedang dikirim',
          'route':
              transactionData?['route'] ??
              [
                {'lat': -6.2, 'lng': 106.8},
                {'lat': -6.21, 'lng': 106.82},
              ],
        },
        // tambahkan data transaksi asli jika ingin tetap ada
        ...?transactionData,
      },
    );

    await addNotification(notification);
    print('✅ [NotifProvider] Order shipped notification added');
  }

  Future<void> addOrderArrivedNotification({
    required String orderId,
    String? productImage,
    Map<String, dynamic>? transactionData,
  }) async {
    print('✅ [NotifProvider] Creating order arrived notification...');
    print('   Order ID: $orderId');

    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotifType.transaksi,
      title: '✅ Pesanan Telah Sampai!',
      message:
          'Order #$orderId telah tiba di lokasi tujuan. Mohon konfirmasi penerimaan pesanan Anda.',
      date: DateTime.now(),
      isRead: false,
      image: productImage,
      detailButtonText: 'Konfirmasi Penerimaan',
      orderId: orderId,
      transactionData: transactionData,
    );

    await addNotification(notification);
    print('✅ [NotifProvider] Order arrived notification added');
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

  // ✅ ADD THIS METHOD after addPaymentSuccessNotification
  Future<void> addTopUpSuccessNotification({
    required double amount,
    required String paymentMethod,
  }) async {
    print('💰 [NotifProvider] Creating top-up notification...');
    print('   Amount: $amount');
    print('   Method: $paymentMethod');

    final transactionId = 'TOPUP${DateTime.now().millisecondsSinceEpoch}';

    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotifType.transaksi,
      title: 'Top Up Berhasil!',
      message:
          'Saldo Klik kamu berhasil ditambah Rp ${NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(amount)} via $paymentMethod',
      date: DateTime.now(),
      isRead: false,
      total: amount,
      orderId: transactionId,
      transactionData: {
        'id': transactionId,
        'no_transaksi': transactionId,
        'type': 'topup',
        'amount': amount,
        'payment_method': paymentMethod,
        'date': DateTime.now().toIso8601String(),
        'status': 'success',
      },
    );

    await addNotification(notification);
    print('✅ [NotifProvider] Top-up notification added');
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

  Future<void> scheduleFlashSaleNotifications() async {
    try {
      print('📅 [NotifProvider] Scheduling flash sale notifications...');

      final flashSaleNotifService = FlashSaleNotificationService();
      await flashSaleNotifService.scheduleAllFlashSaleNotifications(this);

      print('✅ [NotifProvider] Flash sale notifications scheduled');
    } catch (e) {
      print('❌ [NotifProvider] Error scheduling flash sales: $e');
    }
  }

  Future<void> cancelFlashSaleNotifications() async {
    try {
      print('🗑️ [NotifProvider] Cancelling flash sale notifications...');

      final flashSaleNotifService = FlashSaleNotificationService();
      await flashSaleNotifService.cancelAllFlashSaleNotifications();

      print('✅ [NotifProvider] Flash sale notifications cancelled');
    } catch (e) {
      print('❌ [NotifProvider] Error cancelling flash sales: $e');
    }
  }
}
