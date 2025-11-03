import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:indosemecb2b/screen/keranjang.dart';
import 'package:indosemecb2b/screen/main_navigasi.dart';
import 'package:indosemecb2b/screen/notification_provider.dart';
import 'package:indosemecb2b/services/notifikasi.dart';
import 'package:indosemecb2b/services/tracking_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Inisialisasi locale Indonesia
  await initializeDateFormatting('id_ID', null);

  // 🔹 Inisialisasi timezone (WAJIB sebelum pakai zonedSchedule)
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

  // 🔹 Inisialisasi NotificationService kamu
  final notificationService = NotificationService();
  await notificationService.initialize();

  // 🔹 Minta izin notifikasi (Android 13+)
  await notificationService.requestPermission();

  // 🔹 Pastikan izin notifikasi benar-benar diminta (Android 13+)
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final androidPlugin =
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
  final granted = await androidPlugin?.requestNotificationsPermission();
  print('🔔 Notification permission granted: $granted');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  MyApp({Key? key}) : super(key: key) {
    NotificationService.setNavigatorKey(navigatorKey);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IndoSmec B2C',
      navigatorKey: navigatorKey,
      navigatorObservers: [CartScreenState.routeObserver],
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const MainNavigation(),
      debugShowCheckedModeBanner: false,
    );
  }
}
