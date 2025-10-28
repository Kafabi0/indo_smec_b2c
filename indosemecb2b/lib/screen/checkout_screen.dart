import 'package:flutter/material.dart';
import 'package:indosemecb2b/screen/main_navigasi.dart';
import 'package:indosemecb2b/screen/metode_pembayaran.dart';
import 'package:indosemecb2b/screen/notification_provider.dart';
import 'package:indosemecb2b/screen/pembayaran_berhasil.dart';
import 'package:indosemecb2b/screen/transaksi.dart';
import 'package:indosemecb2b/services/notifikasi.dart';
import 'package:indosemecb2b/utils/cart_manager.dart';
import 'package:indosemecb2b/utils/transaction_manager.dart';
import 'package:indosemecb2b/models/cart_item.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  final Map<String, dynamic>? alamat;
  final String deliveryOption;

  CheckoutScreen({required this.alamat, required this.deliveryOption});

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
  }

  Future<void> loadData() async {
    final cartItems = await CartManager.getCartItems();
    setState(() {
      _cartItems = cartItems;
      _isLoading = false;
    });
  }

  double getTotal() =>
      _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  Future<void> _processCheckout(String paymentType) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      print('🔍 DEBUG CHECKOUT - Cart items: ${_cartItems.length}');
      print('🔍 DEBUG CHECKOUT - Delivery option: ${widget.deliveryOption}');
      print('🔍 DEBUG CHECKOUT - Alamat: ${widget.alamat}');
      print('🔍 DEBUG CHECKOUT - Payment type: $paymentType');

      // ✅ Generate transaction ID
      final transactionId = 'TRX${DateTime.now().millisecondsSinceEpoch}';
      print('✅ Generated Transaction ID: $transactionId');

      // Simpan transaksi
      final success = await TransactionManager.createTransaction(
        cartItems: _cartItems,
        deliveryOption: widget.deliveryOption,
        alamat: widget.alamat,
      );

      if (success) {
        print('✅ Transaction created successfully');

        // Hapus semua item dari keranjang
        final clearSuccess = await CartManager.clearCart();
        print('🗑️ Cart cleared: $clearSuccess');

        if (!clearSuccess) {
          print('⚠️ Warning: Cart clearing failed, but transaction was saved');
        }

        // ✅ TRIGGER NOTIFIKASI dengan data lengkap
        if (mounted) {
          // Ambil gambar produk pertama (jika ada)
          final firstProductImage =
              _cartItems.isNotEmpty ? _cartItems.first.imageUrl : null;

          // ✅ Extract alamat dengan aman (SEMUA jadi String!)
          String penerimaName = 'N/A';
          String alamatLengkap = 'Alamat tidak tersedia';
          String nomorHP = 'N/A';

          if (widget.alamat != null) {
            // Ambil nama penerima
            penerimaName =
                widget.alamat!['nama_penerima']?.toString() ??
                widget.alamat!['nama']?.toString() ??
                'N/A';

            // Ambil nomor HP
            nomorHP = widget.alamat!['nomor_hp']?.toString() ?? 'N/A';

            // ✅ Format alamat lengkap dari field-field yang ada
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

          // ✅ Buat transaction data LENGKAP - SEMUA STRING/NUMBER (bukan Map!)
          final transactionData = {
            'no_transaksi': transactionId,
            'tanggal': DateTime.now().toIso8601String(),
            'status': 'Pembayaran Lunas',
            'metode_pembayaran': paymentType,
            'items':
                _cartItems
                    .map(
                      (item) => {
                        'nama': item.name,
                        'name': item.name,
                        'quantity': item.quantity,
                        'harga': item.price,
                        'image': item.imageUrl ?? '',
                      },
                    )
                    .toList(),
            'penerima': penerimaName, // ✅ String
            'nomor_hp': nomorHP, // ✅ String
            'alamat': alamatLengkap, // ✅ String (BUKAN Map!)
            'metode_pengiriman':
                widget.deliveryOption == 'xpress'
                    ? 'Xpress (Rp5.000)'
                    : 'Reguler (Rp5.000)',
            'jadwal_pengiriman':
                'Dikirim : ${DateFormat('EEEE, d MMM yyyy, HH:mm', 'id_ID').format(DateTime.now())}',
            'biaya_pengiriman': 5000.0,
            'biaya_admin': 0.0,
            'delivery_option': widget.deliveryOption,
          };

          print('📦 Transaction data prepared:');
          transactionData.forEach((key, value) {
            print('  $key: ${value.runtimeType} = $value');
          });

          // 1. Tampilkan Local Notification dengan transaction data
          await NotificationService().showPaymentSuccessNotification(
            orderId: transactionId,
            paymentMethod: paymentType,
            totalAmount: getTotal(),
            productImage: firstProductImage,
            transactionData:
                transactionData, // ✅ Pass transaction data untuk navigation
          );

          // 2. Simpan ke NotificationProvider dengan data lengkap
          final notifProvider = Provider.of<NotificationProvider>(
            context,
            listen: false,
          );

          await notifProvider.addPaymentSuccessNotification(
            orderId: transactionId,
            paymentMethod: paymentType,
            total: getTotal(),
            productImage: firstProductImage,
            transactionData: transactionData,
          );

          print('🔔 Notification sent successfully with ID: $transactionId');

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
                            print("✅ Metode dipilih: $selectedPayment");
                            await _processCheckout(selectedPayment);
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
