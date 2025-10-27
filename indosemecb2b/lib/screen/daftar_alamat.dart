import 'package:flutter/material.dart';
import 'lengkapi_alamat_screen.dart';
import '../utils/user_data_manager.dart'; // Import UserDataManager

class DaftarAlamatScreen extends StatefulWidget {
  const DaftarAlamatScreen({Key? key}) : super(key: key);

  @override
  State<DaftarAlamatScreen> createState() => _DaftarAlamatScreenState();
}

class _DaftarAlamatScreenState extends State<DaftarAlamatScreen> {
  List<Map<String, dynamic>> alamatList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlamatList();
  }

  // Load alamat list dari SharedPreferences
  Future<void> _loadAlamatList() async {
    setState(() => isLoading = true);

    final currentUser = await UserDataManager.getCurrentUserLogin();
    if (currentUser != null) {
      final loadedList = await UserDataManager.getAlamatList(currentUser);
      setState(() {
        alamatList = loadedList;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  // Save alamat list ke SharedPreferences
  Future<void> _saveAlamatList() async {
    final currentUser = await UserDataManager.getCurrentUserLogin();
    if (currentUser != null) {
      await UserDataManager.saveAlamatList(currentUser, alamatList);
    }
  }

  void deleteAddress(int index) async {
    setState(() {
      alamatList.removeAt(index);
    });
    await _saveAlamatList();

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Alamat dihapus")));
    }
  }

  void editAddress(int index) async {
    // Navigasi ke LengkapiAlamatScreen dengan data alamat yang dipilih
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                LengkapiAlamatScreen(existingAddress: alamatList[index]),
      ),
    );

    // Jika ada data yang dikembalikan, update alamat
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        alamatList[index] = result;
      });
      await _saveAlamatList();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Alamat berhasil diubah")));
      }
    }
  }

  void addAddress() async {
    // Navigasi ke LengkapiAlamatScreen tanpa data (tambah baru)
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LengkapiAlamatScreen()),
    );

    // Jika ada data yang dikembalikan, tambahkan ke list
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        alamatList.add(result);
      });
      await _saveAlamatList();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Alamat baru berhasil ditambahkan")),
        );
      }
    }
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
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : alamatList.isEmpty
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
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item["label"] ?? "Alamat",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => deleteAddress(index),
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item["nama_penerima"] ?? item["nama"] ?? "",
                          style: const TextStyle(fontSize: 15),
                        ),
                        Text(
                          item["nomor_hp"] ?? item["telepon"] ?? "",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          item["alamat_lengkap"] ?? item["alamat"] ?? "",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
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
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
