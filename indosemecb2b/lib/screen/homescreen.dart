import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/store_model.dart';
import '../models/subcategory_model.dart';
import '../services/product_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductService _productService = ProductService();
  
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
    _loadData();
  }

  void _loadData() {
    // Load data sesuai kategori yang dipilih
    if (selectedCategory == 'Semua') {
      displayedProducts = _productService.getAllProducts();
    } else {
      displayedProducts = _productService.getProductsByCategory(selectedCategory);
    }
    
    flashSaleProducts = _productService.getFlashSaleProducts();
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
      selectedSubCategory = null; // Reset sub-kategori saat kategori berubah
      showCategoryFilter = false;
      _loadData(); // Reload data dengan kategori baru
    });
  }

  void _onSubCategorySelected(String subCategory) {
    setState(() {
      selectedSubCategory = subCategory;
      
      // Filter produk berdasarkan sub-kategori yang dipilih
      if (subCategory == 'Buah') {
        displayedProducts = _productService.getFruitProducts();
      } else if (subCategory == 'Sayuran Organik') {
        displayedProducts = _productService.getVegetableProducts();
      } else {
        // Untuk sub-kategori lain, gunakan filter umum
        displayedProducts = _productService.getProductsBySubCategory(subCategory);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tentukan apakah menampilkan layout default atau layout kategori
    bool isDefaultLayout = selectedCategory == 'Semua';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Modern Top Header
            _buildHeader(),

            // Category Filter Dropdown
            if (showCategoryFilter) _buildCategoryFilter(),

            const SizedBox(height: 8),

            // Login Area
            _buildLoginArea(),

            const SizedBox(height: 8),

            // CONDITIONAL CONTENT - Berubah berdasarkan kategori
            if (isDefaultLayout) ...[
              // TAMPILAN DEFAULT (Semua)
              _buildDeliveryOptions(),
              const SizedBox(height: 16),
              _buildLoyaltyPoints(),
              const SizedBox(height: 20),
              _buildSectionHeader('FLASH SALE 11.00 - 13.00', hasTimer: true),
              _buildFlashSaleSection(),
              const SizedBox(height: 20),
              _buildPromoBanner(),
              const SizedBox(height: 20),
              _buildSectionHeader('Promosi Khusus Anda'),
              _buildProductGrid(displayedProducts.take(6).toList()),
              const SizedBox(height: 20),
              _buildSectionHeader('Produk Rating Tertinggi'),
              _buildProductGrid(topRatedProducts),
              const SizedBox(height: 20),
              _buildSectionHeader('Produk Segar'),
              _buildProductGrid(freshProducts),
              const SizedBox(height: 20),
              _buildSectionHeader('Produk Terbaru'),
              _buildProductGrid(newestProducts),
              const SizedBox(height: 20),
              _buildSectionHeader('Buah & Sayur'),
              _buildProductGrid(fruitAndVeggies),
            ] else ...[
              // TAMPILAN KATEGORI SPESIFIK (Food, Grocery, dll)
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
              _buildSectionHeader('Rekomendasi Khusus Untukmu', showSeeAll: false),
              _buildRecommendationList(displayedProducts),
            ],

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // ============ HEADER & COMMON WIDGETS ============
  
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
                  // Category Selector
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showCategoryFilter = !showCategoryFilter;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.apps_rounded, color: Colors.white, size: 20),
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
                          Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ),
                  // App Title
                  Text(
                    'IndoSmec',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  // Notification Icon
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                  ),
                ],
              ),
            ),
            
            // Search Bar
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
                    prefixIcon: Icon(Icons.search_rounded, color: Colors.blue[700], size: 24),
                    suffixIcon: Icon(Icons.qr_code_scanner_rounded, color: Colors.grey[400], size: 24),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
            children: categories.map((category) {
              bool isSelected = selectedCategory == category['name'];
              return GestureDetector(
                onTap: () => _onCategorySelected(category['name'] as String),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(colors: [Colors.blue[600]!, Colors.blue[700]!])
                        : null,
                    color: isSelected ? null : Colors.grey[100],
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: isSelected
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
                          color: isSelected ? Colors.white : Colors.grey[800],
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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
          Text('Login dulu yuk!',
              style: TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(width: 4),
          Text('|', style: TextStyle(color: Colors.grey[400], fontSize: 15)),
          const SizedBox(width: 4),
          Text('Area Antapani Kidul',
              style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey[600], size: 18),
          Spacer(),
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
            child: Icon(Icons.help_outline_rounded, color: Colors.grey[600], size: 16),
          ),
        ],
      ),
    );
  }

  // ============ DEFAULT LAYOUT WIDGETS (Semua) ============

  Widget _buildDeliveryOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildDeliveryOption(
            isSelected: isXpressSelected,
            icon: Icons.flash_on_rounded,
            title: 'Belanja Xpress',
            subtitle: '1 Jam Sampai',
            colors: [Colors.orange[400]!, Colors.deepOrange[500]!],
            onTap: () => setState(() => isXpressSelected = true),
          ),
          const SizedBox(width: 12),
          _buildDeliveryOption(
            isSelected: !isXpressSelected,
            icon: Icons.inventory_2_rounded,
            title: 'Belanja Xtra',
            subtitle: 'Banyak & Beragam',
            colors: [Colors.green[400]!, Colors.green[600]!],
            onTap: () => setState(() => isXpressSelected = false),
          ),
        ],
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
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: isSelected ? LinearGradient(colors: colors) : null,
            color: isSelected ? null : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? colors[0].withOpacity(0.3)
                    : Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.2) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon,
                    color: isSelected ? Colors.white : Colors.grey[700], size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white.withOpacity(0.9)
                            : Colors.grey[600],
                        fontSize: 11,
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
                  _buildPointCard(Icons.emoji_events_rounded, 'Poin UMKM', '0', Colors.orange),
                  Container(width: 1, height: 30, color: Colors.grey[200]),
                  _buildPointCard(Icons.account_balance_wallet_rounded, 'Poin Cash', '0', Colors.amber),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.blue[600]!, Colors.blue[700]!]),
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
                    Text('i.saku',
                        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 10)),
                    Text('Hubungkan',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointCard(IconData icon, String label, String value, Color color) {
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
            Text(value,
                style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildFlashSaleSection() {
    return Container(
      height: 200,
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
    return Container(
      width: 140,
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
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.grey[200]!, Colors.grey[100]!]),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Center(
              child: Icon(Icons.image_rounded, size: 50, color: Colors.grey[400]),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${product.discountPercentage}% OFF',
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp${product.price.toInt()}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.blue[700],
                    ),
                  ),
                  if (product.originalPrice != null)
                    Text(
                      'Rp${product.originalPrice!.toInt()}',
                      style: TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey[500],
                        fontSize: 11,
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
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

  // ============ CATEGORY LAYOUT WIDGETS (Food, Grocery, dll) ============

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
              // Tambah indikator untuk sub-kategori yang dipilih
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
                          color: isSelected ? Colors.white : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isSelected ? [
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
                          ] : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                          border: isSelected 
                            ? Border.all(color: Colors.blue[700]!, width: 2)
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
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
          // Flagship Store (if exists)
          if (flagshipStore != null) ...[
            _buildStoreCard(flagshipStore!, isFlagship: true),
            const SizedBox(height: 12),
          ],
          // Other stores (limit 3)
          ...categoryStores
              .where((s) => !s.isFlagship)
              .take(3)
              .map((store) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildStoreCard(store),
                  ))
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
        border: isFlagship
            ? Border.all(color: Colors.amber[600]!, width: 2)
            : null,
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
                    Icon(Icons.star_rounded, color: Colors.amber[700], size: 14),
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
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
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
        children: products.take(5).map((product) {
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
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(Icons.image, size: 35, color: Colors.grey[400]),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Product Info
                  Expanded(
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
                        Text(
                          'Rp${product.price.toInt()}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Add Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue[700],
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.add, color: Colors.white, size: 18),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} ditambahkan ke keranjang'),
                            duration: Duration(seconds: 1),
                            backgroundColor: Colors.green[600],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ============ SHARED WIDGETS ============

  Widget _buildSectionHeader(String title, {bool hasTimer = false, bool showSeeAll = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          if (hasTimer)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.red[400]!, Colors.red[600]!]),
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
                  Icon(Icons.access_time_rounded, color: Colors.white, size: 14),
                  const SizedBox(width: 6),
                  Text('00:45:32',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          else if (showSeeAll)
            TextButton(
              onPressed: () {},
              child: Text('Lihat Semua',
                  style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.w600)),
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
    return Container(
      width: 180,
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
          Stack(
            children: [
              Container(
                height: 160,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.grey[200]!, Colors.grey[100]!]),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Center(
                  child: Icon(Icons.image_rounded, size: 60, color: Colors.grey[400]),
                ),
              ),
              if (product.discountPercentage != null)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.green[400]!, Colors.green[600]!]),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.4),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      '${product.discountPercentage}%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(Icons.favorite_border_rounded, color: Colors.grey[600], size: 18),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star_rounded, color: Colors.amber[700], size: 16),
                    const SizedBox(width: 4),
                    Text(
                      product.rating.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${product.reviewCount})',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Rp${product.price.toInt()}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue[700],
                      ),
                    ),
                    if (product.originalPrice != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        'Rp${product.originalPrice!.toInt()}',
                        style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}