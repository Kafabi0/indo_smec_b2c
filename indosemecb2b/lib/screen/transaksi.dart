// ignore_for_file: avoid_print

import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:indosemecb2b/models/tracking.dart';
import 'package:indosemecb2b/screen/detail_transaksi.dart';
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
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatCurrency.format(number);
  }

  bool _isLoading = true;
  List<Transaction> _transactions = [];
  List<Transaction> _allTransactions = [];

  final List<String> kategoriList = [
    'Semua',
    'Xtra', // Delivery option: xtra
    'Xpress', // Delivery option: xpress
    'Top-Up', // Delivery option: topup
    'Food', // Kategori produk: Food
    'Grocery', // Kategori produk: Grocery
    'Fashion', // Kategori produk: Fashion
    'Herbal', // Kategori produk: Herbal
    'Kerajinan', // Kategori produk: Kerajinan
    'Pertanian', // Kategori produk: Pertanian
    'Kreatif', // Kategori produk: Kreatif
    'Jasa', // Kategori produk: Jasa ⭐ TAMBAHAN INI
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadTransactions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('🔄 App resumed - Reloading transactions...');
      _loadTransactions();
    }
  }

  @override
  void didUpdateWidget(TransaksiScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('🔄 Widget updated - Reloading transactions...');
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    if (!mounted) return;

    print('📥 Loading transactions...');
    print(
      '🔍 Current filters - Status: $selectedStatus, Tanggal: $selectedTanggal, Kategori: $selectedKategori',
    );

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 100));

    final userLogin = await UserDataManager.getCurrentUserLogin();
    print('🔍 DEBUG TRANSAKSI - Current user login: $userLogin');

    final allTransactions = await TransactionManager.getTransactions();

    print('🔍 DEBUG TRANSAKSI - Raw transactions: ${allTransactions.length}');

    for (var t in allTransactions) {
      print('  - ${t.id}: ${t.status}');
    }

    if (!mounted) return;

    setState(() {
      _allTransactions = List.from(allTransactions);
      _isLoading = false;
    });

    print(
      '🔍 DEBUG TRANSAKSI - _allTransactions set to: ${_allTransactions.length}',
    );

    _applyFilters();

    print('✅ Transactions loaded successfully');
  }

  void _applyFilters() {
    print('🔍 Applying filters...');
    print('📊 All transactions count: ${_allTransactions.length}');

    List<Transaction> filtered = List.from(_allTransactions);

    // Filter by Status
    if (selectedStatus != 'Semua Status') {
      filtered = filtered.where((t) => t.status == selectedStatus).toList();
      print('📊 After status filter ($selectedStatus): ${filtered.length}');
    }

    // Filter by Date
    if (selectedTanggal != 'Semua Tanggal') {
      final now = DateTime.now();
      DateTime startDate;

      if (selectedTanggal == '7 Hari Terakhir') {
        startDate = now.subtract(const Duration(days: 7));
      } else if (selectedTanggal == '30 Hari Terakhir') {
        startDate = now.subtract(const Duration(days: 30));
      } else {
        startDate = DateTime(1970);
      }

      filtered = filtered.where((t) => t.date.isAfter(startDate)).toList();
      print('📊 After date filter ($selectedTanggal): ${filtered.length}');
    }

    // ⭐ Filter by Category
    if (selectedKategori != 'Semua') {
      // Kategori berdasarkan Delivery Option
      if (selectedKategori == 'Xpress') {
        filtered = filtered.where((t) => t.deliveryOption == 'xpress').toList();
      } else if (selectedKategori == 'Xtra') {
        filtered = filtered.where((t) => t.deliveryOption == 'xtra').toList();
      } else if (selectedKategori == 'Top-Up') {
        filtered = filtered.where((t) => t.deliveryOption == 'topup').toList();
      }
      // ⭐ Kategori berdasarkan Product Category
      else {
        print('🔍 Filtering by category: $selectedKategori');
        filtered =
            filtered.where((t) {
              // Debug: print items di transaksi ini
              print('  Checking transaction ${t.id}:');
              for (var item in t.items) {
                print('    - Item: ${item.name}, Category: ${item.category}');
              }

              // Cek apakah ada item yang kategorinya sesuai
              final hasMatch = t.items.any(
                (item) => item.category == selectedKategori,
              );
              print('  Match found: $hasMatch');
              return hasMatch;
            }).toList();
      }

      print('📊 After category filter ($selectedKategori): ${filtered.length}');
    }

    setState(() {
      _transactions = filtered;
    });

    print('✅ Filters applied. Final count: ${_transactions.length}');
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
      case 'Dibatalkan':
        return Colors.red;
      case 'Diproses':
        return Colors.orange;
      case 'Sedang dikirim':
        return Colors.blue;
      case 'Hampir sampai':
        return Colors.purple;
      case 'Mendekati tujuan':
        return const Color.fromARGB(255, 232, 132, 9);
      case 'Pesanan telah sampai':
        return Colors.teal;
      // case 'selesai':
      //   return Colors.green;
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
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        selectedStatus,
                        [
                          'Semua Status',
                          'Selesai',
                          'Dibatalkan',
                          'Diproses',
                          'Sedang dikirim',
                          'Hampir sampai',
                          'Pesanan telah sampai',
                          // 'Selesai',
                        ],
                        (value) {
                          if (value != null && value != selectedStatus) {
                            print(
                              '📝 Status changed: $selectedStatus -> $value',
                            );
                            setState(() => selectedStatus = value);
                            _applyFilters();
                          }
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
                          if (value != null && value != selectedTanggal) {
                            print(
                              '📝 Date filter changed: $selectedTanggal -> $value',
                            );
                            setState(() => selectedTanggal = value);
                            _applyFilters();
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

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

                if (!_isLoading && _allTransactions.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Menampilkan ${_transactions.length} dari ${_allTransactions.length} transaksi',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],

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
    final isFiltered =
        selectedStatus != 'Semua Status' ||
        selectedTanggal != 'Semua Tanggal' ||
        selectedKategori != 'Semua';

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
              isFiltered ? Icons.filter_alt_off : Icons.receipt_long_outlined,
              color: Colors.blue[600],
              size: 48,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isFiltered ? 'Tidak ada transaksi' : 'Belum ada transaksi',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            isFiltered
                ? 'Tidak ada transaksi yang sesuai dengan filter'
                : 'Yuk, mulai belanja kebutuhanmu di Klik Indomaret!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
          const SizedBox(height: 16),
          if (isFiltered)
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  selectedStatus = 'Semua Status';
                  selectedTanggal = 'Semua Tanggal';
                  selectedKategori = 'Semua';
                });
                _applyFilters();
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('Reset Filter'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue[600],
                side: BorderSide(color: Colors.blue[600]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 22,
                ),
              ),
            )
          else
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
    return FutureBuilder<List<Transaction>>(
      future: Future.value([transaction]),
      builder: (context, snapshot) {
        return ValueListenableBuilder<String>(
          valueListenable: TransactionManager.statusNotifier,
          builder: (context, triggerValue, child) {
            return FutureBuilder<Transaction?>(
              future: _getUpdatedTransaction(transaction.id),
              builder: (context, txSnapshot) {
                final currentTransaction = txSnapshot.data ?? transaction;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => TransactionDetailScreen(
                              transaction: currentTransaction,
                            ),
                      ),
                    );
                  },
                  child: Container(
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
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  currentTransaction.status,
                                ).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                currentTransaction.status,
                                style: TextStyle(
                                  color: _getStatusColor(
                                    currentTransaction.status,
                                  ),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),
                        Text(
                          _formatDate(currentTransaction.date),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),

                        const SizedBox(height: 14),

                        Text(
                          currentTransaction.deliveryOption == 'topup'
                              ? 'Top-Up Saldo Klik' // ✅ ADD
                              : currentTransaction.deliveryOption == 'xpress'
                              ? 'Belanja Xpress'
                              : 'Belanja Xtra',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'No. Transaksi - ${currentTransaction.id}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),

                        const SizedBox(height: 14),

                        ...currentTransaction.items.take(1).map((item) {
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
                                        child: Icon(
                                          Icons.image,
                                          color: Colors.grey[400],
                                        ),
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
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),

                        if (currentTransaction.items.length > 1)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              '+${currentTransaction.items.length - 1} produk lainnya',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                        const SizedBox(height: 14),

                        // ⭐ Jika status "Pesanan telah sampai", tampilkan tombol konfirmasi
                        if (currentTransaction.status == "Pesanan telah sampai")
                          Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.orange[200]!,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.orange[700],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Pesanan sudah sampai? Konfirmasi penerimaan pesanan Anda',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.orange[900],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed:
                                          () => _showConfirmDialog(
                                            context,
                                            currentTransaction,
                                          ),
                                      icon: const Icon(
                                        Icons.check_circle_outline,
                                        size: 18,
                                      ),
                                      label: const Text(
                                        'Pesanan Diterima',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green[600],
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => TrackingScreen(
                                                trackingData: OrderTrackingModel(
                                                  transactionId:
                                                      currentTransaction.id,
                                                  courierName: "Tryan Gumilar",
                                                  courierId: "D 4563 ADP",
                                                  statusMessage:
                                                      currentTransaction.status,
                                                  statusDesc:
                                                      "Pesananmu sedang diproses",
                                                  updatedAt:
                                                      currentTransaction.date ??
                                                      DateTime.now(),
                                                ),
                                              ),
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: Colors.blue[700]!,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 16,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.location_on_outlined,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        else if (currentTransaction.deliveryOption ==
                            'topup') // ✅ ADD
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.green[200]!),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green[700],
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Berhasil',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'Total ${formatRupiah(currentTransaction.finalTotal)}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  if (currentTransaction.status == "Selesai") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => MainNavigation(),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => TrackingScreen(
                                              trackingData: OrderTrackingModel(
                                                transactionId:
                                                    currentTransaction.id,
                                                courierName: "Tryan Gumilar",
                                                courierId: "D 4563 ADP",
                                                statusMessage:
                                                    currentTransaction.status,
                                                statusDesc:
                                                    "Pesananmu sedang diproses",
                                                updatedAt:
                                                    currentTransaction.date ??
                                                    DateTime.now(),
                                              ),
                                            ),
                                      ),
                                    );
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.blue[700]!),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                child: Text(
                                  (currentTransaction.status == "Selesai")
                                      ? "Beli Lagi"
                                      : "Lacak",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.blue[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              Text(
                                'Total ${formatRupiah(_calculateFinalTotal(currentTransaction))}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  double _calculateFinalTotal(Transaction transaction) {
    final discount = transaction.voucherDiscount ?? 0.0;
    return transaction.totalPrice - discount;
  }

  // ⭐ Method untuk menampilkan dialog konfirmasi
  void _showConfirmDialog(BuildContext context, Transaction transaction) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green[600],
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Konfirmasi Penerimaan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Apakah Anda sudah menerima pesanan ini?',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No. Transaksi',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      transaction.id,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Dengan mengkonfirmasi, status pesanan akan berubah menjadi "Selesai".',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();

                // Show loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder:
                      (_) => const Center(child: CircularProgressIndicator()),
                );

                // Confirm order received
                await TransactionManager.confirmOrderReceived(transaction.id);

                // Wait a bit for update
                await Future.delayed(const Duration(milliseconds: 500));

                if (!mounted) return;
                Navigator.of(context).pop(); // Close loading

                // Reload transactions
                await _loadTransactions();

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: const [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Pesanan berhasil dikonfirmasi!',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.green[600],
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Ya, Sudah Terima',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ⭐ Helper untuk fetch status terbaru dari storage
  Future<Transaction?> _getUpdatedTransaction(String transactionId) async {
    try {
      final allTransactions = await TransactionManager.getTransactions();
      return allTransactions.firstWhere(
        (t) => t.id == transactionId,
        orElse: () => _transactions.firstWhere((t) => t.id == transactionId),
      );
    } catch (e) {
      return null;
    }
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
          isExpanded: true,
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

    // Icons untuk Delivery Options
    if (item == 'Xtra') {
      icon = Icons.inventory_2_outlined;
    } else if (item == 'Xpress') {
      icon = Icons.flash_on;
    } else if (item == 'Top-Up') {
      icon = Icons.account_balance_wallet;
    }
    // Icons untuk Product Categories
    else if (item == 'Food') {
      icon = Icons.restaurant_outlined;
    } else if (item == 'Grocery') {
      icon = Icons.shopping_basket_outlined;
    } else if (item == 'Fashion') {
      icon = Icons.checkroom_outlined;
    } else if (item == 'Herbal') {
      icon = Icons.local_pharmacy_outlined;
    } else if (item == 'Kerajinan') {
      icon = Icons.handyman_outlined;
    } else if (item == 'Pertanian') {
      icon = Icons.agriculture_outlined;
    } else if (item == 'Kreatif') {
      icon = Icons.palette_outlined;
    } else if (item == 'Jasa') {
      icon = Icons.room_service_outlined; // ⭐ ICON JASA
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
        print('📝 Category changed: $selectedKategori -> $item');
        setState(() => selectedKategori = item);
        _applyFilters();
      },
    );
  }
}
