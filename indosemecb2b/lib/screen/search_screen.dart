import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../models/koperasi_model.dart';
import 'product_list_screen.dart';
import '../services/flash_sale_service.dart'; // ⭐ TAMBAHKAN INI

class SearchScreen extends StatefulWidget {
  final List<Koperasi>? nearbyKoperasi;

  const SearchScreen({Key? key, this.nearbyKoperasi}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();

  List<Product> allProducts = [];
  List<Product> searchResults = [];
  bool isSearching = false;

  final List<String> popularSearches = [
    'Beras',
    'Minyak Goreng',
    'Telur',
    'Buah Segar',
    'Sayuran',
    'Jamu',
    'Batik',
    'Madu',
    'Jasa Jahit',
    'Laundry',
    'Service AC',
  ];

  List<String> recentSearches = [];

  @override
  void initState() {
    super.initState();
    _loadFilteredProducts();
    _searchController.addListener(_onSearchChanged);
  }

  void _loadFilteredProducts() {
    print('🔍 [SEARCH] Loading filtered products...');

    final allAvailableProducts = _productService.getAllProducts();

    if (widget.nearbyKoperasi != null && widget.nearbyKoperasi!.isNotEmpty) {
      final Set<String> allowedProductIds = {};
      for (var koperasi in widget.nearbyKoperasi!) {
        allowedProductIds.addAll(koperasi.productIds);
      }

      allProducts =
          allAvailableProducts
              .where((p) => allowedProductIds.contains(p.id))
              .toList();

      print(
        '✅ [SEARCH] Filtered ${allProducts.length} products from ${widget.nearbyKoperasi!.length} koperasi',
      );
    } else {
      allProducts = allAvailableProducts;
      print(
        '⚠️ [SEARCH] No koperasi filter, showing all ${allProducts.length} products',
      );
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();

    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        isSearching = false;
      });
      return;
    }

    setState(() {
      isSearching = true;
      searchResults =
          allProducts
              .where(
                (product) =>
                    product.name.toLowerCase().contains(query) ||
                    product.category.toLowerCase().contains(query) ||
                    (product.description?.toLowerCase().contains(query) ??
                        false),
              )
              .toList();
    });
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;

    if (!recentSearches.contains(query)) {
      setState(() {
        recentSearches.insert(0, query);
        if (recentSearches.length > 5) {
          recentSearches.removeLast();
        }
      });
    }

    final results =
        allProducts
            .where(
              (product) =>
                  product.name.toLowerCase().contains(query.toLowerCase()) ||
                  product.category.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  (product.description?.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ??
                      false),
            )
            .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ProductListScreen(
              title: 'Hasil pencarian "$query"',
              products: results,
              nearbyKoperasi: widget.nearbyKoperasi ?? [],
            ),
      ),
    );
  }

  void _clearRecentSearches() {
    setState(() {
      recentSearches.clear();
    });
  }

  // ⭐ HELPER FUNCTION: Format Harga
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Cari produk UMKM...',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            searchResults = [];
                            isSearching = false;
                          });
                        },
                      )
                      : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onSubmitted: _performSearch,
          ),
        ),
      ),
      body:
          isSearching && searchResults.isNotEmpty
              ? _buildSearchResults()
              : isSearching && searchResults.isEmpty
              ? _buildNoResults()
              : _buildSearchSuggestions(),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final product = searchResults[index];
        return _buildProductSearchItem(product);
      },
    );
  }

  Widget _buildProductSearchItem(Product product) {
    // ⭐⭐⭐ CEK FLASH SALE STATUS ⭐⭐⭐
    final isFlashActive = FlashSaleService.isProductOnFlashSale(product.id);
    final flashDiscountPercent = FlashSaleService.getFlashDiscountPercentage(
      product.id,
    );

    // ⭐⭐⭐ HITUNG HARGA DINAMIS ⭐⭐⭐
    final originalPrice = product.originalPrice ?? product.price;
    double displayPrice;

    if (isFlashActive) {
      // Flash Sale AKTIF → gunakan harga flash sale
      displayPrice = FlashSaleService.calculateFlashPrice(
        product.id,
        originalPrice,
      );
    } else {
      // Flash Sale TIDAK AKTIF → gunakan harga normal produk
      displayPrice = product.price;
    }

    return InkWell(
      onTap: () => _performSearch(product.name),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ⭐ GAMBAR PRODUK
            Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.imageUrl ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.image,
                            color: Colors.grey[400],
                            size: 30,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                // ⭐ BADGE FLASH SALE (DINAMIS)
                if (isFlashActive)
                  Positioned(
                    top: 2,
                    left: 2,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red[600]!, Colors.red[800]!],
                        ),
                        borderRadius: BorderRadius.circular(4),
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
            
            SizedBox(width: 12),
            
            // ⭐ INFORMASI PRODUK
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Produk
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  
                  // Kategori
                  Text(
                    product.category,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 4),
                  
                  // ⭐⭐⭐ HARGA DINAMIS (FLASH SALE / NORMAL) ⭐⭐⭐
                  Row(
                    children: [
                      // Harga Utama
                      Text(
                        _formatPrice(displayPrice),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isFlashActive ? Colors.red[700] : Colors.blue[700],
                        ),
                      ),
                      
                      SizedBox(width: 6),
                      
                      // Harga Coret + Badge Diskon (jika ada)
                      if (isFlashActive && displayPrice < originalPrice) ...[
                        Text(
                          _formatPrice(originalPrice),
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey[400],
                            fontSize: 10,
                          ),
                        ),
                        SizedBox(width: 4),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red[600],
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            '-${flashDiscountPercent}%',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ] else if (!isFlashActive && product.discountPercentage != null) ...[
                        // Tampilkan diskon original jika flash sale berakhir
                        Text(
                          _formatPrice(originalPrice),
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey[400],
                            fontSize: 10,
                          ),
                        ),
                        SizedBox(width: 4),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
          SizedBox(height: 16),
          Text(
            'Produk tidak ditemukan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Coba kata kunci lain',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ⭐ INFO KOPERASI
          if (widget.nearbyKoperasi != null &&
              widget.nearbyKoperasi!.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.store, color: Colors.blue[700], size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mencari di: ${widget.nearbyKoperasi!.map((k) => k.name).join(", ")}',
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
          ],

          // Recent Searches
          if (recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pencarian Terakhir',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: _clearRecentSearches,
                  child: Text(
                    'Hapus Semua',
                    style: TextStyle(fontSize: 13, color: Colors.red[600]),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            ...recentSearches.map(
              (search) =>
                  _buildSearchItem(search, Icons.history, isRecent: true),
            ),
            SizedBox(height: 24),
          ],

          // Popular Searches
          Text(
            'Pencarian Populer',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                popularSearches.map((search) {
                  return GestureDetector(
                    onTap: () {
                      _searchController.text = search;
                      _performSearch(search);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey[300]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.trending_up,
                            size: 16,
                            color: Colors.blue[700],
                          ),
                          SizedBox(width: 6),
                          Text(
                            search,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),
          SizedBox(height: 24),

          // Categories Quick Access
          Text(
            'Cari Berdasarkan Kategori',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          _buildCategoryGrid(),
        ],
      ),
    );
  }

  Widget _buildSearchItem(String text, IconData icon, {bool isRecent = false}) {
    return InkWell(
      onTap: () {
        _searchController.text = text;
        _performSearch(text);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
            if (isRecent)
              GestureDetector(
                onTap: () {
                  setState(() {
                    recentSearches.remove(text);
                  });
                },
                child: Icon(Icons.close, size: 18, color: Colors.grey[400]),
              )
            else
              Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final categories = [
      {'name': 'Grocery', 'icon': Icons.shopping_bag, 'color': Colors.orange},
      {'name': 'Food', 'icon': Icons.restaurant, 'color': Colors.red},
      {'name': 'Fashion', 'icon': Icons.checkroom, 'color': Colors.purple},
      {'name': 'Pertanian', 'icon': Icons.agriculture, 'color': Colors.green},
      {'name': 'Herbal', 'icon': Icons.spa, 'color': Colors.teal},
      {'name': 'Kerajinan', 'icon': Icons.handyman, 'color': Colors.brown},
      {'name': 'Jasa', 'icon': Icons.build_circle, 'color': Colors.blue},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];

        final products =
            allProducts.where((p) => p.category == category['name']).toList();

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ProductListScreen(
                      title: category['name'] as String,
                      products: products,
                      nearbyKoperasi:
                          widget.nearbyKoperasi ?? [],
                    ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (category['color'] as Color).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    category['icon'] as IconData,
                    color: category['color'] as Color,
                    size: 28,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  category['name'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}