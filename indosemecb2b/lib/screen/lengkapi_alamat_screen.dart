// screen/lengkapi_alamat_screen.dart
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'tambah_alamat.dart';
import 'tandai_lokasi_screen.dart'; // ⭐ Import TandaiLokasiScreen

class LengkapiAlamatScreen extends StatefulWidget {
  final Map<String, dynamic>? existingAddress;

  const LengkapiAlamatScreen({Key? key, this.existingAddress})
    : super(key: key);

  @override
  State<LengkapiAlamatScreen> createState() => _LengkapiAlamatScreenState();
}

class _LengkapiAlamatScreenState extends State<LengkapiAlamatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pilih Alamat',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child:
                widget.existingAddress != null
                    ? _buildAlamatTersimpan()
                    : _buildBelumAdaAlamat(),
          ),
          // Tombol Tambah Alamat Baru
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _showTambahAlamatBottomSheet,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.blue[700]!, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Icon(Icons.add, color: Colors.blue[700]),
                  label: Text(
                    'Tambah Alamat Baru',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBelumAdaAlamat() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 100,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            const Text(
              'Belum ada alamat tersimpan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan alamat pengiriman untuk memudahkan proses belanja Anda',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlamatTersimpan() {
    final alamat = widget.existingAddress!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F7FF), // biru muda
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label alamat (contoh: rumah)
              Text(
                alamat['label'] ?? 'rumah',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),

              // Nama penerima
              Text(
                alamat['nama_penerima'] ?? '-',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),

              // Nomor HP
              Text(
                alamat['nomor_hp'] ?? '-',
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
              const SizedBox(height: 2),

              // Alamat lengkap
              Text(
                alamat['alamat_lengkap'] ?? 'antapani',
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),

              const SizedBox(height: 12),

              // Tombol Ubah Alamat
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _navigateToEditAlamat,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.blue[400]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(
                    'Ubah Alamat',
                    style: TextStyle(
                      color: Colors.blue[600],
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ⭐ Bottom Sheet untuk tambah alamat baru
  void _showTambahAlamatBottomSheet() {
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
                  // Header bar
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
                      Navigator.pop(context); // tutup bottom sheet

                      // ⭐ Navigasi ke halaman TandaiLokasiScreen terlebih dahulu
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TandaiLokasiScreen(),
                        ),
                      );

                      // Jika ada result, kirim kembali ke CartScreen
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

  // ⭐ Navigasi untuk edit alamat (langsung ke form)
  Future<void> _navigateToEditAlamat() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => TambahAlamatScreen(
              selectedLocation:
                  widget.existingAddress != null
                      ? LatLng(
                        widget.existingAddress!['latitude'] ?? -6.9175,
                        widget.existingAddress!['longitude'] ?? 107.6191,
                      )
                      : null,
            ),
      ),
    );

    // Jika ada data yang dikembalikan dari TambahAlamatScreen
    if (result != null && result is Map<String, dynamic>) {
      // Kirim data kembali ke CartScreen
      if (mounted) {
        Navigator.pop(context, result);
      }
    }
  }
}
