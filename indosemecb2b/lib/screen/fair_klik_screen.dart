import 'package:flutter/material.dart';

// Import screen ini di cart_screen.dart Anda dengan:
// import 'package:indosemecb2b/screen/fair_klik_screen.dart';

class FairKlikScreen extends StatefulWidget {
  const FairKlikScreen({Key? key}) : super(key: key);

  @override
  State<FairKlikScreen> createState() => _FairKlikScreenState();
}

class _FairKlikScreenState extends State<FairKlikScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedFilter = 'Semua Tipe Fair';
  bool showIKupon = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Fair Klik Indomaret',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.blue[700],
              indicatorWeight: 3,
              labelColor: Colors.blue[700],
              unselectedLabelColor: Colors.grey[600],
              labelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: 'Fair Berjalan'),
                Tab(text: 'Semua Fair'),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFairBerjalan(),
                _buildSemuaFair(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari fair di sini',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              _showFilterBottomSheet();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    selectedFilter,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              setState(() {
                showIKupon = !showIKupon;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: showIKupon ? Colors.blue[700] : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'i-Kupon',
                style: TextStyle(
                  fontSize: 14,
                  color: showIKupon ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFairBerjalan() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFairCard(
          title: 'Khusus Member Baru setiap pembelian produk Wings senilai Rp35.000 dapatkan potongan Rp5.000',
          imageUrl: 'https://www.klikindomaret.com/assets-klikidmsearch/_next/image?url=https%3A%2F%2Fcdn-klik.klikindomaret.com%2Fhome%2Fbanner%2F58869d9f-ec02-47b5-a1f8-34a824cbda7d.png&w=1920&q=75',
          tags: ['Exclusive', 'New Member', 'Wings Fair'],
          validUntil: '01 Nov 2025 - 30 Nov 2025',
          discount: 'DISKON\nRP 7.500',
          minPurchase: 'Min. belanja Rp50.000',
          isNew: true,
          buttonText: 'Jalankan Fair Exclusive',
        ),
        const SizedBox(height: 16),
        _buildFairCard(
          title: 'Khusus Member Baru setiap pembelian produk Nutrilon tertentu senilai Rp90.000 dapatkan potongan s.d Rp18.000',
          imageUrl: 'https://www.klikindomaret.com/assets-klikidmsearch/_next/image?url=https%3A%2F%2Fcdn-klik.klikindomaret.com%2Fhome%2Fbanner%2Fdecdc6dc-133b-487d-8c0b-5b18af91c170.png&w=1920&q=75',
          tags: ['Exclusive', 'New Member', 'Nutrilon Fair'],
          validUntil: '01 Nov 2025 - 30 Nov 2025',
          discount: 'DISKON\nS.D RP 18RB',
          minPurchase: '*S&K Berlaku',
          isNew: true,
          buttonText: 'Jalankan Fair Exclusive',
        ),
      ],
    );
  }

  Widget _buildSemuaFair() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFairCard(
          title: 'Khusus Member Baru setiap pembelian produk Wings senilai Rp35.000 dapatkan potongan Rp5.000',
          imageUrl: 'https://www.klikindomaret.com/assets-klikidmsearch/_next/image?url=https%3A%2F%2Fcdn-klik.klikindomaret.com%2Fhome%2Fbanner%2F58869d9f-ec02-47b5-a1f8-34a824cbda7d.png&w=1920&q=75',
          tags: ['Exclusive', 'New Member', 'Wings Fair'],
          validUntil: '01 Nov 2025 - 30 Nov 2025',
          discount: 'DISKON\nRP 7.500',
          minPurchase: 'Min. belanja Rp50.000',
          isNew: true,
          buttonText: 'Jalankan Fair Exclusive',
        ),
        const SizedBox(height: 16),
        _buildFairCard(
          title: 'Khusus Member Baru setiap pembelian produk Nutrilon tertentu senilai Rp90.000 dapatkan potongan s.d Rp18.000',
          imageUrl: 'https://www.klikindomaret.com/assets-klikidmsearch/_next/image?url=https%3A%2F%2Fcdn-klik.klikindomaret.com%2Fhome%2Fbanner%2Fdecdc6dc-133b-487d-8c0b-5b18af91c170.png&w=1920&q=75',
          tags: ['Exclusive', 'New Member', 'Nutrilon Fair'],
          validUntil: '01 Nov 2025 - 30 Nov 2025',
          discount: 'DISKON\nS.D RP 18RB',
          minPurchase: '*S&K Berlaku',
          isNew: true,
          buttonText: 'Jalankan Fair Exclusive',
        ),
        const SizedBox(height: 16),
        _buildFairCard(
          title: 'Diskon hingga 50% untuk produk makanan pilihan',
          imageUrl: 'https://www.klikindomaret.com/assets-klikidmsearch/_next/image?url=https%3A%2F%2Fcdn-klik.klikindomaret.com%2Fhome%2Fbanner%2F055aa64a-58a1-4e2e-aa67-7c58c3bdcd5c.png&w=1920&q=75',
          tags: ['Promo Terbatas', 'Food Fair'],
          validUntil: '01 Nov 2025 - 15 Nov 2025',
          discount: 'DISKON\n50%',
          minPurchase: 'Untuk produk terpilih',
          isNew: false,
          buttonText: 'Jalankan Fair',
        ),
      ],
    );
  }

  Widget _buildFairCard({
    required String title,
    required String imageUrl,
    required List<String> tags,
    required String validUntil,
    required String discount,
    required String minPurchase,
    required bool isNew,
    required String buttonText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: Colors.grey[200],
                      child: Center(
                        child: Icon(Icons.image, size: 50, color: Colors.grey[400]),
                      ),
                    );
                  },
                ),
              ),
              if (isNew)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.orange[400],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Pengguna Baru',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ...tags.map((tag) {
                      bool isExclusive = tag == 'Exclusive';
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isExclusive ? Colors.amber[100] : Colors.blue[50],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isExclusive) ...[
                              const Icon(Icons.star, size: 12, color: Colors.amber),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              tag,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isExclusive ? Colors.amber[900] : Colors.blue[900],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      validUntil,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.circle, size: 8, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tambah produk dulu, yuk!',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                    SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          buttonText,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Fair',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildFilterOption('Semua Tipe Fair'),
              _buildFilterOption('New Member Fair'),
              _buildFilterOption('Exclusive Fair'),
              _buildFilterOption('Regular Fair'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Terapkan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String title) {
    bool isSelected = selectedFilter == title;
    return InkWell(
      onTap: () {
        setState(() {
          selectedFilter = title;
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: title,
              groupValue: selectedFilter,
              onChanged: (value) {
                setState(() {
                  selectedFilter = value!;
                });
                Navigator.pop(context);
              },
              activeColor: Colors.blue[700],
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}