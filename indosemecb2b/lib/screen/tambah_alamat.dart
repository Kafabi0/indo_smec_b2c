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
  String _selectedKelurahan = 'Antapani Kidul';
  String _selectedKodepos = '40291';

  // List untuk dropdown
  List<String> _kelurahanList = [
    'Antapani Kidul',
    'Antapani Tengah',
    'Antapani Wetan',
  ];
  List<String> _kodeposList = ['40291', '40292', '40293'];

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
      _selectedKelurahan = addr['kelurahan'] ?? 'Antapani Kidul';
      _selectedKodepos = addr['kodepos'] ?? '40291';

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

    print('📍 Location: ${location.latitude}, ${location.longitude}');
    print('🏘️ Placemark: ${place.administrativeArea}, ${place.locality}');

    setState(() {
      _selectedLocation = location;
      _lokasiText =
          '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';

      _provinsi = place.administrativeArea ?? '-';
      _kota = place.subAdministrativeArea ?? place.locality ?? '-';
      _kecamatan = place.subLocality ?? '-';

      _lokasiDetail =
          '${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}';

      if (place.subLocality != null && place.subLocality!.isNotEmpty) {
        _selectedKelurahan = place.subLocality!;
        if (!_kelurahanList.contains(_selectedKelurahan)) {
          _kelurahanList.add(_selectedKelurahan);
        }
      }

      if (place.postalCode != null && place.postalCode!.isNotEmpty) {
        _selectedKodepos = place.postalCode!;
        if (!_kodeposList.contains(_selectedKodepos)) {
          _kodeposList.add(_selectedKodepos);
        }
      }
    });

    print('✅ Location initialized: $_provinsi, $_kota, $_kecamatan');
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

      setState(() {
        _selectedLocation = location;
        _lokasiText =
            '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';

        _provinsi = place.administrativeArea ?? '-';
        _kota = place.subAdministrativeArea ?? place.locality ?? '-';
        _kecamatan = place.subLocality ?? '-';

        _lokasiDetail =
            '${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}';

        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          _selectedKelurahan = place.subLocality!;
          if (!_kelurahanList.contains(_selectedKelurahan)) {
            _kelurahanList.add(_selectedKelurahan);
          }
        }

        if (place.postalCode != null && place.postalCode!.isNotEmpty) {
          _selectedKodepos = place.postalCode!;
          if (!_kodeposList.contains(_selectedKodepos)) {
            _kodeposList.add(_selectedKodepos);
          }
        }
      });
      print('✅ Form updated dengan lokasi baru');
    } else {
      print('❌ Tidak ada lokasi dipilih atau dibatalkan');
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

      print('📦 Data alamat yang akan disimpan:');
      print('   Label: ${alamatData['label']}');
      print('   Nama: ${alamatData['nama_penerima']}');
      print('   HP: ${alamatData['nomor_hp']}');
      print('   Lokasi: ${alamatData['lokasi']}');
      print('   Alamat: ${alamatData['alamat_lengkap']}');

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
            // Debug info
            if (_selectedLocation != null)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Text(
                  '✅ Lokasi sudah dipilih: ${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}',
                  style: TextStyle(fontSize: 11, color: Colors.green[900]),
                ),
              ),

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
                                ? _kecamatan
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
                    onChanged:
                        (value) => setState(() => _selectedKelurahan = value!),
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
