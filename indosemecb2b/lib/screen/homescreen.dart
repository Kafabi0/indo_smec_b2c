import 'package:flutter/material.dart';
import 'package:indosemecb2b/screen/detail_produk.dart';
import 'package:indosemecb2b/screen/notif.dart';
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
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Gunakan microtask untuk memastikan semua inisialisasi berjalan berurutan
    Future.microtask(() async {
      print('🚀 [HOME] Starting initialization...');
      await _checkLoginStatus();
      print('✅ [HOME] Login status checked');

      if (!_isLocationInitialized) {
        await _loadUserLocation();
        _isLocationInitialized = true;
        print('✅ [HOME] User location loaded');
      }

      await _loadUserLocation();
      print('✅ [HOME] User location loaded');

      await _loadPoinFromTransactions();
      print('✅ [HOME] Poin data loaded');

      _updateFlashSaleStatus();
      print('✅ [HOME] Flash sale status updated');

      _scheduleFlashSaleNotifications();
      print('✅ [HOME] Flash sale notifications scheduled');

      _refreshData();
      print('✅ [HOME] Initial data loaded');
      print('🎉 [HOME] Initialization complete');
    });

    _flashSaleCheckTimer = Timer.periodic(Duration(seconds: 10), (_) {
      _updateFlashSaleStatus();
    });
  }

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

  void _updateFlashSaleStatus() {
    if (!mounted) return;

    setState(() {
      currentFlashSale = FlashSaleService.getCurrentFlashSale();
      nextFlashSale = FlashSaleService.getNextFlashSale();
    });

    print('🔥 [FLASH SALE] Status update:');
    print('   Current: ${currentFlashSale?.title ?? "None"}');
    print('   Next: ${nextFlashSale?.title ?? "None"}');
  }

  void _onFlashSaleTimerEnd() {
    print('⏰ Timer flash sale berakhir, reload data...');
    _updateFlashSaleStatus();
    _loadData();
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
    print('📍 [HOME] _loadUserLocation() called');

    if (_isLoadingLocation) {
      print('⚠️ [HOME] Location already loading, skipping...');
      return;
    }

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      print('🔄 [HOME] Getting user location...');
      final location = await LocationService.getUserLocation();
      print('🔄 [HOME] Getting koperasi list...');
      final koperasiList = await KoperasiService.getKoperasiByLocation();

      if (mounted) {
        setState(() {
          _userLocation = location;
          _nearbyKoperasi = koperasiList;
          _isLoadingLocation = false;
        });
      }

      if (location != null) {
        print(
          '✅ [HOME] Location loaded: ${location?['kelurahan'] ?? 'Unknown'}',
        );
      } else {
        print('❌ [HOME] Failed to get location');
      }
      print('✅ [HOME] Koperasi found: ${koperasiList.length}');
    } catch (e) {
      print('❌ [HOME] Error loading location: $e');
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  Future<void> _loadAlamatData() async {
    print('🔍 [HOME] _loadAlamatData() dipanggil');
    print('📧 [HOME] userEmail: $userEmail');
    print('🔐 [HOME] isLoggedIn: $isLoggedIn');

    if (userEmail.isNotEmpty) {
      print('⏳ [HOME] Mengambil alamat dari UserDataManager...');
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
          print(
            '🔄 [HOME] setState() selesai, _savedAlamat: ${_savedAlamat!['label']}',
          );
        }
      } else {
        print('❌ [HOME] Tidak ada alamat tersimpan');
        if (mounted) {
          setState(() {
            _listAlamat = [];
            _selectedAlamatIndex = 0;
            _savedAlamat = null;
          });
        }
      }
    } else {
      print('⚠️ [HOME] userEmail kosong, tidak bisa load alamat');
    }
  }

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

  void _loadData() async {
    if (_isLoadingData) {
      print('⚠️ [HOME] Data already loading, skipping...');
      return;
    }

    setState(() {
      _isLoadingData = true;
    });

    try {
      print('🔄 [HOME] Loading data...');

      // Gunakan produk berdasarkan lokasi
      if (selectedCategory == 'Semua') {
        displayedProducts = await KoperasiService.getProductsByLocation();
      } else {
        displayedProducts =
            await KoperasiService.getProductsByCategoryAndLocation(
              selectedCategory,
            );
      }

      flashSaleProducts = _productService.getActiveFlashSaleProducts();

      // Filter produk lain juga berdasarkan lokasi
      final locationProducts = await KoperasiService.getProductsByLocation();

      topRatedProducts = List<Product>.from(locationProducts)
        ..sort((a, b) => b.rating.compareTo(a.rating));
      topRatedProducts = topRatedProducts.take(8).toList();

      freshProducts =
          _productService
              .getFreshProducts()
              .where((p) => locationProducts.any((lp) => lp.id == p.id))
              .take(8)
              .toList();

      newestProducts = List<Product>.from(locationProducts).take(8).toList();

      fruitAndVeggies =
          _productService
              .getFruitAndVeggies()
              .where((p) => locationProducts.any((lp) => lp.id == p.id))
              .take(8)
              .toList();

      categoryStores = _productService.getStoresByCategory(selectedCategory);
      subCategories = _productService.getSubCategories(selectedCategory);
      flagshipStore = _productService.getFlagshipStore(selectedCategory);

      print('✅ [HOME] Data loaded successfully');

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('❌ Error loading data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
      }
    }
  }

  void _onCategorySelected(String category) {
    // Cegah pemanggilan untuk kategori yang sama
    if (selectedCategory == category) return;

    setState(() {
      selectedCategory = category;
      selectedSubCategory = null;
      showCategoryFilter = false;
    });

    _refreshData();
  }

  void _onSubCategorySelected(String subCategory) {
    // Cegah pemanggilan untuk subkategori yang sama
    if (selectedSubCategory == subCategory) return;

    setState(() {
      selectedSubCategory = subCategory;

      // Filter produk berdasarkan subkategori yang dipilih
      if (subCategory == 'Buah') {
        displayedProducts = _productService.getFruitProducts();
      } else if (subCategory == 'Sayuran Organik') {
        displayedProducts = _productService.getVegetableProducts();
      } else if (subCategory == 'Nasi Box') {
        displayedProducts =
            _productService
                .getAllProducts()
                .where((p) => p.name.toLowerCase().contains('nasi'))
                .toList();
      } else if (subCategory == 'Snack & Jajanan') {
        displayedProducts =
            _productService
                .getAllProducts()
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
            _productService
                .getAllProducts()
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
            _productService
                .getAllProducts()
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
            _productService
                .getAllProducts()
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
            _productService
                .getAllProducts()
                .where(
                  (p) =>
                      p.name.toLowerCase().contains('beras') ||
                      p.name.toLowerCase().contains('tepung'),
                )
                .toList();
      } else if (subCategory == 'Bumbu Dapur') {
        displayedProducts =
            _productService
                .getAllProducts()
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
            _productService
                .getAllProducts()
                .where((p) => p.name.toLowerCase().contains('minyak'))
                .toList();
      } else if (subCategory == 'Telur & Susu') {
        displayedProducts =
            _productService
                .getAllProducts()
                .where(
                  (p) =>
                      p.name.toLowerCase().contains('telur') ||
                      p.name.toLowerCase().contains('susu'),
                )
                .toList();
      } else if (subCategory == 'Mie Instan') {
        displayedProducts =
            _productService
                .getAllProducts()
                .where((p) => p.name.toLowerCase().contains('mie'))
                .toList();
      } else if (subCategory == 'Batik') {
        displayedProducts =
            _productService
                .getAllProducts()
                .where((p) => p.name.toLowerCase().contains('batik'))
                .toList();
      } else if (subCategory == 'Hijab') {
        displayedProducts =
            _productService
                .getAllProducts()
                .where((p) => p.name.toLowerCase().contains('hijab'))
                .toList();
      } else if (subCategory == 'Kaos & Kemeja') {
        displayedProducts =
            _productService
                .getAllProducts()
                .where(
                  (p) =>
                      p.name.toLowerCase().contains('kaos') ||
                      p.name.toLowerCase().contains('kemeja'),
                )
                .toList();
      } else if (subCategory == 'Celana') {
        displayedProducts =
            _productService
                .getAllProducts()
                .where((p) => p.name.toLowerCase().contains('celana'))
                .toList();
      } else if (subCategory == 'Dress') {
        displayedProducts =
            _productService
                .getAllProducts()
                .where((p) => p.name.toLowerCase().contains('dress'))
                .toList();
      } else if (subCategory == 'Jamu Tradisional') {
        displayedProducts =
            _productService
                .getAllProducts()
                .where((p) => p.name.toLowerCase().contains('jamu'))
                .toList();
      } else if (subCategory == 'Madu') {
        displayedProducts =
            _productService
                .getAllProducts()
                .where((p) => p.name.toLowerCase().contains('madu'))
                .toList();
      } else if (subCategory == 'Minuman Herbal') {
        displayedProducts =
            _productService
                .getAllProducts()
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
            _productService
                .getAllProducts()
                .where((p) => p.name.toLowerCase().contains('rempah'))
                .toList();
      } else if (subCategory == 'Anyaman') {
        displayedProducts =
            _productService
                .getAllProducts()
                .where(
                  (p) =>
                      p.name.toLowerCase().contains('anyaman') ||
                      p.name.toLowerCase().contains('rotan'),
                )
                .toList();
      } else if (subCategory == 'Ukiran Kayu') {
        displayedProducts =
            _productService
                .getAllProducts()
                .where(
                  (p) =>
                      p.name.toLowerCase().contains('ukir') ||
                      p.name.toLowerCase().contains('kayu'),
                )
                .toList();
      } else if (subCategory == 'Souvenir') {
        displayedProducts =
            _productService
                .getAllProducts()
                .where(
                  (p) =>
                      p.name.toLowerCase().contains('souvenir') ||
                      p.name.toLowerCase().contains('gantungan kunci'),
                )
                .toList();
      } else if (subCategory == 'Pupuk') {
        displayedProducts =
            _productService
                .getAllProducts()
                .where((p) => p.name.toLowerCase().contains('pupuk'))
                .toList();
      } else if (subCategory == 'Bibit Tanaman') {
        displayedProducts =
            _productService
                .getAllProducts()
                .where((p) => p.name.toLowerCase().contains('bibit'))
                .toList();
      } else if (subCategory == 'Alat Tani') {
        displayedProducts =
            _productService
                .getAllProducts()
                .where((p) => p.name.toLowerCase().contains('alat'))
                .toList();
      } else if (subCategory == 'Alat Lukis') {
        displayedProducts =
            _productService
                .getAllProducts()
                .where((p) => p.name.toLowerCase().contains('lukis'))
                .toList();
      } else if (subCategory == 'Buku Sketsa') {
        displayedProducts =
            _productService
                .getAllProducts()
                .where((p) => p.name.toLowerCase().contains('sketsa'))
                .toList();
      } else if (subCategory == 'Clay & Polymer') {
        displayedProducts =
            _productService
                .getAllProducts()
                .where((p) => p.name.toLowerCase().contains('clay'))
                .toList();
      } else {
        displayedProducts = _productService.getProductsBySubCategory(
          subCategory,
        );
      }

      // Jika tidak ada produk, tampilkan semua produk dari kategori utama
      if (displayedProducts.isEmpty) {
        displayedProducts = _productService.getProductsByCategory(
          selectedCategory,
        );
      }
    });

    // HAPUS pemanggilan _refreshData() di akhir method ini untuk mencegah loop
    // _refreshData(); // HAPUS BARIS INI
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
                      builder: (context) => const SearchScreen(),
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(
                          Icons.qr_code_scanner_rounded,
                          color: Colors.grey[400],
                          size: 24,
                        ),
                      ),
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
      child: Row(
        children: [
          if (!isLoggedIn) ...[
            GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
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
            const SizedBox(width: 4),
            Text('|', style: TextStyle(color: Colors.grey[400], fontSize: 15)),
            const SizedBox(width: 4),
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
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _savedAlamat!['label'] ?? 'Rumah',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
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
            const SizedBox(width: 4),
            Text('|', style: TextStyle(color: Colors.grey[400], fontSize: 15)),
            const SizedBox(width: 4),
          ],

          GestureDetector(
            onTap: () {
              // Bisa buka modal atau refresh lokasi
            },
            child: Row(
              children: [
                Text(
                  'Lokasi Anda',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                _isLoadingLocation
                    ? SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.blue[700]!,
                        ),
                      ),
                    )
                    : Row(
                      children: [
                        Text(
                          _userLocation != null
                              ? _userLocation!['kelurahan'] ?? 'Tidak Dikenal'
                              : 'Tidak Dikenal',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 2),
                      ],
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
              child: Icon(Icons.favorite, color: Colors.red[600], size: 21),
            ),
          ),
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
    print(
      '📍 [HOME] _savedAlamat saat build: ${_savedAlamat != null ? "ADA" : "NULL"}',
    );

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

        Divider(height: 1, color: Colors.grey[300]),

        const SizedBox(height: 10),

        Text(
          'Cara Lain',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),

        const SizedBox(height: 10),

        InkWell(
          onTap: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Membuka pilihan lokasi...'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  color: Colors.grey[700],
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pilih Lokasi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pilih area kota atau kecamatan',
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
                  _buildPointCard(
                    Icons.stars_rounded,
                    'Poin UMKM',
                    _formatPoinNumber(_totalPoinUMKM),
                    Colors.blue[700]!,
                  ),
                  Container(width: 1, height: 30, color: Colors.grey[200]),
                  _buildPointCard(
                    Icons.account_balance_wallet_rounded,
                    'Poin Cash',
                    _formatPoinNumber(_totalPoinCash),
                    Colors.green[700]!,
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
    final isFlashActive = FlashSaleService.isProductOnFlashSale(product.id);
    final flashDiscountPercent = FlashSaleService.getFlashDiscountPercentage(
      product.id,
    );

    final displayPrice =
        isFlashActive
            ? FlashSaleService.calculateFlashPrice(
              product.id,
              product.originalPrice ?? product.price,
            )
            : product.price;

    final originalPrice = product.originalPrice ?? product.price;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
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

                if (isFlashActive)
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                            '${flashDiscountPercent}%',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
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
                          fontSize: 11,
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
                            fontSize: 9,
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
                                    : Colors.blue[700],
                          ),
                        ),

                        if (displayPrice < originalPrice)
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
                              if (isFlashActive) ...[
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
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
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
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          ProductDetailPage(product: product),
                                ),
                              );
                            },
                            child: Container(
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
                                  errorBuilder: (context, error, stackTrace) {
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
                          ),
                          const SizedBox(width: 12),

                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            ProductDetailPage(product: product),
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                                  Row(
                                    children: [
                                      Text(
                                        _formatPrice(product.price),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[700],
                                        ),
                                      ),
                                      if (product.originalPrice != null) ...[
                                        const SizedBox(width: 6),
                                        Text(
                                          _formatPrice(product.originalPrice!),
                                          style: TextStyle(
                                            fontSize: 11,
                                            decoration:
                                                TextDecoration.lineThrough,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Column(
                            children: [
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
                                            } else {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Gagal menambahkan ke keranjang',
                                                  ),
                                                  backgroundColor: Colors.red,
                                                  duration: Duration(
                                                    seconds: 2,
                                                  ),
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
                        (context) =>
                            ProductListScreen(title: title, products: products),
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

    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailPage(product: product),
              ),
            );
          },
          child: Container(
            width: 150,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
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
                      child: Center(
                        child: Image.network(
                          product.imageUrl ?? '',
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

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
                                      color: Colors.blue,
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
                                    color: Colors.blue,
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
                                        onTap: () {
                                          if (quantity > 1) {
                                            setState(() {
                                              quantity--;
                                            });
                                          } else {
                                            setState(() {
                                              quantity = 0;
                                            });
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

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatPrice(product.price),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.blue[700],
                              ),
                            ),
                            const SizedBox(width: 4),
                            if (product.originalPrice != null)
                              Text(
                                _formatPrice(product.originalPrice!),
                                style: TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey[400],
                                  fontSize: 10,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        if (product.discountPercentage != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${product.discountPercentage}%',
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 9,
                              ),
                            ),
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
