import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  final List<AppNotification> _notifications = [];

  List<AppNotification> get notifications => _notifications;

  void addNotification(AppNotification notif) {
    _notifications.insert(0, notif); // tambahkan paling atas
    notifyListeners();
  }

  List<AppNotification> getTransaksiNotifs() {
    return _notifications
        .where((notif) => notif.category == "Transaksi")
        .toList();
  }
}
