import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:indosemecb2b/screen/notification_provider.dart';
import 'package:indosemecb2b/services/notifikasi.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/tracking.dart';
import '../services/tracking_service.dart';

class TrackingScreen extends StatefulWidget {
  final OrderTrackingModel trackingData;

  const TrackingScreen({super.key, required this.trackingData});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final MapController _mapController = MapController();
  final TrackingServiceManager _trackingService = TrackingServiceManager();

  bool _isUserInteracting = false;
  Timer? _userInactivityTimer;

  // ⭐ Listener untuk di-dispose
  VoidCallback? _positionListener;
  VoidCallback? _statusListener;

  List<LatLng> _rute = [];
  LatLng? _posisiKurir;
  String _statusPesanan = "Menyiapkan pesanan";
  String _statusDesc = "Kurir sedang menunggu konfirmasi toko";
  List<Map<String, String>> _statusList = [];

  @override
  @override
  void initState() {
    super.initState();

    // ⚠️ VALIDASI STATUS SEBELUM INIT TRACKING
    final initialStatus = widget.trackingData.statusMessage;
    print('🔍 TrackingScreen initState - Status: $initialStatus');

    // ✅ Jangan start tracking jika status sudah Selesai atau Dibatalkan
    if (initialStatus == 'Selesai' || initialStatus == 'Dibatalkan') {
      print('⚠️ Status $initialStatus - Skip tracking initialization');

      // Set initial state saja tanpa start tracking
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        setState(() {
          _statusPesanan = initialStatus ?? "Status tidak diketahui";
          _statusDesc =
              initialStatus == 'Selesai'
                  ? "Pesanan telah selesai dan diterima"
                  : "Pesanan telah dibatalkan";
          _statusList = [
            {
              "title": _statusPesanan,
              "desc": _statusDesc,
              "time": DateFormat(
                'dd MMM yyyy, HH:mm',
                'id_ID',
              ).format(widget.trackingData.updatedAt ?? DateTime.now()),
            },
          ];
        });
      });
      return; // ⚠️ PENTING: Return untuk skip tracking service
    }

    // ✅ Hanya init tracking untuk status yang masih dalam proses
    print('✅ Status dalam proses - Initializing tracking');

    // Setup notification providers
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );
    final notificationService = NotificationService();
    TrackingServiceManager().setNotificationProviders(
      notificationProvider: notificationProvider,
      notificationService: notificationService,
    );

    // Start tracking dan init
    final transactionId = widget.trackingData.transactionId;
    if (transactionId != null) {
      TrackingServiceManager().startTracking(transactionId);
      _initTrackingData(transactionId);
    }
  }

  // ✅ Method terpisah untuk init tracking data
  Future<void> _initTrackingData(String transactionId) async {
    print('🔍 Initializing tracking for: $transactionId');

    if (!_trackingService.hasTracking(transactionId)) {
      print('📦 Starting new tracking...');
      await _trackingService.startTracking(transactionId);
    } else {
      print('✅ Tracking already exists');
    }

    final tracking = _trackingService.getTracking(transactionId);
    if (tracking == null) {
      print('❌ Failed to get tracking data');
      return;
    }

    print('✅ Got tracking data - Status: ${tracking.status}');
    print('📊 Route length: ${tracking.route.length}');
    print('📍 Current index: ${tracking.currentIndex}');

    if (!mounted) return;

    setState(() {
      _rute = tracking.route;
      _posisiKurir = tracking.currentPosition;
      _statusPesanan = tracking.status;
      _statusDesc = tracking.statusDesc;
      _statusList = _trackingService.getStatusHistory(transactionId);
    });

    print('✅ Initial state set - Status: $_statusPesanan');

    // ⭐ Listen to position updates
    _positionListener = () {
      if (!mounted) return;

      final tracking = _trackingService.getTracking(transactionId);
      if (tracking == null) return;

      print('🔄 Position update - Status: ${tracking.status}');

      setState(() {
        _posisiKurir = tracking.currentPosition;
        _statusList = _trackingService.getStatusHistory(transactionId);
      });

      // Auto move camera if not interacting
      if (!_isUserInteracting && _posisiKurir != null) {
        _mapController.move(_posisiKurir!, 16);
      }
    };
    tracking.notifier.addListener(_positionListener!);

    // ⭐ Listen to status updates
    _statusListener = () {
      if (!mounted) return;

      final tracking = _trackingService.getTracking(transactionId);
      if (tracking == null) return;

      print('🔄 Status update - New status: ${tracking.status}');

      setState(() {
        _statusPesanan = tracking.status;
        _statusDesc = tracking.statusDesc;
        _statusList = _trackingService.getStatusHistory(transactionId);
      });
    };
    tracking.statusNotifier.addListener(_statusListener!);
  }

  @override
  void dispose() {
    _userInactivityTimer?.cancel();

    // ⭐ Remove listeners sebelum dispose
    final transactionId = widget.trackingData.transactionId;
    if (transactionId != null) {
      final tracking = _trackingService.getTracking(transactionId);
      if (tracking != null) {
        if (_positionListener != null) {
          tracking.notifier.removeListener(_positionListener!);
        }
        if (_statusListener != null) {
          tracking.statusNotifier.removeListener(_statusListener!);
        }
      }
    }

    super.dispose();
  }

  String formatDate(DateTime? date) {
    if (date == null) return "-";
    return DateFormat("dd MMMM yyyy | HH:mm", "id_ID").format(date);
  }

  IconData _getStatusIcon(String statusTitle) {
    switch (statusTitle) {
      case "Menyiapkan pesanan":
        return Icons.receipt_long;
      case "Sedang dikirim":
        return Icons.local_shipping;
      case "Hampir sampai":
        return Icons.location_on;
      case "Pesanan telah sampai":
        return Icons.check_circle;
      case "Selesai":
        return Icons.done_all;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lacak Pesanan"),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= NOMOR PESANAN =================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      "https://play-lh.googleusercontent.com/DJTA3L_AgQCc_pXa5FWPu28yVttyTVWrFqujT97Ykx9siWaMff7oZloheywrNyIW0A",
                      width: 58,
                      height: 58,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Nomor Pesanan",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.trackingData.orderId ??
                              widget.trackingData.transactionId ??
                              "-",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= MAP =================
            const Text(
              "Lokasi Kurir",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child:
                    _rute.isEmpty
                        ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(),
                          ),
                        )
                        : FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _posisiKurir ?? _rute.first,
                            initialZoom: 16,
                            onMapEvent: (event) {
                              if (event is MapEventMoveStart) {
                                _isUserInteracting = true;
                                _userInactivityTimer?.cancel();
                              }

                              if (event is MapEventMove ||
                                  event is MapEventMoveEnd) {
                                _userInactivityTimer?.cancel();
                                _userInactivityTimer = Timer(
                                  const Duration(seconds: 4),
                                  () {
                                    if (mounted) {
                                      setState(() {
                                        _isUserInteracting = false;
                                      });
                                      if (_posisiKurir != null) {
                                        _mapController.move(_posisiKurir!, 16);
                                      }
                                    }
                                  },
                                );
                              }
                            },
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                              subdomains: const ['a', 'b', 'c'],
                            ),
                            PolylineLayer(
                              polylines: [
                                Polyline(
                                  points: _rute,
                                  strokeWidth: 4,
                                  color: Colors.green,
                                ),
                              ],
                            ),
                            if (_rute.isNotEmpty)
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: _rute.first,
                                    width: 50,
                                    height: 50,
                                    child: Column(
                                      children: const [
                                        Icon(
                                          Icons.location_pin,
                                          color: Colors.red,
                                          size: 32,
                                        ),
                                        Expanded(
                                          child: Text(
                                            "Jemput",
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Marker(
                                    point: _rute.last,
                                    width: 50,
                                    height: 50,
                                    child: Column(
                                      children: const [
                                        Icon(
                                          Icons.location_pin,
                                          color: Colors.red,
                                          size: 32,
                                        ),
                                        Text(
                                          "Tujuan",
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            if (_posisiKurir != null)
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: _posisiKurir!,
                                    width: 50,
                                    height: 50,
                                    child: ClipOval(
                                      child: Image.asset(
                                        'assets/motor.png',
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
              ),
            ),

            const SizedBox(height: 20),

            // ================= DELIVERY MAN =================
            const Text(
              "Informasi Delivery Man",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.blue[700],
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.trackingData.courierName ?? "Delivery Man",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.trackingData.courierId ?? "ID-000",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= STATUS =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Status Pesanan",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                // Debug info badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _statusPesanan,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Timeline Cards - Multiple cards bertambah seiring progress
            ..._statusList.map((status) {
              final isLatest = status["title"] == _statusPesanan;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: isLatest ? Colors.blue : Colors.grey.shade300,
                    width: isLatest ? 2 : 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: isLatest ? Colors.blue : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        if (!isLatest)
                          Container(
                            width: 2,
                            height: 40,
                            color: Colors.grey.shade300,
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            status["title"]!,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  isLatest ? FontWeight.bold : FontWeight.w500,
                              color: isLatest ? Colors.blue : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            status["desc"]!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            status["time"]!,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
