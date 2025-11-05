import 'package:flutter/material.dart';
import 'package:indosemecb2b/screen/detail_produk.dart';
import 'package:indosemecb2b/screen/notif.dart';
import 'package:indosemecb2b/screen/poinku.dart';
import 'package:indosemecb2b/screen/product_list_screen.dart';
import 'package:indosemecb2b/screen/search_screen.dart';
import 'package:indosemecb2b/utils/cart_manager.dart';
import 'package:indosemecb2b/utils/poin_cash_manager.dart';
import 'package:indosemecb2b/utils/user_data_manager.dart';
import 'package:indosemecb2b/utils/voucher_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';
import '../models/store_model.dart';
import '../models/subcategory_model.dart';
import '../services/product_service.dart';
import 'login.dart';
import '../services/favorite_service.dart';
import 'favorit.dart';
import 'package:indosemecb2b/screen/lengkapi_alamat_screen.dart';
import 'package:indosemecb2b/utils/transaction_manager.dart';
import 'package:indosemecb2b/models/transaction.dart';
import 'notification_provider.dart';
import 'dart:async';
import 'package:indosemecb2b/models/flash_sale_model.dart';
import 'package:indosemecb2b/services/flash_sale_service.dart';
import 'package:indosemecb2b/widgets/flash_sale_timer.dart';
import 'package:indosemecb2b/services/notifikasi.dart';
import '../services/location_service.dart';
import '../services/koperasi_service.dart';
import '../models/koperasi_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final ProductService _productService = ProductService();
  final FavoriteService _favoriteService = FavoriteService();

  bool isLoggedIn = false;
  String userEmail = '';

  String selectedCategory = 'Semua';
  bool showCategoryFilter = false;
  bool isXpressSelected = true;
  String? selectedSubCategory;

  // Data produk & stores
  List<Product> displayedProducts = [];
  List<Product> flashSaleProducts = [];
  List<Product> topRatedProducts = [];
  List<Product> freshProducts = [];
  List<Product> newestProducts = [];
  List<Product> fruitAndVeggies = [];
  List<Store> categoryStores = [];
  List<SubCategory> subCategories = [];
  Store? flagshipStore;
  Map<String, bool> favoriteStatus = {};
  Map<String, dynamic>? _savedAlamat;
  List<Map<String, dynamic>> _listAlamat = [];
  int _selectedAlamatIndex = 0;
  int _totalPoinUMKM = 0;
  int _totalPoinCash = 0;
  FlashSaleSchedule? currentFlashSale;
  FlashSaleSchedule? nextFlashSale;
  Timer? _flashSaleCheckTimer;
  bool _flashSaleNotifScheduled = false;
  Map<String, dynamic>? _userLocation;
  List<Koperasi> _nearbyKoperasi = [];
  bool _isLocationInitialized = false;

  // Flags untuk mencegah pemanggilan berulang
  bool _isLoadingLocation = true;
  bool _isLoadingData = false;
  bool _isLoadingPoin = false; // TAMBAHKAN FLAG INI
  Timer? _debounceTimer;

  final List<Map<String, dynamic>> categories = [
    {'name': 'Semua', 'icon': Icons.apps},
    {'name': 'Grocery', 'icon': Icons.shopping_bag},
    {'name': 'Food', 'icon': Icons.restaurant},
    {'name': 'Fashion', 'icon': Icons.checkroom},
    {'name': 'Kerajinan', 'icon': Icons.handyman},
    {'name': 'Pertanian', 'icon': Icons.agriculture},
    {'name': 'Kreatif', 'icon': Icons.palette},
    {'name': 'Herbal', 'icon': Icons.spa},
    {'name': 'Jasa', 'icon': Icons.build_circle},
  ];

  @override
  void initState() {
    super.initState();
    print('🚀 [HOME] ========== initState START ==========');
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      try {
        print('🔄 [HOME] Step 1: Check login...');
        await _checkLoginStatus();

        // ⭐ PERBAIKAN: Load alamat dulu, baru dapat lokasi dari alamat
        if (isLoggedIn && userEmail.isNotEmpty) {
          print('🔄 [HOME] Step 2: Load alamat user...');
          await _loadAlamatData();
        }

        print('🔄 [HOME] Step 3: Load poin...');
        await _loadPoinFromTransactions();

        print('🔄 [HOME] Step 4: Update flash sale...');
        _updateFlashSaleStatus();

        print('🔄 [HOME] Step 5: Schedule notifications...');
        _scheduleFlashSaleNotifications();

        print('🔄 [HOME] Step 6: Load data...');
        _loadData();

        print('🎉 [HOME] ========== initState COMPLETE ==========');
      } catch (e, stackTrace) {
        print('❌ [HOME] FATAL ERROR in initState: $e');
        print('📜 [HOME] Stack: $stackTrace');
      }
    });

    _flashSaleCheckTimer = Timer.periodic(Duration(seconds: 10), (_) {
      _updateFlashSaleStatus();

      if (mounted) {
        setState(() {
          // Trigger rebuild untuk update harga
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _flashSaleCheckTimer?.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      final prefs = await SharedPreferences.getInstance();
      final shouldRefresh = prefs.getBool('should_refresh_poin') ?? false;

      if (shouldRefresh) {
        print('🔄 [HOME] Refreshing poin after payment...');
        await _loadPoinFromTransactions();
        await prefs.setBool('should_refresh_poin', false);
        _refreshData();
      }
    }
  }

  Future<void> _scheduleFlashSaleNotifications() async {
    if (_flashSaleNotifScheduled) return;

    try {
      debugPrint('🔔 [HOME] Scheduling flash sale notifications...');

      final notifProvider = context.read<NotificationProvider>();
      await NotificationService().scheduleAllFlashSaleNotifications(
        notifProvider,
      );

      _flashSaleNotifScheduled = true;
      debugPrint('✅ [HOME] Flash sale notifications scheduled!');
    } catch (e) {
      debugPrint('❌ [HOME] Error: $e');
    }
  }

  // ⭐ TAMBAHKAN METHOD BARU INI
  // ⭐ GANTI SELURUH FUNGSI INI DI home.dart
  Future<void> _updateLocationFromAddress(Map<String, dynamic> alamat) async {
    print('📍 [HOME] ========== UPDATE LOCATION FROM ADDRESS ==========');
    print('📦 [HOME] Raw alamat data: $alamat');

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // ⭐ NORMALISASI YANG LEBIH KETAT
      String normalize(String text) {
        return text
            .toLowerCase()
            .trim()
            .replaceAll(RegExp(r'\s+'), ' ') // Multiple spaces → 1 space
            .replaceAll(RegExp(r'[^\w\s]'), '') // Remove special chars
            // ⭐ HAPUS SEMUA PREFIX YANG MUNGKIN
            .replaceAll(
              RegExp(
                r'^(kecamatan|kelurahan|kota|kabupaten|desa)\s+',
                caseSensitive: false,
              ),
              '',
            );
      }

      // ⭐ Get data dari alamat
      final kelurahan = normalize(
        (alamat['kelurahan'] ?? 'Unknown').toString(),
      );
      final kecamatan = normalize(
        (alamat['kecamatan'] ?? 'Unknown').toString(),
      );
      final kota = normalize((alamat['kota'] ?? 'Unknown').toString());

      print('\n🔍 [HOME] ========== NORMALIZED ALAMAT USER ==========');
      print('   Kelurahan: "$kelurahan"');
      print('   Kecamatan: "$kecamatan"');
      print('   Kota: "$kota"');

      final locationFromAddress = {
        'kelurahan': kelurahan,
        'kecamatan': kecamatan,
        'kota': kota,
        'provinsi': alamat['provinsi'] ?? 'Jawa Barat',
        'latitude': alamat['latitude'] ?? -6.905789,
        'longitude': alamat['longitude'] ?? 107.653267,
      };

      // ⭐ Cari koperasi berdasarkan alamat yang dipilih
      final koperasiList = KoperasiService.getAllKoperasi();
      print('\n📋 [HOME] Total koperasi available: ${koperasiList.length}');

      // ⭐ DEBUG: Print semua koperasi (NORMALIZED)
      print('\n🏪 [HOME] ========== DATA KOPERASI (NORMALIZED) ==========');
      for (var k in koperasiList) {
        final kKelurahan = normalize(k.kelurahan);
        final kKecamatan = normalize(k.kecamatan);
        final kKota = normalize(k.kota);

        print('   ${k.name}:');
        print('      Kelurahan: "$kKelurahan" (original: "${k.kelurahan}")');
        print('      Kecamatan: "$kKecamatan" (original: "${k.kecamatan}")');
        print('      Kota: "$kKota" (original: "${k.kota}")');
      }

      // ⭐ SMART MATCHING DENGAN PRIORITAS JELAS
      final matchedKoperasi =
          koperasiList.where((k) {
            final kKelurahan = normalize(k.kelurahan);
            final kKecamatan = normalize(k.kecamatan);
            final kKota = normalize(k.kota);

            print('\n🔍 [HOME] Checking ${k.name}:');
            print('   Kelurahan: "$kKelurahan" == "$kelurahan"');
            print('   Kecamatan: "$kKecamatan" == "$kecamatan"');
            print('   Kota: "$kKota" == "$kota"');

            // ⭐ PRIORITAS 1: EXACT MATCH KELURAHAN (PALING AKURAT!)
            if (kKelurahan == kelurahan && kKecamatan == kecamatan) {
              print('   ✅ Result: EXACT MATCH (Kelurahan + Kecamatan)');
              return true;
            }

            // ⭐ PRIORITAS 2: KELURAHAN SAMA (meski beda kecamatan, tapi masih relevan)
            if (kKelurahan == kelurahan) {
              print('   ⚠️ Result: PARTIAL MATCH (Kelurahan only)');
              return true;
            }

            // ⭐ PRIORITAS 3: KECAMATAN + KOTA SAMA
            if (kKecamatan == kecamatan && kKota == kota) {
              print('   ⚠️ Result: MATCH (Kecamatan + Kota, beda kelurahan)');
              return true;
            }

            print('   ❌ Result: NO MATCH');
            return false;
          }).toList();

      // ⭐ SORTING BERDASARKAN PRIORITAS (Kelurahan exact match di depan)
      matchedKoperasi.sort((a, b) {
        final aKelurahan = normalize(a.kelurahan);
        final bKelurahan = normalize(b.kelurahan);

        final aExact = (aKelurahan == kelurahan) ? 0 : 1;
        final bExact = (bKelurahan == kelurahan) ? 0 : 1;

        return aExact.compareTo(bExact);
      });

      if (!mounted) return;

      setState(() {
        _userLocation = locationFromAddress;
        _nearbyKoperasi = matchedKoperasi;
        _isLoadingLocation = false;
      });

      print('\n✅ [HOME] ========== MATCHING RESULT ==========');
      print('🏪 [HOME] Found ${_nearbyKoperasi.length} matching koperasi:');
      if (_nearbyKoperasi.isNotEmpty) {
        for (var i = 0; i < _nearbyKoperasi.length; i++) {
          final k = _nearbyKoperasi[i];
          print('   ${i + 1}. ${k.name}');
          print('      - Kelurahan: ${k.kelurahan}');
          print('      - Produk: ${k.productIds.length}');
        }
      } else {
        print('❌ [HOME] NO MATCHING KOPERASI FOUND!');
        print('   User alamat: $kelurahan, $kecamatan, $kota');
      }
      print('========================================================\n');

      // ⭐ Reload produk berdasarkan koperasi baru
      _loadData();
    } catch (e, stackTrace) {
      print('❌ [HOME] Error updating location from address: $e');
      print('📜 Stack: $stackTrace');

      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  void _updateFlashSaleStatus() {
    if (!mounted) return;

    final previousFlashSale = currentFlashSale;

    setState(() {
      currentFlashSale = FlashSaleService.getCurrentFlashSale();
      nextFlashSale = FlashSaleService.getNextFlashSale();
    });

    print('🔥 [FLASH SALE] Status update:');
    print('   Current: ${currentFlashSale?.title ?? "None"}');
    print('   Next: ${nextFlashSale?.title ?? "None"}');

    // ⭐ RELOAD DATA JIKA FLASH SALE BERUBAH
    if (previousFlashSale?.id != currentFlashSale?.id) {
      print('🔄 [FLASH SALE] Flash sale changed, reloading data...');
      _loadData();
    }
  }

  void _onFlashSaleTimerEnd() {
    print('⏰ Timer flash sale berakhir, reload data...');
    _updateFlashSaleStatus();
    _loadData(); // ⭐ Pastir ini dipanggil

    // ⭐ TAMBAHKAN: Force rebuild UI
    if (mounted) {
      setState(() {});
    }
  }

  String _getFlashSaleTimeRange() {
    FlashSaleSchedule? activeOrNext = currentFlashSale ?? nextFlashSale;

    if (activeOrNext == null) return '00.00 - 00.00';

    String startHour = activeOrNext.startTime.hour.toString().padLeft(2, '0');
    String startMinute = activeOrNext.startTime.minute.toString().padLeft(
      2,
      '0',
    );
    String endHour = activeOrNext.endTime.hour.toString().padLeft(2, '0');
    String endMinute = activeOrNext.endTime.minute.toString().padLeft(2, '0');

    return '$startHour.$startMinute - $endHour.$endMinute';
  }

  Future<void> _loadAlamat() async {
    if (isLoggedIn && userEmail.isNotEmpty) {
      final alamatList = await UserDataManager.getAlamatList(userEmail);
      setState(() {
        _savedAlamat = alamatList.isNotEmpty ? alamatList[0] : null;
      });
    }
  }

  Future<void> _checkLoginStatus() async {
    print('🔐 [HOME] Checking login status...');

    final prefs = await SharedPreferences.getInstance();
    final currentUser = await UserDataManager.getCurrentUserLogin();

    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      userEmail = currentUser ?? '';
    });

    print('🔐 [HOME] Login status check:');
    print('   isLoggedIn: $isLoggedIn');
    print('   userEmail: $userEmail');

    if (isLoggedIn && userEmail.isNotEmpty) {
      print('✅ [HOME] User is logged in, loading data...');
      _loadFavoriteStatus();
      await _loadAlamatData();
      await _loadPoinFromTransactions();
    } else {
      print('❌ [HOME] User is not logged in');
      setState(() {
        favoriteStatus = {};
        _savedAlamat = null;
        _totalPoinUMKM = 0;
        _totalPoinCash = 0;
      });
    }
  }

  Future<void> _loadUserLocation() async {
    print('📍 [HOME] _loadUserLocation() - SKIPPED (using selected address)');
    // Method ini tidak digunakan lagi karena kita pakai alamat pilihan user
  }

  Future<void> _loadAlamatData() async {
    print('🔍 [HOME] _loadAlamatData() dipanggil');
    print('📧 [HOME] userEmail: $userEmail');

    if (userEmail.isNotEmpty) {
      print('⏳ [HOME] Mengambil alamat dari UserDataManager...');

      // ⭐ Ambil alamat yang sedang dipilih
      final alamatList = await UserDataManager.getAlamatList(userEmail);
      final selectedIndex = await UserDataManager.getSelectedAlamatIndex(
        userEmail,
      );

      print('📦 [HOME] Alamat list length: ${alamatList.length}');
      print('🎯 [HOME] Selected index: $selectedIndex');

      if (alamatList.isNotEmpty) {
        final validIndex =
            selectedIndex < alamatList.length ? selectedIndex : 0;
        print('✅ [HOME] Alamat terpilih: ${alamatList[validIndex]['label']}');

        if (mounted) {
          setState(() {
            _listAlamat = alamatList;
            _selectedAlamatIndex = validIndex;
            _savedAlamat = alamatList[validIndex];
          });

          // ⭐ UPDATE LOKASI DARI ALAMAT YANG DIPILIH
          await _updateLocationFromAddress(_savedAlamat!);
        }
      } else {
        print('❌ [HOME] Tidak ada alamat tersimpan');
        if (mounted) {
          setState(() {
            _listAlamat = [];
            _selectedAlamatIndex = 0;
            _savedAlamat = null;
            _userLocation = null;
            _nearbyKoperasi = [];
          });
        }
      }
    } else {
      print('⚠️ [HOME] userEmail kosong, tidak bisa load alamat');
    }
  }

  void _loadData() async {
    if (_isLoadingData) {
      print('⚠️ [HOME] Data already loading, skipping...');
      return;
    }

    setState(() {
      _isLoadingData = true;
    });

    try {
      print('🔄 [HOME] ========== _loadData START ==========');
      print('📍 [HOME] Nearby koperasi count: ${_nearbyKoperasi.length}');
      print('🏷️ [HOME] Selected category: $selectedCategory');

      // ⭐ FILTER PRODUK BERDASARKAN KOPERASI DAN KATEGORI
      if (_nearbyKoperasi.isNotEmpty) {
        // Kumpulkan semua productIds dari koperasi yang match
        final Set<String> allowedProductIds = {};
        for (var koperasi in _nearbyKoperasi) {
          allowedProductIds.addAll(koperasi.productIds);
        }

        print('📦 [HOME] Total allowed products: ${allowedProductIds.length}');

        // Load semua produk
        final allProducts = _productService.getAllProducts();

        // ⭐⭐⭐ FILTER BERDASARKAN KATEGORI DAN KOPERASI ⭐⭐⭐
        if (selectedCategory == 'Semua') {
          // Tampilkan semua produk dari koperasi
          displayedProducts =
              allProducts
                  .where((p) => allowedProductIds.contains(p.id))
                  .toList();
        } else {
          // ⭐ FILTER BERDASARKAN KATEGORI DAN KOPERASI
          displayedProducts =
              allProducts
                  .where(
                    (p) =>
                        allowedProductIds.contains(p.id) &&
                        p.category == selectedCategory,
                  )
                  .toList();
        }

        print(
          '📦 [HOME] displayedProducts (after category filter): ${displayedProducts.length}',
        );

        // Flash Sale Products (filter by koperasi)
        print('\n🏠 [HOME] ========== LOADING FLASH SALE ==========');
        flashSaleProducts = _productService.getFlashSaleProductsByKoperasi(
          allowedProductIds.toList(),
        );
        print(
          '✅ [HOME] Flash sale products loaded: ${flashSaleProducts.length}',
        );

        // ⭐ Top Rated Products (filter berdasarkan koperasi DAN kategori)
        final filteredProducts =
            allProducts.where((p) => allowedProductIds.contains(p.id)).toList();

        if (selectedCategory == 'Semua') {
          topRatedProducts = List<Product>.from(filteredProducts)
            ..sort((a, b) => b.rating.compareTo(a.rating));
          topRatedProducts = topRatedProducts.take(8).toList();
        } else {
          // Filter by category juga untuk top rated
          topRatedProducts =
              filteredProducts
                  .where((p) => p.category == selectedCategory)
                  .toList()
                ..sort((a, b) => b.rating.compareTo(a.rating));
          topRatedProducts = topRatedProducts.take(8).toList();
        }

        // ⭐ Fresh Products (filter berdasarkan koperasi DAN kategori)
        print('\n🍹 [HOME] Calling getFreshProducts...');
        final allFreshProducts = _productService.getFreshProducts().where(
          (p) => allowedProductIds.contains(p.id),
        );

        if (selectedCategory == 'Semua') {
          freshProducts = allFreshProducts.take(8).toList();
        } else {
          freshProducts =
              allFreshProducts
                  .where((p) => p.category == selectedCategory)
                  .take(8)
                  .toList();
        }
        print('📦 [HOME] freshProducts after filter: ${freshProducts.length}');

        // ⭐ Newest Products (filter berdasarkan koperasi DAN kategori)
        if (selectedCategory == 'Semua') {
          newestProducts = filteredProducts.take(8).toList();
        } else {
          newestProducts =
              filteredProducts
                  .where((p) => p.category == selectedCategory)
                  .take(8)
                  .toList();
        }

        // ⭐ Buah & Sayur (filter berdasarkan koperasi DAN kategori)
        print('\n🍎 [HOME] Calling getFruitAndVeggies...');
        final allFruitVeggies = _productService.getFruitAndVeggies().where(
          (p) => allowedProductIds.contains(p.id),
        );

        if (selectedCategory == 'Semua' ||
            selectedCategory == 'Grocery' ||
            selectedCategory == 'Food') {
          fruitAndVeggies =
              allFruitVeggies.toList()
                ..sort((a, b) => b.rating.compareTo(a.rating));
        } else {
          // Jika kategori bukan Grocery/Food, kosongkan fruit & veggies
          fruitAndVeggies = [];
        }

        print('📦 [HOME] fruitAndVeggies: ${fruitAndVeggies.length}');
      } else {
        // ⭐ JIKA TIDAK ADA KOPERASI MATCH, FILTER HANYA BERDASARKAN KATEGORI
        print(
          '⚠️ [HOME] No matching koperasi, showing all products by category',
        );

        displayedProducts =
            selectedCategory == 'Semua'
                ? _productService.getAllProducts()
                : _productService.getProductsByCategory(selectedCategory);

        flashSaleProducts = _productService.getActiveFlashSaleProducts();

        final allProducts = _productService.getAllProducts();

        if (selectedCategory == 'Semua') {
          topRatedProducts = List<Product>.from(allProducts)
            ..sort((a, b) => b.rating.compareTo(a.rating));
          topRatedProducts = topRatedProducts.take(8).toList();

          freshProducts = _productService.getFreshProducts().take(8).toList();
          newestProducts = allProducts.take(8).toList();
          fruitAndVeggies =
              _productService.getFruitAndVeggies().take(8).toList();
        } else {
          // Filter by category
          final categoryProducts =
              allProducts.where((p) => p.category == selectedCategory).toList();

          topRatedProducts = List<Product>.from(categoryProducts)
            ..sort((a, b) => b.rating.compareTo(a.rating));
          topRatedProducts = topRatedProducts.take(8).toList();

          freshProducts =
              _productService
                  .getFreshProducts()
                  .where((p) => p.category == selectedCategory)
                  .take(8)
                  .toList();

          newestProducts = categoryProducts.take(8).toList();

          // Buah & Sayur hanya untuk Grocery/Food
          if (selectedCategory == 'Grocery' || selectedCategory == 'Food') {
            fruitAndVeggies =
                _productService.getFruitAndVeggies().take(8).toList();
          } else {
            fruitAndVeggies = [];
          }
        }
      }

      // Load stores dan subcategories (tetap berdasarkan kategori)
      categoryStores = _productService.getStoresByCategory(selectedCategory);
      subCategories = _productService.getSubCategories(selectedCategory);
      flagshipStore = _productService.getFlagshipStore(selectedCategory);

      print('✅ [HOME] Data loaded successfully');
      print('📊 [HOME] Final counts:');
      print('   - displayedProducts: ${displayedProducts.length}');
      print('   - flashSaleProducts: ${flashSaleProducts.length}');
      print('   - topRatedProducts: ${topRatedProducts.length}');
      print('   - freshProducts: ${freshProducts.length}');
      print('   - newestProducts: ${newestProducts.length}');
      print('   - fruitAndVeggies: ${fruitAndVeggies.length}');
      print('🔄 [HOME] ========== _loadData END ==========\n');

      if (mounted) {
        setState(() {});
      }
    } catch (e, stackTrace) {
      print('❌ [HOME] Error loading data: $e');
      print('📜 [HOME] Stack trace: $stackTrace');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
      }
    }
  }

  // Future<void> _loadAlamatData() async {
  //   print('🔍 [HOME] _loadAlamatData() dipanggil');
  //   print('📧 [HOME] userEmail: $userEmail');
  //   print('🔐 [HOME] isLoggedIn: $isLoggedIn');

  //   if (userEmail.isNotEmpty) {
  //     print('⏳ [HOME] Mengambil alamat dari UserDataManager...');
  //     final alamatList = await UserDataManager.getAlamatList(userEmail);
  //     final selectedIndex = await UserDataManager.getSelectedAlamatIndex(
  //       userEmail,
  //     );

  //     print('📦 [HOME] Alamat list length: ${alamatList.length}');
  //     print('🎯 [HOME] Selected index: $selectedIndex');

  //     if (alamatList.isNotEmpty) {
  //       final validIndex =
  //           selectedIndex < alamatList.length ? selectedIndex : 0;
  //       print('✅ [HOME] Alamat terpilih: ${alamatList[validIndex]['label']}');

  //       if (mounted) {
  //         setState(() {
  //           _listAlamat = alamatList;
  //           _selectedAlamatIndex = validIndex;
  //           _savedAlamat = alamatList[validIndex];
  //         });
  //         print(
  //           '🔄 [HOME] setState() selesai, _savedAlamat: ${_savedAlamat!['label']}',
  //         );

  //         // ⭐ TAMBAHKAN: Update lokasi dari alamat yang tersimpan
  //         await _updateLocationFromAddress(_savedAlamat!);
  //       }
  //     } else {
  //       print('❌ [HOME] Tidak ada alamat tersimpan');
  //       if (mounted) {
  //         setState(() {
  //           _listAlamat = [];
  //           _selectedAlamatIndex = 0;
  //           _savedAlamat = null;
  //         });
  //       }
  //     }
  //   } else {
  //     print('⚠️ [HOME] userEmail kosong, tidak bisa load alamat');
  //   }
  // }

  Future<void> _loadPoinFromTransactions() async {
    print('🔍 [HOME] _loadPoinFromTransactions dipanggil');

    if (!isLoggedIn || userEmail.isEmpty) {
      if (mounted) {
        setState(() {
          _totalPoinUMKM = 0;
          _totalPoinCash = 0;
        });
      }
      return;
    }

    // Tambahkan pengecekan flag untuk mencegah pemanggilan berulang
    if (_isLoadingPoin) {
      print('⚠️ [HOME] Poin already loading, skipping...');
      return;
    }

    setState(() {
      _isLoadingPoin = true;
    });

    try {
      final transactions = await TransactionManager.getFilteredTransactions(
        status: 'Selesai',
        dateFilter: 'Semua Tanggal',
        category: 'Semua',
      );

      int stampCount = 0;

      for (var transaction in transactions) {
        if (transaction.deliveryOption == 'poin_cash_usage' ||
            transaction.deliveryOption == 'topup') {
          continue;
        }
        stampCount++;
      }

      final prefs = await SharedPreferences.getInstance();
      final isFirstTime = prefs.getBool('poin_welcome_given') ?? false;
      if (!isFirstTime) {
        await prefs.setBool('poin_welcome_given', true);
      }
      final poinUMKM = await VoucherManager.getUserPoinUMKM();
      final poinCashValue = await PoinCashManager.getTotalPoinCash();

      if (mounted) {
        setState(() {
          _totalPoinUMKM = poinUMKM.toInt();
          _totalPoinCash = poinCashValue.toInt();
        });
      }
    } catch (e) {
      print('❌ Error loading poin: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPoin = false;
        });
      }
    }
  }

  String _formatPoinNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  Future<void> _loadFavoriteStatus() async {
    final favoriteIds = await _favoriteService.getAllFavoriteIds();
    setState(() {
      for (var product in _productService.getAllProducts()) {
        favoriteStatus[product.id] = favoriteIds.contains(product.id);
      }
    });
  }

  Future<void> _toggleFavorite(String productId, String productName) async {
    if (!isLoggedIn) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Anda harus login terlebih dahulu untuk menyimpan favorit.',
            ),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red[700],
          ),
        );
      }
      return;
    }

    final isFavorite = await _favoriteService.toggleFavorite(productId);

    setState(() {
      favoriteStatus[productId] = isFavorite;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorite
                ? '$productName ditambahkan ke favorit'
                : '$productName dihapus dari favorit',
          ),
          duration: Duration(seconds: 1),
          backgroundColor: isFavorite ? Colors.green[600] : Colors.orange[700],
        ),
      );
    }
  }

  Future<void> refreshLoginStatus() async {
    print('🔄 [HOME] refreshLoginStatus() dipanggil');
    await _checkLoginStatus();
    _refreshData(); // Gunakan _refreshData() instead of _loadData()
  }

  // void _loadData() async {
  //   if (_isLoadingData) {
  //     print('⚠️ [HOME] Data already loading, skipping...');
  //     return;
  //   }

  //   setState(() {
  //     _isLoadingData = true;
  //   });

  //   try {
  //     print('🔄 [HOME] Loading data...');

  //     // ⭐ PERBAIKAN: Gunakan produk dari koperasi yang cocok dengan alamat
  //     if (_nearbyKoperasi.isNotEmpty) {
  //       // Ambil semua produk dari koperasi yang match
  //       final Set<String> allowedProductIds = {};
  //       for (var koperasi in _nearbyKoperasi) {
  //         allowedProductIds.addAll(koperasi.productIds);
  //       }

  //       final allProducts = _productService.getAllProducts();

  //       if (selectedCategory == 'Semua') {
  //         displayedProducts =
  //             allProducts
  //                 .where((p) => allowedProductIds.contains(p.id))
  //                 .toList();
  //       } else {
  //         displayedProducts =
  //             allProducts
  //                 .where(
  //                   (p) =>
  //                       allowedProductIds.contains(p.id) &&
  //                       p.category == selectedCategory,
  //                 )
  //                 .toList();
  //       }

  //       print(
  //         '📦 [HOME] Filtered ${displayedProducts.length} products from koperasi',
  //       );
  //     } else {
  //       // Jika tidak ada koperasi match, tampilkan semua
  //       print('⚠️ [HOME] No matching koperasi, showing all products');
  //       displayedProducts =
  //           selectedCategory == 'Semua'
  //               ? _productService.getAllProducts()
  //               : _productService.getProductsByCategory(selectedCategory);
  //     }

  //     flashSaleProducts = _productService.getActiveFlashSaleProducts();

  //     // Filter produk lain berdasarkan koperasi
  //     if (_nearbyKoperasi.isNotEmpty) {
  //       final allowedIds = <String>{};
  //       for (var k in _nearbyKoperasi) {
  //         allowedIds.addAll(k.productIds);
  //       }

  //       final allProducts = _productService.getAllProducts();
  //       final filteredProducts =
  //           allProducts.where((p) => allowedIds.contains(p.id)).toList();

  //       topRatedProducts = List<Product>.from(filteredProducts)
  //         ..sort((a, b) => b.rating.compareTo(a.rating));
  //       topRatedProducts = topRatedProducts.take(8).toList();

  //       freshProducts =
  //           _productService
  //               .getFreshProducts()
  //               .where((p) => allowedIds.contains(p.id))
  //               .take(8)
  //               .toList();

  //       newestProducts = filteredProducts.take(8).toList();

  //       fruitAndVeggies =
  //           _productService
  //               .getFruitAndVeggies()
  //               .where((p) => allowedIds.contains(p.id))
  //               .take(8)
  //               .toList();
  //     } else {
  //       // Fallback ke semua produk
  //       topRatedProducts = List<Product>.from(_productService.getAllProducts())
  //         ..sort((a, b) => b.rating.compareTo(a.rating));
  //       topRatedProducts = topRatedProducts.take(8).toList();

  //       freshProducts = _productService.getFreshProducts().take(8).toList();
  //       newestProducts = _productService.getAllProducts().take(8).toList();
  //       fruitAndVeggies = _productService.getFruitAndVeggies().take(8).toList();
  //     }

  //     categoryStores = _productService.getStoresByCategory(selectedCategory);
  //     subCategories = _productService.getSubCategories(selectedCategory);
  //     flagshipStore = _productService.getFlagshipStore(selectedCategory);

  //     print('✅ [HOME] Data loaded successfully');

  //     if (mounted) {
  //       setState(() {});
  //     }
  //   } catch (e) {
  //     print('❌ Error loading data: $e');
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         _isLoadingData = false;
  //       });
  //     }
  //   }
  // }

  void _refreshData() {
    if (_isLoadingData) {
      print('⚠️ [HOME] Data already loading, skipping refresh...');
      return;
    }

    // Hapus timer sebelumnya jika ada (debounce)
    _debounceTimer?.cancel();

    // Set timer baru untuk mencegah pemanggilan terlalu cepat
    _debounceTimer = Timer(Duration(milliseconds: 300), () {
      if (mounted && !_isLoadingData) {
        print('🔄 [HOME] Refreshing data...');
        _loadData();
      }
    });
  }

  void _onCategorySelected(String category) {
    // Cegah pemanggilan untuk kategori yang sama
    if (selectedCategory == category) return;

    setState(() {
      selectedCategory = category;
      selectedSubCategory = null;
      showCategoryFilter = false;
    });

    _refreshData(); // Ini akan memanggil _loadData() yang sudah diperbaiki
  }

  void _onSubCategorySelected(String subCategory) {
    // Cegah pemanggilan untuk subkategori yang sama
    if (selectedSubCategory == subCategory) return;

    setState(() {
      selectedSubCategory = subCategory;

      // ⭐ AMBIL SEMUA PRODUK DARI KOPERASI TERDEKAT
      final Set<String> allowedProductIds = {};
      if (_nearbyKoperasi.isNotEmpty) {
        for (var koperasi in _nearbyKoperasi) {
          allowedProductIds.addAll(koperasi.productIds);
        }
        print('🏪 [SUBCAT] Filtering from ${_nearbyKoperasi.length} koperasi');
        print('📦 [SUBCAT] Allowed products: ${allowedProductIds.length}');
      }

      // ⭐⭐⭐ FILTER SUBKATEGORI DENGAN KOPERASI ⭐⭐⭐
      List<Product> allProducts = _productService.getAllProducts();

      // Jika ada koperasi, filter dulu berdasarkan koperasi
      if (allowedProductIds.isNotEmpty) {
        allProducts =
            allProducts.where((p) => allowedProductIds.contains(p.id)).toList();
        print('📦 [SUBCAT] After koperasi filter: ${allProducts.length}');
      }

      // Filter berdasarkan subkategori
      if (subCategory == 'Buah') {
        displayedProducts =
            _productService
                .getFruitProducts()
                .where(
                  (p) =>
                      allowedProductIds.isEmpty ||
                      allowedProductIds.contains(p.id),
                )
                .toList();
      } else if (subCategory == 'Sayuran Organik') {
        displayedProducts =
            _productService
                .getVegetableProducts()
                .where(
                  (p) =>
                      allowedProductIds.isEmpty ||
                      allowedProductIds.contains(p.id),
                )
                .toList();
      } else if (subCategory == 'Nasi Box') {
        displayedProducts =
            allProducts
                .where((p) => p.name.toLowerCase().contains('nasi'))
                .toList();
      } else if (subCategory == 'Snack & Jajanan') {
        displayedProducts =
            allProducts
                .where(
                  (p) =>
                      p.name.toLowerCase().contains('snack') ||
                      p.name.toLowerCase().contains('jajan') ||
                      p.name.toLowerCase().contains('keripik') ||
                      p.name.toLowerCase().contains('biskuit'),
                )
                .toList();
      } else if (subCategory == 'Minuman') {
        displayedProducts =
            allProducts
                .where(
                  (p) =>
                      p.name.toLowerCase().contains('minuman') ||
                      p.name.toLowerCase().contains('es ') ||
                      p.name.toLowerCase().contains('jus') ||
                      p.name.toLowerCase().contains('teh') ||
                      p.name.toLowerCase().contains('susu'),
                )
                .toList();
      } else if (subCategory == 'Lauk Pauk') {
        displayedProducts =
            allProducts
                .where(
                  (p) =>
                      p.name.toLowerCase().contains('ayam') ||
                      p.name.toLowerCase().contains('ikan') ||
                      p.name.toLowerCase().contains('rendang') ||
                      p.name.toLowerCase().contains('sate'),
                )
                .toList();
      } else if (subCategory == 'Dessert') {
        displayedProducts =
            allProducts
                .where(
                  (p) =>
                      p.name.toLowerCase().contains('dessert') ||
                      p.name.toLowerCase().contains('kue') ||
                      p.name.toLowerCase().contains('jelly') ||
                      p.name.toLowerCase().contains('mochi'),
                )
                .toList();
      } else if (subCategory == 'Beras & Tepung') {
        displayedProducts =
            allProducts
                .where(
                  (p) =>
                      p.name.toLowerCase().contains('beras') ||
                      p.name.toLowerCase().contains('tepung'),
                )
                .toList();
      } else if (subCategory == 'Bumbu Dapur') {
        displayedProducts =
            allProducts
                .where(
                  (p) =>
                      p.name.toLowerCase().contains('bumbu') ||
                      p.name.toLowerCase().contains('bawang') ||
                      p.name.toLowerCase().contains('cabai') ||
                      p.name.toLowerCase().contains('garam'),
                )
                .toList();
      } else if (subCategory == 'Minyak Goreng') {
        displayedProducts =
            allProducts
                .where((p) => p.name.toLowerCase().contains('minyak'))
                .toList();
      } else if (subCategory == 'Telur & Susu') {
        displayedProducts =
            allProducts
                .where(
                  (p) =>
                      p.name.toLowerCase().contains('telur') ||
                      p.name.toLowerCase().contains('susu'),
                )
                .toList();
      } else if (subCategory == 'Mie Instan') {
        displayedProducts =
            allProducts
                .where((p) => p.name.toLowerCase().contains('mie'))
                .toList();
      } else if (subCategory == 'Batik') {
        displayedProducts =
            allProducts
                .where((p) => p.name.toLowerCase().contains('batik'))
                .toList();
      } else if (subCategory == 'Hijab') {
        displayedProducts =
            allProducts
                .where((p) => p.name.toLowerCase().contains('hijab'))
                .toList();
      } else if (subCategory == 'Kaos & Kemeja') {
        displayedProducts =
            allProducts
                .where(
                  (p) =>
                      p.name.toLowerCase().contains('kaos') ||
                      p.name.toLowerCase().contains('kemeja'),
                )
                .toList();
      } else if (subCategory == 'Celana') {
        displayedProducts =
            allProducts
                .where((p) => p.name.toLowerCase().contains('celana'))
                .toList();
      } else if (subCategory == 'Dress') {
        displayedProducts =
            allProducts
                .where((p) => p.name.toLowerCase().contains('dress'))
                .toList();
      } else if (subCategory == 'Jamu Tradisional') {
        displayedProducts =
            allProducts
                .where((p) => p.name.toLowerCase().contains('jamu'))
                .toList();
      } else if (subCategory == 'Madu') {
        displayedProducts =
            allProducts
                .where((p) => p.name.toLowerCase().contains('madu'))
                .toList();
      } else if (subCategory == 'Minuman Herbal') {
        displayedProducts =
            allProducts
                .where(
                  (p) =>
                      p.name.toLowerCase().contains('herbal') ||
                      p.name.toLowerCase().contains('temulawak') ||
                      p.name.toLowerCase().contains('jahe') ||
                      p.name.toLowerCase().contains('wedang') ||
                      p.name.toLowerCase().contains('bandrek'),
                )
                .toList();
      } else if (subCategory == 'Rempah') {
        displayedProducts =
            allProducts
                .where((p) => p.name.toLowerCase().contains('rempah'))
                .toList();
      } else if (subCategory == 'Anyaman') {
        displayedProducts =
            allProducts
                .where(
                  (p) =>
                      p.name.toLowerCase().contains('anyaman') ||
                      p.name.toLowerCase().contains('rotan'),
                )
                .toList();
      } else if (subCategory == 'Ukiran Kayu') {
        displayedProducts =
            allProducts
                .where(
                  (p) =>
                      p.name.toLowerCase().contains('ukir') ||
                      p.name.toLowerCase().contains('kayu'),
                )
                .toList();
      } else if (subCategory == 'Souvenir') {
        displayedProducts =
            allProducts
                .where(
                  (p) =>
                      p.name.toLowerCase().contains('souvenir') ||
                      p.name.toLowerCase().contains('gantungan kunci'),
                )
                .toList();
      } else if (subCategory == 'Pupuk') {
        displayedProducts =
            allProducts
                .where((p) => p.name.toLowerCase().contains('pupuk'))
                .toList();
      } else if (subCategory == 'Bibit Tanaman') {
        displayedProducts =
            allProducts
                .where((p) => p.name.toLowerCase().contains('bibit'))
                .toList();
      } else if (subCategory == 'Alat Tani') {
        displayedProducts =
            allProducts
                .where((p) => p.name.toLowerCase().contains('alat'))
                .toList();
      } else if (subCategory == 'Alat Lukis') {
        displayedProducts =
            allProducts
                .where((p) => p.name.toLowerCase().contains('lukis'))
                .toList();
      } else if (subCategory == 'Buku Sketsa') {
        displayedProducts =
            allProducts
                .where((p) => p.name.toLowerCase().contains('sketsa'))
                .toList();
      } else if (subCategory == 'Jahit & Bordir') {
        displayedProducts =
            allProducts
                .where(
                  (p) =>
                      p.name.toLowerCase().contains('jahit') ||
                      p.name.toLowerCase().contains('bordir') ||
                      p.name.toLowerCase().contains('obras'),
                )
                .toList();
      } else if (subCategory == 'Laundry') {
        displayedProducts =
            allProducts
                .where(
                  (p) =>
                      p.name.toLowerCase().contains('laundry') ||
                      p.name.toLowerCase().contains('cuci') ||
                      p.name.toLowerCase().contains('dry cleaning'),
                )
                .toList();
      } else if (subCategory == 'Salon & Spa') {
        displayedProducts =
            allProducts
                .where(
                  (p) =>
                      p.name.toLowerCase().contains('salon') ||
                      p.name.toLowerCase().contains('potong rambut') ||
                      p.name.toLowerCase().contains('creambath') ||
                      p.name.toLowerCase().contains('facial'),
                )
                .toList();
      } else if (subCategory == 'Bengkel') {
        displayedProducts =
            allProducts
                .where(
                  (p) =>
                      p.name.toLowerCase().contains('service motor') ||
                      p.name.toLowerCase().contains('ganti ban') ||
                      p.name.toLowerCase().contains('tambal ban'),
                )
                .toList();
      } else if (subCategory == 'Tukang') {
        displayedProducts =
            allProducts
                .where(
                  (p) =>
                      p.name.toLowerCase().contains('pembuatan') ||
                      p.name.toLowerCase().contains('reparasi') ||
                      p.name.toLowerCase().contains('furniture'),
                )
                .toList();
      } else if (subCategory == 'Service Elektronik') {
        displayedProducts =
            allProducts
                .where(
                  (p) =>
                      p.name.toLowerCase().contains('service') ||
                      p.name.toLowerCase().contains('cuci ac') ||
                      p.name.toLowerCase().contains('tv') ||
                      p.name.toLowerCase().contains('kulkas'),
                )
                .toList();
      } else if (subCategory == 'Cleaning Service') {
        displayedProducts =
            allProducts
                .where(
                  (p) =>
                      p.name.toLowerCase().contains('cleaning') ||
                      p.name.toLowerCase().contains('cuci sofa') ||
                      p.name.toLowerCase().contains('cuci karpet'),
                )
                .toList();
      } else if (subCategory == 'Catering') {
        displayedProducts =
            allProducts
                .where((p) => p.name.toLowerCase().contains('catering'))
                .toList();
      } else if (subCategory == 'Clay & Polymer') {
        displayedProducts =
            allProducts
                .where((p) => p.name.toLowerCase().contains('clay'))
                .toList();
      } else {
        displayedProducts =
            _productService
                .getProductsBySubCategory(subCategory)
                .where(
                  (p) =>
                      allowedProductIds.isEmpty ||
                      allowedProductIds.contains(p.id),
                )
                .toList();
      }

      // Jika tidak ada produk setelah filter, fallback ke kategori utama (dengan filter koperasi)
      if (displayedProducts.isEmpty) {
        displayedProducts =
            allProducts.where((p) => p.category == selectedCategory).toList();

        print(
          '⚠️ [SUBCAT] No products found, fallback to category: ${displayedProducts.length}',
        );
      }

      print(
        '✅ [SUBCAT] Final products for "$subCategory": ${displayedProducts.length}',
      );
    });

    // TIDAK perlu panggil _refreshData() karena sudah setState di atas
  }

  @override
  Widget build(BuildContext context) {
    bool isDefaultLayout = selectedCategory == 'Semua';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            if (showCategoryFilter) _buildCategoryFilter(),
            const SizedBox(height: 8),
            _buildLoginArea(),
            const SizedBox(height: 8),

            if (isDefaultLayout) ...[
              const SizedBox(height: 4),

              if (isLoggedIn) ...[
                _buildLoyaltyPoints(),
                const SizedBox(height: 20),
              ],

              _buildSectionHeader(
                'FLASH SALE ${_getFlashSaleTimeRange()}',
                hasTimer: true,
              ),

              _buildFlashSaleSection(),
              const SizedBox(height: 20),
              _buildPromoBanner(),
              const SizedBox(height: 20),
              _buildSectionHeader(
                'Promosi Khusus Anda',
                products: displayedProducts,
              ),

              _buildProductGrid(displayedProducts.take(6).toList()),
              const SizedBox(height: 20),
              _buildSectionHeader(
                'Produk Rating Tertinggi',
                products: topRatedProducts,
              ),
              _buildProductGrid(topRatedProducts),
              const SizedBox(height: 20),
              _buildSectionHeader('Produk Segar', products: freshProducts),
              _buildProductGrid(freshProducts),
              const SizedBox(height: 20),
              _buildSectionHeader('Produk Terbaru', products: newestProducts),
              _buildProductGrid(newestProducts),
              const SizedBox(height: 20),
              _buildSectionHeader('Buah & Sayur', products: fruitAndVeggies),
              _buildProductGrid(fruitAndVeggies),
            ] else ...[
              if (subCategories.isNotEmpty) ...[
                _buildCategoryShoppingSection(),
                const SizedBox(height: 8),
                _buildSubCategoryIndicator(),
                const SizedBox(height: 12),
              ],

              _buildSectionHeader('Nikmati Promonya!'),
              _buildProductGrid(displayedProducts.take(6).toList()),
              const SizedBox(height: 20),
              _buildSectionHeader(
                'Rekomendasi Khusus Untukmu',
                showSeeAll: false,
              ),
              _buildRecommendationList(displayedProducts),
            ],

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[700]!, Colors.blue[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showCategoryFilter = !showCategoryFilter;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.apps_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            selectedCategory,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    'IndoSmec',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Consumer<NotificationProvider>(
                    builder: (context, notifProvider, child) {
                      final unreadCount = notifProvider.unreadCount;

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotificationScreen(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(30),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.notifications_outlined,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),

                            if (unreadCount > 0)
                              Positioned(
                                right: -2,
                                top: -2,
                                child: Container(
                                  padding: EdgeInsets.all(
                                    unreadCount > 9 ? 4 : 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red[600],
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.red.withOpacity(0.5),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: unreadCount > 9 ? 22 : 20,
                                    minHeight: unreadCount > 9 ? 22 : 20,
                                  ),
                                  child: Center(
                                    child: Text(
                                      unreadCount > 99 ? '99+' : '$unreadCount',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: unreadCount > 9 ? 9 : 10,
                                        fontWeight: FontWeight.bold,
                                        height: 1,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              SearchScreen(nearbyKoperasi: _nearbyKoperasi),
                    ),
                  );
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(
                          Icons.search_rounded,
                          color: Colors.blue[700],
                          size: 24,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Cari produk UMKM...',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 15,
                          ),
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 16),
                      //   child: Icon(
                      //     Icons.qr_code_scanner_rounded,
                      //     color: Colors.grey[400],
                      //     size: 24,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pilih Kategori',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    showCategoryFilter = false;
                  });
                },
                child: Icon(Icons.close_rounded, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children:
                categories.map((category) {
                  bool isSelected = selectedCategory == category['name'];
                  return GestureDetector(
                    onTap:
                        () => _onCategorySelected(category['name'] as String),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient:
                            isSelected
                                ? LinearGradient(
                                  colors: [
                                    Colors.blue[600]!,
                                    Colors.blue[700]!,
                                  ],
                                )
                                : null,
                        color: isSelected ? null : Colors.grey[100],
                        borderRadius: BorderRadius.circular(25),
                        boxShadow:
                            isSelected
                                ? [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: Offset(0, 3),
                                  ),
                                ]
                                : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            category['icon'] as IconData,
                            size: 18,
                            color: isSelected ? Colors.white : Colors.grey[700],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            category['name'] as String,
                            style: TextStyle(
                              color:
                                  isSelected ? Colors.white : Colors.grey[800],
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              if (!isLoggedIn) ...[
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                    if (result == true || mounted) {
                      _checkLoginStatus();
                    }
                  },
                  child: Text(
                    'Login dulu yuk!',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],

              if (isLoggedIn && _savedAlamat != null) ...[
                GestureDetector(
                  onTap: () {
                    _showLocationModal();
                  },
                  child: Row(
                    children: [
                      Text(
                        'Dikirim ke',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _savedAlamat!['label'] ?? 'Rumah',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey[600],
                        size: 14,
                      ),
                    ],
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FavoritScreen()),
                    );
                    _loadFavoriteStatus();
                  },
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite,
                      color: Colors.red[600],
                      size: 21,
                    ),
                  ),
                ),
              ],
            ],
          ),

          // ⭐ INFO KOPERASI DARI ALAMAT YANG DIPILIH
          if (_nearbyKoperasi.isNotEmpty) ...[
            const SizedBox(height: 8),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.store, color: Colors.green[700], size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Belanja dari: ${_nearbyKoperasi.first.name}',
                          style: TextStyle(
                            color: Colors.green[800],
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${_nearbyKoperasi.first.productIds.length} produk',
                        style: TextStyle(
                          color: Colors.green[600],
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // ⭐ FLASH SALE INFO
                if (flashSaleProducts.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red[50]!, Colors.orange[50]!],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: Colors.red[700],
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${flashSaleProducts.length} produk Flash Sale tersedia!',
                            style: TextStyle(
                              color: Colors.red[800],
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (currentFlashSale != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red[700],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${currentFlashSale!.discountPercentage}%',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ] else if (_savedAlamat != null) ...[
            // Jika alamat dipilih tapi tidak ada koperasi match
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber,
                    color: Colors.orange[700],
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Belum ada koperasi di ${_savedAlamat!['kelurahan']}',
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showLocationModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return isLoggedIn
            ? _buildLoggedInLocationModal()
            : _buildGuestLocationModal();
      },
    );
  }

  Widget _buildLoggedInLocationModal() {
    print('🏗️ [HOME] _buildLoggedInLocationModal() building...');

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tipe Pemesanan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.grey[600], size: 20),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[700]!, width: 1.5),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.delivery_dining,
                      color: Colors.blue[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Pesan Antar',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              Divider(height: 1, color: Colors.grey[200]),
              const SizedBox(height: 16),

              Text(
                'Pilih Alamat',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              if (_listAlamat.isNotEmpty) ...[
                ...(_listAlamat.asMap().entries.map((entry) {
                  final index = entry.key;
                  final alamat = entry.value;
                  final isSelected = _selectedAlamatIndex == index;

                  return Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () async {
                        setModalState(() {
                          _selectedAlamatIndex = index;
                          _savedAlamat = alamat;
                        });

                        setState(() {
                          _selectedAlamatIndex = index;
                          _savedAlamat = alamat;
                        });

                        if (userEmail.isNotEmpty) {
                          await UserDataManager.setSelectedAlamatIndex(
                            userEmail,
                            index,
                          );
                          print('💾 Selected index saved: $index');
                        }

                        // ⭐ UPDATE LOKASI DARI ALAMAT YANG DIPILIH
                        await _updateLocationFromAddress(alamat);

                        // Tutup modal
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color:
                                isSelected
                                    ? Colors.blue[700]!
                                    : Colors.grey[300]!,
                            width: isSelected ? 1.5 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color:
                                  isSelected
                                      ? Colors.blue[700]
                                      : Colors.grey[600],
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    alamat['label'] ?? 'rumah',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${alamat['nama_penerima'] ?? ''} (${alamat['nomor_hp'] ?? ''})',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    alamat['is_manual'] == true
                                        ? '${alamat['alamat_lengkap'] ?? ''}, ${alamat['kelurahan'] ?? ''}'
                                        : 'Jl. ${alamat['jalan'] ?? alamat['alamat_lengkap'] ?? ''}, ${alamat['kelurahan'] ?? ''}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: Colors.blue[700],
                                size: 20,
                              )
                            else
                              Icon(
                                Icons.circle_outlined,
                                color: Colors.grey[400],
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList()),
              ],

              InkWell(
                onTap: () async {
                  print('➕ [HOME] Tombol Tambah Alamat ditekan');
                  Navigator.pop(context);

                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              LengkapiAlamatScreen(existingAddress: null),
                    ),
                  );

                  if (result != null && result is Map<String, dynamic>) {
                    setState(() {
                      _listAlamat.add(result);
                      _selectedAlamatIndex = _listAlamat.length - 1;
                      _savedAlamat = result;
                    });

                    final saved = await UserDataManager.saveAlamat(
                      userEmail,
                      result,
                    );
                    if (saved && mounted) {
                      // ⭐ UPDATE LOKASI DARI ALAMAT BARU
                      await _updateLocationFromAddress(result);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Alamat berhasil disimpan'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: Colors.blue[700],
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _listAlamat.isEmpty
                              ? 'Tambah Alamat'
                              : 'Tambah Alamat Lain',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey[400],
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGuestLocationModal() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tentukan Lokasimu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.close_rounded, color: Colors.grey[600]),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 20),

        InkWell(
          onTap: () async {
            Navigator.pop(context);
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
            if (result == true || mounted) {
              _checkLoginStatus();
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Icon(Icons.login_rounded, color: Colors.grey[700], size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Masuk',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Masuk agar alamat pengirimanmu disimpan',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildLoyaltyPoints() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // ⭐ POIN UMKM - Dengan Navigasi
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PoinkuMainScreen(),
                          ),
                        );
                      },
                      child: _buildPointCard(
                        Icons.stars_rounded,
                        'Poin UMKM',
                        _formatPoinNumber(_totalPoinUMKM),
                        Colors.blue[700]!,
                      ),
                    ),
                  ),

                  Container(width: 1, height: 30, color: Colors.grey[200]),

                  // ⭐ POIN CASH - Dengan Navigasi
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PoinkuMainScreen(),
                          ),
                        );
                      },
                      child: _buildPointCard(
                        Icons.account_balance_wallet_rounded,
                        'Poin Cash',
                        _formatPoinNumber(_totalPoinCash),
                        Colors.green[700]!,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[600]!, Colors.blue[700]!],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'i',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'i.saku',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      'Hubungkan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointCard(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 9)),
            Text(
              value,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFlashSaleSection() {
    // PERBAIKAN: Ubah pengecekan null ke empty karena sekarang bukan nullable
    if (flashSaleProducts.isEmpty) {
      return Container(
        height: 210,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      height: 210,
      margin: const EdgeInsets.only(left: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: flashSaleProducts.length,
        itemBuilder: (context, index) {
          return _buildFlashSaleCard(flashSaleProducts[index]);
        },
      ),
    );
  }

  Widget _buildFlashSaleCard(Product product) {
    // ⭐ PENTING: CEK STATUS FLASH SALE **SETIAP KALI BUILD**
    final isFlashActive = FlashSaleService.isProductOnFlashSale(product.id);
    final flashDiscountPercent = FlashSaleService.getFlashDiscountPercentage(
      product.id,
    );

    // ⭐ HARGA DINAMIS BERDASARKAN STATUS FLASH SALE
    final originalPrice = product.originalPrice ?? product.price;
    double displayPrice;

    if (isFlashActive) {
      // Flash Sale AKTIF → gunakan harga diskon flash sale
      displayPrice = FlashSaleService.calculateFlashPrice(
        product.id,
        originalPrice,
      );
    } else {
      // Flash Sale TIDAK AKTIF → gunakan harga normal produk
      displayPrice = product.price; // ⭐ INI YANG DIPERBAIKI!
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ProductDetailPage(
                  product: product,
                  userKoperasi:
                      _nearbyKoperasi.isNotEmpty ? _nearbyKoperasi.first : null,
                ),
          ),
        );
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 100,
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Image.network(
                      product.imageUrl ?? '',
                      width: double.infinity,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: Icon(
                              Icons.image_rounded,
                              size: 40,
                              color: Colors.grey[400],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // ⭐ BADGE DINAMIS
                Positioned(
                  top: 4,
                  left: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Flash Sale Badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors:
                                isFlashActive
                                    ? [Colors.red[600]!, Colors.red[800]!]
                                    : [
                                      Colors.grey[400]!,
                                      Colors.grey[500]!,
                                    ], // ⭐ BERUBAH JADI ABU
                          ),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: (isFlashActive ? Colors.red : Colors.grey)
                                  .withOpacity(0.4),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isFlashActive
                                  ? Icons.local_fire_department
                                  : Icons.schedule,
                              color: Colors.white,
                              size: 10,
                            ),
                            SizedBox(width: 2),
                            Text(
                              isFlashActive
                                  ? '${flashDiscountPercent}%'
                                  : 'Berakhir',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // if (_nearbyKoperasi.isNotEmpty)
                      //   Container(
                      //     margin: EdgeInsets.only(top: 4),
                      //     padding: EdgeInsets.symmetric(
                      //       horizontal: 4,
                      //       vertical: 1,
                      //     ),
                      //     decoration: BoxDecoration(
                      //       color: Colors.green[700],
                      //       borderRadius: BorderRadius.circular(3),
                      //     ),
                      //     child: Row(
                      //       mainAxisSize: MainAxisSize.min,
                      //       children: [
                      //         Icon(Icons.store, color: Colors.white, size: 8),
                      //         SizedBox(width: 2),
                      //         Text(
                      //           'UMKM',
                      //           style: TextStyle(
                      //             color: Colors.white,
                      //             fontSize: 7,
                      //             fontWeight: FontWeight.bold,
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                    ],
                  ),
                ),
              ],
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),

                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: Colors.amber[700],
                          size: 10,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${product.rating}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '(${product.reviewCount})',
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // ⭐ TAMPILAN HARGA DINAMIS
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatPrice(displayPrice),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color:
                                isFlashActive
                                    ? Colors.red[700]
                                    : Colors.blue[700], // ⭐ WARNA BERUBAH
                          ),
                        ),

                        // ⭐ HANYA TAMPILKAN CORET + DISKON JIKA FLASH SALE AKTIF
                        if (isFlashActive && displayPrice < originalPrice)
                          Row(
                            children: [
                              Text(
                                _formatPrice(originalPrice),
                                style: TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey[400],
                                  fontSize: 9,
                                ),
                              ),
                              SizedBox(width: 4),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 3,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  '-${flashDiscountPercent}%',
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                        // ⭐ TAMPILKAN DISKON ORIGINAL JIKA FLASH SALE BERAKHIR
                        if (!isFlashActive &&
                            product.discountPercentage != null)
                          Row(
                            children: [
                              Text(
                                _formatPrice(originalPrice),
                                style: TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey[400],
                                  fontSize: 9,
                                ),
                              ),
                              SizedBox(width: 4),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 3,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  '-${product.discountPercentage}%',
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    final priceInt = price.toInt();
    final priceString = priceInt.toString();

    String result = '';
    int counter = 0;

    for (int i = priceString.length - 1; i >= 0; i--) {
      if (counter == 3) {
        result = '.$result';
        counter = 0;
      }
      result = priceString[i] + result;
      counter++;
    }

    return 'Rp$result';
  }

  Widget _buildPromoBanner() {
    return Container(
      height: 150,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
        image: DecorationImage(
          image: NetworkImage(
            'https://www.klikindomaret.com/assets-klikidmcore/_next/image?url=https%3A%2F%2Fcdn-klik.klikindomaret.com%2Fhome%2Fbanner%2F2e8dd8a3-cdd5-4123-9805-5b3d7d49c57b.png&w=1080&q=75',
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildCategoryShoppingSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kategori ${selectedCategory}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Lihat Semua',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 100,
          margin: const EdgeInsets.only(left: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: subCategories.length,
            itemBuilder: (context, index) {
              final subCat = subCategories[index];
              bool isSelected = selectedSubCategory == subCat.name;

              return GestureDetector(
                onTap: () => _onSubCategorySelected(subCat.name),
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow:
                              isSelected
                                  ? [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.2),
                                      blurRadius: 12,
                                      offset: Offset(0, 8),
                                    ),
                                  ]
                                  : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                          border:
                              isSelected
                                  ? Border.all(
                                    color: Colors.blue[700]!,
                                    width: 2,
                                  )
                                  : null,
                        ),
                        child: Center(
                          child: Text(
                            subCat.icon,
                            style: TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subCat.name,
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected ? Colors.blue[700] : Colors.black87,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubCategoryIndicator() {
    if (selectedSubCategory == null) return SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'Menampilkan: ',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedSubCategory!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedSubCategory = null;
                      _loadData();
                    });
                  },
                  child: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          Text(
            '${displayedProducts.length} produk',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationList(List<Product> products) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children:
            products.take(5).map((product) {
              final isFavorite = favoriteStatus[product.id] ?? false;

              // ⭐ CEK FLASH SALE STATUS
              final isFlashSaleActive = FlashSaleService.isProductOnFlashSale(
                product.id,
              );
              final flashDiscountPercent =
                  FlashSaleService.getFlashDiscountPercentage(product.id);

              // ⭐ HITUNG HARGA REAL-TIME DARI SERVICE
              final displayPrice = _productService.getProductPrice(product.id);
              final originalPrice = product.originalPrice ?? product.price;

              // ⭐ TENTUKAN DISKON YANG DITAMPILKAN (Flash Sale Priority)
              final discountToShow =
                  isFlashSaleActive
                      ? flashDiscountPercent
                      : product.discountPercentage;

              return StatefulBuilder(
                builder: (context, setStateLocal) {
                  int quantity = 0;

                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // ⭐ GAMBAR PRODUK
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ProductDetailPage(
                                        product: product,
                                        userKoperasi:
                                            _nearbyKoperasi.isNotEmpty
                                                ? _nearbyKoperasi.first
                                                : null,
                                      ),
                                ),
                              );
                            },
                            child: Stack(
                              children: [
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      product.imageUrl ?? '',
                                      height: 70,
                                      width: 70,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Center(
                                          child: Icon(
                                            Icons.image_rounded,
                                            size: 30,
                                            color: Colors.grey[400],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),

                                // ⭐ BADGE FLASH SALE (JIKA AKTIF)
                                if (isFlashSaleActive)
                                  Positioned(
                                    top: 2,
                                    left: 2,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.red[600]!,
                                            Colors.red[800]!,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.red.withOpacity(0.4),
                                            blurRadius: 3,
                                            offset: Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.local_fire_department,
                                            color: Colors.white,
                                            size: 8,
                                          ),
                                          SizedBox(width: 2),
                                          Text(
                                            'FLASH',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 7,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),

                          // ⭐ INFORMASI PRODUK
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => ProductDetailPage(
                                          product: product,
                                          userKoperasi:
                                              _nearbyKoperasi.isNotEmpty
                                                  ? _nearbyKoperasi.first
                                                  : null,
                                        ),
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Nama Produk
                                  Text(
                                    product.name,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),

                                  // Rating
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star_rounded,
                                        color: Colors.amber[700],
                                        size: 12,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${product.rating}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '(${product.reviewCount})',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 4),

                                  // Deskripsi
                                  Text(
                                    product.description,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  const SizedBox(height: 6),

                                  // ⭐ HARGA DINAMIS (FLASH SALE / NORMAL)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Harga Utama
                                      Text(
                                        _formatPrice(displayPrice),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              isFlashSaleActive
                                                  ? Colors.red[700]
                                                  : Colors.blue[700],
                                        ),
                                      ),

                                      // ⭐ HARGA CORET + BADGE DISKON (JIKA ADA)
                                      if (discountToShow != null &&
                                          discountToShow > 0)
                                        Row(
                                          children: [
                                            // Harga Original (Dicoret)
                                            Text(
                                              _formatPrice(originalPrice),
                                              style: TextStyle(
                                                fontSize: 11,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                color: Colors.grey[400],
                                              ),
                                            ),
                                            const SizedBox(width: 6),

                                            // Badge Diskon
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 4,
                                                vertical: 1,
                                              ),
                                              decoration: BoxDecoration(
                                                color:
                                                    isFlashSaleActive
                                                        ? Colors.red[600]
                                                        : Colors.blue[50],
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  if (isFlashSaleActive) ...[
                                                    Icon(
                                                      Icons
                                                          .local_fire_department,
                                                      color: Colors.white,
                                                      size: 8,
                                                    ),
                                                    SizedBox(width: 2),
                                                  ],
                                                  Text(
                                                    '$discountToShow%',
                                                    style: TextStyle(
                                                      color:
                                                          isFlashSaleActive
                                                              ? Colors.white
                                                              : Colors
                                                                  .blue[700],
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 9,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // ⭐ TOMBOL FAVORIT & KERANJANG
                          Column(
                            children: [
                              // Tombol Favorit
                              GestureDetector(
                                onTap:
                                    () => _toggleFavorite(
                                      product.id,
                                      product.name,
                                    ),
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color:
                                        isFavorite
                                            ? Colors.red[50]
                                            : Colors.grey[100],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color:
                                        isFavorite
                                            ? Colors.red
                                            : Colors.grey[600],
                                    size: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Tombol Keranjang (Dinamis)
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                transitionBuilder:
                                    (child, animation) => ScaleTransition(
                                      scale: animation,
                                      child: child,
                                    ),
                                child:
                                    quantity == 0
                                        ? GestureDetector(
                                          key: const ValueKey('addButton'),
                                          onTap: () async {
                                            final userLogin =
                                                await UserDataManager.getCurrentUserLogin();
                                            if (userLogin == null) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Silakan login terlebih dahulu',
                                                  ),
                                                  backgroundColor:
                                                      Colors.orange,
                                                  duration: Duration(
                                                    seconds: 2,
                                                  ),
                                                ),
                                              );
                                              return;
                                            }

                                            final success =
                                                await CartManager.addToCart(
                                                  productId: product.id,
                                                  name: product.name,
                                                  price: product.price,
                                                  originalPrice:
                                                      product.originalPrice,
                                                  discountPercentage:
                                                      product
                                                          .discountPercentage,
                                                  imageUrl: product.imageUrl,
                                                  category: product.category,
                                                );

                                            if (success) {
                                              setStateLocal(() {
                                                quantity = 1;
                                              });
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.check_circle,
                                                        color: Colors.white,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: Text(
                                                          '${product.name} ditambahkan ke keranjang',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  backgroundColor: Colors.green,
                                                  duration: const Duration(
                                                    milliseconds: 1500,
                                                  ),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                ),
                                              );
                                            }
                                          },
                                          child: Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: Colors.blue[700],
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.15),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.add,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        )
                                        : Container(
                                          key: const ValueKey('counter'),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.blue[700],
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.15,
                                                ),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              GestureDetector(
                                                onTap: () async {
                                                  if (quantity > 1) {
                                                    final success =
                                                        await CartManager.updateQuantity(
                                                          product.id,
                                                          quantity - 1,
                                                        );
                                                    if (success) {
                                                      setStateLocal(() {
                                                        quantity--;
                                                      });
                                                    }
                                                  } else {
                                                    final success =
                                                        await CartManager.removeFromCart(
                                                          product.id,
                                                        );
                                                    if (success) {
                                                      setStateLocal(() {
                                                        quantity = 0;
                                                      });
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            '${product.name} dihapus dari keranjang',
                                                          ),
                                                          backgroundColor:
                                                              Colors
                                                                  .orange[700],
                                                          duration:
                                                              const Duration(
                                                                milliseconds:
                                                                    1500,
                                                              ),
                                                          behavior:
                                                              SnackBarBehavior
                                                                  .floating,
                                                        ),
                                                      );
                                                    }
                                                  }
                                                },
                                                child: const Icon(
                                                  Icons.remove,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                    ),
                                                child: Text(
                                                  '$quantity',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () async {
                                                  final success =
                                                      await CartManager.addToCart(
                                                        productId: product.id,
                                                        name: product.name,
                                                        price: product.price,
                                                        originalPrice:
                                                            product
                                                                .originalPrice,
                                                        discountPercentage:
                                                            product
                                                                .discountPercentage,
                                                        imageUrl:
                                                            product.imageUrl,
                                                        category:
                                                            product.category,
                                                      );

                                                  if (success) {
                                                    setStateLocal(() {
                                                      quantity++;
                                                    });
                                                  }
                                                },
                                                child: const Icon(
                                                  Icons.add,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title, {
    bool hasTimer = false,
    bool showSeeAll = true,
    List<Product>? products,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          if (hasTimer && (currentFlashSale != null || nextFlashSale != null))
            FlashSaleTimer(
              schedule: currentFlashSale ?? nextFlashSale!,
              onTimerEnd: _onFlashSaleTimerEnd,
            )
          else if (showSeeAll && products != null && products.isNotEmpty)
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ProductListScreen(
                          title: title,
                          products: products,
                          nearbyKoperasi: _nearbyKoperasi,
                        ),
                  ),
                );
              },
              child: Text(
                'Lihat Semua',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(List<Product> products) {
    return Container(
      height: 260,
      margin: const EdgeInsets.only(left: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          return _buildProductCard(products[index]);
        },
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final isFavorite = favoriteStatus[product.id] ?? false;
    int quantity = 0;

    // ⭐ CEK FLASH SALE STATUS SETIAP BUILD
    final isFlashSaleActive = FlashSaleService.isProductOnFlashSale(product.id);
    final flashDiscountPercent = FlashSaleService.getFlashDiscountPercentage(
      product.id,
    );

    // ⭐ HITUNG HARGA REAL-TIME DARI SERVICE
    final displayPrice = _productService.getProductPrice(product.id);
    final originalPrice = product.originalPrice ?? product.price;

    // ⭐ TENTUKAN DISKON YANG DITAMPILKAN (Flash Sale Priority)
    final discountToShow =
        isFlashSaleActive ? flashDiscountPercent : product.discountPercentage;

    print('🛒 [CARD] Product: ${product.name}');
    print('   Flash Active: $isFlashSaleActive');
    print('   Display Price: ${displayPrice.toInt()}');
    print('   Original Price: ${originalPrice.toInt()}');

    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ProductDetailPage(
                      product: product,
                      userKoperasi:
                          _nearbyKoperasi.isNotEmpty
                              ? _nearbyKoperasi.first
                              : null,
                    ),
              ),
            );
          },
          child: Container(
            width: 150,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    // ⭐ GAMBAR PRODUK
                    Container(
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.grey[200]!, Colors.grey[100]!],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Image.network(
                          product.imageUrl ?? '',
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.image,
                                color: Colors.grey[400],
                                size: 40,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // ⭐ BADGE FLASH SALE (DINAMIS)
                    if (isFlashSaleActive)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.red[600]!, Colors.red[800]!],
                            ),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.4),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                color: Colors.white,
                                size: 10,
                              ),
                              SizedBox(width: 2),
                              Text(
                                'FLASH SALE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // ⭐ TOMBOL TAMBAH KERANJANG
                    Positioned(
                      top: 8,
                      right: 8,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder:
                            (child, animation) =>
                                ScaleTransition(scale: animation, child: child),
                        child:
                            quantity == 0
                                ? GestureDetector(
                                  key: const ValueKey('addButton'),
                                  onTap: () async {
                                    final userLogin =
                                        await UserDataManager.getCurrentUserLogin();
                                    if (userLogin == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Silakan login terlebih dahulu',
                                          ),
                                          backgroundColor: Colors.orange,
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                      return;
                                    }

                                    final success = await CartManager.addToCart(
                                      productId: product.id,
                                      name: product.name,
                                      price: product.price,
                                      originalPrice: product.originalPrice,
                                      discountPercentage:
                                          product.discountPercentage,
                                      imageUrl: product.imageUrl,
                                      category: product.category,
                                    );

                                    if (success) {
                                      setState(() {
                                        quantity = 1;
                                      });
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              const Icon(
                                                Icons.check_circle,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  '${product.name} ditambahkan ke keranjang',
                                                ),
                                              ),
                                            ],
                                          ),
                                          backgroundColor: Colors.green,
                                          duration: const Duration(
                                            milliseconds: 1500,
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Gagal menambahkan ke keranjang',
                                          ),
                                          backgroundColor: Colors.red,
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.blue[700],
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                )
                                : Container(
                                  key: const ValueKey('counter'),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[700],
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          if (quantity > 1) {
                                            final success =
                                                await CartManager.updateQuantity(
                                                  product.id,
                                                  quantity - 1,
                                                );
                                            if (success) {
                                              setState(() {
                                                quantity--;
                                              });
                                            }
                                          } else {
                                            final success =
                                                await CartManager.removeFromCart(
                                                  product.id,
                                                );
                                            if (success) {
                                              setState(() {
                                                quantity = 0;
                                              });
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    '${product.name} dihapus dari keranjang',
                                                  ),
                                                  backgroundColor:
                                                      Colors.orange[700],
                                                  duration: const Duration(
                                                    milliseconds: 1500,
                                                  ),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        child: const Icon(
                                          Icons.remove,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                        ),
                                        child: Text(
                                          '$quantity',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          final success =
                                              await CartManager.addToCart(
                                                productId: product.id,
                                                name: product.name,
                                                price: product.price,
                                                originalPrice:
                                                    product.originalPrice,
                                                discountPercentage:
                                                    product.discountPercentage,
                                                imageUrl: product.imageUrl,
                                                category: product.category,
                                              );

                                          if (success) {
                                            setState(() {
                                              quantity++;
                                            });
                                          }
                                        },
                                        child: const Icon(
                                          Icons.add,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                      ),
                    ),
                  ],
                ),

                // ⭐ INFORMASI PRODUK
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nama Produk
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),

                        // Rating
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: Colors.amber[700],
                              size: 14,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${product.rating}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${product.reviewCount})',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        // ⭐ HARGA DINAMIS (FLASH SALE / NORMAL)
                        Text(
                          _formatPrice(displayPrice),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color:
                                isFlashSaleActive
                                    ? Colors.red[700]
                                    : Colors.blue[700],
                          ),
                        ),

                        const SizedBox(height: 2),

                        // ⭐ HARGA CORET + BADGE DISKON (JIKA ADA)
                        if (discountToShow != null && discountToShow > 0)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Harga Original (Dicoret)
                              Text(
                                _formatPrice(originalPrice),
                                style: TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey[400],
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(width: 4),

                              // Badge Diskon
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isFlashSaleActive
                                          ? Colors.red[600]
                                          : Colors.blue[50],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isFlashSaleActive) ...[
                                      Icon(
                                        Icons.local_fire_department,
                                        color: Colors.white,
                                        size: 7,
                                      ),
                                      SizedBox(width: 1),
                                    ],
                                    Text(
                                      '$discountToShow%',
                                      style: TextStyle(
                                        color:
                                            isFlashSaleActive
                                                ? Colors.white
                                                : Colors.blue[700],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
