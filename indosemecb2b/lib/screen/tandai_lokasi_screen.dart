import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

class TandaiLokasiScreen extends StatefulWidget {
  const TandaiLokasiScreen({Key? key}) : super(key: key);

  @override
  State<TandaiLokasiScreen> createState() => _TandaiLokasiScreenState();
}

class _TandaiLokasiScreenState extends State<TandaiLokasiScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentLatLng;
  String? _currentAddress;
  Placemark? _currentPlacemark;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    print('🗺️ TandaiLokasiScreen - initState');
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    print('📍 Getting current location...');
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan aktifkan layanan lokasi'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin lokasi ditolak permanen'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final latLng = LatLng(position.latitude, position.longitude);
      print('✅ Got location: ${latLng.latitude}, ${latLng.longitude}');

      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      Placemark place = placemarks.first;
      print('🏘️ Placemark: ${place.administrativeArea}, ${place.locality}');

      setState(() {
        _currentLatLng = latLng;
        _currentPlacemark = place;
        _currentAddress =
            "${place.name ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}";
        _isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _currentLatLng != null) {
          _mapController.move(_currentLatLng!, 16);
        }
      });
    } catch (e) {
      print('❌ Error getting location: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mendapatkan lokasi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateLocationOnTap(LatLng point) async {
    print('📍 Location updated via tap: ${point.latitude}, ${point.longitude}');
    setState(() {
      _currentLatLng = point;
      _currentAddress = 'Memuat alamat...';
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        print('🏘️ New placemark: ${place.administrativeArea}, ${place.locality}');
        setState(() {
          _currentPlacemark = place;
          _currentAddress =
              "${place.name ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}";
        });
      }
    } catch (e) {
      print('❌ Error getting placemark: $e');
      setState(() {
        _currentAddress = 'Tidak dapat memuat alamat';
      });
    }
  }

  void _pilihLokasiIni() {
    print('✅ Pilih lokasi button pressed');
    if (_currentLatLng != null && _currentPlacemark != null) {
      final data = {
        'location': _currentLatLng!,
        'placemark': _currentPlacemark!,
      };
      
      print('📦 Returning data to LengkapiAlamatScreen:');
      print('   Location: ${_currentLatLng!.latitude}, ${_currentLatLng!.longitude}');
      print('   Placemark: ${_currentPlacemark!.administrativeArea}');
      
      // ⭐ PERBAIKAN: Gunakan pop dengan data, bukan pushReplacement
      Navigator.pop(context, data);
      print('🔙 Popped with data');
    } else {
      print('❌ Location or placemark is null');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih lokasi terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tandai Titik Lokasi',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentLatLng == null
              ? const Center(
                  child: Text(
                    'Tidak dapat mengambil lokasi.\nSilakan aktifkan GPS.',
                    textAlign: TextAlign.center,
                  ),
                )
              : Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _currentLatLng!,
                        initialZoom: 16,
                        onTap: (tapPosition, point) async {
                          await _updateLocationOnTap(point);
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                          subdomains: const ['a', 'b', 'c', 'd'],
                          userAgentPackageName: 'com.example.app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _currentLatLng!,
                              width: 60,
                              height: 60,
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Panel bawah
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.red),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _currentAddress ?? 'Memuat alamat...',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: _pilihLokasiIni,
                                child: const Text(
                                  'Pilih Titik Lokasi',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}