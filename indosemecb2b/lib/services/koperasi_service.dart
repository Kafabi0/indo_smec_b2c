import '../models/koperasi_model.dart';
import '../models/product_model.dart';
import '../services/location_service.dart';
import '../services/product_service.dart';

class KoperasiService {
  // ============ DATA KOPERASI (DUMMY) ============
  static final List<Koperasi> _allKoperasi = [
    // KOTA BANDUNG
    Koperasi(
      id: 'kop1',
      name: 'Koperasi Merah Putih Antapani Kidul',
      kelurahan: 'Antapani Kidul',
      kecamatan: 'Antapani',
      kota: 'Kota Bandung',
      latitude: -6.912429,
      longitude: 107.654358,
      description: 'Koperasi yang melayani UMKM di wilayah Antapani Kidul',
      productIds: [
        '1', '2', '9', '10', '15', '20', '27', '33', '45', '100',
        '121', '122', '123', '124', '125',
        '126', '127', '128', '129', '130', // ⭐ Tambahkan jasa
        '134', '135', '136', '137', // Jasa Salon
      ],
    ),

    Koperasi(
      id: 'kop2',
      name: 'Koperasi Sejahtera Cicadas',
      kelurahan: 'Cicadas',
      kecamatan: 'Cibeunying Kidul',
      kota: 'Kota Bandung',
      latitude: -6.905789,
      longitude: 107.653267,
      description: 'Koperasi yang melayani UMKM di wilayah Cicadas',
      productIds: [
        '3',
        '4',
        '5',
        '11',
        '16',
        '21',
        '28',
        '34',
        '46',
        '101',
        '138',
        '139',
        '140', // Jasa Bengkel
        '141', '142', '143',
      ],
    ),

    Koperasi(
      id: 'kop3',
      name: 'Koperasi Mandiri Sukajadi',
      kelurahan: 'Sukajadi',
      kecamatan: 'Sukajadi',
      kota: 'Kota Bandung',
      latitude: -6.894321,
      longitude: 107.589876,
      description: 'Koperasi yang melayani UMKM di wilayah Sukajadi',
      productIds: [
        '6',
        '7',
        '8',
        '12',
        '17',
        '22',
        '29',
        '35',
        '47',
        '102',
        '144',
        '145',
        '146',
        '147', // Service Elektronik
        '148', '149', '150',
      ],
    ),

    // KABUPATEN BANDUNG
    Koperasi(
      id: 'kop4',
      name: 'Koperasi Tani Makmur Cileunyi',
      kelurahan: 'Cileunyi Wetan',
      kecamatan: 'Cileunyi',
      kota: 'Kabupaten Bandung',
      latitude: -6.939567,
      longitude: 107.753421,
      description: 'Koperasi pertanian di Cileunyi',
      productIds: ['13', '14', '18', '23', '30', '36', '48', '55', '103'],
    ),

    Koperasi(
      id: 'kop5',
      name: 'Koperasi Bersama Baleendah',
      kelurahan: 'Baleendah',
      kecamatan: 'Baleendah',
      kota: 'Kabupaten Bandung',
      latitude: -7.001234,
      longitude: 107.632456,
      description: 'Koperasi UMKM di Baleendah',
      productIds: ['19', '24', '25', '31', '37', '49', '56', '104'],
    ),

    // KOTA CIMAHI
    Koperasi(
      id: 'kop6',
      name: 'Koperasi Karya Bersama Cimahi',
      kelurahan: 'Baros',
      kecamatan: 'Cimahi Tengah',
      kota: 'Kota Cimahi',
      latitude: -6.887654,
      longitude: 107.542789,
      description: 'Koperasi UMKM Kota Cimahi',
      productIds: ['26', '32', '38', '50', '57', '105'],
    ),
  ];

  // ============ GET KOPERASI BY LOCATION ============
  static Future<List<Koperasi>> getKoperasiByLocation() async {
    final location = await LocationService.getUserLocation();

    if (location == null) {
      print(
        '⚠️ [KoperasiService] Lokasi tidak terdeteksi, tampilkan semua koperasi',
      );
      return _allKoperasi;
    }

    final kelurahan = location['kelurahan'] as String;
    final kecamatan = location['kecamatan'] as String;
    final kota = location['kota'] as String;

    print('📍 [KoperasiService] Lokasi user: $kelurahan, $kecamatan, $kota');

    // 1. Cari koperasi di kelurahan yang sama
    List<Koperasi> filtered =
        _allKoperasi.where((k) {
          final match = k.matchLocation(kelurahan: kelurahan);
          if (match) {
            print('✅ [KoperasiService] Match found: ${k.name} (kelurahan)');
          }
          return match;
        }).toList();

    if (filtered.isNotEmpty) {
      print(
        '✅ [KoperasiService] Ditemukan ${filtered.length} koperasi di $kelurahan',
      );
      return filtered;
    }

    // 2. Fallback ke kecamatan
    filtered =
        _allKoperasi.where((k) {
          final match = k.matchLocation(kecamatan: kecamatan);
          if (match) {
            print('✅ [KoperasiService] Match found: ${k.name} (kecamatan)');
          }
          return match;
        }).toList();

    if (filtered.isNotEmpty) {
      print(
        '✅ [KoperasiService] Ditemukan ${filtered.length} koperasi di $kecamatan',
      );
      return filtered;
    }

    // 3. Fallback ke kota
    filtered =
        _allKoperasi.where((k) {
          final match = k.matchLocation(kota: kota);
          if (match) {
            print('✅ [KoperasiService] Match found: ${k.name} (kota)');
          }
          return match;
        }).toList();

    if (filtered.isNotEmpty) {
      print(
        '✅ [KoperasiService] Ditemukan ${filtered.length} koperasi di $kota',
      );
      return filtered;
    }

    // 4. Jika tidak ada, tampilkan semua
    print(
      '⚠️ [KoperasiService] Tidak ada koperasi di lokasi ini, tampilkan semua',
    );
    return _allKoperasi;
  }

  // ============ GET PRODUK DARI KOPERASI TERDEKAT SAJA ============
  static Future<List<Product>> getProductsFromNearestKoperasi() async {
    final nearestKoperasi = await getNearestKoperasi();

    if (nearestKoperasi == null) {
      print('⚠️ Tidak ada koperasi terdekat, tampilkan semua produk');
      return ProductService().getAllProducts();
    }

    print('🎯 Mengambil produk dari: ${nearestKoperasi.name}');
    print('📦 Jumlah produk di koperasi: ${nearestKoperasi.productIds.length}');

    // Filter produk berdasarkan ID dari koperasi terdekat
    final allProducts = ProductService().getAllProducts();
    final filteredProducts =
        allProducts
            .where((p) => nearestKoperasi.productIds.contains(p.id))
            .toList();

    print('✅ Produk terfilter: ${filteredProducts.length}');

    return filteredProducts;
  }

  // ============ GET PRODUK BY CATEGORY DARI KOPERASI TERDEKAT ============
  static Future<List<Product>> getProductsByCategoryFromNearestKoperasi(
    String category,
  ) async {
    final productsFromNearest = await getProductsFromNearestKoperasi();

    if (category == 'Semua') {
      return productsFromNearest;
    }

    return productsFromNearest.where((p) => p.category == category).toList();
  }

  // ============ GET NEAREST KOPERASI ============
  static Future<Koperasi?> getNearestKoperasi() async {
    final location = await LocationService.getUserLocation();
    if (location == null) return null;

    final userLat = location['latitude'] as double;
    final userLon = location['longitude'] as double;

    Koperasi? nearest;
    double minDistance = double.infinity;

    for (var koperasi in _allKoperasi) {
      final distance = LocationService.calculateDistance(
        userLat,
        userLon,
        koperasi.latitude,
        koperasi.longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearest = koperasi;
      }
    }

    if (nearest != null) {
      print(
        '🎯 Koperasi terdekat: ${nearest.name} (${minDistance.toStringAsFixed(1)} km)',
      );
    }

    return nearest;
  }

  // ============ GET ALL KOPERASI ============
  static List<Koperasi> getAllKoperasi() {
    return _allKoperasi;
  }

  // ============ GET KOPERASI BY ID ============
  static Koperasi? getKoperasiById(String id) {
    try {
      return _allKoperasi.firstWhere((k) => k.id == id);
    } catch (e) {
      return null;
    }
  }

  // ⭐ TAMBAHKAN METHOD INI (YANG HILANG) ⭐
  // ============ GET PRODUK BY LOCATION ============
  static Future<List<Product>> getProductsByLocation() async {
    final koperasiList = await getKoperasiByLocation();

    if (koperasiList.isEmpty) {
      print('⚠️ Tidak ada koperasi, tampilkan semua produk');
      return ProductService().getAllProducts();
    }

    // Kumpulkan semua productIds dari koperasi-koperasi yang ditemukan
    final Set<String> allowedProductIds = {};
    for (var koperasi in koperasiList) {
      allowedProductIds.addAll(koperasi.productIds);
    }

    print('🛒 Total produk tersedia: ${allowedProductIds.length}');

    // Filter produk
    final allProducts = ProductService().getAllProducts();
    return allProducts.where((p) => allowedProductIds.contains(p.id)).toList();
  }

  // ⭐ TAMBAHKAN METHOD INI JUGA ⭐
  // ============ GET PRODUK BY CATEGORY & LOCATION ============
  static Future<List<Product>> getProductsByCategoryAndLocation(
    String category,
  ) async {
    final locationProducts = await getProductsByLocation();

    if (category == 'Semua') {
      return locationProducts;
    }

    return locationProducts.where((p) => p.category == category).toList();
  }
}
