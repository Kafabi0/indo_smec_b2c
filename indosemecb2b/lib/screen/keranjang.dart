// screen/keranjang.dart
import 'package:flutter/material.dart';
import 'package:indosemecb2b/screen/favorit.dart';
import 'package:indosemecb2b/screen/lengkapi_alamat_screen.dart';
import 'package:indosemecb2b/screen/main_navigasi.dart';
import 'package:indosemecb2b/utils/user_data_manager.dart'; // versi baru yang support email / no HP

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedDelivery = 'xpress';

  Map<String, dynamic>? _savedAlamat;
  String? _currentUserLogin; // <- sekarang ini bisa email atau no hp
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // ambil identifier user (email atau nomor hp)
    final userLogin = await UserDataManager.getCurrentUserLogin();

    if (userLogin != null) {
      final alamat = await UserDataManager.getAlamat(userLogin);

      setState(() {
        _currentUserLogin = userLogin;
        _savedAlamat = alamat;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _navigateToLengkapiAlamat() async {
    if (_currentUserLogin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan login terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => LengkapiAlamatScreen(existingAddress: _savedAlamat),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      final saved = await UserDataManager.saveAlamat(
        _currentUserLogin!,
        result,
      );

      if (saved) {
        setState(() {
          _savedAlamat = result;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Alamat berhasil disimpan'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal menyimpan alamat'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Keranjang Belanja',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_sharp, color: Colors.grey[700]),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoritScreen()),
              );
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // Tabs
                  Container(
                    color: Colors.white,
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.blue[700],
                      unselectedLabelColor: Colors.grey[600],
                      indicatorColor: Colors.blue[700],
                      indicatorWeight: 3,
                      labelStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      tabs: const [Tab(text: 'Grocery'), Tab(text: 'Food')],
                    ),
                  ),

                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Grocery Tab
                        _buildGroceryTab(),
                        // Food Tab
                        const Center(child: Text('Food Tab Content')),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildGroceryTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Alamat Pengiriman Section (Conditional)
          _buildAlamatPengirimanSection(),

          const SizedBox(height: 24),

          // Delivery Options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(80),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDelivery = 'xpress';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              selectedDelivery == 'xpress'
                                  ? Colors.orange[400]
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(80),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.flash_on,
                              color:
                                  selectedDelivery == 'xpress'
                                      ? Colors.white
                                      : Colors.grey[600],
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Belanja Xpress',
                              style: TextStyle(
                                color:
                                    selectedDelivery == 'xpress'
                                        ? Colors.white
                                        : Colors.grey[600],
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDelivery = 'xtra';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              selectedDelivery == 'xtra'
                                  ? Colors.green[400]
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(80),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              color:
                                  selectedDelivery == 'xtra'
                                      ? Colors.white
                                      : Colors.grey[600],
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Belanja Xtra',
                              style: TextStyle(
                                color:
                                    selectedDelivery == 'xtra'
                                        ? Colors.white
                                        : Colors.grey[600],
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Promo Banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[700]!, Colors.blue[400]!],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hadiah dan Tebus Murah',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Tambah ',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 8,
                              ),
                            ),
                            const Text(
                              'Rp7.900',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              ' untuk dapat promo',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 8,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.shopping_basket,
                  color: Colors.white,
                  size: 50,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Empty Cart
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.shopping_basket_outlined,
                        size: 50,
                        color: Colors.blue[300],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Keranjang belanjamu masih \nkosong',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Yuk, isi dengan barang-barang menarik dari Klik Indomaret.',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainNavigation(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Mulai Berbelanja !',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Promo Fair Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Promo Fair',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Lihat Semua',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Promo Cards
                SizedBox(
                  height: 250,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildPromoCard(
                        context,
                        title: 'New Member Bu Krim',
                        description:
                            'Khusus Member Baru setiap pembelian produk Bu Krim, Total...',
                        tag: 'Pengguna Baru',
                      ),
                      _buildPromoCard(
                        context,
                        title: 'New Member Personal Care Wings',
                        description:
                            'Khusus Member Baru setiap pembelian produk Wings personal...',
                        tag: 'Pengguna Baru',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk Alamat Pengiriman (Conditional)
  Widget _buildAlamatPengirimanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Alamat Pengiriman',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              if (_savedAlamat != null)
                TextButton(
                  onPressed: _navigateToLengkapiAlamat,
                  child: Text(
                    'Ubah Alamat',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Conditional Display
        _savedAlamat == null ? _buildBelumAdaAlamat() : _buildSudahAdaAlamat(),
      ],
    );
  }

  // UI ketika belum ada alamat
  Widget _buildBelumAdaAlamat() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.blue[700], size: 25),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Area Antapani Kidul',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kami membutuhkan lokasimu untuk menentukan\nstok produk dan alamat pengiriman.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _navigateToLengkapiAlamat,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit, size: 18, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Lengkapi Alamat',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

  // UI ketika sudah ada alamat
  Widget _buildSudahAdaAlamat() {
    return Column(
      children: [
        // Card Alamat Utama
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, color: Colors.blue[700], size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label Alamat dengan nomor HP
                    Text(
                      '${_savedAlamat!['label'] ?? 'rumah'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Nama Penerima dengan Nomor HP
                    Text(
                      '${_savedAlamat!['nama_penerima'] ?? 'kafabi'} (${_savedAlamat!['nomor_hp'] ?? '084664644412'})',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Alamat Lengkap - Format sesuai gambar
                    Text(
                      '${_savedAlamat!['provinsi'] ?? 'Jawa Barat'}, ${_savedAlamat!['kota'] ?? 'Kota Bandung'}, ${_savedAlamat!['kecamatan'] ?? 'Antapani'}, ${_savedAlamat!['kelurahan'] ?? 'Antapani Kidul'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Tombol Tambah Catatan Pengiriman
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey[300]!,
              style: BorderStyle.solid,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: _showCatatanPengirimanDialog,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: Colors.blue[700],
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Catatan Pengiriman',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCatatanPengirimanDialog() {
    final TextEditingController catatanController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Catatan Pengiriman'),
            content: TextField(
              controller: catatanController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Masukkan catatan untuk kurir...',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Catatan pengiriman disimpan'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
    );
  }

  Widget _buildPromoCard(
    BuildContext context, {
    required String title,
    required String description,
    required String tag,
  }) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              Container(
                height: 85,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Icon(Icons.image, size: 50, color: Colors.grey[400]),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange[400],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, size: 12, color: Colors.amber),
                          SizedBox(width: 2),
                          Text(
                            'Exclusive',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.circle, size: 8, color: Colors.blue),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Tambah produk dulu, yuk!',
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Jalankan',
                        style: TextStyle(fontSize: 11, color: Colors.white),
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
}
