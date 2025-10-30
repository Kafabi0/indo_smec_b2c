import 'package:flutter/material.dart';
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
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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

    // ✅ DEBUG: Verifikasi catatan diterima
    print('📝 [CHECKOUT INIT] Catatan diterima: "${widget.catatanPengiriman}"');
  }

  Future<void> loadData() async {
    final cartItems = await CartManager.getCartItems();
    setState(() {
      _cartItems = cartItems;
      _isLoading = false;
    });
  }

  Future<String?> _showPinDialog() async {
    final pinController = TextEditingController();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Masukkan PIN Saldo Klik'),
          content: TextField(
            controller: pinController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'PIN (6 digit)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (pinController.text.length == 6) {
                  Navigator.pop(context, pinController.text);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('PIN harus 6 digit'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Lanjut'),
            ),
          ],
        );
      },
    );
  }

  double getSubtotal() =>
      _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  double getBiayaPengiriman() => 5000.0;

  double getTotal() => getSubtotal() + getBiayaPengiriman();

  // double getTotal() =>
  //     _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  Future<void> _processCheckout(String paymentType) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      print('🔍 DEBUG CHECKOUT - Cart items: ${_cartItems.length}');
      print('🔍 DEBUG CHECKOUT - Delivery option: ${widget.deliveryOption}');
      print('🔍 DEBUG CHECKOUT - Catatan: "${widget.catatanPengiriman}"');
      print('🔍 DEBUG CHECKOUT - Alamat: ${widget.alamat}');
      print('💳 DEBUG CHECKOUT - Payment type: $paymentType'); // ✅ LOG PAYMENT

      final transactionId = 'TRX${DateTime.now().millisecondsSinceEpoch}';
      print('✅ Generated Transaction ID: $transactionId');

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

      print('📍 Penerima: $penerimaName');
      print('📍 Nomor HP: $nomorHP');
      print('📍 Alamat: $alamatLengkap');

      // ✅ PERBAIKAN: Siapkan alamat data dengan metode pembayaran
      final alamatData = {
        'nama_penerima': penerimaName,
        'nomor_hp': nomorHP,
        'alamat_lengkap': alamatLengkap,
        'kelurahan': widget.alamat?['kelurahan'],
        'kecamatan': widget.alamat?['kecamatan'],
        'kota': widget.alamat?['kota'],
        'provinsi': widget.alamat?['provinsi'],
        'kodepos': widget.alamat?['kodepos'],
        'metode_pembayaran': paymentType, // ✅ SIMPAN METODE PEMBAYARAN
      };

      print('💳 Metode pembayaran yang akan disimpan: $paymentType');

      // ✅ SIMPAN TRANSAKSI dengan parameter metodePembayaran
      final success = await TransactionManager.createTransaction(
        cartItems: _cartItems,
        deliveryOption: widget.deliveryOption,
        alamat: alamatData, // ✅ Alamat sudah include metode_pembayaran
        catatanPengiriman: widget.catatanPengiriman,
        metodePembayaran: paymentType, // ✅ PASS SEBAGAI PARAMETER TERPISAH
      );

      if (success) {
        print('✅ Transaction created successfully');

        // ✅ VERIFIKASI: Ambil transaksi yang baru disimpan
        final transactions = await TransactionManager.getTransactions();
        if (transactions.isNotEmpty) {
          final savedTransaction = transactions.first;
          print('✅ Verified saved transaction:');
          print('  📝 Catatan: "${savedTransaction.catatanPengiriman}"');
          print('  💳 Metode: "${savedTransaction.metodePembayaran}"');
        }
        if (paymentType == "Saldo Klik") {
          // ❌ HAPUS BAGIAN INI - PIN sudah diminta di PaymentMethodScreen
          // Tidak perlu request PIN lagi di checkout

          print('✅ Payment with Saldo Klik (PIN already verified)');

          // Saldo sudah dipotong di PaymentMethodScreen
          // Tidak perlu deduct lagi
          print('✅ Saldo already deducted in PaymentMethodScreen');
        }
        // Hapus semua item dari keranjang
        final clearSuccess = await CartManager.clearCart();
        print('🗑️ Cart cleared: $clearSuccess');

        if (!clearSuccess) {
          print('⚠️ Warning: Cart clearing failed, but transaction was saved');
        }

        // Prepare transaction data for notification
        final transactionData = {
          'no_transaksi': transactionId,
          'id': transactionId,
          'tanggal': DateTime.now().toIso8601String(),
          'date': DateTime.now().toIso8601String(),
          'status': 'Diproses',
          'metode_pembayaran': paymentType, // ✅ TAMBAHKAN DI NOTIFICATION DATA
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

        print('📦 Transaction data for notification:');
        print(
          '  💳 metode_pembayaran: "${transactionData['metode_pembayaran']}"',
        );
        print(
          '  📝 catatan_pengiriman: "${transactionData['catatan_pengiriman']}"',
        );

        // ✅ TRIGGER NOTIFIKASI dengan data lengkap
        if (mounted) {
          final firstProductImage =
              _cartItems.isNotEmpty ? _cartItems.first.imageUrl : null;

          // ✅ PERBAIKAN: Ensure provider is ready
          final notifProvider = Provider.of<NotificationProvider>(
            context,
            listen: false,
          );

          // ✅ Ensure user is loaded before adding notification
          print('🔄 [CHECKOUT] Ensuring notification provider is ready...');
          await notifProvider.ensureUserLoaded();

          // 1. Tampilkan Local Notification
          await NotificationService().showPaymentSuccessNotification(
            orderId: transactionId,
            paymentMethod: paymentType,
            totalAmount: getTotal(),
            productImage: firstProductImage,
            transactionData: transactionData,
          );

          // 2. Simpan ke NotificationProvider (user sudah pasti loaded)
          print('💾 [CHECKOUT] Saving notification to provider...');
          await notifProvider.addPaymentSuccessNotification(
            orderId: transactionId,
            paymentMethod: paymentType,
            total: getTotal(),
            productImage: firstProductImage,
            transactionData: transactionData,
          );

          print('✅ [CHECKOUT] Notification saved with metode: "$paymentType"');

          // 3. Navigasi ke halaman sukses
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder:
                  (_) => PaymentSuccessScreen(
                    totalPembayaran: getTotal(),
                    metodePembayaran: paymentType,
                    tanggal: DateTime.now(),
                  ),
            ),
            (route) => false,
          );
        }
      } else {
        print('❌ Transaction creation failed');
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

                          // ✅ TAMPILKAN CATATAN DI CHECKOUT
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
                  Text(
                    formatRupiah(getTotal()),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
