import 'package:flutter/material.dart';
import 'tandai_lokasi_screen.dart'; // halaman peta

class LengkapiAlamatScreen extends StatefulWidget {
  final Map<String, dynamic>? existingAddress; // Alamat yang sudah ada
  
  const LengkapiAlamatScreen({Key? key, this.existingAddress}) : super(key: key);

  @override
  State<LengkapiAlamatScreen> createState() => _LengkapiAlamatScreenState();
}

class _LengkapiAlamatScreenState extends State<LengkapiAlamatScreen> {
  Map<String, dynamic>? _selectedAddress;
  
  @override
  void initState() {
    super.initState();
    // Set alamat yang sudah ada jika ada
    if (widget.existingAddress != null) {
      _selectedAddress = widget.existingAddress;
    }
  }

  // Fungsi untuk menampilkan bottom sheet
  void _showTambahAlamatBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header bar (indikator drag)
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),

                  const Text(
                    'Cari Lokasi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),

                  // Search bar
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.location_on_outlined,
                        color: Colors.redAccent,
                      ),
                      hintText: 'Cari lokasi / gedung / nama jalan',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tombol "Gunakan lokasi saat ini"
                  ListTile(
                    leading: const Icon(
                      Icons.my_location_outlined,
                      color: Colors.blue,
                    ),
                    title: const Text(
                      'Gunakan lokasi saat ini',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(context); // Tutup bottom sheet

                      // Navigasi ke halaman tandai lokasi
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TandaiLokasiScreen(),
                        ),
                      );

                      // Jika ada result (data alamat), kembalikan ke CartScreen
                      if (result != null && mounted) {
                        Navigator.pop(context, result);
                      }
                    },
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Text(
                      'Silakan masukkan alamat/lokasimu untuk menentukan lokasi pengiriman',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
        centerTitle: false,
        title: const Text(
          'Pilih Alamat',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Column(
        children: [
          // Jika ada alamat yang tersimpan
          if (_selectedAddress != null)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildAddressCard(_selectedAddress!),
                  ],
                ),
              ),
            )
          else
            // Jika belum ada alamat
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Ilustrasi pin lokasi
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 90,
                          color: Colors.blue[700],
                        ),
                        Positioned(
                          right: 4,
                          top: 6,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            padding: const EdgeInsets.all(2),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Kamu belum menambahkan alamat pengiriman,\n'
                      'silahkan tambahkan alamat pengiriman.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Tombol "Tambah Alamat Baru +"
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => _showTambahAlamatBottomSheet(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.blue.shade700, width: 1.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  backgroundColor: Colors.white,
                  overlayColor: Colors.blue.withOpacity(0.1),
                ),
                child: Text(
                  'Tambah Alamat Baru +',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk card alamat
  Widget _buildAddressCard(Map<String, dynamic> address) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[300]!, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label alamat
          Text(
            address['label'] ?? 'rumah',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),

          // Nama penerima
          Text(
            address['nama_penerima'] ?? 'kafabi',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),

          // Nomor HP
          Text(
            address['nomor_hp'] ?? '084664644412',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),

          // Alamat singkat (kecamatan)
          Text(
            address['kecamatan'] ?? 'antapani',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),

          const SizedBox(height: 16),

          // Tombol Ubah Alamat
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _showTambahAlamatBottomSheet(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.blue[700]!, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Ubah Alamat',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}