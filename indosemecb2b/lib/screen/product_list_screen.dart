import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/favorite_service.dart';
import '../utils/cart_manager.dart';
import '../utils/user_data_manager.dart';
import 'detail_produk.dart';
import 'package:intl/intl.dart';

class ProductListScreen extends StatefulWidget {
  final String title;
  final List<Product> products;

  const ProductListScreen({
    Key? key,
    required this.title,
    required this.products,
  }) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final FavoriteService _favoriteService = FavoriteService();
  Map<String, bool> favoriteStatus = {};
  Map<String, int> cartQuantities = {};

  bool isGridView = true; // true = grid, false = list
  String sortBy = 'default'; // default, price_asc, price_desc, rating, newest
  List<Product> displayedProducts = [];

  @override
  void initState() {
    super.initState();
    displayedProducts = List.from(widget.products);
    _loadFavoriteStatus();
    _loadCartQuantities();
  }

  Future<void> _loadFavoriteStatus() async {
    final favoriteIds = await _favoriteService.getAllFavoriteIds();
    setState(() {
      for (var product in widget.products) {
        favoriteStatus[product.id] = favoriteIds.contains(product.id);
      }
    });
  }

  String formatRupiah(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp.',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  Future<void> _loadCartQuantities() async {
    // Load cart quantities for all products
    for (var product in widget.products) {
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
          displayedProducts = List.from(widget.products);
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
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share
            },
          ),
        ],
      ),
      body: Column(
        children: [
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
                TextButton.icon(
                  onPressed: () {
                    // TODO: Implement filter
                  },
                  icon: Icon(Icons.filter_list, size: 18),
                  label: Text('Filter'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    padding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
                SizedBox(width: 8),
                // View toggle buttons
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
          Expanded(child: isGridView ? _buildGridView() : _buildListView()),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.60,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with favorite button
            Stack(
              children: [
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
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
                // Add/Counter button
                Positioned(
                  top: 8,
                  right: 8,
                  child: _buildAddButton(product, quantity),
                ),
              ],
            ),

            // Product info
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

                    // Rating - TAMBAHKAN INI
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: Colors.amber[700],
                          size: 12,
                        ),
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
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 4),
                    Text(
                      formatRupiah(product.price),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (product.originalPrice != null) ...[
                      SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            formatRupiah(product.originalPrice!),
                            style: TextStyle(
                              fontSize: 10,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey[400],
                            ),
                          ),
                          SizedBox(width: 4),
                          if (product.discountPercentage != null)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${product.discountPercentage}%',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
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
            // Product image
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
            SizedBox(width: 12),

            // Product info
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

                  // Rating - TAMBAHKAN INI
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: Colors.amber[700],
                        size: 12,
                      ),
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
                  Text(
                    'Rp${product.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (product.originalPrice != null) ...[
                    SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          'Rp${product.originalPrice!.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 11,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey[400],
                          ),
                        ),
                        SizedBox(width: 6),
                        if (product.discountPercentage != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${product.discountPercentage}%',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Favorite & Add buttons
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
                          // Update quantity di cart
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
                          // Remove dari cart
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
