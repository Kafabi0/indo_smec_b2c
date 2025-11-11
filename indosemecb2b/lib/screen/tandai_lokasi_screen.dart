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
  final TextEditingController _searchController = TextEditingController();
  LatLng? _currentLatLng;
  String? _currentAddress;
  Placemark? _currentPlacemark;
  bool _isLoading = true;
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];
  bool _showSearchResults = false;

  @override
  void initState() {
    super.initState();
    print('🗺️ TandaiLokasiScreen - initState');
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _showSearchResults = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      print('🔍 Searching for: $query');

      // Cari lokasi berdasarkan query
      List<Location> locations = await locationFromAddress(query);
      print('✅ Found ${locations.length} location results');

      // Convert setiap location ke placemark untuk mendapatkan nama lengkap
      List<Map<String, dynamic>> detailedResults = [];

      for (var location in locations) {
        try {
          List<Placemark> placemarks = await placemarkFromCoordinates(
            location.latitude,
            location.longitude,
          );

          if (placemarks.isNotEmpty) {
            Placemark place = placemarks.first;

            // Format nama lengkap
            String mainName = place.name ?? place.street ?? '';
            String subLocality = place.subLocality ?? '';
            String locality = place.locality ?? '';
            String subAdminArea = place.subAdministrativeArea ?? '';
            String adminArea = place.administrativeArea ?? '';

            // Buat alamat yang readable
            List<String> addressParts = [];
            if (mainName.isNotEmpty && mainName != locality) {
              addressParts.add(mainName);
            }
            if (subLocality.isNotEmpty && subLocality != mainName) {
              addressParts.add(subLocality);
            }
            if (locality.isNotEmpty) {
              addressParts.add(locality);
            }
            if (subAdminArea.isNotEmpty && subAdminArea != locality) {
              addressParts.add(subAdminArea);
            }
            if (adminArea.isNotEmpty) {
              addressParts.add(adminArea);
            }

            String fullAddress = addressParts.join(', ');

            // Buat subtitle (area/region)
            List<String> subtitleParts = [];
            if (locality.isNotEmpty) {
              subtitleParts.add(locality);
            }
            if (adminArea.isNotEmpty && adminArea != locality) {
              subtitleParts.add(adminArea);
            }
            String subtitle = subtitleParts.join(', ');

            detailedResults.add({
              'location': location,
              'placemark': place,
              'title':
                  fullAddress.isNotEmpty ? fullAddress : 'Lokasi ditemukan',
              'subtitle': subtitle.isNotEmpty ? subtitle : 'Indonesia',
            });

            print('📍 Result: $fullAddress');
          }
        } catch (e) {
          print('⚠️ Error getting placemark for location: $e');
          // Tetap tambahkan hasil meskipun gagal mendapat placemark
          detailedResults.add({
            'location': location,
            'placemark': null,
            'title':
                'Lat: ${location.latitude.toStringAsFixed(6)}, Lng: ${location.longitude.toStringAsFixed(6)}',
            'subtitle': 'Koordinat',
          });
        }
      }

      setState(() {
        _searchResults = detailedResults;
        _showSearchResults = true;
        _isSearching = false;
      });

      print('✅ Processed ${detailedResults.length} detailed results');
    } catch (e) {
      print('❌ Error searching location: $e');
      setState(() {
        _searchResults = [];
        _showSearchResults = false;
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lokasi tidak ditemukan. Coba kata kunci lain.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _selectSearchResult(Map<String, dynamic> result) async {
    final Location location = result['location'];
    final Placemark? placemark = result['placemark'];

    final latLng = LatLng(location.latitude, location.longitude);
    print('📍 Selected: ${result['title']}');
    print('📍 Coordinates: ${latLng.latitude}, ${latLng.longitude}');

    setState(() {
      _showSearchResults = false;
      _searchResults = [];
      _currentLatLng = latLng;
      _currentPlacemark = placemark;
      _currentAddress = result['title'];
    });

    // Animasi ke lokasi yang dipilih
    _mapController.move(latLng, 16);

    // Clear search field
    _searchController.clear();
    FocusScope.of(context).unfocus();
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
        print(
          '🏘️ New placemark: ${place.administrativeArea}, ${place.locality}',
        );
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
      print(
        '   Location: ${_currentLatLng!.latitude}, ${_currentLatLng!.longitude}',
      );
      print('   Placemark: ${_currentPlacemark!.administrativeArea}');

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
      body:
          _isLoading
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
                  // Map
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

                  // Search Bar
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Cari alamat atau tempat...',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey[600],
                              ),
                              suffixIcon:
                                  _searchController.text.isNotEmpty
                                      ? IconButton(
                                        icon: Icon(
                                          Icons.clear,
                                          color: Colors.grey[600],
                                        ),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() {
                                            _searchResults = [];
                                            _showSearchResults = false;
                                          });
                                        },
                                      )
                                      : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {});
                            },
                            onSubmitted: (value) {
                              _searchLocation(value);
                            },
                          ),
                        ),

                        // Search Results
                        if (_showSearchResults && _searchResults.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            constraints: const BoxConstraints(maxHeight: 200),
                            child: ListView.separated(
                              shrinkWrap: true,
                              padding: const EdgeInsets.all(8),
                              itemCount: _searchResults.length,
                              separatorBuilder:
                                  (context, index) => Divider(
                                    color: Colors.grey[300],
                                    height: 1,
                                  ),
                              itemBuilder: (context, index) {
                                final result = _searchResults[index];
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.location_on,
                                      color: Colors.blue[700],
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    result['title'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    result['subtitle'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 14,
                                    color: Colors.grey[400],
                                  ),
                                  onTap: () => _selectSearchResult(result),
                                );
                              },
                            ),
                          ),

                        if (_isSearching)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'Mencari lokasi...',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Current Location Button
                  Positioned(
                    right: 16,
                    bottom: 180,
                    child: FloatingActionButton(
                      mini: true,
                      backgroundColor: Colors.white,
                      onPressed: () {
                        if (_currentLatLng != null) {
                          _mapController.move(_currentLatLng!, 16);
                        } else {
                          _getCurrentLocation();
                        }
                      },
                      child: Icon(Icons.my_location, color: Colors.blue[700]),
                    ),
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
