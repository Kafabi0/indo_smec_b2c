// screen/lengkapi_alamat_screen.dart - DEBUG VERSION
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'tambah_alamat.dart';
import 'tambah_alamat_manual.dart';
import 'tandai_lokasi_screen.dart';
import '../utils/user_data_manager.dart';

class LengkapiAlamatScreen extends StatefulWidget {
  final Map<String, dynamic>? existingAddress;
  final int? editIndex;

  const LengkapiAlamatScreen({
    Key? key,
    this.existingAddress,
    this.editIndex,
  }) : super(key: key);

  @override
  State<LengkapiAlamatScreen> createState() => _LengkapiAlamatScreenState();
}

class _LengkapiAlamatScreenState extends State<LengkapiAlamatScreen> {
  List<Map<String, dynamic>> _alamatList = [];
  bool _isLoading = true;
  String? _currentUserLogin;

  @override
  void initState() {
    super.initState();
    print('🚀 LengkapiAlamatScreen - initState');
    _loadAlamatList();
  }

  Future<void> _loadAlamatList() async {
    print('📂 Loading alamat list...');
    setState(() => _isLoading = true);

    final currentUser = await UserDataManager.getCurrentUserLogin();
    print('👤 Current user: $currentUser');

    if (currentUser != null) {
      final loadedList = await UserDataManager.getAlamatList(currentUser);
      print('✅ Loaded ${loadedList.length} alamat');
      for (int i = 0; i < loadedList.length; i++) {
        print('  [$i] ${loadedList[i]['label']} - ${loadedList[i]['nama_penerima']}');
      }

      setState(() {
        _currentUserLogin = currentUser;
        _alamatList = loadedList;
        _isLoading = false;
      });
    } else {
      print('❌ No user logged in!');
      setState(() => _isLoading = false);
      
      // Tampilkan alert jika user belum login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Anda belum login. Silakan login terlebih dahulu.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      });
    }
  }

  Future<void> _saveAlamatList() async {
    print('💾 Saving ${_alamatList.length} alamat...');
    
    if (_currentUserLogin != null) {
      final success = await UserDataManager.saveAlamatList(_currentUserLogin!, _alamatList);
      print('💾 Save result: $success');
      
      if (success) {
        // Verify save dengan reload
        final verifyList = await UserDataManager.getAlamatList(_currentUserLogin!);
        print('✔️ Verify: Saved ${verifyList.length} alamat');
      }
    } else {
      print('❌ Cannot save: No user logged in');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Memuat data alamat...'),
            ],
          ),
        ),
      );
    }

    // Tampilkan warning jika user belum login
    if (_currentUserLogin == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Pilih Alamat', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_off, size: 100, color: Colors.grey[300]),
                const SizedBox(height: 24),
                const Text(
                  'Anda belum login',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Silakan login terlebih dahulu untuk mengelola alamat',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Kembali'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pilih Alamat (${_alamatList.length})',
          style: const TextStyle(color: Colors.black, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          // Debug button
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () async {
              await UserDataManager.debugPrintAllKeys();
              final user = await UserDataManager.getCurrentUserLogin();
              if (mounted) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Debug Info'),
                    content: Text(
                      'User: $user\n'
                      'Alamat count: ${_alamatList.length}\n'
                      'Check console for all keys',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Info bar
          // Container(
          //   width: double.infinity,
          //   padding: const EdgeInsets.all(12),
          //   color: Colors.blue[50],
          //   child: Text(
          //     '👤 Login sebagai: $_currentUserLogin',
          //     style: const TextStyle(fontSize: 12),
          //     textAlign: TextAlign.center,
          //   ),
          // ),
          
          Expanded(
            child: _alamatList.isEmpty
                ? _buildBelumAdaAlamat()
                : _buildDaftarAlamat(),
          ),
          
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
            Icon(Icons.location_off_outlined, size: 100, color: Colors.grey[300]),
            const SizedBox(height: 24),
            const Text(
              'Belum ada alamat tersimpan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan alamat pengiriman untuk memudahkan proses belanja Anda',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaftarAlamat() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _alamatList.length,
      itemBuilder: (context, index) {
        final alamat = _alamatList[index];
        final isSelected = widget.editIndex == index;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF1F7FF) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.blue[400]! : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    alamat['label'] ?? 'Alamat',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[700],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Dipilih',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                alamat['nama_penerima'] ?? '-',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                alamat['nomor_hp'] ?? '-',
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
              const SizedBox(height: 2),
              Text(
                alamat['alamat_lengkap'] ?? '-',
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
              const SizedBox(height: 4),
              Text(
                '${alamat['kelurahan']}, ${alamat['kecamatan']}, ${alamat['kota']}, ${alamat['provinsi']}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pilihAlamat(index),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.blue[400]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(
                        'Pilih Alamat',
                        style: TextStyle(
                          color: Colors.blue[600],
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => _editAlamat(index),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[400]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: Icon(Icons.edit, size: 20, color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => _hapusAlamat(index),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: Icon(Icons.delete, size: 20, color: Colors.red[400]),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _pilihAlamat(int index) {
    print('✅ Alamat dipilih: ${_alamatList[index]['label']}');
    Navigator.pop(context, _alamatList[index]);
  }

  Future<void> _editAlamat(int index) async {
    print('✏️ Edit alamat index: $index');
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TambahAlamatScreen(
          existingAddress: _alamatList[index],
          selectedLocation: _alamatList[index]['latitude'] != null
              ? LatLng(_alamatList[index]['latitude'], _alamatList[index]['longitude'])
              : null,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      print('✅ Alamat edited: ${result['label']}');
      setState(() {
        _alamatList[index] = result;
      });
      await _saveAlamatList();
      await _loadAlamatList(); // Reload untuk verify

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alamat berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _hapusAlamat(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Alamat'),
        content: const Text('Apakah Anda yakin ingin menghapus alamat ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      print('🗑️ Hapus alamat index: $index');
      setState(() {
        _alamatList.removeAt(index);
      });
      await _saveAlamatList();
      await _loadAlamatList(); // Reload untuk verify

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alamat berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _showTambahAlamatBottomSheet() {
    print('📝 Show tambah alamat bottom sheet');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.5,
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
                    'Pilih Metode Input Alamat',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pilih cara untuk menambahkan alamat pengiriman',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  _buildOptionCard(
                    icon: Icons.map_outlined,
                    iconColor: Colors.blue,
                    iconBgColor: Colors.blue[50]!,
                    title: 'Pilih dari Peta',
                    description: 'Tandai lokasi langsung di peta',
                    onTap: () {
                      print('🗺️ Pilih dari peta - closing bottom sheet');
                      Navigator.pop(context); // Tutup bottom sheet
                      // ⭐ Gunakan addPostFrameCallback untuk memastikan context valid
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _navigateToPeta();
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildOptionCard(
                    icon: Icons.edit_location_alt_outlined,
                    iconColor: Colors.green,
                    iconBgColor: Colors.green[50]!,
                    title: 'Input Manual',
                    description: 'Isi alamat secara manual untuk orang lain',
                    onTap: () {
                      print('📝 Input manual - closing bottom sheet');
                      Navigator.pop(context); // Tutup bottom sheet
                      // ⭐ Gunakan addPostFrameCallback untuk memastikan context valid
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _navigateToManual();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Divider(color: Colors.grey[300]),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Anda bisa mengirim ke alamat orang lain dengan input manual',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ⭐ Pisahkan navigasi ke fungsi terpisah
  Future<void> _navigateToPeta() async {
    print('🗺️ Navigating to TandaiLokasiScreen');
    if (!mounted) {
      print('❌ Widget not mounted');
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TandaiLokasiScreen(),
      ),
    );

    print('🔙 Returned from TandaiLokasiScreen');
    print('📦 Result: $result');

    if (result != null && result is Map<String, dynamic>) {
      print('✅ Got location from map');
      await _handleTambahAlamatDariPeta(result);
    } else {
      print('❌ No location selected or invalid result');
    }
  }

  Future<void> _navigateToManual() async {
    print('📝 Navigating to TambahAlamatManualScreen');
    if (!mounted) {
      print('❌ Widget not mounted');
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TambahAlamatManualScreen(),
      ),
    );

    print('🔙 Returned from TambahAlamatManualScreen');
    print('📦 Result: $result');

    if (result != null && result is Map<String, dynamic>) {
      print('✅ Got manual address');
      await _handleTambahAlamatManual(result);
    } else {
      print('❌ No manual address or invalid result');
    }
  }

  Future<void> _handleTambahAlamatDariPeta(Map<String, dynamic> result) async {
    print('🗺️ Handling address from map');
    print('🗺️ Result from TandaiLokasiScreen: $result');
    
    // ⭐ PERBAIKAN: Langsung navigasi ke TambahAlamatScreen
    // Navigator.push akan membuka screen baru dan menunggu hasilnya
    final alamatResult = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TambahAlamatScreen(
          selectedLocation: result['location'] as LatLng,
          placemark: result['placemark'],
        ),
      ),
    );

    print('🔍 Checking alamatResult: $alamatResult');
    
    if (alamatResult != null && alamatResult is Map<String, dynamic>) {
      print('✅ Alamat dari peta received: ${alamatResult['label']}');
      print('📦 Full data: $alamatResult');
      
      setState(() {
        _alamatList.add(alamatResult);
        print('📝 List size now: ${_alamatList.length}');
      });
      
      await _saveAlamatList();
      await _loadAlamatList(); // Reload untuk verify

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Alamat "${alamatResult['label']}" berhasil ditambahkan!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      print('❌ No alamat result from form');
      print('❌ Result type: ${alamatResult.runtimeType}');
      print('❌ Result value: $alamatResult');
    }
  }

  Future<void> _handleTambahAlamatManual(Map<String, dynamic> result) async {
    print('📝 Handling manual address: ${result['label']}');
    setState(() {
      _alamatList.add(result);
      print('📝 List size now: ${_alamatList.length}');
    });
    
    await _saveAlamatList();
    await _loadAlamatList(); // Reload untuk verify

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Alamat "${result['label']}" berhasil ditambahkan!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildOptionCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}