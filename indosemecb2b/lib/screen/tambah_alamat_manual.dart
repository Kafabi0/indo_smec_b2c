// screen/tambah_alamat_manual.dart
import 'package:flutter/material.dart';

class TambahAlamatManualScreen extends StatefulWidget {
  const TambahAlamatManualScreen({Key? key}) : super(key: key);

  @override
  State<TambahAlamatManualScreen> createState() =>
      _TambahAlamatManualScreenState();
}

class _TambahAlamatManualScreenState extends State<TambahAlamatManualScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _labelAlamatController = TextEditingController();
  final TextEditingController _namaPenerimaController = TextEditingController();
  final TextEditingController _nomorHpController = TextEditingController();
  final TextEditingController _alamatLengkapController =
      TextEditingController();
  final TextEditingController _rtController = TextEditingController();
  final TextEditingController _rwController = TextEditingController();

  // Dropdown values
  String? _selectedProvinsi;
  String? _selectedKota;
  String? _selectedKecamatan;
  String? _selectedKelurahan;
  String? _selectedKodepos;

  // Data untuk dropdown (contoh data, bisa diganti dengan API)
  final List<String> _provinsiList = [
    'Jawa Barat',
    'Jawa Tengah',
    'Jawa Timur',
    'DKI Jakarta',
    'Banten',
  ];

  final Map<String, List<String>> _kotaList = {
    'Jawa Barat': ['Kota Bandung', 'Kota Bekasi', 'Kota Depok', 'Kota Bogor'],
    'DKI Jakarta': ['Jakarta Pusat', 'Jakarta Selatan', 'Jakarta Timur'],
  };

  final Map<String, List<String>> _kecamatanList = {
    'Kota Bandung': ['Antapani', 'Cicadas', 'Arcamanik', 'Ujung Berung'],
    'Kota Bekasi': ['Bekasi Timur', 'Bekasi Barat', 'Bekasi Selatan'],
  };

  final Map<String, List<String>> _kelurahanList = {
    'Antapani': ['Antapani Kidul', 'Antapani Tengah', 'Antapani Wetan'],
    'Cicadas': ['Cicadas', 'Cibangkong'],
  };

  final List<String> _kodeposList = [
    '40291',
    '40292',
    '40293',
    '40294',
    '40295',
  ];

  @override
  void dispose() {
    _labelAlamatController.dispose();
    _namaPenerimaController.dispose();
    _nomorHpController.dispose();
    _alamatLengkapController.dispose();
    _rtController.dispose();
    _rwController.dispose();
    super.dispose();
  }

  void _simpanAlamat() async {
    if (_formKey.currentState!.validate()) {
      // Validasi dropdown
      if (_selectedProvinsi == null ||
          _selectedKota == null ||
          _selectedKecamatan == null ||
          _selectedKelurahan == null ||
          _selectedKodepos == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mohon lengkapi semua field yang bertanda *'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Buat data alamat
      final alamatData = {
        'label': _labelAlamatController.text,
        'nama_penerima': _namaPenerimaController.text,
        'nomor_hp': _nomorHpController.text,
        'alamat_lengkap': _alamatLengkapController.text,
        'rt': _rtController.text,
        'rw': _rwController.text,
        'provinsi': _selectedProvinsi,
        'kota': _selectedKota,
        'kecamatan': _selectedKecamatan,
        'kelurahan': _selectedKelurahan,
        'kodepos': _selectedKodepos,
        'is_manual': true, // ⭐ Penanda bahwa ini alamat manual
        'latitude': null, // Tidak ada koordinat
        'longitude': null,
      };

      // Tutup keyboard
      FocusScope.of(context).unfocus();
      await Future.delayed(const Duration(milliseconds: 100));

      // ⭐ Langsung pop dengan data ke LengkapiAlamatScreen
      if (mounted) {
        Navigator.of(context).pop(alamatData);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Input Alamat Manual',
          style: TextStyle(color: Colors.black, fontSize: 18),
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
            // Info banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Isi alamat ini untuk mengirim ke orang lain di lokasi berbeda',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[900],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _buildTextField(
              label: 'Label Alamat',
              controller: _labelAlamatController,
              hint: 'Contoh: Rumah Ibu, Kantor Pak Budi',
              helperText: 'Label untuk mengidentifikasi alamat ini',
              isRequired: true,
            ),

            const SizedBox(height: 16),

            _buildTextField(
              label: 'Nama Penerima',
              controller: _namaPenerimaController,
              hint: 'Nama lengkap penerima',
              isRequired: true,
            ),

            const SizedBox(height: 16),

            _buildTextField(
              label: 'Nomor Handphone',
              controller: _nomorHpController,
              hint: '08xxxxxxxxxx',
              keyboardType: TextInputType.phone,
              isRequired: true,
            ),

            const SizedBox(height: 16),

            _buildTextField(
              label: 'Alamat Lengkap',
              controller: _alamatLengkapController,
              hint: 'Nama jalan, nomor rumah, gedung, dll',
              maxLines: 3,
              isRequired: true,
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'RT',
                    controller: _rtController,
                    hint: '001',
                    keyboardType: TextInputType.number,
                    isRequired: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    label: 'RW',
                    controller: _rwController,
                    hint: '002',
                    keyboardType: TextInputType.number,
                    isRequired: false,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildDropdown(
              label: 'Provinsi',
              value: _selectedProvinsi,
              items: _provinsiList,
              hint: 'Pilih Provinsi',
              onChanged: (value) {
                setState(() {
                  _selectedProvinsi = value;
                  _selectedKota = null;
                  _selectedKecamatan = null;
                  _selectedKelurahan = null;
                });
              },
            ),

            const SizedBox(height: 16),

            _buildDropdown(
              label: 'Kota/Kabupaten',
              value: _selectedKota,
              items:
                  _selectedProvinsi != null
                      ? (_kotaList[_selectedProvinsi!] ?? [])
                      : [],
              hint: 'Pilih Kota/Kabupaten',
              enabled: _selectedProvinsi != null,
              onChanged: (value) {
                setState(() {
                  _selectedKota = value;
                  _selectedKecamatan = null;
                  _selectedKelurahan = null;
                });
              },
            ),

            const SizedBox(height: 16),

            _buildDropdown(
              label: 'Kecamatan',
              value: _selectedKecamatan,
              items:
                  _selectedKota != null
                      ? (_kecamatanList[_selectedKota!] ?? [])
                      : [],
              hint: 'Pilih Kecamatan',
              enabled: _selectedKota != null,
              onChanged: (value) {
                setState(() {
                  _selectedKecamatan = value;
                  _selectedKelurahan = null;
                });
              },
            ),

            const SizedBox(height: 16),

            // ✅ BENAR - Tanpa Expanded
            _buildDropdown(
              label: 'Kelurahan',
              value: _selectedKelurahan,
              items:
                  _selectedKecamatan != null
                      ? (_kelurahanList[_selectedKecamatan!] ?? [])
                      : [],
              hint: 'Pilih Kelurahan',
              enabled: _selectedKecamatan != null,
              onChanged: (value) {
                setState(() {
                  _selectedKelurahan = value;
                });
              },
            ),

            const SizedBox(height: 16),

            // ✅ BENAR - Tanpa Expanded
            _buildDropdown(
              label: 'Kode Pos',
              value: _selectedKodepos,
              items: _kodeposList,
              hint: 'Pilih Kode Pos',
              onChanged: (value) {
                setState(() {
                  _selectedKodepos = value;
                });
              },
            ),

            const SizedBox(height: 32), // Tambah spacing sebelum tombol
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
              child: const Text(
                'Simpan dan Gunakan Alamat',
                style: TextStyle(
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
            if (label == 'Nomor Handphone' &&
                value != null &&
                value.isNotEmpty) {
              if (!RegExp(r'^08[0-9]{8,11}$').hasMatch(value)) {
                return 'Format nomor HP tidak valid';
              }
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

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required String hint,
    required void Function(String?) onChanged,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 12,
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
            color: enabled ? Colors.grey[50] : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: InputBorder.none,
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: enabled ? Colors.grey[600] : Colors.grey[400],
            ),
            items:
                items.isEmpty
                    ? null
                    : items.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item, style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
            onChanged: enabled ? onChanged : null,
          ),
        ),
      ],
    );
  }
}
