import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/flash_sale_model.dart';
import '../services/flash_sale_service.dart';
import '../screen/notification_provider.dart';
import '../models/notification_model.dart';

class FlashSaleNotificationService {
  static final FlashSaleNotificationService _instance = 
      FlashSaleNotificationService._internal();
  factory FlashSaleNotificationService() => _instance;
  FlashSaleNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // ✅ Schedule semua notifikasi flash sale untuk hari ini
  Future<void> scheduleAllFlashSaleNotifications(
    NotificationProvider notifProvider,
  ) async {
    final schedules = FlashSaleService.getFlashSaleSchedules();
    
    print('📅 [FlashSale] Scheduling ${schedules.length} flash sales');
    
    for (var schedule in schedules) {
      await _scheduleFlashSaleNotifications(schedule, notifProvider);
    }
    
    print('✅ [FlashSale] All notifications scheduled');
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
      print('⏭️ [FlashSale] ${schedule.title} already started, skipping start notification');
    }
    
    // ⭐ 2. NOTIFIKASI HAMPIR BERAKHIR (10 menit sebelum selesai)
    final almostEndTime = schedule.endTime.subtract(const Duration(minutes: 10));
    if (almostEndTime.isAfter(now)) {
      await _scheduleFlashSaleEndingSoonNotification(schedule, notifProvider);
    } else {
      print('⏭️ [FlashSale] ${schedule.title} ending time passed, skipping');
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
      color: const Color(0xFFFF6B35), // ✅ TAMBAHKAN const
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

    final notificationId = schedule.id.hashCode + 1; // +1 untuk start notification

    await _notifications.zonedSchedule(
      notificationId,
      '🔥 ${schedule.title} DIMULAI!',
      'Diskon ${schedule.discountPercentage}% untuk ${schedule.productIds.length} produk pilihan! Buruan cek sekarang!',
      scheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    // ✅ Tambahkan ke NotificationProvider juga (akan muncul di list notifikasi)
    _scheduleInAppNotification(
      schedule,
      notifProvider,
      isStarting: true,
    );

    print('🔔 [FlashSale] Scheduled START notification for ${schedule.title} at ${schedule.startTime}');
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
      color: const Color(0xFFFF3B30), // ✅ TAMBAHKAN const
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

    final notificationId = schedule.id.hashCode + 2; // +2 untuk ending notification

    await _notifications.zonedSchedule(
      notificationId,
      '⏰ ${schedule.title} HAMPIR BERAKHIR!',
      'Tinggal 10 menit! Jangan sampai ketinggalan diskon ${schedule.discountPercentage}%',
      scheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    // ✅ Tambahkan ke NotificationProvider juga
    _scheduleInAppNotification(
      schedule,
      notifProvider,
      isStarting: false,
    );

    print('🔔 [FlashSale] Scheduled ENDING notification for ${schedule.title} at $endingSoonTime');
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

    // Hitung delay sampai waktu trigger
    final now = DateTime.now();
    final delay = triggerTime.difference(now);

    if (delay.isNegative) {
      print('⏭️ [FlashSale] Time passed, skipping in-app notification');
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
      print('✅ [FlashSale] In-app notification added: ${notification.title}');
    });

    print('📅 [FlashSale] Scheduled in-app notification in ${delay.inMinutes} minutes');
  }

  // ✅ Cancel semua flash sale notifications
  Future<void> cancelAllFlashSaleNotifications() async {
    final schedules = FlashSaleService.getFlashSaleSchedules();
    
    for (var schedule in schedules) {
      // Cancel start notification
      await _notifications.cancel(schedule.id.hashCode + 1);
      // Cancel ending notification
      await _notifications.cancel(schedule.id.hashCode + 2);
    }
    
    print('🗑️ [FlashSale] All flash sale notifications cancelled');
  }

  // ✅ INSTANT: Kirim notifikasi flash sale sekarang (untuk testing atau immediate trigger)
  Future<void> sendFlashSaleNotificationNow({
    required String title,
    required String message,
    NotificationProvider? notifProvider,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'flash_sale_channel',
      'Flash Sale Notifications',
      channelDescription: 'Notifikasi untuk flash sale',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFFFF6B35), // ✅ TAMBAHKAN const
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

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      message,
      details,
    );

    // Tambahkan ke in-app notification jika provider tersedia
    if (notifProvider != null) {
      final notification = AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: NotifType.informasi,
        title: title,
        message: message,
        date: DateTime.now(),
        isRead: false,
        detailButtonText: 'Lihat Produk',
      );
      await notifProvider.addNotification(notification);
    }

    print('🔔 [FlashSale] Instant notification sent: $title');
  }
}