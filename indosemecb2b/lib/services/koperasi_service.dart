import '../models/koperasi_model.dart';
import '../models/product_model.dart';
import '../services/location_service.dart';
import '../services/product_service.dart';

class KoperasiService {
  // ============ DATA KOPERASI (DUMMY) ============
  static final List<Koperasi> _allKoperasi = [
    // ========================================
    // KOTA BANDUNG - KOPERASI BESAR
    // ========================================
    
    // 🏪 KOPERASI 1: Antapani Kidul (LENGKAP!)
    Koperasi(
      id: 'kop1',
      name: 'Koperasi Merah Putih Antapani Kidul',
      kelurahan: 'Antapani Kidul',
      kecamatan: 'Antapani',
      kota: 'Kota Bandung',
      latitude: -6.912429,
      longitude: 107.654358,
      description: 'Koperasi besar yang melayani UMKM di wilayah Antapani Kidul',
      productIds: [
        // Produk Reguler (Food, Grocery, Fashion, Herbal)
        '1', '2', '9', '10', '15', '20', '27', '33', '34', '35', '36', '37', '38', '39', '40', '41', '42', '43', '44', '45',

        '71', '72',
        
        // ⭐ FLASH SALE - SEMUA PAKET (100-120)
        '100', '101', '102', '103', '104', '105', '106', '107', '108', '109', '110',
        '111', '112', '113', '114', '115', '116', '117', '118', '119', '120',
        
        // Produk Lokal Buah & Sayur (121-125)
        '121', '122', '123', '124', '125',
        
        // Produk Tambahan
        '46', '47', '48', '49', '50', '51', '52', '53', '54', '68', '69', '70', '73',
        
        // Jasa (126-137)
        '126', '127', '128', '129', '130',
        '134', '135', '136', '137',
      ],
    ),

    // 🏪 KOPERASI 2: Cicadas (MENENGAH)
    Koperasi(
      id: 'kop2',
      name: 'Koperasi Sejahtera Cicadas',
      kelurahan: 'Cicadas',
      kecamatan: 'Cibeunying Kidul',
      kota: 'Kota Bandung',
      latitude: -6.905789,
      longitude: 107.653267,
      description: 'Koperasi menengah fokus Fashion & Herbal',
      productIds: [
        // Produk Reguler
        '3', '4', '5', '11', '16', '21', '28', '34', '46',
        
        // ⭐ FLASH SALE - FOKUS: Fashion & Herbal (partial)
        '101', '107', '109',              // Flash Sale Pagi (3 produk)
        '105', '108', '110',              // Flash Sale Siang (3 produk)
        '111', '112', '113', '115', '119', // Flash Sale Sore (5 produk - FULL!)
        '100', '114', '120',              // Flash Sale Malam (3 produk)
        
        // Jasa Bengkel
        '138', '139', '140', '141', '142', '143',
      ],
    ),

    // 🏪 KOPERASI 3: Sukajadi (LENGKAP!)
    Koperasi(
      id: 'kop3',
      name: 'Koperasi Mandiri Sukajadi',
      kelurahan: 'Sukajadi',
      kecamatan: 'Sukajadi',
      kota: 'Kota Bandung',
      latitude: -6.894321,
      longitude: 107.589876,
      description: 'Koperasi besar dengan produk paling lengkap',
      productIds: [
        // Produk Reguler
        '6', '7', '8', '12', '17', '22', '29', '35', '47',
        
        // ⭐ FLASH SALE - SEMUA PAKET (100-120)
        '100', '101', '102', '103', '104', '105', '106', '107', '108', '109', '110',
        '111', '112', '113', '114', '115', '116', '117', '118', '119', '120',
        
        // Jasa Service Elektronik
        '144', '145', '146', '147', '148', '149', '150',
      ],
    ),

    // ========================================
    // KABUPATEN BANDUNG - KOPERASI MENENGAH
    // ========================================
    
    // 🏪 KOPERASI 4: Cileunyi (PERTANIAN)
    Koperasi(
      id: 'kop4',
      name: 'Koperasi Tani Makmur Cileunyi',
      kelurahan: 'Cileunyi Wetan',
      kecamatan: 'Cileunyi',
      kota: 'Kabupaten Bandung',
      latitude: -6.939567,
      longitude: 107.753421,
      description: 'Koperasi pertanian fokus Buah, Sayur, dan Herbal',
      productIds: [
        // Produk Reguler Pertanian
        '13', '14', '18', '23', '30', '36', '48', '55',
        
        // ⭐ FLASH SALE - FOKUS: Pertanian & Herbal
        '103',                    // Flash Sale Pagi (1 produk)
        '102', '106', '110',      // Flash Sale Siang (3 produk)
        '109', '111', '115',      // Flash Sale Sore (3 produk)
        '114',                    // Flash Sale Malam (1 produk)
      ],
    ),

    // 🏪 KOPERASI 5: Baleendah (KECIL)
    Koperasi(
      id: 'kop5',
      name: 'Koperasi Bersama Baleendah',
      kelurahan: 'Baleendah',
      kecamatan: 'Baleendah',
      kota: 'Kabupaten Bandung',
      latitude: -7.001234,
      longitude: 107.632456,
      description: 'Koperasi kecil fokus Kerajinan & Fashion',
      productIds: [
        // Produk Reguler
        '19', '24', '25', '31', '37', '49', '56',
        
        // ⭐ FLASH SALE - FOKUS: Fashion & Kerajinan (minimal)
        '104',        // Flash Sale Pagi (1 produk)
        '108',        // Flash Sale Siang (1 produk)
        '119',        // Flash Sale Sore (1 produk)
        '120',        // Flash Sale Malam (1 produk)
      ],
    ),

    // ========================================
    // KOTA CIMAHI - KOPERASI KECIL
    // ========================================
    
    // 🏪 KOPERASI 6: Cimahi (KECIL)
    Koperasi(
      id: 'kop6',
      name: 'Koperasi Karya Bersama Cimahi',
      kelurahan: 'Baros',
      kecamatan: 'Cimahi Tengah',
      kota: 'Kota Cimahi',
      latitude: -6.887654,
      longitude: 107.542789,
      description: 'Koperasi kecil fokus Kreatif & Jasa',
      productIds: [
        // Produk Reguler
        '26', '32', '38', '50', '57',
        
        // ⭐ FLASH SALE - FOKUS: Snack & Minuman (minimal)
        '105',        // Flash Sale Pagi (1 produk)
        '107', '108', // Flash Sale Siang (2 produk)
        '112',        // Flash Sale Sore (1 produk)
        '107',        // Flash Sale Malam (1 produk)
      ],
    ),
  ];

  // ============ GET KOPERASI BY LOCATION ============
  static Future<List<Koperasi>> getKoperasiByLocation() async {
    final location = await LocationService.getUserLocation();

    if (location == null) {
      print('⚠️ [KoperasiService] Lokasi tidak terdeteksi, tampilkan semua koperasi');
      return _allKoperasi;
    }

    final kelurahan = location['kelurahan'] as String;
    final kecamatan = location['kecamatan'] as String;
    final kota = location['kota'] as String;

    print('📍 [KoperasiService] Lokasi user: $kelurahan, $kecamatan, $kota');

    // 1. Cari koperasi di kelurahan yang sama
    List<Koperasi> filtered = _allKoperasi.where((k) {
      final match = k.matchLocation(kelurahan: kelurahan);
      if (match) {
        print('✅ [KoperasiService] Match found: ${k.name} (kelurahan)');
      }
      return match;
    }).toList();

    if (filtered.isNotEmpty) {
      print('✅ [KoperasiService] Ditemukan ${filtered.length} koperasi di $kelurahan');
      return filtered;
    }

    // 2. Fallback ke kecamatan
    filtered = _allKoperasi.where((k) {
      final match = k.matchLocation(kecamatan: kecamatan);
      if (match) {
        print('✅ [KoperasiService] Match found: ${k.name} (kecamatan)');
      }
      return match;
    }).toList();

    if (filtered.isNotEmpty) {
      print('✅ [KoperasiService] Ditemukan ${filtered.length} koperasi di $kecamatan');
      return filtered;
    }

    // 3. Fallback ke kota
    filtered = _allKoperasi.where((k) {
      final match = k.matchLocation(kota: kota);
      if (match) {
        print('✅ [KoperasiService] Match found: ${k.name} (kota)');
      }
      return match;
    }).toList();

    if (filtered.isNotEmpty) {
      print('✅ [KoperasiService] Ditemukan ${filtered.length} koperasi di $kota');
      return filtered;
    }

    // 4. Jika tidak ada, tampilkan semua
    print('⚠️ [KoperasiService] Tidak ada koperasi di lokasi ini, tampilkan semua');
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

    final allProducts = ProductService().getAllProducts();
    final filteredProducts = allProducts
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
      print('🎯 Koperasi terdekat: ${nearest.name} (${minDistance.toStringAsFixed(1)} km)');
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

  // ============ GET PRODUK BY LOCATION ============
  static Future<List<Product>> getProductsByLocation() async {
    final koperasiList = await getKoperasiByLocation();

    if (koperasiList.isEmpty) {
      print('⚠️ Tidak ada koperasi, tampilkan semua produk');
      return ProductService().getAllProducts();
    }

    final Set<String> allowedProductIds = {};
    for (var koperasi in koperasiList) {
      allowedProductIds.addAll(koperasi.productIds);
    }

    print('🛒 Total produk tersedia: ${allowedProductIds.length}');

    final allProducts = ProductService().getAllProducts();
    return allProducts.where((p) => allowedProductIds.contains(p.id)).toList();
  }

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