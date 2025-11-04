import 'package:flutter/material.dart';
import 'package:indosemecb2b/screen/main_navigasi.dart';
import '../models/product_model.dart';
import '../services/favorite_service.dart';
import '../services/product_service.dart';
import '../utils/cart_manager.dart';
import '../utils/user_data_manager.dart';
import 'package:share_plus/share_plus.dart';
import '../models/koperasi_model.dart';
import '../services/koperasi_service.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  final Koperasi? userKoperasi; // ⭐ TAMBAH PARAMETER INI

  const ProductDetailPage({
    super.key,
    required this.product,
    this.userKoperasi,
  });

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

  Future<void> _loadSimilarProducts() async {
    // ⭐ AMBIL KOPERASI PRODUK INI
    final productKoperasi = await _getProductKoperasi();

    if (productKoperasi == null) {
      // Fallback: tampilkan produk serupa tanpa filter koperasi
      final allProducts = _productService.getProductsByCategory(
        widget.product.category,
      );
      final filtered =
          allProducts.where((p) => p.id != widget.product.id).toList();

      setState(() {
        similarProducts = filtered.take(8).toList();
      });
      return;
    }

    // ⭐ FILTER: Hanya produk dari koperasi yang sama
    final allProducts = _productService.getProductsByCategory(
      widget.product.category,
    );

    final filtered =
        allProducts.where((p) {
          // Exclude produk saat ini
          if (p.id == widget.product.id) return false;

          // ✅ HANYA produk dari koperasi yang sama
          return productKoperasi.productIds.contains(p.id);
        }).toList();

    print('🔍 [SIMILAR] Koperasi: ${productKoperasi.name}');
    print('🔍 [SIMILAR] Produk serupa dari koperasi ini: ${filtered.length}');

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

  Future<Koperasi?> _getProductKoperasi() async {
    // ⭐ PRIORITAS 1: Gunakan koperasi yang di-pass dari home
    if (widget.userKoperasi != null) {
      // Cek apakah koperasi ini punya produk ini
      if (widget.userKoperasi!.productIds.contains(widget.product.id)) {
        print(
          '✅ [DETAIL] Using koperasi from home: ${widget.userKoperasi!.name}',
        );
        return widget.userKoperasi;
      }
    }

    // ⭐ PRIORITAS 2: Fallback ke pencarian manual
    print(
      '⚠️ [DETAIL] User koperasi not provided or product not found, searching...',
    );
    final allKoperasi = KoperasiService.getAllKoperasi();

    for (var koperasi in allKoperasi) {
      if (koperasi.productIds.contains(widget.product.id)) {
        print('✅ [DETAIL] Found koperasi: ${koperasi.name}');
        return koperasi;
      }
    }

    print('❌ [DETAIL] No koperasi found for product ${widget.product.id}');
    return null;
  }

  void _showKoperasiDetail(Koperasi koperasi) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Buat transparan untuk custom shape
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white, // Background putih eksplisit
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.store, color: Colors.blue[700], size: 28),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          koperasi.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            SizedBox(width: 4),
                            Text(
                              '${koperasi.rating}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.grey[600], size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      koperasi.fullAddress,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
              if (koperasi.description != null) ...[
                SizedBox(height: 12),
                Text(
                  koperasi.description!,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
              SizedBox(height: 16),
              Text(
                koperasi.info,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
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
      price: _productService.getProductPrice(widget.product.id),
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

  void _navigateToCart() async {
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

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainNavigationWithCart()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ HITUNG HARGA FLASH SALE
    final displayPrice = _productService.getProductPrice(widget.product.id);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
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
                    // ✅ FIX 1: Share dengan harga flash sale
                    final sharePrice = _productService.getProductPrice(
                      product.id,
                    );

                    final productUrl =
                        "https://indosemecb2b.com/product/${product.id}";
                    final message =
                        "Lihat produk ini di IndoSemec!\n\n"
                        "${product.name}\n"
                        "Harga: Rp${sharePrice.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}\n\n"
                        "Link: $productUrl";

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

                  // ✅ FIX 2: Display harga utama dengan flash sale
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
                              'Rp${displayPrice.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                            if (widget.product.originalPrice != null) ...[
                              const SizedBox(width: 12),
                              Text(
                                'Rp${widget.product.originalPrice!.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}',
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

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: FutureBuilder<Koperasi?>(
                      future: _getProductKoperasi(),
                      builder: (context, snapshot) {
                        final koperasiName =
                            snapshot.data?.name ?? 'Koperasi Merah Putih';

                        return OutlinedButton.icon(
                          onPressed: () {
                            if (snapshot.data != null) {
                              _showKoperasiDetail(snapshot.data!);
                            }
                          },
                          icon: Icon(
                            Icons.store,
                            color: Colors.blue[600],
                            size: 18,
                          ),
                          label: Text(
                            koperasiName,
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
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

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
                          onTap: () {},
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

                  // ✅ FIX 3: Produk serupa dengan harga flash sale
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
                                final productPrice = _productService
                                    .getProductPrice(product.id);

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => ProductDetailPage(
                                              product: product,
                                              userKoperasi:
                                                  widget
                                                      .userKoperasi, // ⭐ PASS KE PRODUK SERUPA
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
                                          'Rp${productPrice.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}',
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

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

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
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  IconButton(
                    onPressed: _navigateToCart,
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

class MainNavigationWithCart extends StatefulWidget {
  const MainNavigationWithCart({Key? key}) : super(key: key);

  @override
  State<MainNavigationWithCart> createState() => _MainNavigationWithCartState();
}

class _MainNavigationWithCartState extends State<MainNavigationWithCart> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ini akan trigger setelah MainNavigation selesai build
    });
  }

  @override
  Widget build(BuildContext context) {
    return const MainNavigation(initialIndex: 1);
  }
}
