import 'package:flutter/material.dart';
import 'package:indosemecb2b/screen/detail_produk.dart';
import 'package:indosemecb2b/screen/product_list_screen.dart';
import 'package:indosemecb2b/utils/cart_manager.dart';
import 'package:indosemecb2b/utils/user_data_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';
import '../models/store_model.dart';
import '../models/subcategory_model.dart';
import '../services/product_service.dart';
import 'login.dart';
import '../services/favorite_service.dart';
import 'favorit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final ProductService _productService = ProductService();
  final FavoriteService _favoriteService = FavoriteService(); // TAMBAHKAN INI

  bool isLoggedIn = false;
  String userEmail = '';

  String selectedCategory = 'Semua';
  bool showCategoryFilter = false;
  bool isXpressSelected = true;
  String? selectedSubCategory;

  // Data produk & stores
  late List<Product> displayedProducts;
  late List<Product> flashSaleProducts;
  late List<Product> topRatedProducts;
  late List<Product> freshProducts;
  late List<Product> newestProducts;
  late List<Product> fruitAndVeggies;
  late List<Store> categoryStores;
  late List<SubCategory> subCategories;
  Store? flagshipStore;
  Map<String, bool> favoriteStatus = {};

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
    _checkLoginStatus();
    _loadData();
    // _loadFavoriteStatus(); // TAMBAHKAN INI
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      userEmail = prefs.getString('userEmail') ?? '';
    });
    if (isLoggedIn) {
      _loadFavoriteStatus();
    } else {
      // CLEAR STATUS FAVORIT JIKA BELUM LOGIN
      setState(() {
        favoriteStatus = {};
      });
    }
  }

  // CATATAN: PANGGILAN INI SUDAH TEPAT
  Future<void> _loadFavoriteStatus() async {
    final favoriteIds = await _favoriteService.getAllFavoriteIds();
    setState(() {
      // Perhatikan: favoriteStatus diisi berdasarkan SEMUA produk
      // dan dicek apakah ada di dalam favoriteIds yang dimuat dari SharedPreferences
      for (var product in _productService.getAllProducts()) {
        favoriteStatus[product.id] = favoriteIds.contains(product.id);
      }
    });
  }

  // Future<void> _loadFavoriteStatus() async {
  //   final favoriteIds = await _favoriteService.getAllFavoriteIds();
  //   setState(() {
  //     for (var product in _productService.getAllProducts()) {
  //       favoriteStatus[product.id] = favoriteIds.contains(product.id);
  //     }
  //   });
  // }

  // TAMBAHKAN METHOD INI
  Future<void> _toggleFavorite(String productId, String productName) async {
    // START MODIFIKASI: Tambahkan pemeriksaan login
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
      return; // Keluar jika belum login
    }
    // END MODIFIKASI

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

  void refreshLoginStatus() {
    _checkLoginStatus();
    _loadData();
  }

  void _loadData() {
    // Load data sesuai kategori yang dipilih
    if (selectedCategory == 'Semua') {
      displayedProducts = _productService.getAllProducts();
    } else {
      displayedProducts = _productService.getProductsByCategory(
        selectedCategory,
      );
    }

    flashSaleProducts = _productService.getFlashSalePaketan();
    topRatedProducts = _productService.getTopRatedProducts();
    freshProducts = _productService.getFreshProducts();
    newestProducts = _productService.getNewestProducts();
    fruitAndVeggies = _productService.getFruitAndVeggies();

    // Load stores & sub-categories untuk kategori spesifik
    categoryStores = _productService.getStoresByCategory(selectedCategory);
    subCategories = _productService.getSubCategories(selectedCategory);
    flagshipStore = _productService.getFlagshipStore(selectedCategory);
  }

  void _onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
      selectedSubCategory = null;
      showCategoryFilter = false;
      _loadData();
    });
  }

  void _onSubCategorySelected(String subCategory) {
    setState(() {
      selectedSubCategory = subCategory;

      if (subCategory == 'Buah') {
        displayedProducts = _productService.getFruitProducts();
      } else if (subCategory == 'Sayuran Organik') {
        displayedProducts = _productService.getVegetableProducts();
      } else {
        displayedProducts = _productService.getProductsBySubCategory(
          subCategory,
        );
      }
    });
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
              _buildDeliveryOptions(),
              const SizedBox(height: 16),

              if (isLoggedIn) ...[
                _buildLoyaltyPoints(),
                const SizedBox(height: 20),
              ],

              _buildSectionHeader('FLASH SALE 11.00 - 13.00', hasTimer: true),
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
                const SizedBox(height: 20),
              ],

              if (categoryStores.isNotEmpty) ...[
                _buildStoreList(),
                const SizedBox(height: 20),
              ],

              _buildLiveShopping(),
              const SizedBox(height: 20),
              _buildSectionHeader('Nikmati Promoynya!'),
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
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
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
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari produk UMKM...',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Colors.blue[700],
                      size: 24,
                    ),
                    suffixIcon: Icon(
                      Icons.qr_code_scanner_rounded,
                      color: Colors.grey[400],
                      size: 24,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
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
          GestureDetector(
            onTap: () {
              _showLocationModal();
            },
            child: Row(
              children: [
                if (isLoggedIn) ...[
                  Text(
                    'Dikirim ke',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  'Area Antapani Kidul',
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
                  size: 18,
                ),
              ],
            ),
          ),
          Spacer(),
          GestureDetector(
            onTap: () async {
              // Navigate ke FavoritScreen
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoritScreen()),
              );
              // Reload favorite status setelah kembali
              _loadFavoriteStatus();
            },
            child: Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.favorite, color: Colors.red, size: 21),
            ),
          ),
        ],
      ),
    );
  }

  void _showLocationModal() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child:
              isLoggedIn
                  ? _buildLoggedInLocationModal()
                  : _buildGuestLocationModal(),
        );
      },
    );
  }

  // Modal untuk yang SUDAH LOGIN
  Widget _buildLoggedInLocationModal() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tipe Pemesanan',
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

        // Tipe Pemesanan Options
        Row(
          children: [
            Expanded(
              child: _buildOrderTypeCard(
                icon: Icons.delivery_dining_rounded,
                label: 'Pesan Antar',
                isSelected: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOrderTypeCard(
                icon: Icons.store_rounded,
                label: 'Ambil di Toko',
                isSelected: false,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Pilih Alamat Section
        Text(
          'Pilih Alamat',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),

        InkWell(
          onTap: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Membuka form tambah alamat...'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.blue[700]!, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    color: Colors.blue[700],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tambah Alamat Pengiriman',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.blue[700]),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        Divider(height: 1, color: Colors.grey[300]),

        const SizedBox(height: 16),

        // Cara Lain Section
        Text(
          'Cara Lain',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),

        const SizedBox(height: 12),

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

  // Modal untuk yang BELUM LOGIN
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

        // Masuk Option (Login)
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

        // Pilih Lokasi Option
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

  Widget _buildOrderTypeCard({
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue[700] : Colors.white,
        border: Border.all(
          color: isSelected ? Colors.blue[700]! : Colors.grey[300]!,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white : Colors.grey[700],
            size: 32,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 4),
                Icon(Icons.check_rounded, color: Colors.white, size: 16),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildDeliveryOption(
              isSelected: isXpressSelected,
              icon: Icons.flash_on_rounded,
              title: 'Belanja Xpress',
              subtitle: '1 Jam Sampai',
              colors: [Colors.orange[400]!, Colors.deepOrange[500]!],
              onTap: () => setState(() => isXpressSelected = true),
              isLeft: true,
            ),
            _buildDeliveryOption(
              isSelected: !isXpressSelected,
              icon: Icons.inventory_2_rounded,
              title: 'Belanja Xtra',
              subtitle: 'Banyak & Beragam',
              colors: [Colors.green[400]!, Colors.green[600]!],
              onTap: () => setState(() => isXpressSelected = false),
              isLeft: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryOption({
    required bool isSelected,
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> colors,
    required VoidCallback onTap,
    required bool isLeft,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected ? LinearGradient(colors: colors) : null,
            color: isSelected ? null : Colors.grey[200],
            borderRadius:
                isLeft
                    ? BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    )
                    : BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color:
                      isSelected ? Colors.white.withOpacity(0.2) : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.grey[700],
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color:
                            isSelected
                                ? Colors.white.withOpacity(0.9)
                                : Colors.grey[600],
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
                    Icons.emoji_events_rounded,
                    'Poin UMKM',
                    '0',
                    Colors.orange,
                  ),
                  Container(width: 1, height: 30, color: Colors.grey[200]),
                  _buildPointCard(
                    Icons.account_balance_wallet_rounded,
                    'Poin Cash',
                    '0',
                    Colors.amber,
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
          child: Icon(icon, color: color, size: 10),
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
    return Container(
      height: 230,
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
          // GAMBAR PRODUK
          Container(
            height: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                product.imageUrl ?? '',
                width: double.infinity,
                height: 110,
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
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          // INFO PRODUK
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // BADGE DISKON
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${product.discountPercentage?.toInt() ?? 0}% OFF',
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  
                  // NAMA PRODUK
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
                  const SizedBox(height: 6),
                  
                  // HARGA - ✅ FORMAT BARU
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatPrice(product.price),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.blue[700],
                        ),
                      ),
                      if (product.originalPrice != null)
                        Text(
                          _formatPrice(product.originalPrice!),
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey[500],
                            fontSize: 10,
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
}

String _formatPrice(double price) {
  final priceInt = price.toInt();
  final priceString = priceInt.toString();
  
  // Tambahkan titik setiap 3 digit dari belakang
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
      height: 160,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange[400]!, Colors.deepOrange[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.4),
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -20,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '🔥 PROMO SPESIAL',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Diskon hingga',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            '50',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              height: 1,
                            ),
                          ),
                          Text(
                            '%',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Untuk semua produk pilihan',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.celebration_rounded, color: Colors.white, size: 70),
              ],
            ),
          ),
        ],
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

  Widget _buildStoreList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'UMKM ${selectedCategory} Terdekat',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          if (flagshipStore != null) ...[
            _buildStoreCard(flagshipStore!, isFlagship: true),
            const SizedBox(height: 12),
          ],
          ...categoryStores
              .where((s) => !s.isFlagship)
              .take(3)
              .map(
                (store) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildStoreCard(store),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildStoreCard(Store store, {bool isFlagship = false}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:
            isFlagship ? Border.all(color: Colors.amber[600]!, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isFlagship ? Colors.amber[50] : Colors.blue[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isFlagship ? Icons.stars_rounded : Icons.store,
              color: isFlagship ? Colors.amber[700] : Colors.blue[700],
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (isFlagship) ...[
                      Icon(Icons.verified, color: Colors.amber[700], size: 14),
                      const SizedBox(width: 4),
                    ],
                    Expanded(
                      child: Text(
                        store.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: Colors.amber[700],
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${store.rating}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${store.distanceText} • ${store.openHours}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildLiveShopping() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Live Shopping',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildLiveShoppingCard('10.00 - 11.00 WIB')),
              const SizedBox(width: 12),
              Expanded(child: _buildLiveShoppingCard('18.00 - 19.00 WIB')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiveShoppingCard(String time) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[700]!, Colors.purple[900]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.live_tv, color: Colors.purple[700], size: 40),
          ),
          const SizedBox(height: 12),
          Text(
            time,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Segera Live',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
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
                  int quantity = 0; // quantity untuk setiap produk

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
                          // Product Image
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

                          // Product Info
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
                                            decoration: TextDecoration.lineThrough,
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

                          // Action Buttons (Favorite & Add to Cart)
                          Column(
                            children: [
                              // Favorite Button
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

                              // Add to Cart Button with Counter
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
                                                    // Update quantity di cart
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
                                                    // Remove dari cart
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
    List<Product>? products, // Tambahkan parameter ini
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          if (hasTimer)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red[400]!, Colors.red[600]!],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '00:45:32',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          else if (showSeeAll && products != null) // Modifikasi ini
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
      height: 280,
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
    int quantity = 0; // jumlah produk sementara

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
            width: 180,
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
                    Container(
                      height: 160,
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
                          height: 260,
                          width: 260,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // 🔵 Tombol tambah atau counter
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
                                        quantity = 1; // tampilkan counter
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
                                    width: 36,
                                    height: 36,
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
                                      size: 22,
                                    ),
                                  ),
                                )
                                : Container(
                                  key: const ValueKey('counter'),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
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
                                          size: 20,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        child: Text(
                                          '$quantity',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
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
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                      ),
                    ),
                  ],
                ),

                // --- BAGIAN INFORMASI PRODUK ---
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatPrice(product.price),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (product.originalPrice != null)
                            Text(
                              _formatPrice(product.originalPrice!),
                              style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (product.discountPercentage != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
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
                              fontSize: 11,
                            ),
                          ),
                        ),
                    ],
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
