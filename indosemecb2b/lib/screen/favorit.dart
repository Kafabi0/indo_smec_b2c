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
  final TextEditingController _searchController = TextEditingController();

  List<Product> favoriteProducts = [];
  List<Product> filteredProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteProducts();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredProducts =
          favoriteProducts
              .where((p) => p.name.toLowerCase().contains(query))
              .toList();
    });
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
              : _buildFavoriteContent(),
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

  Widget _buildFavoriteContent() {
    return Column(
      children: [
        // 🔹 Search Bar dengan tombol X
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari di Barang Favoritmu',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            filteredProducts = favoriteProducts;
                          });
                        },
                      )
                      : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            onChanged: (value) => _onSearchChanged(),
          ),
        ),
        const SizedBox(height: 6),

        // 🔹 Daftar Produk Favorit
        Expanded(child: _buildFavoriteList()),
      ],
    );
  }

  // 🔹 Tampilan grid dua kolom
  Widget _buildFavoriteList() {
    final displayList =
        _searchController.text.isEmpty ? favoriteProducts : filteredProducts;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: GridView.builder(
        itemCount: displayList.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.68,
        ),
        itemBuilder: (context, index) {
          final product = displayList[index];
          return _buildFavoriteCard(product);
        },
      ),
    );
  }

  // 🔹 Kartu produk gaya e-commerce
  Widget _buildFavoriteCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔸 Gambar produk
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: Container(
                    color: Colors.grey[200],
                    width: double.infinity,
                    child: Image.network(
                      product.imageUrl ?? '',
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => const Icon(
                            Icons.image,
                            size: 60,
                            color: Colors.grey,
                          ),
                    ),
                  ),
                ),
              ),

              // 🔸 Informasi produk
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp${product.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    if (product.originalPrice != null &&
                        product.originalPrice! > product.price) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            'Rp${product.originalPrice!.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${(((product.originalPrice! - product.price) / product.originalPrice!) * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // 🔸 Tombol favorit (hati)
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: () => _removeFavorite(product.id),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite, color: Colors.red, size: 18),
              ),
            ),
          ),

          // 🔸 Tombol tambah (+)
          Positioned(
            top: 6,
            right: 36,
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.name} ditambahkan ke keranjang'),
                    duration: const Duration(seconds: 1),
                    backgroundColor: Colors.green[600],
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
