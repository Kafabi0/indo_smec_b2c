import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import '../models/tracking.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/transaction_manager.dart'; // Tambahkan import ini

class TrackingScreen extends StatefulWidget {
  final OrderTrackingModel trackingData;

  const TrackingScreen({super.key, required this.trackingData});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();

  final List<LatLng> _rute = [];
  bool _isUserInteracting = false;
  Timer? _userInactivityTimer;

  String _statusPesanan = "Menyiapkan pesanan";
  String _statusDesc = "Kurir sedang menunggu konfirmasi toko";
  final List<Map<String, String>> _semuaStatus = [
    {
      "title": "Menyiapkan pesanan",
      "desc": "Kurir sedang menunggu konfirmasi toko",
    },
    {
      "title": "Sedang dikirim",
      "desc": "Kurir sedang dalam perjalanan mengambil rute utama",
    },
    {
      "title": "Hampir sampai",
      "desc": "Kurir sebentar lagi tiba di lokasi tujuan",
    },
    {
      "title": "Pesanan telah sampai",
      "desc": "Pesanan berhasil diantarkan ke alamat tujuan",
    },
    {
      "title": "Pesanan selesai",
      "desc": "Kurir telah menyelesaikan pengantaran",
    },
  ];

  int _index = 0;
  LatLng? _posisiKurir;
  Timer? _timer;

  late AnimationController _animController;
  Animation<double>? _animasi;
  final ValueNotifier<String> _statusNotifier = ValueNotifier<String>("Menyiapkan pesanan");

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _loadRoute();
  }

  final List<Map<String, String>> _statusList = [
    {
      "title": "Menyiapkan pesanan",
      "desc": "Kurir sedang menunggu konfirmasi toko",
      "time": DateFormat("dd MMM yyyy | HH:mm", "id_ID").format(DateTime.now()),
    },
  ];

  Future<List<LatLng>> getRouteFromOSRM(LatLng start, LatLng end) async {
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

  Future<void> _loadRoute() async {
    try {
      final start = LatLng(-6.9379454, 107.661099);
      final end = LatLng(-6.9254643, 107.6604138);
      final route = await getRouteFromOSRM(start, end);

      setState(() {
        _rute.clear();
        _rute.addAll(route);
        _posisiKurir = _rute.first;
      });

      _mulaiSimulasi();
    } catch (e) {
      print('Error memuat rute: $e');
    }
  }

  void _updateStatus() {
    String newStatus;
    String newDesc;
    
    if (_index < _rute.length / 3) {
      newStatus = _semuaStatus[1]["title"]!;
      newDesc = _semuaStatus[1]["desc"]!;
    } else if (_index < _rute.length * 2 / 3) {
      newStatus = _semuaStatus[2]["title"]!;
      newDesc = _semuaStatus[2]["desc"]!;
    } else {
      newStatus = _semuaStatus[3]["title"]!;
      newDesc = _semuaStatus[3]["desc"]!;
    }
    
    // Update status notifier
    _statusNotifier.value = newStatus;
    
    setState(() {
      _statusPesanan = newStatus;
      _statusDesc = newDesc;
    });
    
    // Update status di TransactionManager
    if (widget.trackingData.transactionId != null) {
      TransactionManager.updateTransactionStatus(
        widget.trackingData.transactionId!, 
        newStatus
      );
    }
    
    // Tambahkan status ke list jika belum ada
    final sudahAda = _statusList.any((s) => s["title"] == newStatus);
    if (!sudahAda) {
      _statusList.add({
        "title": newStatus,
        "desc": newDesc,
        "time": formatDate(DateTime.now()),
      });
    }
  }

  void _mulaiSimulasi() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_index < _rute.length - 1) {
        final start = _rute[_index];
        final end = _rute[_index + 1];
        _animController.reset();

        _animasi = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
        )..addListener(() {
          final lat =
              start.latitude +
              (_animasi!.value * (end.latitude - start.latitude));
          final lng =
              start.longitude +
              (_animasi!.value * (end.longitude - start.longitude));
          setState(() => _posisiKurir = LatLng(lat, lng));

          // Hanya pindahkan kamera jika user tidak sedang menggeser
          if (!_isUserInteracting) {
            _mapController.move(_posisiKurir!, 16);
          }
        });

        _animController.forward();
        _index++;

        setState(() => _updateStatus());
      } else {
        setState(() {
          _statusPesanan = "Pesanan selesai";
          _statusDesc = "Kurir telah menyelesaikan pengantaran";
        });
        
        // Update final status
        _statusNotifier.value = "Pesanan selesai";
        if (widget.trackingData.transactionId != null) {
          TransactionManager.updateTransactionStatus(
            widget.trackingData.transactionId!, 
            "Pesanan selesai"
          );
        }
        
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    _userInactivityTimer?.cancel();
    _statusNotifier.dispose();
    super.dispose();
  }

  String formatDate(DateTime? date) {
    if (date == null) return "-";
    return DateFormat("dd MMMM yyyy | HH:mm", "id_ID").format(date);
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
                          widget.trackingData.orderId ?? "-",
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
                            initialCenter: _rute.first,
                            initialZoom: 16,
                            onMapEvent: (event) {
                              // Ketika user mulai menggeser peta
                              if (event is MapEventMoveStart) {
                                _isUserInteracting = true;
                                _userInactivityTimer
                                    ?.cancel(); // hentikan timer lama
                              }

                              // Setiap kali user menggerakkan peta (move / pan / zoom)
                              if (event is MapEventMove ||
                                  event is MapEventMoveEnd) {
                                _userInactivityTimer?.cancel(); // reset timer
                                _userInactivityTimer = Timer(
                                  const Duration(seconds: 4),
                                  () {
                                    // Setelah 4 detik tidak ada interaksi
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
                            // --- Peta dasar ---
                            TileLayer(
                              urlTemplate:
                                  'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                              subdomains: const ['a', 'b', 'c'],
                            ),

                            // --- Garis rute kurir ---
                            PolylineLayer(
                              polylines: [
                                Polyline(
                                  points: _rute,
                                  strokeWidth: 4,
                                  color: Colors.green,
                                ),
                              ],
                            ),

                            // --- Titik penjemputan & tujuan ---
                            if (_rute.isNotEmpty)
                              MarkerLayer(
                                markers: [
                                  // Titik penjemputan
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
                                  // Titik tujuan
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

                            // --- Posisi kurir yang bergerak ---
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
            ValueListenableBuilder<String>(
              valueListenable: _statusNotifier,
              builder: (context, currentStatus, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Status Pesanan",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children:
                          _statusList.map((status) {
                            final isLast = status["title"] == currentStatus;
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
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                border: Border.all(
                                  color: isLast ? Colors.blue : Colors.grey.shade300,
                                  width: isLast ? 2 : 1,
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
                                          color: isLast ? Colors.blue : Colors.grey,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      if (!isLast)
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
                                                isLast
                                                    ? FontWeight.bold
                                                    : FontWeight.w500,
                                            color: isLast ? Colors.blue : Colors.black,
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
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}