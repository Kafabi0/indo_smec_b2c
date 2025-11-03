import 'package:flutter/material.dart';

class CaraBerbelanjaScreen extends StatelessWidget {
  const CaraBerbelanjaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = [
      {
        "title": "Daftar / Login",
        "image": "assets/images/step1.jpg",
      },
      {
        "title": "Lengkapi alamat pengiriman",
        "image": "assets/images/step2.jpg",
      },
      
      {
        "title": "Sobat sudah bisa mulai belanja!",
        "image": "assets/images/step4.jpg",
      },
      {
        "title": "Jika sudah, cek keranjang",
        "image": "assets/images/step5.jpg",
      },
      {
        "title": "Cek juga Promo dan Fair agar makin hemat",
        "image": "assets/images/step6.jpg",
      },
      {
        "title": "Pilih waktu pengiriman / pengambilan yang diinginkan",
        "image": "assets/images/step7.jpg",
      },
      {
        "title": "Pilih metode pembayaran!",
        "image": "assets/images/step8.jpg",
      },
      {
        "title": "Belanjaanmu dikirim!",
        "image": "assets/images/step9.jpg",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cara Berbelanja',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blue[600],
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: steps.length,
        itemBuilder: (context, index) {
          final step = steps[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              border: Border.all(color: Colors.blue.shade600, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue,
                        radius: 14,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          step["title"]!,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      step["image"]!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
