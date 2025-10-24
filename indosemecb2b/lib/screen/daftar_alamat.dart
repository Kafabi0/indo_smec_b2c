import 'package:flutter/material.dart';

class DaftarAlamatScreen extends StatefulWidget {
  const DaftarAlamatScreen({Key? key}) : super(key: key);

  @override
  State<DaftarAlamatScreen> createState() => _DaftarAlamatScreenState();
}

class _DaftarAlamatScreenState extends State<DaftarAlamatScreen> {
  List<Map<String, String>> alamatList = [
    {
      "label": "Rumah",
      "nama": "Kafabi",
      "telepon": "084646444412",
      "alamat": "Antapani"
    }
  ];

  void deleteAddress(int index) {
    setState(() {
      alamatList.removeAt(index);
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Alamat dihapus")));
  }

  void editAddress(int index) async {
    // Arahkan ke halaman edit, nanti kamu isi logiknya
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Edit alamat")));
  }

  void addAddress() async {
    // Arahkan ke halaman tambah alamat
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Tambah alamat baru")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Daftar Alamat",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(color: Colors.white),
        child: OutlinedButton(
          onPressed: addAddress,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
            side: const BorderSide(color: Colors.blue),
          ),
          child: const Text(
            "Tambah Alamat Baru +",
            style: TextStyle(color: Colors.blue, fontSize: 16),
          ),
        ),
      ),

      body: alamatList.isEmpty
          ? const Center(child: Text("Belum ada alamat"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: alamatList.length,
              itemBuilder: (context, index) {
                final item = alamatList[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 4,
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item["label"] ?? "",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          GestureDetector(
                            onTap: () => deleteAddress(index),
                            child: const Icon(Icons.delete_outline,
                                color: Colors.grey),
                          )
                        ],
                      ),

                      const SizedBox(height: 6),
                      Text(
                        item["nama"] ?? "",
                        style: const TextStyle(fontSize: 15),
                      ),
                      Text(
                        item["telepon"] ?? "",
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Text(
                        item["alamat"] ?? "",
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),

                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => editAddress(index),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.blue),
                        ),
                        child: const Text(
                          "Ubah Alamat",
                          style: TextStyle(color: Colors.blue),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }
}
