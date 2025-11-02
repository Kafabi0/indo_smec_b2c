import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'tandai_lokasi_screen.dart';

class TambahAlamatScreen extends StatefulWidget {
  final LatLng? selectedLocation;
  final Placemark? placemark;
  final Map<String, dynamic>? existingAddress;

  const TambahAlamatScreen({
    Key? key,
    this.selectedLocation,
    this.placemark,
    this.existingAddress,
  }) : super(key: key);

  @override
  State<TambahAlamatScreen> createState() => _TambahAlamatScreenState();
}

class _TambahAlamatScreenState extends State<TambahAlamatScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _labelAlamatController = TextEditingController();
  final TextEditingController _alamatLengkapController =
      TextEditingController();
  final TextEditingController _namaPenerimaController = TextEditingController();
  final TextEditingController _nomorHpController = TextEditingController();

  // Data lokasi
  LatLng? _selectedLocation;
  String _lokasiText = 'Pilih lokasi dari peta';
  String _lokasiDetail = 'Tap untuk memilih lokasi';

  // Data dari placemark (read-only)
  String _provinsi = '-';
  String _kota = '-';
  String _kecamatan = '-';

  // Dropdown values yang bisa diubah
  String _selectedKelurahan = 'Cicadas'; // ⭐ Default untuk Cicadas
  String _selectedKodepos = '40293';

  // List untuk dropdown - ⭐ TAMBAHKAN SEMUA KELURAHAN DARI KOPERASI
  List<String> _kelurahanList = [
    'Antapani Kidul',
    'Antapani Tengah',
    'Antapani Wetan',
    'Cicadas',
    'Cibangkong',
    'Sukajadi',
    'Cileunyi Wetan',
    'Baleendah',
    'Baros',
  ];

  List<String> _kodeposList = [
    '40291',
    '40292',
    '40293',
    '40294',
    '40295',
    '40371',
    '40372',
    '40393',
  ];

  @override
  void initState() {
    super.initState();
    print('🏗️ TambahAlamatScreen - initState');

    if (widget.existingAddress != null) {
      print('✏️ Edit mode: ${widget.existingAddress!['label']}');
      _initializeFromExistingAddress();
    } else if (widget.selectedLocation != null && widget.placemark != null) {
      print('🗺️ New address from map');
      _initializeLocationData();
    } else {
      print('⚠️ No location data provided');
    }
  }

  void _initializeFromExistingAddress() {
    final addr = widget.existingAddress!;

    _labelAlamatController.text = addr['label'] ?? '';
    _alamatLengkapController.text = addr['alamat_lengkap'] ?? '';
    _namaPenerimaController.text = addr['nama_penerima'] ?? '';
    _nomorHpController.text = addr['nomor_hp'] ?? '';

    setState(() {
      if (addr['latitude'] != null && addr['longitude'] != null) {
        _selectedLocation = LatLng(addr['latitude'], addr['longitude']);
        _lokasiText =
            '${addr['latitude'].toStringAsFixed(6)}, ${addr['longitude'].toStringAsFixed(6)}';
      }

      _provinsi = addr['provinsi'] ?? '-';
      _kota = addr['kota'] ?? '-';
      _kecamatan = addr['kecamatan'] ?? '-';
      _selectedKelurahan = addr['kelurahan'] ?? 'Cicadas';
      _selectedKodepos = addr['kodepos'] ?? '40293';

      _lokasiDetail = '$_kecamatan, $_kota, $_provinsi';

      if (!_kelurahanList.contains(_selectedKelurahan)) {
        _kelurahanList.add(_selectedKelurahan);
      }
      if (!_kodeposList.contains(_selectedKodepos)) {
        _kodeposList.add(_selectedKodepos);
      }
    });
  }

  void _initializeLocationData() {
    final location = widget.selectedLocation!;
    final place = widget.placemark!;

    print('📍 ========== RAW PLACEMARK DATA ==========');
    print('Location: ${location.latitude}, ${location.longitude}');
    print('name: "${place.name}"');
    print('street: "${place.street}"');
    print('subThoroughfare: "${place.subThoroughfare}"');
    print('thoroughfare: "${place.thoroughfare}"');
    print('subLocality: "${place.subLocality}"'); // ⭐ Biasanya Kelurahan
    print('locality: "${place.locality}"'); // ⭐ Biasanya Kecamatan
    print(
      'subAdministrativeArea: "${place.subAdministrativeArea}"',
    ); // ⭐ Biasanya Kota
    print('administrativeArea: "${place.administrativeArea}"'); // ⭐ Provinsi
    print('postalCode: "${place.postalCode}"');
    print('country: "${place.country}"');
    print('isoCountryCode: "${place.isoCountryCode}"');
    print('==========================================');

    setState(() {
      _selectedLocation = location;
      _lokasiText =
          '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';

      // ⭐ MAPPING YANG BENAR UNTUK INDONESIA:
      // administrativeArea = Provinsi
      // subAdministrativeArea = Kota/Kabupaten
      // locality = Kecamatan (kadang Kota jika subAdministrativeArea kosong)
      // subLocality = Kelurahan/Desa

      _provinsi = place.administrativeArea ?? 'Jawa Barat';

      // Kota: prioritas subAdministrativeArea, fallback locality
      _kota = place.subAdministrativeArea ?? place.locality ?? 'Kota Bandung';

      // ⭐ PERBAIKAN: Deteksi Kecamatan dan Kelurahan
      final subLoc = (place.subLocality ?? '').trim();
      final loc = (place.locality ?? '').trim();

      print('🔍 Detection:');
      print('   subLocality: "$subLoc"');
      print('   locality: "$loc"');

      // Jika subLocality ada dan bukan kota
      if (subLoc.isNotEmpty &&
          !subLoc.toLowerCase().contains('kota') &&
          !subLoc.toLowerCase().contains('kabupaten')) {
        _selectedKelurahan = subLoc;
        print('   ✅ Kelurahan: "$_selectedKelurahan" (from subLocality)');

        // Kecamatan dari locality jika bukan kota
        if (loc.isNotEmpty &&
            !loc.toLowerCase().contains('kota') &&
            !loc.toLowerCase().contains('kabupaten')) {
          _kecamatan = loc;
          print('   ✅ Kecamatan: "$_kecamatan" (from locality)');
        } else {
          // Deteksi kecamatan dari nama kelurahan
          _kecamatan = _detectKecamatanFromKelurahan(subLoc);
          print('   ✅ Kecamatan: "$_kecamatan" (detected)');
        }
      }
      // Jika subLocality kosong, coba deteksi dari locality
      else if (loc.isNotEmpty) {
        _selectedKelurahan = loc;
        _kecamatan = _detectKecamatanFromKelurahan(loc);
        print(
          '   ⚠️ Kelurahan: "$_selectedKelurahan" (fallback from locality)',
        );
        print('   ⚠️ Kecamatan: "$_kecamatan" (detected)');
      }
      // Fallback terakhir
      else {
        _selectedKelurahan = 'Antapani Kidul';
        _kecamatan = 'Antapani';
        print('   ❌ Using default: Antapani Kidul, Antapani');
      }

      _lokasiDetail = '$_selectedKelurahan, $_kecamatan, $_kota';

      // Ensure kelurahan ada di list
      if (!_kelurahanList.contains(_selectedKelurahan)) {
        _kelurahanList.add(_selectedKelurahan);
      }

      // Kodepos
      if (place.postalCode != null && place.postalCode!.isNotEmpty) {
        _selectedKodepos = place.postalCode!;
        if (!_kodeposList.contains(_selectedKodepos)) {
          _kodeposList.add(_selectedKodepos);
        }
      }
    });

    print('✅ ========== RESULT ==========');
    print('   Provinsi: $_provinsi');
    print('   Kota: $_kota');
    print('   Kecamatan: $_kecamatan');
    print('   ⭐ KELURAHAN: "$_selectedKelurahan" ⭐');
    print('   Kodepos: $_selectedKodepos');
    print('==============================');
  }

  // ⭐ Helper function untuk deteksi kecamatan
  String _detectKecamatanFromKelurahan(String kelurahan) {
    final kel = kelurahan.toLowerCase().trim();

    // Mapping berdasarkan data koperasi Anda
    if (kel.contains('cicadas')) return 'Cibeunying Kidul';
    if (kel.contains('antapani')) return 'Antapani';
    if (kel.contains('sukajadi')) return 'Sukajadi';
    if (kel.contains('cileunyi')) return 'Cileunyi';
    if (kel.contains('baleendah')) return 'Baleendah';
    if (kel.contains('baros')) return 'Cimahi Tengah';
    if (kel.contains('cibangkong')) return 'Cibeunying Kidul';

    // Fallback: gunakan kelurahan sebagai kecamatan
    return kelurahan;
  }

  @override
  void dispose() {
    _labelAlamatController.dispose();
    _alamatLengkapController.dispose();
    _namaPenerimaController.dispose();
    _nomorHpController.dispose();
    super.dispose();
  }

  Future<void> _pilihLokasiDariPeta() async {
    print('🗺️ Membuka peta untuk pilih lokasi...');
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TandaiLokasiScreen()),
    );

    if (result != null && result is Map<String, dynamic>) {
      print('✅ Lokasi dipilih dari peta');
      final location = result['location'] as LatLng;
      final place = result['placemark'] as Placemark;

      print('🏘️ New Placemark from map:');
      print('   subLocality: ${place.subLocality}');
      print('   locality: ${place.locality}');

      setState(() {
        _selectedLocation = location;
        _lokasiText =
            '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';

        _provinsi = place.administrativeArea ?? 'Jawa Barat';
        _kota = place.subAdministrativeArea ?? place.locality ?? 'Kota Bandung';

        // ⭐ SAMA SEPERTI _initializeLocationData
        final subLoc = (place.subLocality ?? '').trim();

        if (subLoc.toLowerCase().contains('cicadas')) {
          _kecamatan = 'Cibeunying Kidul';
          _selectedKelurahan = 'Cicadas';
        } else if (subLoc.toLowerCase().contains('antapani')) {
          _kecamatan = 'Antapani';
          if (subLoc.toLowerCase().contains('kidul')) {
            _selectedKelurahan = 'Antapani Kidul';
          } else if (subLoc.toLowerCase().contains('tengah')) {
            _selectedKelurahan = 'Antapani Tengah';
          } else if (subLoc.toLowerCase().contains('wetan')) {
            _selectedKelurahan = 'Antapani Wetan';
          } else {
            _selectedKelurahan = 'Antapani Kidul';
          }
        } else if (subLoc.toLowerCase().contains('sukajadi')) {
          _kecamatan = 'Sukajadi';
          _selectedKelurahan = 'Sukajadi';
        } else if (subLoc.toLowerCase().contains('cileunyi')) {
          _kecamatan = 'Cileunyi';
          _selectedKelurahan = 'Cileunyi Wetan';
        } else if (subLoc.toLowerCase().contains('baleendah')) {
          _kecamatan = 'Baleendah';
          _selectedKelurahan = 'Baleendah';
        } else if (subLoc.toLowerCase().contains('baros') ||
            subLoc.toLowerCase().contains('cimahi')) {
          _kecamatan = 'Cimahi Tengah';
          _selectedKelurahan = 'Baros';
        } else {
          _kecamatan = place.locality ?? 'Unknown';
          _selectedKelurahan = subLoc.isNotEmpty ? subLoc : 'Cicadas';
        }

        _lokasiDetail = '$_selectedKelurahan, $_kecamatan, $_kota';

        if (!_kelurahanList.contains(_selectedKelurahan)) {
          _kelurahanList.add(_selectedKelurahan);
        }

        if (place.postalCode != null && place.postalCode!.isNotEmpty) {
          _selectedKodepos = place.postalCode!;
          if (!_kodeposList.contains(_selectedKodepos)) {
            _kodeposList.add(_selectedKodepos);
          }
        }
      });

      print('✅ Form updated dengan lokasi baru:');
      print('   Kecamatan: $_kecamatan');
      print('   Kelurahan: $_selectedKelurahan');
    }
  }

  void _simpanAlamat() async {
    print('💾 Tombol Simpan ditekan');

    if (_formKey.currentState!.validate()) {
      print('✅ Validasi form berhasil');

      if (_selectedLocation == null) {
        print('❌ Lokasi belum dipilih');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan pilih titik lokasi dari peta'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Proses simpan data
      final alamatData = {
        'label': _labelAlamatController.text,
        'lokasi': _lokasiText,
        'latitude': _selectedLocation!.latitude,
        'longitude': _selectedLocation!.longitude,
        'alamat_lengkap': _alamatLengkapController.text,
        'provinsi': _provinsi,
        'kota': _kota,
        'kecamatan': _kecamatan,
        'kelurahan': _selectedKelurahan,
        'kodepos': _selectedKodepos,
        'nama_penerima': _namaPenerimaController.text,
        'nomor_hp': _nomorHpController.text,
        'is_manual': false,
      };

      print('📦 ========== DATA ALAMAT AKAN DISIMPAN ==========');
      print('   Label: ${alamatData['label']}');
      print('   Provinsi: ${alamatData['provinsi']}');
      print('   Kota: ${alamatData['kota']}');
      print('   Kecamatan: ${alamatData['kecamatan']}');
      print('   ⭐ KELURAHAN: "${alamatData['kelurahan']}" ⭐'); // CRITICAL!
      print('   Nama: ${alamatData['nama_penerima']}');
      print('   HP: ${alamatData['nomor_hp']}');
      print('   Latitude: ${alamatData['latitude']}');
      print('   Longitude: ${alamatData['longitude']}');
      print('==================================================');

      // Tutup keyboard
      FocusScope.of(context).unfocus();
      await Future.delayed(const Duration(milliseconds: 100));

      print('🔙 Menutup screen dengan data...');

      // Pop dengan data
      if (mounted) {
        Navigator.of(context).pop(alamatData);
        print('✅ Screen ditutup dengan data alamat');
      }
    } else {
      print('❌ Validasi form gagal');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.existingAddress != null ? 'Edit Alamat' : 'Tambah Alamat',
          style: const TextStyle(color: Colors.black, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTextField(
              label: 'Label Alamat',
              controller: _labelAlamatController,
              hint: 'Masukkan Label Alamat',
              helperText: 'Contoh: Rumah, apartmen, atau kantor',
              isRequired: true,
            ),
            const SizedBox(height: 16),

            const Text(
              'Titik Lokasi *',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pilihLokasiDariPeta,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.red, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedLocation != null
                                ? _selectedKelurahan
                                : 'Pilih Lokasi',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedLocation != null
                                ? _lokasiDetail
                                : 'Tap untuk memilih titik lokasi dari peta',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey[400]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pastikan titik lokasi kamu sudah tepat untuk mempermudah pengiriman.',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),

            const SizedBox(height: 16),
            _buildTextField(
              label: 'Alamat Lengkap',
              controller: _alamatLengkapController,
              hint: 'Masukkan Alamat Lengkap',
              maxLines: 1,
              isRequired: true,
            ),

            const SizedBox(height: 16),
            _buildReadOnlyField(label: 'Provinsi', value: _provinsi),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildReadOnlyField(label: 'Kota', value: _kota),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildReadOnlyField(
                    label: 'Kecamatan',
                    value: _kecamatan,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    label: 'Kelurahan',
                    value: _selectedKelurahan,
                    items: _kelurahanList,
                    onChanged: (value) {
                      setState(() => _selectedKelurahan = value!);
                      print('📍 Kelurahan changed to: $value');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdown(
                    label: 'Kodepos',
                    value: _selectedKodepos,
                    items: _kodeposList,
                    onChanged:
                        (value) => setState(() => _selectedKodepos = value!),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            _buildTextField(
              label: 'Nama Penerima',
              controller: _namaPenerimaController,
              hint: 'Masukkan Nama Penerima',
              isRequired: true,
            ),

            const SizedBox(height: 16),
            _buildTextField(
              label: 'Nomor Handphone',
              controller: _nomorHpController,
              hint: 'Masukkan Nomor Handphone',
              keyboardType: TextInputType.phone,
              isRequired: true,
            ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
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
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _simpanAlamat,
              child: Text(
                widget.existingAddress != null
                    ? 'Simpan Perubahan'
                    : 'Simpan dan Gunakan Alamat',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    String? helperText,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            children: [
              if (isRequired)
                const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
          ),
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return '$label tidak boleh kosong';
            }
            return null;
          },
        ),
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            helperText,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ],
    );
  }

  Widget _buildReadOnlyField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            children: const [
              TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            children: const [
              TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: InputBorder.none,
            ),
            icon: Icon(Icons.chevron_right, color: Colors.grey[400]),
            items:
                items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item, style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
