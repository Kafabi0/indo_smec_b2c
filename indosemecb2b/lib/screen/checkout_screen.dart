// ============================================
// UPDATED: screen/checkout.dart dengan Voucher (FIXED)
// ============================================

// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:indosemecb2b/models/transaction.dart';
import 'package:indosemecb2b/screen/main_navigasi.dart';
import 'package:indosemecb2b/screen/metode_pembayaran.dart';
import 'package:indosemecb2b/screen/notification_provider.dart';
import 'package:indosemecb2b/screen/pembayaran_berhasil.dart';
import 'package:indosemecb2b/screen/transaksi.dart';
import 'package:indosemecb2b/services/notifikasi.dart';
import 'package:indosemecb2b/utils/cart_manager.dart';
import 'package:indosemecb2b/utils/saldo_klik_manager.dart';
import 'package:indosemecb2b/utils/transaction_manager.dart';
import 'package:indosemecb2b/models/cart_item.dart';
import 'package:indosemecb2b/utils/user_data_manager.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

// ✅ IMPORT VOUCHER
import 'package:indosemecb2b/models/voucher_model.dart';
import 'package:indosemecb2b/utils/voucher_manager.dart';

class CheckoutScreen extends StatefulWidget {
  final Map<String, dynamic>? alamat;
  final String deliveryOption;
  final String? catatanPengiriman;

  CheckoutScreen({
    required this.alamat,
    required this.deliveryOption,
    required this.catatanPengiriman,
  });

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  List<CartItem> _cartItems = [];
  bool _isLoading = true;
  bool _isProcessing = false;

  // ✅ TAMBAH STATE UNTUK VOUCHER
  UserVoucher? _selectedVoucher;
  List<UserVoucher> _availableVouchers = [];

  // ✅ TAMBAH STATE UNTUK POIN UMKM
  int _userPoinUMKM = 0;

  String formatRupiah(double value) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return format.format(value);
  }

  @override
  void initState() {
    super.initState();
    loadData();
    _loadAvailableVouchers();
    _loadUserPoints(); // ✅ LOAD POIN UMKM
  }

  Future<void> loadData() async {
    final cartItems = await CartManager.getCartItems();
    setState(() {
      _cartItems = cartItems;
      _isLoading = false;
    });
  }

  // ✅ LOAD POIN UMKM USER
  Future<void> _loadUserPoints() async {
    final points = await VoucherManager.getUserPoinUMKM();
    setState(() {
      _userPoinUMKM = points;
    });
  }

  // ✅ LOAD VOUCHER YANG TERSEDIA
  Future<void> _loadAvailableVouchers() async {
    final vouchers = await VoucherManager.getUserVouchers(onlyValid: true);

    // Filter voucher yang bisa dipakai untuk transaksi ini
    final category =
        _cartItems.isNotEmpty ? _cartItems.first.category : 'Semua';
    final usableVouchers =
        vouchers.where((v) {
          // Cek minimal pembelian
          if (getSubtotal() < v.minPurchase) return false;

          // Cek kategori
          if (v.category != 'Semua' && v.category != category) return false;

          return true;
        }).toList();

    setState(() {
      _availableVouchers = usableVouchers;
    });
  }

  // ✅ SHOW VOUCHER SELECTOR (DENGAN 2 TAB)
  Future<void> _showVoucherSelector() async {
    final selectedVoucher = await showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => VoucherSelectorBottomSheet(
            currentTotal: getSubtotal().toInt(),
            selectedVoucher: _selectedVoucher,
            userPoints: _userPoinUMKM, // ✅ Pass user points
          ),
    );

    if (selectedVoucher != null ||
        selectedVoucher == null && _selectedVoucher != null) {
      setState(() {
        _selectedVoucher = selectedVoucher;
      });

      // ✅ RELOAD POIN SETELAH PENUKARAN VOUCHER
      await _loadUserPoints();
    }
  }

  double getSubtotal() =>
      _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  double getBiayaPengiriman() => 5000.0;

  // ✅ CALCULATE DISCOUNT FROM VOUCHER
  double getVoucherDiscount() {
    if (_selectedVoucher == null) return 0.0;
    return VoucherManager.calculateDiscount(
      _selectedVoucher!,
      getSubtotal().toInt(),
    ).toDouble();
  }

  // ✅ TOTAL DENGAN VOUCHER
  double getTotal() {
    final subtotal = getSubtotal();
    final shipping = getBiayaPengiriman();
    final discount = getVoucherDiscount();
    return subtotal + shipping - discount;
  }

  // ============================================
  // FIXED: screen/checkout.dart - Payment Logic
  // ============================================

  // Di CheckoutScreen, ubah method _processCheckout:

  Future<void> _processCheckout(String paymentType) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Extract alamat
      String penerimaName = 'N/A';
      String alamatLengkap = 'Alamat tidak tersedia';
      String nomorHP = 'N/A';

      if (widget.alamat != null) {
        penerimaName =
            widget.alamat!['nama_penerima']?.toString() ??
            widget.alamat!['nama']?.toString() ??
            'N/A';

        nomorHP = widget.alamat!['nomor_hp']?.toString() ?? 'N/A';

        final List<String> alamatParts = [];

        if (widget.alamat!['alamat_lengkap'] != null &&
            widget.alamat!['alamat_lengkap'].toString().isNotEmpty) {
          alamatParts.add(widget.alamat!['alamat_lengkap'].toString());
        }

        if (widget.alamat!['kelurahan'] != null) {
          alamatParts.add('Kel. ${widget.alamat!['kelurahan']}');
        }

        if (widget.alamat!['kecamatan'] != null) {
          alamatParts.add('Kec. ${widget.alamat!['kecamatan']}');
        }

        if (widget.alamat!['kota'] != null) {
          alamatParts.add(widget.alamat!['kota'].toString());
        }

        if (widget.alamat!['provinsi'] != null) {
          alamatParts.add(widget.alamat!['provinsi'].toString());
        }

        if (widget.alamat!['kodepos'] != null) {
          alamatParts.add(widget.alamat!['kodepos'].toString());
        }

        if (alamatParts.isNotEmpty) {
          alamatLengkap = alamatParts.join(', ');
        }
      }

      // ✅ CEK APAKAH PEMBAYARAN KOMBINASI
      bool isKombinasi = paymentType.startsWith('Kombinasi');
      bool isPoinCashOnly = paymentType == 'Poin Cash';
      double poinCashUsed = 0.0;
      String actualPaymentMethod = paymentType;

      if (isKombinasi) {
        // Extract jumlah Poin Cash yang digunakan
        // Format: "Kombinasi: Poin Cash (Rp50000) + GoPay"
        final regex = RegExp(r'Poin Cash \(Rp(\d+)\)');
        final match = regex.firstMatch(paymentType);

        if (match != null) {
          poinCashUsed = double.parse(match.group(1)!);
          print('💰 Poin Cash digunakan dalam kombinasi: Rp$poinCashUsed');

          // Extract metode pembayaran sisanya
          final parts = paymentType.split(' + ');
          if (parts.length > 1) {
            actualPaymentMethod = parts[1];
          }
        }
      } else if (isPoinCashOnly) {
        poinCashUsed = getTotal();
        print('💰 Poin Cash digunakan (full): Rp$poinCashUsed');
      }

      // ✅ SIMPAN TRANSAKSI DENGAN METADATA POIN CASH
      final alamatData = <String, dynamic>{
        'nama_penerima': penerimaName,
        'nomor_hp': nomorHP,
        'alamat_lengkap': alamatLengkap,
        'kelurahan': widget.alamat?['kelurahan'],
        'kecamatan': widget.alamat?['kecamatan'],
        'kota': widget.alamat?['kota'],
        'provinsi': widget.alamat?['provinsi'],
        'kodepos': widget.alamat?['kodepos'],
        'metode_pembayaran': isKombinasi ? actualPaymentMethod : paymentType,
        'voucher_code': _selectedVoucher?.code,
        'voucher_discount': getVoucherDiscount(),
      };

      // ⭐ TAMBAHKAN METADATA POIN CASH (jika digunakan)
      if (isPoinCashOnly || isKombinasi) {
        alamatData['poin_cash_used'] = poinCashUsed;
        alamatData['is_using_poin_cash'] = true;
      }

      // ⭐ DAPATKAN TRANSACTION ID DARI createTransaction
      final transactionId = await TransactionManager.createTransaction(
        cartItems: _cartItems,
        deliveryOption: widget.deliveryOption,
        alamat: alamatData,
        catatanPengiriman: widget.catatanPengiriman,
        metodePembayaran: isKombinasi ? actualPaymentMethod : paymentType,
        initialStatus:
            isPoinCashOnly
                ? 'Selesai'
                : null, // Langsung selesai jika full Poin Cash
      );

      // ✅ CEK APAKAH TRANSAKSI BERHASIL DIBUAT
      if (transactionId != null && transactionId.isNotEmpty) {
        print('✅ Transaction created with ID: $transactionId');

        // ✅ USE VOUCHER (MARK AS USED)
        if (_selectedVoucher != null) {
          await VoucherManager.useVoucher(_selectedVoucher!.id, transactionId);
        }

        if (paymentType == "Saldo Klik") {
          print('✅ Payment with Saldo Klik (PIN already verified)');
        }

        // Clear cart
        await CartManager.clearCart();

        // Prepare transaction data
        final transactionData = <String, dynamic>{
          'no_transaksi': transactionId,
          'id': transactionId,
          'tanggal': DateTime.now().toIso8601String(),
          'date': DateTime.now().toIso8601String(),
          'status': isPoinCashOnly ? 'Selesai' : 'Diproses',
          'metode_pembayaran': paymentType,
          'voucher_code': _selectedVoucher?.code,
          'voucher_discount': getVoucherDiscount(),
          'items':
              _cartItems
                  .map(
                    (item) => {
                      'nama': item.name,
                      'name': item.name,
                      'quantity': item.quantity,
                      'harga': item.price,
                      'price': item.price,
                      'image': item.imageUrl ?? '',
                      'imageUrl': item.imageUrl ?? '',
                    },
                  )
                  .toList(),
          'penerima': penerimaName,
          'nomor_hp': nomorHP,
          'alamat': alamatLengkap,
          'metode_pengiriman':
              widget.deliveryOption.contains('xpress')
                  ? 'Xpress (Rp5.000)'
                  : 'Reguler (Rp5.000)',
          'deliveryOption': widget.deliveryOption,
          'jadwal_pengiriman':
              'Dikirim : ${DateFormat('EEEE, d MMM yyyy, HH:mm', 'id_ID').format(DateTime.now())}',
          'biaya_pengiriman': 5000.0,
          'biaya_admin': 0.0,
          'delivery_option': widget.deliveryOption,
          'catatan_pengiriman': widget.catatanPengiriman ?? '',
          'catatanPengiriman': widget.catatanPengiriman ?? '',
          'delivery_note': widget.catatanPengiriman ?? '',
          'totalPrice': getTotal(),
        };

        // ⭐ TAMBAHKAN METADATA POIN CASH
        if (isPoinCashOnly || isKombinasi) {
          transactionData['poin_cash_used'] = poinCashUsed;
          transactionData['is_using_poin_cash'] = true;
        }

        if (mounted) {
          final firstProductImage =
              _cartItems.isNotEmpty ? _cartItems.first.imageUrl : null;

          final notifProvider = Provider.of<NotificationProvider>(
            context,
            listen: false,
          );

          await notifProvider.ensureUserLoaded();

          await NotificationService().showPaymentSuccessNotification(
            orderId: transactionId,
            paymentMethod: paymentType,
            totalAmount: getTotal(),
            productImage: firstProductImage,
            transactionData: transactionData,
          );

          await notifProvider.addPaymentSuccessNotification(
            orderId: transactionId,
            paymentMethod: paymentType,
            total: getTotal(),
            productImage: firstProductImage,
            transactionData: transactionData,
          );

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder:
                  (_) => PaymentSuccessScreen(
                    totalPembayaran: getTotal(),
                    metodePembayaran: paymentType,
                    tanggal: DateTime.now(),
                    voucherDiscount: getVoucherDiscount(),
                  ),
            ),
            (route) => false,
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal memproses pembayaran'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      print('❌ ERROR CHECKOUT: $e');
      print('❌ STACK TRACE: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 150),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Alamat Pengiriman
                          const Text(
                            "Alamat Pengiriman",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.blue[700],
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    widget.alamat?['alamat_lengkap'] ??
                                        'Alamat belum lengkap',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Catatan Pengiriman
                          if (widget.catatanPengiriman != null &&
                              widget.catatanPengiriman!.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blue[200]!),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.edit_note,
                                    color: Colors.blue[700],
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Catatan Pengiriman',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue[900],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          widget.catatanPengiriman!,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 20),

                          // ✅ VOUCHER SECTION
                          InkWell(
                            onTap: _showVoucherSelector,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color:
                                    _selectedVoucher != null
                                        ? Colors.green[50]
                                        : Colors.orange[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      _selectedVoucher != null
                                          ? Colors.green[200]!
                                          : Colors.orange[200]!,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.local_offer,
                                    color:
                                        _selectedVoucher != null
                                            ? Colors.green[700]
                                            : Colors.orange[700],
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child:
                                        _selectedVoucher != null
                                            ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Voucher Digunakan',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                Text(
                                                  _selectedVoucher!.code,
                                                  style: GoogleFonts.robotoMono(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.green[900],
                                                  ),
                                                ),
                                                Text(
                                                  'Hemat ${formatRupiah(getVoucherDiscount())}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.green[700],
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            )
                                            : Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Gunakan Voucher',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.orange[900],
                                                  ),
                                                ),
                                                Text(
                                                  _availableVouchers.isNotEmpty
                                                      ? '${_availableVouchers.length} voucher tersedia'
                                                      : 'Belum ada voucher',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey[400],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Daftar Produk
                          const Text(
                            "Daftar Produk",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ..._cartItems.map((item) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 12,
                              ),
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      item.imageUrl ?? "",
                                      width: 65,
                                      height: 65,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Container(
                                          width: 65,
                                          height: 65,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Jumlah: ${item.quantity}",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    formatRupiah(item.totalPrice),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                          const SizedBox(height: 20),

                          // Rincian Pembayaran
                          const Text(
                            "Rincian Pembayaran",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Subtotal Produk",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    Text(
                                      formatRupiah(getSubtotal()),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.local_shipping_outlined,
                                          size: 18,
                                          color: Colors.blue[700],
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "Biaya Pengiriman",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      formatRupiah(getBiayaPengiriman()),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),

                                // ✅ TAMPILKAN DISKON VOUCHER
                                if (_selectedVoucher != null) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.local_offer,
                                            size: 18,
                                            color: Colors.green[700],
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            "Diskon Voucher",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.green[700],
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '- ${formatRupiah(getVoucherDiscount())}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],

                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Divider(
                                    color: Colors.grey[300],
                                    thickness: 1,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Total Pembayaran",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      formatRupiah(getTotal()),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[700],
                                      ),
                                    ),
                                  ],
                                ),

                                // ✅ INFO HEMAT
                                if (_selectedVoucher != null) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.green[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.green[700],
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Anda hemat ${formatRupiah(getVoucherDiscount())} dengan voucher',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.green[900],
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_isProcessing)
                    Container(
                      color: Colors.black26,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total Pembayaran",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (_selectedVoucher != null)
                        Text(
                          formatRupiah(getSubtotal() + getBiayaPengiriman()),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      Text(
                        formatRupiah(getTotal()),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed:
                    _isProcessing
                        ? null
                        : () async {
                          double total = getTotal();

                          if (_cartItems.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Keranjang masih kosong!'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          if (total <= 0 || total.isNaN || total.isInfinite) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Total pembayaran tidak valid: $total',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          final selectedPayment = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => PaymentMethodScreen(
                                    totalPembayaran: total,
                                  ),
                            ),
                          );

                          if (selectedPayment != null && mounted) {
                            // Cek apakah menggunakan kombinasi
                            if (selectedPayment is Map) {
                              final poinCashUsed =
                                  selectedPayment['poinCashUsed'] ?? 0.0;
                              final remaining =
                                  selectedPayment['remaining'] ?? 0.0;

                              if (remaining > 0) {
                                // Masih ada sisa - perlu metode pembayaran tambahan
                                final additionalPayment = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => PaymentMethodScreen(
                                          totalPembayaran: remaining,
                                        ),
                                  ),
                                );

                                if (additionalPayment != null && mounted) {
                                  await _processCheckout(
                                    'Kombinasi: Poin Cash (Rp${poinCashUsed.toInt()}) + $additionalPayment',
                                  );
                                }
                              } else {
                                // Lunas dengan Poin Cash
                                await _processCheckout('Poin Cash');
                              }
                            } else {
                              // Metode pembayaran biasa
                              await _processCheckout(selectedPayment);
                            }
                          }
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey[400],
                ),
                child:
                    _isProcessing
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text(
                          "Lanjut ke Pembayaran",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String formatCurrency(int amount) {
  return 'Rp${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
}

// ============================================
// VOUCHER SELECTOR BOTTOM SHEET (2 TAB)
// ============================================

class VoucherSelectorBottomSheet extends StatefulWidget {
  final int currentTotal;
  final UserVoucher? selectedVoucher;
  final int userPoints;

  const VoucherSelectorBottomSheet({
    Key? key,
    required this.currentTotal,
    this.selectedVoucher,
    required this.userPoints,
  }) : super(key: key);

  @override
  State<VoucherSelectorBottomSheet> createState() =>
      _VoucherSelectorBottomSheetState();
}

class _VoucherSelectorBottomSheetState extends State<VoucherSelectorBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<UserVoucher> _myVouchers = [];
  List<Voucher> _availableVouchers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadVouchers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadVouchers() async {
    setState(() => _isLoading = true);

    // Load voucher milik user
    final myVouchers = await VoucherManager.getUserVouchers(onlyValid: true);

    // Filter yang bisa dipakai untuk total belanja ini
    final usableMyVouchers =
        myVouchers.where((v) {
          return widget.currentTotal >= v.minPurchase;
        }).toList();

    // Load semua voucher yang tersedia di toko
    final availableVouchers = VoucherManager.getAvailableVouchers();

    // Filter yang bisa dipakai untuk total belanja ini
    final usableAvailableVouchers =
        availableVouchers.where((v) {
          return widget.currentTotal >= v.minPurchase;
        }).toList();

    setState(() {
      _myVouchers = usableMyVouchers;
      _availableVouchers = usableAvailableVouchers;
      _isLoading = false;
    });
  }

  Future<void> _redeemAndUseVoucher(Voucher voucher) async {
    // Konfirmasi
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.redeem, color: Colors.orange[700]),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tukar & Gunakan Voucher?',
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  voucher.name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Biaya:'),
                          Row(
                            children: [
                              Icon(
                                Icons.stars,
                                color: Colors.orange[700],
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '${voucher.pointCost} Poin',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Hemat:'),
                          Text(
                            formatCurrency(voucher.discountAmount),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.blue[700],
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Poin UMKM Anda: ${widget.userPoints}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Tukar & Gunakan',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    // Proses penukaran
    final result = await VoucherManager.redeemVoucher(
      voucher.id,
      widget.userPoints,
    );

    Navigator.pop(context); // Close loading

    if (result['success']) {
      // Success - langsung gunakan voucher
      final userVoucher = result['voucher'] as UserVoucher;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${result['message']}'),
          backgroundColor: Colors.green[700],
          duration: Duration(seconds: 2),
        ),
      );

      // Tutup bottom sheet dan return voucher yang baru ditukar
      Navigator.pop(context, userVoucher);
    } else {
      // Error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.local_offer,
                      color: Colors.orange[700],
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Pilih Voucher',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.stars, color: Colors.orange[700], size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Poin UMKM Anda: ',
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      ),
                      Text(
                        '${widget.userPoints}',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[900],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab Bar
          TabBar(
            controller: _tabController,
            labelColor: Colors.blue[700],
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: Colors.blue[700],
            labelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            tabs: [
              Tab(text: 'Voucher Saya (${_myVouchers.length})'),
              Tab(text: 'Tukar Poin (${_availableVouchers.length})'),
            ],
          ),

          // Tab View
          Expanded(
            child:
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildMyVouchersTab(),
                        _buildAvailableVouchersTab(),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyVouchersTab() {
    if (_myVouchers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'Tidak ada voucher tersedia',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(
              'Tukar poin Anda untuk mendapatkan voucher',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _myVouchers.length + 1, // +1 untuk opsi "Tidak Pakai"
      itemBuilder: (context, index) {
        // Opsi "Tidak Pakai Voucher"
        if (index == 0) {
          return _buildNoVoucherOption();
        }

        final voucher = _myVouchers[index - 1];
        final discount = VoucherManager.calculateDiscount(
          voucher,
          widget.currentTotal,
        );
        final isSelected = widget.selectedVoucher?.id == voucher.id;

        return _buildMyVoucherCard(voucher, discount, isSelected);
      },
    );
  }

  Widget _buildAvailableVouchersTab() {
    if (_availableVouchers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.card_giftcard_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'Tidak ada voucher yang sesuai',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(
              'Minimum belanja tidak terpenuhi',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _availableVouchers.length,
      itemBuilder: (context, index) {
        final voucher = _availableVouchers[index];
        final canAfford = widget.userPoints >= voucher.pointCost;

        return _buildAvailableVoucherCard(voucher, canAfford);
      },
    );
  }

  Widget _buildNoVoucherOption() {
    final isSelected = widget.selectedVoucher == null;

    return InkWell(
      onTap: () => Navigator.pop(context, null),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue[700]! : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.block, color: Colors.grey[600]),
            SizedBox(width: 12),
            Text(
              'Tidak Pakai Voucher',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            Spacer(),
            if (isSelected) Icon(Icons.check_circle, color: Colors.blue[700]),
          ],
        ),
      ),
    );
  }

  Widget _buildMyVoucherCard(
    UserVoucher voucher,
    int discount,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () => Navigator.pop(context, voucher),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green[700]! : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                  : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.local_offer,
                    color: Colors.green[700],
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        voucher.name,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        voucher.code,
                        style: GoogleFonts.robotoMono(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: Colors.green[700]),
              ],
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hemat',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    formatCurrency(discount),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableVoucherCard(Voucher voucher, bool canAfford) {
    final estimatedDiscount =
        voucher.discountPercentage != null
            ? (widget.currentTotal * voucher.discountPercentage! / 100).round()
            : voucher.discountAmount;
    final finalDiscount =
        estimatedDiscount > voucher.discountAmount
            ? voucher.discountAmount
            : estimatedDiscount;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange[400]!, Colors.orange[600]!],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.local_offer,
                    color: Colors.orange[700],
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        voucher.name,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        voucher.code,
                        style: GoogleFonts.robotoMono(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Hemat',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              formatCurrency(finalDiscount),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.stars,
                                  size: 12,
                                  color: Colors.orange[700],
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Biaya',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${voucher.pointCost}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[900],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed:
                      canAfford ? () => _redeemAndUseVoucher(voucher) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        canAfford ? Colors.blue[700] : Colors.grey[300],
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    canAfford ? 'Tukar & Gunakan' : 'Poin Tidak Cukup',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
