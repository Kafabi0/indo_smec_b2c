import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../utils/user_data_manager.dart';
import 'package:intl/intl.dart';
import '../services/flash_sale_notification_service.dart';

class NotificationProvider with ChangeNotifier {
  List<AppNotification> _notifications = [];
  String? _currentUser;
  bool _isInitialized = false;
  bool _isInitializing = false;

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

  Future<void> ensureUserLoaded() async {
    if (_isInitialized && _currentUser != null) {
      print('✅ [NotifProvider] User already loaded: $_currentUser');
      return;
    }

    if (_isInitializing) {
      print('⏳ [NotifProvider] Waiting for initialization...');
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

  Future<void> _loadNotifications() async {
    if (_currentUser == null) {
      print('❌ [NotifProvider] Cannot load: no current user');
      return;
    }

    try {
      final notifList = await UserDataManager.getNotifications(_currentUser!);
      _notifications =
          notifList.map((json) => AppNotification.fromJson(json)).toList();

      _notifications.sort((a, b) => b.date.compareTo(a.date));

      print('✅ [NotifProvider] Loaded ${_notifications.length} notifications');
      notifyListeners();
    } catch (e) {
      print('❌ Error loading notifications: $e');
    }
  }

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

  Future<void> reloadForCurrentUser() async {
    print('🔄 [NotifProvider] Reloading for current user...');
    _isInitialized = false;
    await _initializeForCurrentUser();
  }

  Future<void> clearForLogout() async {
    print('🚪 [NotifProvider] Clearing notifications on logout');
    _notifications = [];
    _currentUser = null;
    _isInitialized = false;
    notifyListeners();
  }

  Future<void> addNotification(AppNotification notification) async {
    await ensureUserLoaded();

    if (_currentUser == null) {
      print('❌ Cannot add notification: no user logged in after ensure');
      return;
    }

    print('✅ [NotifProvider] Adding notification for user: $_currentUser');
    _notifications.insert(0, notification);
    await _saveNotifications();
    notifyListeners();
    print('✅ Notification added successfully');
  }

  // ✅ PERBAIKAN KUNCI - Simpan semua data transaksi lengkap
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
    print('   Total (before poin cash): $total');

    if (transactionData != null) {
      print('   📋 Transaction Data Keys: ${transactionData.keys}');
      print('   📋 Metode Pembayaran: ${transactionData['metode_pembayaran']}');
      print('   📋 Voucher: ${transactionData['voucher_code']}');
      print('   📋 Catatan: ${transactionData['catatan_pengiriman']}');
      print('   📋 Poin Cash Used: ${transactionData['poin_cash_used']}');
    }

    final poinCashUsed =
        transactionData?['poin_cash_used'] ??
        transactionData?['poinCashUsed'] ??
        0.0;
    final totalFinal =
        total - (poinCashUsed is int ? poinCashUsed.toDouble() : poinCashUsed);

    print('   💰 Poin Cash Used: $poinCashUsed');
    print('   💰 Total Final (after poin cash): $totalFinal');

    final completeTransactionData =
        transactionData != null
            ? {
              ...transactionData,
              'no_transaksi': orderId,
              'id': orderId,
              'metode_pembayaran': paymentMethod,
              'total_pembayaran': totalFinal,
              'status': transactionData['status'] ?? 'Pembayaran Lunas',
              'poin_cash_used': poinCashUsed,
              'poinCashUsed': poinCashUsed,
            }
            : {
              'no_transaksi': orderId,
              'id': orderId,
              'metode_pembayaran': paymentMethod,
              'total_pembayaran': totalFinal,
              'status': 'Pembayaran Lunas',
            };

    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotifType.transaksi,
      title: 'Pembayaran Berhasil!',
      message:
          'Order #$orderId dengan metode $paymentMethod telah terkonfirmasi',
      date: DateTime.now(),
      isRead: false,
      image: productImage,
      total: totalFinal,
      detailButtonText: 'Lihat Detail',
      orderId: orderId,
      transactionData: completeTransactionData,
    );

    await addNotification(notification);
    print('✅ [NotifProvider] Payment notification added with complete data');
    print('   Total in notification: $totalFinal');
  }

  // ⭐ UPDATE: Simpan tracking data lengkap
  Future<void> addOrderShippedNotification({
    required String orderId,
    required String deliveryTime,
    String? productImage,
    Map<String, dynamic>? transactionData,
  }) async {
    print('🚚 [NotifProvider] Creating order shipped notification...');
    print('   Order ID: $orderId');
    print('   Delivery time: $deliveryTime');

    // ⭐ AMBIL TRACKING DATA LENGKAP DARI TRANSACTION
    Map<String, dynamic>? fullTrackingData;
    if (transactionData != null) {
      fullTrackingData = {
        'transaction_id': transactionData['transaction_id'] ?? orderId,
        'order_id': orderId,
        'courier_name':  'Tryan Gumilar',
        'courier_id':  'D 4563 ADP',
        'status_message': transactionData['status'] ?? 'Sedang dikirim',
        'status_desc':
            transactionData['status_desc'] ?? 'Pesanan dalam perjalanan',
        // ⭐ KOORDINAT KOPERASI
        'koperasi_id': transactionData['koperasi_id'],
        'koperasi_name': transactionData['koperasi_name'],
        'koperasi_latitude': transactionData['koperasi_latitude'],
        'koperasi_longitude': transactionData['koperasi_longitude'],
        // ⭐ KOORDINAT ALAMAT TUJUAN
        'delivery_latitude':
            transactionData['latitude'] ?? transactionData['delivery_latitude'],
        'delivery_longitude':
            transactionData['longitude'] ??
            transactionData['delivery_longitude'],
        'alamat_lengkap': transactionData['alamat_lengkap'],
        'kelurahan': transactionData['kelurahan'],
        'kecamatan': transactionData['kecamatan'],
      };

      print('   📍 Tracking Data Created:');
      print('      Koperasi: ${fullTrackingData['koperasi_name']}');
      print(
        '      Koperasi Coords: (${fullTrackingData['koperasi_latitude']}, ${fullTrackingData['koperasi_longitude']})',
      );
      print(
        '      Delivery Coords: (${fullTrackingData['delivery_latitude']}, ${fullTrackingData['delivery_longitude']})',
      );
    }

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
        'trackingData': fullTrackingData,
        ...?transactionData,
      },
    );

    await addNotification(notification);
    print(
      '✅ [NotifProvider] Order shipped notification added with tracking data',
    );
  }

  Future<void> addOrderArrivedNotification({
    required String orderId,
    String? productImage,
    Map<String, dynamic>? transactionData,
  }) async {
    print('✅ [NotifProvider] Creating order arrived notification...');
    print('   Order ID: $orderId');

    // ⭐ AMBIL TRACKING DATA LENGKAP
    Map<String, dynamic>? fullTrackingData;
    if (transactionData != null) {
      fullTrackingData = {
        'transaction_id': transactionData['transaction_id'] ?? orderId,
        'order_id': orderId,
        'courier_name': 'Tryan Gumilar',
        'courier_id':  'D 4563 ADP',
        'status_message': 'Pesanan telah sampai',
        'status_desc': 'Pesanan telah tiba di tujuan',
        // ⭐ KOORDINAT KOPERASI
        'koperasi_id': transactionData['koperasi_id'],
        'koperasi_name': transactionData['koperasi_name'],
        'koperasi_latitude': transactionData['koperasi_latitude'],
        'koperasi_longitude': transactionData['koperasi_longitude'],
        // ⭐ KOORDINAT ALAMAT TUJUAN
        'delivery_latitude':
            transactionData['latitude'] ?? transactionData['delivery_latitude'],
        'delivery_longitude':
            transactionData['longitude'] ??
            transactionData['delivery_longitude'],
        'alamat_lengkap': transactionData['alamat_lengkap'],
        'kelurahan': transactionData['kelurahan'],
        'kecamatan': transactionData['kecamatan'],
      };
    }

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
      transactionData: {
        'orderId': orderId,
        'trackingData': fullTrackingData,
        ...?transactionData,
      },
    );

    await addNotification(notification);
    print(
      '✅ [NotifProvider] Order arrived notification added with tracking data',
    );
  }

  Future<void> markAsRead(String notifId) async {
    final index = _notifications.indexWhere((n) => n.id == notifId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _saveNotifications();
      notifyListeners();
    }
  }

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

  Future<void> markAllAsRead() async {
    _notifications =
        _notifications.map((n) => n.copyWith(isRead: true)).toList();
    await _saveNotifications();
    notifyListeners();
  }

  Future<void> deleteNotification(String notifId) async {
    _notifications.removeWhere((n) => n.id == notifId);
    await _saveNotifications();
    notifyListeners();
  }

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
