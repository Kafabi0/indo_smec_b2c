import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:indosemecb2b/utils/transaction_manager.dart';

class TrackingServiceManager {
  static final TrackingServiceManager _instance =
      TrackingServiceManager._internal();
  factory TrackingServiceManager() => _instance;
  TrackingServiceManager._internal();

  final Map<String, TrackingData> _trackings = {};

  Future<void> startTracking(String transactionId) async {
    if (_trackings.containsKey(transactionId)) {
      print('⚠️ Tracking sudah berjalan untuk $transactionId');
      return;
    }

    print('🚀 Starting tracking for $transactionId');

    try {
      final start = LatLng(-6.9379454, 107.661099);
      final end = LatLng(-6.9254643, 107.6604138);
      final route = await _getRouteFromOSRM(start, end);

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

      print('✅ Tracking started for $transactionId');
    } catch (e) {
      print('❌ Error starting tracking: $e');
    }
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

    history.add({
      "title": "Menyiapkan pesanan",
      "desc": "Kurir sedang menunggu konfirmasi toko",
      "time": _formatTime(
        now.subtract(Duration(minutes: (progress * 60).round())),
      ),
    });

    if (progress >= 0.33) {
      history.add({
        "title": "Sedang dikirim",
        "desc": "Kurir sedang dalam perjalanan mengambil rute utama",
        "time": _formatTime(
          now.subtract(Duration(minutes: ((1 - progress) * 40).round())),
        ),
      });
    }

    if (progress >= 0.66) {
      history.add({
        "title": "Hampir sampai",
        "desc": "Kurir sebentar lagi tiba di lokasi tujuan",
        "time": _formatTime(
          now.subtract(Duration(minutes: ((1 - progress) * 20).round())),
        ),
      });
    }

    if (progress >= 0.95) {
      history.add({
        "title": "Pesanan telah sampai",
        "desc": "Pesanan berhasil diantarkan ke alamat tujuan",
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

      // Cek apakah sudah hampir sampai tujuan
      final remainingDistance = distance(
        tracking.currentPosition,
        tracking.route.last,
      );

      // 🚫 Jangan selesai kalau masih jauh
      if (remainingDistance > 50) {
        // Geser ke titik berikutnya
        if (tracking.currentIndex < tracking.route.length - 1) {
          tracking.currentIndex++;
          tracking.currentPosition = tracking.route[tracking.currentIndex];
          _updateStatus(tracking);
        }

        tracking.notifier.value = tracking.currentPosition;
        tracking.statusNotifier.value = tracking.status;
      } else {
        // ✅ Benar-benar sudah sampai
        tracking.status = "Pesanan telah sampai";
        tracking.statusDesc = "Pesanan berhasil diantarkan ke alamat tujuan";
        tracking.notifier.value = tracking.currentPosition;
        tracking.statusNotifier.value = tracking.status;

        TransactionManager.updateTransactionStatus(
          transactionId,
          "Pesanan selesai",
        );

        timer.cancel();
        print('✅ Kurir sampai di tujuan - Tracking selesai');
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

  Future<List<LatLng>> _getRouteFromOSRM(LatLng start, LatLng end) async {
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${start.longitude},${start.latitude};${end.longitude},${end.latitude}'
      '?overview=full&geometries=geojson',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final coords = data['routes'][0]['geometry']['coordinates'] as List;
      return coords.map((c) => LatLng(c[1], c[0])).toList();
    } else {
      throw Exception('Gagal memuat rute');
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
  final ValueNotifier<String> statusNotifier; // ⭐ TAMBAHAN untuk status

  TrackingData({
    required this.transactionId,
    required this.route,
    required this.currentIndex,
    required this.currentPosition,
    required this.status,
    required this.statusDesc,
  }) : notifier = ValueNotifier<LatLng>(currentPosition),
       statusNotifier = ValueNotifier<String>(status); // ⭐ INIT status notifier
}
