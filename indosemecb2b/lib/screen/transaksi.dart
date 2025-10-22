import 'package:flutter/material.dart';

class TransaksiScreen extends StatefulWidget {
  const TransaksiScreen({Key? key}) : super(key: key);

  @override
  State<TransaksiScreen> createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends State<TransaksiScreen> {
  String selectedStatus = 'Semua Status';
  String selectedTanggal = 'Semua Tanggal';
  String selectedKategori = 'Semua';

  final List<String> kategoriList = [
    'Semua',
    'Xtra',
    'Xpress',
    'Food',
    'Virtual',
    'Merchant',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Daftar Transaksi',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dropdown filter
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      selectedStatus,
                      ['Semua Status', 'Selesai', 'Dibatalkan'],
                      (value) {
                        setState(() => selectedStatus = value!);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildDropdown(
                      selectedTanggal,
                      ['Semua Tanggal', '7 Hari Terakhir', '30 Hari Terakhir'],
                      (value) {
                        setState(() => selectedTanggal = value!);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Tab kategori
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: kategoriList.map((item) {
                    final isSelected = selectedKategori == item;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildKategoriChip(item, isSelected),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // Info box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kamu dapat melihat daftar transaksi, termasuk transaksi Parcel Lebaran, dari Klik Indomaret versi sebelumnya.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 16,
                              ),
                            ),
                            child: const Text(
                              'Daftar Transaksi Sebelumnya',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Tampilan kosong
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.receipt_long_outlined,
                        color: Colors.blue[600],
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Belum ada transaksi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Yuk, mulai belanja kebutuhanmu di Klik Indomaret!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 22,
                        ),
                      ),
                      child: const Text(
                        'Mulai Belanja',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String currentValue,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(50),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentValue,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
          style: const TextStyle(fontSize: 13, color: Colors.black),
          onChanged: onChanged,
          items: options.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildKategoriChip(String item, bool isSelected) {
    // Tentukan ikon untuk tiap kategori
    IconData? icon;
    switch (item) {
      case 'Xtra':
        icon = Icons.local_offer_outlined;
        break;
      case 'Xpress':
        icon = Icons.delivery_dining_outlined;
        break;
      case 'Food':
        icon = Icons.restaurant_outlined;
        break;
      case 'Virtual':
        icon = Icons.devices_other_outlined;
        break;
      case 'Merchant':
        icon = Icons.store_mall_directory_outlined;
        break;
      default:
        icon = null; // “Semua” tidak pakai ikon
    }

    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 6),
          ],
          Text(item),
        ],
      ),
      selected: isSelected,
      showCheckmark: false,
      backgroundColor: Colors.white,
      selectedColor: Colors.blue[700],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: BorderSide(
          color: isSelected ? Colors.white : Colors.grey[300]!,
          width: 1,
        ),
      ),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[600],
        fontWeight: FontWeight.w600,
      ),
      onSelected: (_) {
        setState(() => selectedKategori = item);
      },
    );
  }
}
