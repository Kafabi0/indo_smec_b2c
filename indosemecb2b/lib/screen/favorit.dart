import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../services/favorite_service.dart';
import '../utils/user_data_manager.dart'; // tambahkan import ini

class FavoritScreen extends StatefulWidget {
  const FavoritScreen({Key? key}) : super(key: key);

  @override
  State<FavoritScreen> createState() => _FavoritScreenState();
}

class _FavoritScreenState extends State<FavoritScreen> {
  final ProductService _productService = ProductService();
  final FavoriteService _favoriteService = FavoriteService();
  List<Product> favoriteProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteProducts();
  }

  Future<void> _loadFavoriteProducts() async {
    setState(() => isLoading = true);

    final favoriteIds = await _favoriteService.getAllFavoriteIds();
    final allProducts = _productService.getAllProducts();

    setState(() {
      favoriteProducts =
          allProducts
              .where((product) => favoriteIds.contains(product.id))
              .toList();
      isLoading = false;
    });
  }

  Future<void> _removeFavorite(String productId) async {
    await _favoriteService.removeFavorite(productId);
    await _loadFavoriteProducts();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dihapus dari favorit'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.orange[700],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: false,
        title: Text(
          'Semua Barang Favorit (${favoriteProducts.length})',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (favoriteProducts.isNotEmpty)
            TextButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: Text('Hapus Semua Favorit?'),
                        content: Text('Semua produk favorit akan dihapus.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(
                              'Hapus',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                );

                if (confirm == true) {
                  await _favoriteService.clearAllFavorites();
                  await _loadFavoriteProducts();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Semua favorit telah dihapus'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
              child: Text(
                'Hapus Semua',
                style: TextStyle(color: Colors.red[600]),
              ),
            ),
        ],
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : favoriteProducts.isEmpty
              ? _buildEmptyState()
              : _buildFavoriteList(),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_border_rounded,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 24),
              const Text(
                'Barang di Favorit Masih Kosong',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Cari barang yang kamu inginkan dan tambahkan ke Favorit.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Mulai Belanja',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: favoriteProducts.length,
      itemBuilder: (context, index) {
        return _buildFavoriteCard(favoriteProducts[index]);
      },
    );
  }

  Widget _buildFavoriteCard(Product product) {
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
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(Icons.image, size: 40, color: Colors.grey[400]),
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
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
                          fontSize: 15,
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

            // Actions
            Column(
              children: [
                // Remove from Favorite Button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.favorite, color: Colors.red, size: 20),
                    onPressed: () => _removeFavorite(product.id),
                  ),
                ),
                const SizedBox(height: 8),
                // Add to Cart Button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[700],
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.add_shopping_cart,
                      color: Colors.white,
                      size: 18,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${product.name} ditambahkan ke keranjang',
                          ),
                          duration: Duration(seconds: 1),
                          backgroundColor: Colors.green[600],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
