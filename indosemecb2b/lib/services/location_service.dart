import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static const String _cachedLocationKey = 'cached_user_location';
  static const String _lastLocationUpdateKey = 'last_location_update';
  
  // Cache untuk menyimpan lokasi terakhir
  static Map<String, dynamic>? _cachedLocation;
  static DateTime? _lastUpdateTime;

  // ============ GET USER LOCATION DENGAN CACHING ============
  static Future<Map<String, dynamic>?> getUserLocation({bool forceRefresh = false}) async {
    // Cek cache dulu jika tidak force refresh
    if (!forceRefresh && _cachedLocation != null) {
      // Cek apakah cache masih valid (kurang dari 1 jam)
      if (_lastUpdateTime != null && 
          DateTime.now().difference(_lastUpdateTime!).inMinutes < 60) {
        print('📍 [LocationService] Menggunakan lokasi dari cache');
        return _cachedLocation;
      }
    }

    print('🔄 [LocationService] Mendapatkan lokasi baru...');
    
    bool serviceEnabled;
    LocationPermission permission;

    // Cek apakah location service aktif
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('⚠️ Location service tidak aktif');
      return _cachedLocation; // Kembalikan cache jika ada
    }

    // Cek permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('⚠️ Location permission ditolak');
        return _cachedLocation; // Kembalikan cache jika ada
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('⚠️ Location permission ditolak permanen');
      return _cachedLocation; // Kembalikan cache jika ada
    }

    // Dapatkan posisi
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Dapatkan alamat dari koordinat
      final address = await getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (address == null) {
        print('❌ Gagal mendapatkan alamat dari koordinat');
        return _cachedLocation;
      }

      // Buat hasil lokasi
      final locationData = {
        'latitude': position.latitude,
        'longitude': position.longitude,
        ...address,
      };

      // Simpan ke cache
      await _saveLocationToCache(locationData);
      
      print('✅ [LocationService] Lokasi berhasil diperbarui: ${address['kelurahan']}');
      return locationData;
    } catch (e) {
      print('❌ Error getting position: $e');
      return _cachedLocation; // Kembalikan cache jika ada
    }
  }

  // ============ SIMPAN LOKASI KE CACHE ============
  static Future<void> _saveLocationToCache(Map<String, dynamic> location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Fixed: Changed 'locationData' to 'location'
      await prefs.setString(_cachedLocationKey, location.toString());
      await prefs.setString(_lastLocationUpdateKey, DateTime.now().toIso8601String());
      
      // Update cache di memory
      _cachedLocation = location;
      _lastUpdateTime = DateTime.now();
      
      print('💾 [LocationService] Lokasi disimpan ke cache');
    } catch (e) {
      print('❌ Error saving location to cache: $e');
    }
  }

  // ============ MUAT LOKASI DARI CACHE ============
  static Future<Map<String, dynamic>?> getLocationFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_cachedLocationKey);
      final lastUpdateString = prefs.getString(_lastLocationUpdateKey);
      
      if (cachedData == null || lastUpdateString == null) {
        return null;
      }
      
      final lastUpdate = DateTime.parse(lastUpdateString);
      
      // Cek apakah cache masih valid (kurang dari 1 jam)
      if (DateTime.now().difference(lastUpdate).inMinutes >= 60) {
        print('⏰ [LocationService] Cache lokasi sudah kedaluwarsa');
        return null;
      }
      
      // Parse data lokasi dari string
      // Format: {latitude: -6.123, longitude: 106.123, kelurahan: Antapani Kidul, ...}
      // Ini perlu disesuaikan dengan format penyimpanan Anda
      return _cachedLocation; // Kembalikan cache di memory
    } catch (e) {
      print('❌ Error loading location from cache: $e');
      return null;
    }
  }

  // ============ CONVERT KOORDINAT → ALAMAT ============
  static Future<Map<String, String>?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isEmpty) return null;

      final place = placemarks.first;

      return {
        'kelurahan': place.subLocality ?? 'Unknown',
        'kecamatan': place.locality ?? 'Unknown',
        'kota': place.administrativeArea ?? 'Unknown',
        'provinsi': place.country ?? 'Indonesia',
        'postal_code': place.postalCode ?? '',
        'full_address': 
            '${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}',
      };
    } catch (e) {
      print('❌ Error geocoding: $e');
      return null;
    }
  }

  // ============ GET CURRENT POSITION (RAW) ============
  static Future<Position?> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('⚠️ Location service tidak aktif');
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('⚠️ Location permission ditolak');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('⚠️ Location permission ditolak permanen');
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('❌ Error getting position: $e');
      return null;
    }
  }

  // ============ HITUNG JARAK (KM) ============
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000; // dalam km
  }

  // ============ CLEAR CACHE ============
  static Future<void> clearLocationCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cachedLocationKey);
      await prefs.remove(_lastLocationUpdateKey);
      _cachedLocation = null;
      _lastUpdateTime = null;
      print('🗑️ [LocationService] Cache lokasi dihapus');
    } catch (e) {
      print('❌ Error clearing location cache: $e');
    }
  }
}