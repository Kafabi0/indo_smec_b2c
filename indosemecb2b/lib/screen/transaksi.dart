import 'dart:math';

import 'package:flutter/material.dart';
import 'package:indosemecb2b/models/tracking.dart';
import 'package:indosemecb2b/screen/lacak.dart';
import 'package:indosemecb2b/screen/main_navigasi.dart';
import 'package:indosemecb2b/utils/transaction_manager.dart';
import 'package:indosemecb2b/models/transaction.dart';
import 'package:indosemecb2b/utils/user_data_manager.dart';
import 'package:intl/intl.dart';

class TransaksiScreen extends StatefulWidget {
  const TransaksiScreen({Key? key}) : super(key: key);

  @override
  State<TransaksiScreen> createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends State<TransaksiScreen>
    with WidgetsBindingObserver {
  String selectedStatus = 'Semua Status';
  String selectedTanggal = 'Semua Tanggal';
  String selectedKategori = 'Semua';
  String formatRupiah(double number) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp.',
      decimalDigits: 0,
    );
    return formatCurrency.format(number);
  }

  bool _isLoading = true;
  List<Transaction> _transactions = [];

  final List<String> kategoriList = [
    'Semua',
    'Xtra',
    'Xpress',
    'Food',
    'Virtual',
    'Merchant',
  ];

  @override
  void initState() {
    super.initState();
    // ⭐ Tambahkan observer untuk detect app lifecycle
    WidgetsBinding.instance.addObserver(this);
    _loadTransactions();
  }

  @override
  void dispose() {
    // ⭐ Remove observer saat dispose
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ⭐ Detect ketika app kembali ke foreground
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('🔄 App resumed - Reloading transactions...');
      _loadTransactions();
    }
  }

  // ⭐ PENTING: Ini akan dipanggil setiap kali widget rebuild
  @override
  void didUpdateWidget(TransaksiScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('🔄 Widget updated - Reloading transactions...');
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    if (!mounted) return;

    print('📥 Loading transactions...');

    setState(() {
      _isLoading = true;
    });

    // Tambahkan sedikit delay untuk memastikan data sudah tersimpan
    await Future.delayed(const Duration(milliseconds: 100));

    // Debug: Cek user login
    final userLogin = await UserDataManager.getCurrentUserLogin();
    print('🔍 DEBUG TRANSAKSI - Current user login: $userLogin');

    final transactions = await TransactionManager.getFilteredTransactions(
      status: selectedStatus,
      dateFilter: selectedTanggal,
      category: selectedKategori,
    );
    final statuses = ['Diproses', 'Selesai'];
    for (var t in transactions) {
      t.status = statuses[Random().nextInt(statuses.length)];
    }

    // Debug: Cek jumlah transaksi
    print(
      '🔍 DEBUG TRANSAKSI - Total transactions loaded: ${transactions.length}',
    );
    if (transactions.isNotEmpty) {
      print(
        '🔍 DEBUG TRANSAKSI - Latest transaction ID: ${transactions[0].id}',
      );
      print(
        '🔍 DEBUG TRANSAKSI - Latest transaction date: ${transactions[0].date}',
      );
    }

    if (!mounted) return;

    setState(() {
      _transactions = transactions;
      _isLoading = false;
    });

    print('✅ Transactions loaded successfully');
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final month = months[date.month];
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day $month $year, $hour:$minute';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Selesai':
        return Colors.green;
      // case 'Dibatalkan':
      //   return Colors.red;
      case 'Diproses':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getDeliveryIcon(String deliveryOption) {
    return deliveryOption == 'xpress'
        ? Icons.flash_on
        : Icons.inventory_2_outlined;
  }

  Color _getDeliveryColor(String deliveryOption) {
    return deliveryOption == 'xpress'
        ? Colors.orange[400]!
        : Colors.green[400]!;
  }

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
          // Tombol refresh manual
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadTransactions,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTransactions,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                        ['Semua Status', 'Selesai', 'Dibatalkan', 'Diproses'],
                        (value) {
                          setState(() => selectedStatus = value!);
                          _loadTransactions();
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildDropdown(
                        selectedTanggal,
                        [
                          'Semua Tanggal',
                          '7 Hari Terakhir',
                          '30 Hari Terakhir',
                        ],
                        (value) {
                          setState(() => selectedTanggal = value!);
                          _loadTransactions();
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
                    children:
                        kategoriList.map((item) {
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

                const SizedBox(height: 20),

                // Content: Loading, Empty, or Transaction List
                _isLoading
                    ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    )
                    : _transactions.isEmpty
                    ? _buildEmptyState()
                    : _buildTransactionList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 20),
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
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Yuk, mulai belanja kebutuhanmu di Klik Indomaret!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MainNavigation()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 22),
            ),
            child: const Text(
              'Mulai Belanja',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final transaction = _transactions[index];
        return _buildTransactionCard(transaction);
      },
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Grocery',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(transaction.status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  transaction.status,
                  style: TextStyle(
                    color: _getStatusColor(transaction.status),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),
          Text(
            _formatDate(transaction.date),
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),

          const SizedBox(height: 14),

          Text(
            transaction.deliveryOption == 'xpress'
                ? 'Belanja Xpress'
                : 'Belanja Xtra',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 2),
          Text(
            'No. Transaksi - ${transaction.id}',
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),

          const SizedBox(height: 14),

          ...transaction.items.take(1).map((item) {
            return Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.imageUrl ?? '',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey[200],
                          child: Icon(Icons.image, color: Colors.grey[400]),
                        ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'x${item.quantity}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),

          if (transaction.items.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '+${transaction.items.length - 1} produk lainnya',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: () {
                  if (transaction.status == "Selesai") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => MainNavigation()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => TrackingScreen(
                              trackingData: OrderTrackingModel(
                                courierName: "Tryan Gumilar",
                                courierId: "D 4563 ADP",
                                statusMessage: transaction.status,
                                statusDesc: "Pesananmu sedang diproses",
                                updatedAt: transaction.date ?? DateTime.now(),
                              ),
                            ),
                      ),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color:
                        transaction.status == "Selesai"
                            ? Colors.blue[700]!
                            : Colors.blue[700]!,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  transaction.status == "Selesai" ? "Beli Lagi" : "Lacak",
                  style: TextStyle(
                    fontSize: 13,
                    color:
                        transaction.status == "Selesai"
                            ? Colors.blue[700]
                            : Colors.blue[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Text(
                'Total ${formatRupiah(transaction.totalPrice)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTransactionDetail(Transaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Detail Transaksi',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildDetailRow('ID Transaksi', transaction.id),
                      _buildDetailRow('Tanggal', _formatDate(transaction.date)),
                      _buildDetailRow('Status', transaction.status),
                      _buildDetailRow(
                        'Metode Pengiriman',
                        transaction.deliveryOption == 'xpress'
                            ? 'Belanja Xpress'
                            : 'Belanja Xtra',
                      ),

                      const SizedBox(height: 20),
                      const Text(
                        'Alamat Pengiriman',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          transaction.alamat?['alamat_lengkap'] ??
                              'Alamat tidak tersedia',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),

                      const SizedBox(height: 20),
                      const Text(
                        'Daftar Produk',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      ...transaction.items.map((item) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item.imageUrl ?? '',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[200],
                                      child: Icon(
                                        Icons.image,
                                        color: Colors.grey[400],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      formatRupiah(item.totalPrice),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Jumlah: ${item.quantity}',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                formatRupiah(item.totalPrice),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Pembayaran',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              formatRupiah(transaction.totalPrice),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
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
          items:
              options.map((String value) {
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
    IconData? icon;
    switch (item) {
      case 'Xtra':
        icon = Icons.inventory_2_outlined;
        break;
      case 'Xpress':
        icon = Icons.flash_on;
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
        icon = null;
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
        _loadTransactions();
      },
    );
  }
}
