import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:indosemecb2b/utils/transaction_manager.dart';
import 'package:indosemecb2b/screen/notification_provider.dart';
import 'package:indosemecb2b/services/notifikasi.dart';

class TrackingServiceManager {
  static final TrackingServiceManager _instance =
      TrackingServiceManager._internal();
  factory TrackingServiceManager() => _instance;
  TrackingServiceManager._internal();

  final Map<String, TrackingData> _trackings = {};

  NotificationProvider? _notificationProvider;
  NotificationService? _notificationService;

  void setNotificationProviders({
    required NotificationProvider notificationProvider,
    required NotificationService notificationService,
  }) {
    _notificationProvider = notificationProvider;
    _notificationService = notificationService;
    print('✅ Notification providers set in TrackingServiceManager');
  }

  // ⭐ BARU: Start tracking dengan koordinat real
  Future<void> startTrackingWithCoordinates({
    required String transactionId,
    required LatLng koperasiLocation,
    required LatLng deliveryLocation,
  }) async {
    if (_trackings.containsKey(transactionId)) {
      print('⚠️ Tracking sudah berjalan untuk $transactionId');
      return;
    }

    print('🚀 Starting tracking for $transactionId');
    print(
      '📍 Koperasi: ${koperasiLocation.latitude}, ${koperasiLocation.longitude}',
    );
    print(
      '🏠 Tujuan: ${deliveryLocation.latitude}, ${deliveryLocation.longitude}',
    );

    try {
      // ⭐ Gunakan koordinat real dari koperasi & alamat
      final route = await _getRouteFromOSRM(koperasiLocation, deliveryLocation);

      final trackingData = TrackingData(
        transactionId: transactionId,
        route: route,
        currentIndex: 0,
        currentPosition: route.first,
        status: "Menyiapkan pesanan",
        statusDesc: "Kurir sedang menunggu konfirmasi toko",
      );

      _trackings[transactionId] = trackingData;
      _startTimer(transactionId);

      print('✅ Tracking started with real coordinates');
      print('📊 Route length: ${route.length} points');
    } catch (e) {
      print('❌ Error starting tracking: $e');
    }
  }

  // ⭐ FALLBACK: Jika tidak ada koordinat (backward compatibility)
  Future<void> startTracking(String transactionId) async {
    print('⚠️ Using fallback coordinates (backward compatibility)');

    // Koordinat default Bandung area
    final start = LatLng(-6.9379454, 107.661099);
    final end = LatLng(-6.9254643, 107.6604138);

    await startTrackingWithCoordinates(
      transactionId: transactionId,
      koperasiLocation: start,
      deliveryLocation: end,
    );
  }

  void stopTracking(String transactionId) {
    final tracking = _trackings[transactionId];
    if (tracking != null) {
      tracking.timer?.cancel();
      _trackings.remove(transactionId);
      print('🛑 Tracking stopped for $transactionId');
    }
  }

  TrackingData? getTracking(String transactionId) {
    return _trackings[transactionId];
  }

  bool hasTracking(String transactionId) {
    return _trackings.containsKey(transactionId);
  }

  List<Map<String, String>> getStatusHistory(String transactionId) {
    final tracking = _trackings[transactionId];
    if (tracking == null) {
      return [
        {
          "title": "Menyiapkan pesanan",
          "desc": "Kurir sedang menunggu konfirmasi toko",
          "time": _formatTime(DateTime.now()),
        },
      ];
    }

    final progress = tracking.currentIndex / tracking.route.length;
    final now = DateTime.now();

    List<Map<String, String>> history = [];

    if (progress >= 0.0) {
      history.add({
        "title": "Menyiapkan pesanan",
        "desc": "Kurir sedang menunggu konfirmasi toko",
        "time": _formatTime(
          now.subtract(Duration(minutes: (progress * 60).round())),
        ),
      });
    }

    if (progress >= 0.2) {
      history.add({
        "title": "Sedang dikirim",
        "desc": "Kurir sedang dalam perjalanan mengambil rute utama",
        "time": _formatTime(
          now.subtract(Duration(minutes: ((1 - progress) * 50).round())),
        ),
      });
    }

    if (progress >= 0.5) {
      history.add({
        "title": "Hampir sampai",
        "desc": "Kurir sebentar lagi tiba di lokasi tujuan",
        "time": _formatTime(
          now.subtract(Duration(minutes: ((1 - progress) * 30).round())),
        ),
      });
    }

    if (progress >= 0.9) {
      history.add({
        "title": "Pesanan telah sampai",
        "desc": "Pesanan berhasil diantarkan ke alamat tujuan",
        "time": _formatTime(now),
      });
    }

    if (!history.any((h) => h["title"] == tracking.status)) {
      history.add({
        "title": tracking.status,
        "desc": tracking.statusDesc,
        "time": _formatTime(now),
      });
    }

    return history;
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat("dd MMMM yyyy | HH:mm", "id_ID").format(dateTime);
  }

  void _startTimer(String transactionId) {
    final tracking = _trackings[transactionId];
    if (tracking == null) return;

    final distance = Distance();

    tracking.timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      final tracking = _trackings[transactionId];
      if (tracking == null) {
        timer.cancel();
        return;
      }

      final remainingDistance = distance(
        tracking.currentPosition,
        tracking.route.last,
      );

      if (remainingDistance > 50) {
        if (tracking.currentIndex < tracking.route.length - 1) {
          tracking.currentIndex++;
          tracking.currentPosition = tracking.route[tracking.currentIndex];

          final previousStatus = tracking.status;
          _updateStatus(tracking);

          if (previousStatus != tracking.status) {
            _sendStatusChangeNotification(transactionId, tracking.status);
          }
        }

        tracking.notifier.value = tracking.currentPosition;
        tracking.statusNotifier.value = tracking.status;
      } else {
        final previousStatus = tracking.status;

        tracking.status = "Pesanan telah sampai";
        tracking.statusDesc = "Pesanan berhasil diantarkan ke alamat tujuan";
        tracking.notifier.value = tracking.currentPosition;
        tracking.statusNotifier.value = tracking.status;

        if (previousStatus != "Pesanan telah sampai") {
          _sendStatusChangeNotification(transactionId, tracking.status);
        }

        TransactionManager.updateTransactionStatus(
          transactionId,
          "Pesanan telah sampai",
        );

        timer.cancel();
        print('✅ Kurir sampai di tujuan - Menunggu konfirmasi penerimaan');
      }
    });
  }

  void _updateStatus(TrackingData tracking) {
    final progress = tracking.currentIndex / tracking.route.length;
    String newStatus;
    String newStatusDesc;

    if (progress < 0.3) {
      newStatus = "Sedang dikirim";
      newStatusDesc = "Kurir sedang dalam perjalanan mengambil rute utama";
    } else if (progress < 0.7) {
      newStatus = "Hampir sampai";
      newStatusDesc = "Kurir sebentar lagi tiba di lokasi tujuan";
    } else {
      newStatus = "Mendekati tujuan";
      newStatusDesc = "Kurir akan segera tiba di lokasi pengantaran";
    }

    tracking.status = newStatus;
    tracking.statusDesc = newStatusDesc;

    TransactionManager.updateTransactionStatus(
      tracking.transactionId,
      newStatus,
    );
  }

  Future<void> _sendStatusChangeNotification(
    String transactionId,
    String newStatus,
  ) async {
    try {
      print('🔔 Sending notification for status change: $newStatus');

      final transactions = await TransactionManager.getTransactions();
      final transaction = transactions.firstWhere(
        (t) => t.id == transactionId,
        orElse: () => throw Exception('Transaction not found'),
      );

      final transactionData = {
        'id': transaction.id,
        'no_transaksi': transaction.id,
        'status': newStatus,
        'date': transaction.date.toIso8601String(),
        'totalPrice': transaction.totalPrice,
        'items':
            transaction.items
                .map(
                  (item) => {
                    'productId': item.productId,
                    'name': item.name,
                    'price': item.price,
                    'quantity': item.quantity,
                    'imageUrl': item.imageUrl,
                  },
                )
                .toList(),
        'deliveryOption': transaction.deliveryOption,
        'alamat': transaction.alamat,
        'metodePembayaran': transaction.metodePembayaran,
        'voucherCode': transaction.voucherCode,
        'voucherDiscount': transaction.voucherDiscount,
      };

      if (newStatus == "Sedang dikirim") {
        if (_notificationService != null) {
          await _notificationService!.showOrderShippedNotification(
            orderId: transactionId,
            deliveryTime: "30-45 menit",
            transactionData: transactionData,
          );
        }

        if (_notificationProvider != null) {
          await _notificationProvider!.addOrderShippedNotification(
            orderId: transactionId,
            deliveryTime: "30-45 menit",
            productImage:
                transaction.items.isNotEmpty
                    ? transaction.items.first.imageUrl
                    : null,
            transactionData: transactionData,
          );
        }

        print('✅ Notification sent: Sedang dikirim');
      } else if (newStatus == "Pesanan telah sampai") {
        if (_notificationService != null) {
          await _notificationService!.showOrderArrivedNotification(
            orderId: transactionId,
            transactionData: transactionData,
          );
        }

        if (_notificationProvider != null) {
          await _notificationProvider!.addOrderArrivedNotification(
            orderId: transactionId,
            productImage:
                transaction.items.isNotEmpty
                    ? transaction.items.first.imageUrl
                    : null,
            transactionData: transactionData,
          );
        }

        print('✅ Notification sent: Pesanan telah sampai');
      }
    } catch (e) {
      print('❌ Error sending notification: $e');
    }
  }

  // ⭐ OSRM Route dengan error handling lebih baik
  Future<List<LatLng>> _getRouteFromOSRM(LatLng start, LatLng end) async {
    try {
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${start.longitude},${start.latitude};${end.longitude},${end.latitude}'
        '?overview=full&geometries=geojson',
      );

      print('🌐 Fetching route from OSRM...');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coords = data['routes'][0]['geometry']['coordinates'] as List;
        final route = coords.map((c) => LatLng(c[1], c[0])).toList();
        print('✅ Route fetched: ${route.length} points');
        return route;
      } else {
        throw Exception('OSRM API error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching route: $e');
      print('⚠️ Using direct line as fallback');
      // Fallback: buat garis lurus jika OSRM gagal
      return [start, end];
    }
  }

  void disposeAll() {
    for (var tracking in _trackings.values) {
      tracking.timer?.cancel();
      tracking.notifier.dispose();
      tracking.statusNotifier.dispose();
    }
    _trackings.clear();
  }
}

class TrackingData {
  final String transactionId;
  final List<LatLng> route;
  int currentIndex;
  LatLng currentPosition;
  String status;
  String statusDesc;
  Timer? timer;
  final ValueNotifier<LatLng> notifier;
  final ValueNotifier<String> statusNotifier;

  TrackingData({
    required this.transactionId,
    required this.route,
    required this.currentIndex,
    required this.currentPosition,
    required this.status,
    required this.statusDesc,
  }) : notifier = ValueNotifier<LatLng>(currentPosition),
       statusNotifier = ValueNotifier<String>(status);
}
