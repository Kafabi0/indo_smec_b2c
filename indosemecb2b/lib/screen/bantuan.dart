import 'package:flutter/material.dart';
import 'cara_belanja.dart';

class BantuanScreen extends StatelessWidget {
  const BantuanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topics = [
      'Cara Berbelanja',
      'Tentang IndoSmec b2c',
      'Kebijakan Refund',
      'Saldo Klik',
      'Produk Virtual',
      'Petunjuk Pembayaran',
      'i.saku & PoinKu',
      'Pertanyaan Umum',
      'Syarat & Ketentuan',
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        elevation: 0,
        title: const Text(
          'Bantuan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header biru
          Container(
            width: double.infinity,
            color: Colors.blue[600],
            padding: const EdgeInsets.all(16),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Halo!',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                SizedBox(height: 4),
                Text(
                  'Ada yang bisa kami bantu?',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 18),
                ),
              ],
            ),
          ),

          // Kolom pencarian
          Container(
            color: Colors.blue[600],
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Masukkan kata kunci',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Daftar topik bantuan
          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView.separated(
                itemCount: topics.length + 1,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: Colors.grey[300],
                  indent: 16,
                  endIndent: 16,
                ),
                itemBuilder: (context, index) {
                  if (index < topics.length) {
                    return ListTile(
                      title: Text(topics[index],
                          style: const TextStyle(fontSize: 14)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        if (topics[index] == 'Cara Berbelanja') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const CaraBerbelanjaScreen()),
                          );
                        }
                      },
                    );
                  } else {
                    // Bagian bawah “Hubungi Kami”
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Perlu bantuan lebih lanjut?',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {},
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(14),
                              child: const Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Colors.blue,
                                    child: Icon(Icons.person,
                                        color: Colors.white, size: 20),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Hubungi Kami',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500)),
                                  Spacer(),
                                  Icon(Icons.arrow_forward_ios, size: 16),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
