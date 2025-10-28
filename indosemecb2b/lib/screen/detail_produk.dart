import 'package:flutter/material.dart';
import 'package:indosemecb2b/screen/keranjang.dart';
import '../models/product_model.dart';
import '../services/favorite_service.dart';
import '../services/product_service.dart';
import '../utils/cart_manager.dart';
import '../utils/user_data_manager.dart';
import 'package:share_plus/share_plus.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  bool isFavorite = false;
  int quantity = 0;
  final FavoriteService _favoriteService = FavoriteService();
  final ProductService _productService = ProductService();
  List<Product> similarProducts = [];

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
    _loadCartQuantity();
    _loadSimilarProducts();
  }

  void _loadSimilarProducts() {
    // Ambil produk dari kategori yang sama
    final allProducts = _productService.getProductsByCategory(
      widget.product.category,
    );

    // Filter: hapus produk saat ini dari list
    final filtered =
        allProducts.where((p) => p.id != widget.product.id).toList();

    // Ambil maksimal 8 produk
    setState(() {
      similarProducts = filtered.take(8).toList();
    });
  }

  Future<void> _loadFavoriteStatus() async {
    final status = await _favoriteService.isFavorite(widget.product.id);
    if (mounted) {
      setState(() {
        isFavorite = status;
      });
    }
  }

  Future<void> _loadCartQuantity() async {
    final qty = await CartManager.getProductQuantity(widget.product.id);
    if (mounted) {
      setState(() {
        quantity = qty;
      });
    }
  }

  Future<void> _addToCart() async {
    final userLogin = await UserDataManager.getCurrentUserLogin();
    if (userLogin == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan login terlebih dahulu'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    final success = await CartManager.addToCart(
      productId: widget.product.id,
      name: widget.product.name,
      price: widget.product.price,
      originalPrice: widget.product.originalPrice,
      discountPercentage: widget.product.discountPercentage,
      imageUrl: widget.product.imageUrl,
    );

    if (success) {
      await _loadCartQuantity();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${widget.product.name} ditambahkan ke keranjang',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(milliseconds: 1500),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menambahkan ke keranjang'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar dengan gambar produk
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              // Tombol Favorite
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.black87,
                  ),
                  onPressed: () async {
                    final userLogin =
                        await UserDataManager.getCurrentUserLogin();
                    if (userLogin == null) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Anda harus login terlebih dahulu untuk menyimpan favorit.',
                            ),
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                      return;
                    }

                    final newStatus = await _favoriteService.toggleFavorite(
                      widget.product.id,
                    );
                    if (mounted) {
                      setState(() {
                        isFavorite = newStatus;
                      });
                    }

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            newStatus
                                ? '${widget.product.name} ditambahkan ke favorit'
                                : '${widget.product.name} dihapus dari favorit',
                          ),
                          duration: const Duration(seconds: 1),
                          backgroundColor:
                              newStatus
                                  ? Colors.green[600]
                                  : Colors.orange[700],
                        ),
                      );
                    }
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.share, color: Colors.black87),
                  onPressed: () async {
                    final product = widget.product;

                    // ✅ Buat link produk (kamu bisa ganti sesuai format link sebenarnya)
                    final productUrl =
                        "https://indosemecb2b.com/product/${product.id}";
                    final message =
                        "Lihat produk ini di IndoSemec!\n\n"
                        "${product.name}\n"
                        "Harga: Rp${product.price.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}\n\n"
                        "Link: $productUrl";

                    // ✅ Gunakan Share.share() untuk membuka menu share
                    await Share.share(message, subject: product.name);
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.grey[200]!, Colors.grey[100]!],
                  ),
                ),
                child:
                    widget.product.imageUrl != null
                        ? Image.network(
                          widget.product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.image,
                                size: 100,
                                color: Colors.grey[400],
                              ),
                            );
                          },
                        )
                        : Icon(Icons.image, size: 100, color: Colors.grey[400]),
              ),
            ),
          ),

          // Konten produk
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Nama & Harga
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              'Rp.${widget.product.price.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                            if (widget.product.originalPrice != null) ...[
                              const SizedBox(width: 12),
                              Text(
                                'Rp.${widget.product.originalPrice!.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}',
                                style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (widget.product.discountPercentage != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${widget.product.discountPercentage}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tombol Cari Toko
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Implementasi cari toko
                      },
                      // icon: Icon(
                      //   Icons.location_on_outlined,
                      //   color: Colors.blue[600],
                      //   size: 20,
                      // ),
                      label: Text(
                        'Koperasi Merah Putih',
                        style: TextStyle(
                          color: Colors.blue[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        side: BorderSide(color: Colors.blue[600]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Deskripsi Produk
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Deskripsi Produk',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.product.description ??
                              'Diformulasikan secara khusus untuk membersihkan perlengkapan bayi dengan bahan 100% food grade dan alami, yaitu dari ekstrak jagung dan kelapa sehingga aman untuk bayi...',
                          style: const TextStyle(
                            color: Colors.black87,
                            height: 1.5,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            // Implementasi lihat selengkapnya
                          },
                          child: Text(
                            'Selengkapnya',
                            style: TextStyle(
                              color: Colors.blue[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Produk Serupa
                  if (similarProducts.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Produk Serupa',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 220,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: similarProducts.length,
                              itemBuilder: (context, index) {
                                final product = similarProducts[index];
                                return GestureDetector(
                                  onTap: () {
                                    // Navigate ke detail produk yang diklik
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => ProductDetailPage(
                                              product: product,
                                            ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 140,
                                    margin: const EdgeInsets.only(right: 12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Stack(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child:
                                                      product.imageUrl != null
                                                          ? Image.network(
                                                            product.imageUrl!,
                                                            width:
                                                                double.infinity,
                                                            height:
                                                                double.infinity,
                                                            fit: BoxFit.cover,
                                                            errorBuilder: (
                                                              context,
                                                              error,
                                                              stackTrace,
                                                            ) {
                                                              return Center(
                                                                child: Icon(
                                                                  Icons.image,
                                                                  size: 40,
                                                                  color:
                                                                      Colors
                                                                          .grey[400],
                                                                ),
                                                              );
                                                            },
                                                          )
                                                          : Center(
                                                            child: Icon(
                                                              Icons.image,
                                                              size: 40,
                                                              color:
                                                                  Colors
                                                                      .grey[400],
                                                            ),
                                                          ),
                                                ),
                                                if (product
                                                        .discountPercentage !=
                                                    null)
                                                  Positioned(
                                                    top: 8,
                                                    left: 8,
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 6,
                                                            vertical: 2,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.red,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        '${product.discountPercentage}%',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          product.name,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Rp${product.price.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.blue[700],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (product.originalPrice != null)
                                          Text(
                                            'Rp${product.originalPrice!.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}',
                                            style: const TextStyle(
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              color: Colors.grey,
                                              fontSize: 10,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 100), // Space for bottom buttons
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Tombol Keranjang (Icon saja) - Menampilkan badge quantity
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder:
                      //         (context) => CartScreen(),
                      //   ),
                      // );
                    },
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.black87,
                    ),
                  ),
                  if (quantity > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Center(
                          child: Text(
                            '$quantity',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Tombol Keranjang dengan text
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _addToCart,
                icon: const Icon(Icons.add, size: 18),
                label: Text(
                  quantity > 0
                      ? 'Tambah Lagi ($quantity)'
                      : 'Tambah ke Keranjang',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
