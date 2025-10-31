import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:indosemecb2b/screen/detail_pembayaran.dart';
import '../models/flash_sale_model.dart';
import '../services/flash_sale_service.dart';
import '../screen/notification_provider.dart';
import '../models/notification_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ✅ Global key untuk navigation
  static GlobalKey<NavigatorState>? navigatorKey;

  // ✅ Set navigator key dari main.dart
  static void setNavigatorKey(GlobalKey<NavigatorState> key) {
    navigatorKey = key;
  }

  // Inisialisasi notifikasi
  Future<void> initialize() async {
    if (_initialized) return;

    // Inisialisasi timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    // Android settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
  }

  // Request permission (khusus iOS & Android 13+)
  Future<bool> requestPermission() async {
    if (!_initialized) await initialize();

    final androidPlugin =
        _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    final iosPlugin =
        _notifications
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();

    // Request Android 13+ permission
    final androidGranted =
        await androidPlugin?.requestNotificationsPermission() ?? true;

    // Request iOS permission
    final iosGranted =
        await iosPlugin?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        true;

    return androidGranted && iosGranted;
  }

  // ✅ Handle ketika notifikasi di-tap dengan navigation
  void _onNotificationTap(NotificationResponse response) {
    debugPrint('🔔 Notification tapped: ${response.payload}');

    if (response.payload == null || response.payload!.isEmpty) {
      debugPrint('❌ No payload data');
      return;
    }

    try {
      // Parse payload (berisi data transaksi dalam format JSON)
      final Map<String, dynamic> payloadData = json.decode(response.payload!);

      debugPrint('📦 Payload data keys: ${payloadData.keys}');

      // ✅ Navigate ke DetailPembayaranScreen
      if (navigatorKey?.currentContext != null) {
        Navigator.of(navigatorKey!.currentContext!).push(
          MaterialPageRoute(
            builder: (_) => DetailPembayaranScreen(transaksi: payloadData),
          ),
        );
        debugPrint('✅ Navigating to detail screen');
      } else {
        debugPrint('❌ Navigator key context is null');
      }
    } catch (e) {
      debugPrint('❌ Error parsing notification payload: $e');
    }
  }

  // ✅ Tampilkan notifikasi pembayaran berhasil dengan transaction data
  Future<void> showPaymentSuccessNotification({
    required String orderId,
    required String paymentMethod,
    required double totalAmount,
    String? productImage,
    Map<String, dynamic>? transactionData,
  }) async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'payment_channel',
      'Payment Notifications',
      channelDescription: 'Notifikasi untuk transaksi pembayaran',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(''),
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    String payload;
    if (transactionData != null) {
      payload = json.encode(transactionData);
      debugPrint('📦 Notification payload created with transaction data');
    } else {
      payload = json.encode({'no_transaksi': orderId});
      debugPrint('⚠️ No transaction data, using orderId only');
    }

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '✅ Pembayaran Berhasil!',
      'Order #$orderId - $paymentMethod telah terkonfirmasi',
      details,
      payload: payload,
    );

    debugPrint('🔔 Payment notification shown for order: $orderId');
  }

  // Tampilkan notifikasi top-up berhasil
  Future<void> showTopUpSuccessNotification({
    required double amount,
    required String paymentMethod,
    required String transactionId,
    Map<String, dynamic>? transactionData,
  }) async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'topup_channel',
      'Top-Up Notifications',
      channelDescription: 'Notifikasi untuk top-up saldo',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(''),
      enableVibration: true,
      playSound: true,
      color: Color(0xFF4CAF50),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final formattedAmount = _formatRupiah(amount);

    String payload;
    if (transactionData != null) {
      payload = json.encode(transactionData);
      debugPrint(
        '📦 Top-up notification payload created with transaction data',
      );
    } else {
      payload = json.encode({
        'id': transactionId,
        'type': 'topup',
        'amount': amount,
        'payment_method': paymentMethod,
      });
      debugPrint('⚠️ No transaction data, using basic topup info');
    }

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '💰 Top-Up Berhasil!',
      'Saldo kamu berhasil ditambah $formattedAmount via $paymentMethod',
      details,
      payload: payload,
    );

    debugPrint('🔔 Top-up notification shown: $transactionId');
  }

  // ✅ Helper method untuk format Rupiah
  String _formatRupiah(double amount) {
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(amount % 1000000 == 0 ? 0 : 1)}jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(amount % 1000 == 0 ? 0 : 0)}rb';
    } else {
      return 'Rp ${amount.toStringAsFixed(0)}';
    }
  }

  // Tampilkan notifikasi pesanan sedang dikirim
  Future<void> showOrderShippedNotification({
    required String orderId,
    required String deliveryTime,
    Map<String, dynamic>? transactionData,
  }) async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'order_channel',
      'Order Notifications',
      channelDescription: 'Notifikasi untuk status pesanan',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    String payload;
    if (transactionData != null) {
      payload = json.encode(transactionData);
    } else {
      payload = json.encode({'no_transaksi': orderId});
    }

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '🚚 Pesanan Sedang Dikirim',
      'Order #$orderId akan tiba pada $deliveryTime',
      details,
      payload: payload,
    );

    debugPrint('🔔 Shipping notification shown for order: $orderId');
  }

  // ========================================
  // ⭐ FLASH SALE NOTIFICATIONS
  // ========================================

  // ✅ Schedule semua flash sale notifications untuk hari ini
  Future<void> scheduleAllFlashSaleNotifications(
    NotificationProvider notifProvider,
  ) async {
    if (!_initialized) await initialize();

    final schedules = FlashSaleService.getFlashSaleSchedules();
    
    debugPrint('📅 [FlashSale] Scheduling ${schedules.length} flash sales');
    
    for (var schedule in schedules) {
      await _scheduleFlashSaleNotifications(schedule, notifProvider);
    }
    
    debugPrint('✅ [FlashSale] All notifications scheduled');
  }

  // ✅ Schedule notifikasi untuk 1 flash sale (mulai + hampir berakhir)
  Future<void> _scheduleFlashSaleNotifications(
    FlashSaleSchedule schedule,
    NotificationProvider notifProvider,
  ) async {
    final now = DateTime.now();
    
    // ⭐ 1. NOTIFIKASI FLASH SALE DIMULAI
    if (schedule.startTime.isAfter(now)) {
      await _scheduleFlashSaleStartNotification(schedule, notifProvider);
    } else {
      debugPrint('⏭️ [FlashSale] ${schedule.title} already started, skipping');
    }
    
    // ⭐ 2. NOTIFIKASI HAMPIR BERAKHIR (10 menit sebelum selesai)
    final almostEndTime = schedule.endTime.subtract(const Duration(minutes: 10));
    if (almostEndTime.isAfter(now)) {
      await _scheduleFlashSaleEndingSoonNotification(schedule, notifProvider);
    } else {
      debugPrint('⏭️ [FlashSale] ${schedule.title} ending time passed');
    }
  }

  // 📢 Notifikasi: Flash Sale DIMULAI
  Future<void> _scheduleFlashSaleStartNotification(
    FlashSaleSchedule schedule,
    NotificationProvider notifProvider,
  ) async {
    final scheduledTime = tz.TZDateTime.from(schedule.startTime, tz.local);
    
    final androidDetails = AndroidNotificationDetails(
      'flash_sale_channel',
      'Flash Sale Notifications',
      channelDescription: 'Notifikasi untuk flash sale',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFFFF6B35),
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: const BigTextStyleInformation(''),
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final notificationId = schedule.id.hashCode + 1;

    await _notifications.zonedSchedule(
      notificationId,
      '🔥 ${schedule.title} DIMULAI!',
      'Diskon ${schedule.discountPercentage}% untuk ${schedule.productIds.length} produk pilihan! Buruan cek sekarang!',
      scheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    // ✅ Tambahkan ke NotificationProvider
    _scheduleInAppNotification(schedule, notifProvider, isStarting: true);

    debugPrint('🔔 [FlashSale] START notification scheduled for ${schedule.title} at ${schedule.startTime}');
  }

  // 📢 Notifikasi: Flash Sale HAMPIR BERAKHIR
  Future<void> _scheduleFlashSaleEndingSoonNotification(
    FlashSaleSchedule schedule,
    NotificationProvider notifProvider,
  ) async {
    final endingSoonTime = schedule.endTime.subtract(const Duration(minutes: 10));
    final scheduledTime = tz.TZDateTime.from(endingSoonTime, tz.local);
    
    final androidDetails = AndroidNotificationDetails(
      'flash_sale_channel',
      'Flash Sale Notifications',
      channelDescription: 'Notifikasi untuk flash sale',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFFFF3B30),
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: const BigTextStyleInformation(''),
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final notificationId = schedule.id.hashCode + 2;

    await _notifications.zonedSchedule(
      notificationId,
      '⏰ ${schedule.title} HAMPIR BERAKHIR!',
      'Tinggal 10 menit! Jangan sampai ketinggalan diskon ${schedule.discountPercentage}%',
      scheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    // ✅ Tambahkan ke NotificationProvider
    _scheduleInAppNotification(schedule, notifProvider, isStarting: false);

    debugPrint('🔔 [FlashSale] ENDING notification scheduled for ${schedule.title} at $endingSoonTime');
  }

  // ✅ Tambahkan notifikasi ke in-app notification list
  Future<void> _scheduleInAppNotification(
    FlashSaleSchedule schedule,
    NotificationProvider notifProvider,
    {required bool isStarting}
  ) async {
    final triggerTime = isStarting 
        ? schedule.startTime 
        : schedule.endTime.subtract(const Duration(minutes: 10));

    final now = DateTime.now();
    final delay = triggerTime.difference(now);

    if (delay.isNegative) {
      debugPrint('⏭️ [FlashSale] Time passed, skipping in-app notification');
      return;
    }

    // Schedule dengan Future.delayed
    Future.delayed(delay, () async {
      final notification = AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: NotifType.informasi,
        title: isStarting 
            ? '🔥 ${schedule.title} DIMULAI!' 
            : '⏰ ${schedule.title} HAMPIR BERAKHIR!',
        message: isStarting
            ? 'Diskon ${schedule.discountPercentage}% untuk ${schedule.productIds.length} produk pilihan! Buruan cek sekarang!'
            : 'Tinggal 10 menit! Jangan sampai ketinggalan diskon ${schedule.discountPercentage}%',
        date: DateTime.now(),
        isRead: false,
        detailButtonText: 'Lihat Produk',
      );

      await notifProvider.addNotification(notification);
      debugPrint('✅ [FlashSale] In-app notification added: ${notification.title}');
    });

    debugPrint('📅 [FlashSale] In-app notification scheduled in ${delay.inMinutes} minutes');
  }

  // ✅ Cancel semua flash sale notifications
  Future<void> cancelAllFlashSaleNotifications() async {
    final schedules = FlashSaleService.getFlashSaleSchedules();
    
    for (var schedule in schedules) {
      await _notifications.cancel(schedule.id.hashCode + 1);
      await _notifications.cancel(schedule.id.hashCode + 2);
    }
    
    debugPrint('🗑️ [FlashSale] All flash sale notifications cancelled');
  }

  // Cancel semua notifikasi
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  // Cancel notifikasi tertentu
  Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }
}