import 'package:flutter/material.dart';
import 'tandai_lokasi_screen.dart'; // halaman peta

class PilihAlamatScreen extends StatefulWidget {
  const PilihAlamatScreen({Key? key}) : super(key: key);

  @override
  State<PilihAlamatScreen> createState() => _PilihAlamatScreenState();
}

class _PilihAlamatScreenState extends State<PilihAlamatScreen> {
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Search bar
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.location_on_outlined,
                          color: Colors.redAccent),
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
                    leading: const Icon(Icons.my_location_outlined,
                        color: Colors.blue),
                    title: const Text(
                      'Gunakan lokasi saat ini',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(context); // tutup bottom sheet

                      // Navigasi ke halaman tandai lokasi
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TandaiLokasiScreen(),
                        ),
                      );

                      if (result != null) {
                        print('Koordinat dipilih: $result');
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
      appBar: AppBar(
        title: const Text('Pilih Alamat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Daftar alamat pengguna akan tampil di sini
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: _showTambahAlamatBottomSheet,
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
}
