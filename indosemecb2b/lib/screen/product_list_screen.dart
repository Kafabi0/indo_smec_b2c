import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/koperasi_model.dart';
import '../services/favorite_service.dart';
import '../utils/cart_manager.dart';
import '../utils/user_data_manager.dart';
import 'detail_produk.dart';
import '../services/flash_sale_service.dart';
import '../services/product_service.dart';
import 'package:intl/intl.dart';

class ProductListScreen extends StatefulWidget {
  final String title;
  final List<Product> products;
  final List<Koperasi> nearbyKoperasi; // ⭐ TAMBAH PARAMETER INI

  const ProductListScreen({
    Key? key,
    required this.title,
    required this.products,
    this.nearbyKoperasi = const [], // ⭐ DEFAULT EMPTY LIST
  }) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final FavoriteService _favoriteService = FavoriteService();
  Map<String, bool> favoriteStatus = {};
  Map<String, int> cartQuantities = {};

  bool isGridView = true;
  String sortBy = 'default';
  List<Product> displayedProducts = [];
  final ProductService _productService = ProductService();

  @override
  void initState() {
    super.initState();
    print('📋 [LIST] ========== ProductListScreen initState ==========');
    print('📦 [LIST] Total products from parent: ${widget.products.length}');
    print('🏪 [LIST] Nearby koperasi count: ${widget.nearbyKoperasi.length}');

    // ⭐ FILTER PRODUK BERDASARKAN KOPERASI
    _filterProductsByKoperasi();

    _loadFavoriteStatus();
    _loadCartQuantities();
  }

  // ⭐ METHOD BARU: FILTER PRODUK BERDASARKAN KOPERASI
  void _filterProductsByKoperasi() {
    if (widget.nearbyKoperasi.isEmpty) {
      // Jika tidak ada koperasi, tampilkan semua produk
      print('⚠️ [LIST] No koperasi, showing all products');
      displayedProducts = List.from(widget.products);
    } else {
      // Kumpulkan semua productIds dari koperasi yang match
      final Set<String> allowedProductIds = {};
      for (var koperasi in widget.nearbyKoperasi) {
        allowedProductIds.addAll(koperasi.productIds);
      }

      print('📊 [LIST] Allowed product IDs: ${allowedProductIds.length}');

      // Filter produk
      displayedProducts =
          widget.products
              .where((p) => allowedProductIds.contains(p.id))
              .toList();

      print('✅ [LIST] Filtered products: ${displayedProducts.length}');

      // Debug: tampilkan info koperasi
      if (widget.nearbyKoperasi.isNotEmpty) {
        print('🏪 [LIST] Shopping from: ${widget.nearbyKoperasi.first.name}');
      }
    }
  }

  Future<void> _loadFavoriteStatus() async {
    final favoriteIds = await _favoriteService.getAllFavoriteIds();
    setState(() {
      for (var product in displayedProducts) {
        favoriteStatus[product.id] = favoriteIds.contains(product.id);
      }
    });
  }

  String formatRupiah(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  Future<void> _loadCartQuantities() async {
    for (var product in displayedProducts) {
      final quantity = await CartManager.getProductQuantity(product.id);
      setState(() {
        cartQuantities[product.id] = quantity;
      });
    }
  }

  Future<void> _toggleFavorite(String productId, String productName) async {
    final userLogin = await UserDataManager.getCurrentUserLogin();
    if (userLogin == null) {
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

  void _sortProducts(String sortType) {
    setState(() {
      sortBy = sortType;

      switch (sortType) {
        case 'price_asc':
          displayedProducts.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'price_desc':
          displayedProducts.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'rating':
          displayedProducts.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case 'newest':
          displayedProducts.sort((a, b) => b.id.compareTo(a.id));
          break;
        default:
          _filterProductsByKoperasi(); // Reset ke filter awal
      }
    });
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Urutkan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              _buildSortOption('Default', 'default'),
              _buildSortOption('Harga: Rendah ke Tinggi', 'price_asc'),
              _buildSortOption('Harga: Tinggi ke Rendah', 'price_desc'),
              _buildSortOption('Rating Tertinggi', 'rating'),
              _buildSortOption('Terbaru', 'newest'),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String label, String value) {
    final isSelected = sortBy == value;
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _sortProducts(value);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.blue[700] : Colors.black87,
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: Colors.blue[700], size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.search),
        //     onPressed: () {
        //       // TODO: Implement search
        //     },
        //   ),
        //   IconButton(
        //     icon: Icon(Icons.share),
        //     onPressed: () {
        //       // TODO: Implement share
        //     },
        //   ),
        // ],
      ),
      body: Column(
        children: [
          // ⭐ INFO KOPERASI (JIKA ADA)
          if (widget.nearbyKoperasi.isNotEmpty)
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.store, color: Colors.green[700], size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Belanja dari:',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green[600],
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          widget.nearbyKoperasi.first.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[700],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${displayedProducts.length} produk',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Header info & view toggle
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(
                  '${displayedProducts.length} Produk',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                Spacer(),
                TextButton.icon(
                  onPressed: _showSortBottomSheet,
                  icon: Icon(Icons.sort, size: 18),
                  label: Text('Urutkan'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    padding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => setState(() => isGridView = true),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                isGridView
                                    ? Colors.blue[700]
                                    : Colors.transparent,
                            borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(8),
                            ),
                          ),
                          child: Icon(
                            Icons.grid_view,
                            size: 20,
                            color: isGridView ? Colors.white : Colors.grey[600],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => setState(() => isGridView = false),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                !isGridView
                                    ? Colors.blue[700]
                                    : Colors.transparent,
                            borderRadius: BorderRadius.horizontal(
                              right: Radius.circular(8),
                            ),
                          ),
                          child: Icon(
                            Icons.view_list,
                            size: 20,
                            color:
                                !isGridView ? Colors.white : Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey[200]),

          // Product list/grid
          Expanded(
            child:
                displayedProducts.isEmpty
                    ? _buildEmptyState()
                    : (isGridView ? _buildGridView() : _buildListView()),
          ),
        ],
      ),
    );
  }

  // ⭐ TAMBAH EMPTY STATE
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'Tidak ada produk tersedia',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          if (widget.nearbyKoperasi.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Koperasi ${widget.nearbyKoperasi.first.name} belum memiliki produk di kategori ini',
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.51,
        crossAxisSpacing: 12,
        mainAxisSpacing: 8,
      ),
      itemCount: displayedProducts.length,
      itemBuilder: (context, index) {
        return _buildProductGridCard(displayedProducts[index]);
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: displayedProducts.length,
      itemBuilder: (context, index) {
        return _buildProductListCard(displayedProducts[index]);
      },
    );
  }

  Widget _buildProductGridCard(Product product) {
  final isFavorite = favoriteStatus[product.id] ?? false;
  final quantity = cartQuantities[product.id] ?? 0;

  // ⭐ CEK FLASH SALE STATUS
  final isFlashSaleActive = FlashSaleService.isProductOnFlashSale(product.id);
  final flashDiscountPercent = FlashSaleService.getFlashDiscountPercentage(product.id);
  
  // ⭐ HITUNG HARGA REAL-TIME
  final displayPrice = _productService.getProductPrice(product.id);
  final originalPrice = product.originalPrice ?? product.price;
  
  // ⭐ TENTUKAN DISKON YANG DITAMPILKAN
  final discountToShow = isFlashSaleActive ? flashDiscountPercent : product.discountPercentage;

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailPage(
            product: product,
            userKoperasi: widget.nearbyKoperasi.isNotEmpty
                ? widget.nearbyKoperasi.first
                : null,
          ),
        ),
      );
    },
    child: Container(
      
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 185,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Image.network(
                    product.imageUrl ?? '',
                    height: 185,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              // ⭐ BADGE FLASH SALE
              if (isFlashSaleActive)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_fire_department, color: Colors.white, size: 10),
                        SizedBox(width: 2),
                        Text(
                          'FLASH',
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
              
              Positioned(
                top: 8,
                right: 8,
                child: _buildAddButton(product, quantity),
              ),
            ],
          ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, color: Colors.amber[700], size: 12),
                      SizedBox(width: 2),
                      Text(
                        '${product.rating}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(width: 2),
                      Text(
                        '(${product.reviewCount})',
                        style: TextStyle(fontSize: 9, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  
                  // ⭐ HARGA DENGAN FLASH SALE
                  Text(
                    formatRupiah(displayPrice),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isFlashSaleActive ? Colors.red[700] : Colors.blue[700],
                    ),
                  ),
                  
                  if (discountToShow != null) ...[
                    SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          formatRupiah(originalPrice),
                          style: TextStyle(
                            fontSize: 10,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey[400],
                          ),
                        ),
                        SizedBox(width: 4),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: isFlashSaleActive ? Colors.red : Colors.blue[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '$discountToShow%',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isFlashSaleActive ? Colors.white : Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildProductListCard(Product product) {
  final isFavorite = favoriteStatus[product.id] ?? false;
  final quantity = cartQuantities[product.id] ?? 0;

  // ⭐ CEK FLASH SALE STATUS
  final isFlashSaleActive = FlashSaleService.isProductOnFlashSale(product.id);
  final flashDiscountPercent = FlashSaleService.getFlashDiscountPercentage(product.id);
  
  // ⭐ HITUNG HARGA REAL-TIME
  final displayPrice = _productService.getProductPrice(product.id);
  final originalPrice = product.originalPrice ?? product.price;
  
  // ⭐ TENTUKAN DISKON YANG DITAMPILKAN
  final discountToShow = isFlashSaleActive ? flashDiscountPercent : product.discountPercentage;

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailPage(
            product: product,
            userKoperasi: widget.nearbyKoperasi.isNotEmpty
                ? widget.nearbyKoperasi.first
                : null,
          ),
        ),
      );
    },
    child: Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
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
          Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(product.imageUrl ?? '', fit: BoxFit.cover),
                ),
              ),
              
              // ⭐ BADGE FLASH SALE
              if (isFlashSaleActive)
                Positioned(
                  top: 4,
                  left: 4,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_fire_department, color: Colors.white, size: 8),
                        SizedBox(width: 1),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star_rounded, color: Colors.amber[700], size: 12),
                    SizedBox(width: 2),
                    Text(
                      '${product.rating}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '(${product.reviewCount})',
                      style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                
                // ⭐ HARGA DENGAN FLASH SALE
                Text(
                  formatRupiah(displayPrice),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isFlashSaleActive ? Colors.red[700] : Colors.blue[700],
                  ),
                ),
                
                if (discountToShow != null) ...[
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        formatRupiah(originalPrice),
                        style: TextStyle(
                          fontSize: 11,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey[400],
                        ),
                      ),
                      SizedBox(width: 6),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isFlashSaleActive ? Colors.red : Colors.blue[50],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isFlashSaleActive) ...[
                              Icon(Icons.local_fire_department, color: Colors.white, size: 8),
                              SizedBox(width: 2),
                            ],
                            Text(
                              '$discountToShow%',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isFlashSaleActive ? Colors.white : Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Column(
            children: [
              GestureDetector(
                onTap: () => _toggleFavorite(product.id, product.name),
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isFavorite ? Colors.red[50] : Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey[600],
                    size: 18,
                  ),
                ),
              ),
              SizedBox(height: 8),
              _buildAddButton(product, quantity),
            ],
          ),
        ],
      ),
    ),
  );
}

  Widget _buildAddButton(Product product, int quantity) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 200),
      transitionBuilder:
          (child, animation) => ScaleTransition(scale: animation, child: child),
      child:
          quantity == 0
              ? GestureDetector(
                key: ValueKey('addButton'),
                onTap: () async {
                  final userLogin = await UserDataManager.getCurrentUserLogin();
                  if (userLogin == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Silakan login terlebih dahulu'),
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
                    discountPercentage: product.discountPercentage,
                    imageUrl: product.imageUrl,
                    category: product.category,
                  );

                  if (success) {
                    setState(() {
                      cartQuantities[product.id] = 1;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${product.name} ditambahkan ke keranjang',
                        ),
                        backgroundColor: Colors.green,
                        duration: Duration(milliseconds: 1500),
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
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(Icons.add, color: Colors.white, size: 20),
                ),
              )
              : Container(
                key: ValueKey('counter'),
                padding: EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: Colors.blue[700],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        if (quantity > 1) {
                          final success = await CartManager.updateQuantity(
                            product.id,
                            quantity - 1,
                          );
                          if (success) {
                            setState(() {
                              cartQuantities[product.id] = quantity - 1;
                            });
                          }
                        } else {
                          final success = await CartManager.removeFromCart(
                            product.id,
                          );
                          if (success) {
                            setState(() {
                              cartQuantities[product.id] = 0;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${product.name} dihapus dari keranjang',
                                ),
                                backgroundColor: Colors.orange[700],
                                duration: Duration(milliseconds: 1500),
                              ),
                            );
                          }
                        }
                      },
                      child: Icon(Icons.remove, color: Colors.white, size: 16),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        '$quantity',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final success = await CartManager.addToCart(
                          productId: product.id,
                          name: product.name,
                          price: product.price,
                          originalPrice: product.originalPrice,
                          discountPercentage: product.discountPercentage,
                          imageUrl: product.imageUrl,
                          category: product.category,
                        );

                        if (success) {
                          setState(() {
                            cartQuantities[product.id] = quantity + 1;
                          });
                        }
                      },
                      child: Icon(Icons.add, color: Colors.white, size: 16),
                    ),
                  ],
                ),
              ),
    );
  }
}
