import 'package:flutter/material.dart';
import 'package:indosemecb2b/screen/main_navigasi.dart';
import 'package:indosemecb2b/screen/metode_pembayaran.dart';
import 'package:indosemecb2b/screen/pembayaran_berhasil.dart';
import 'package:indosemecb2b/screen/transaksi.dart';
import 'package:indosemecb2b/utils/cart_manager.dart';
import 'package:indosemecb2b/utils/transaction_manager.dart';
import 'package:indosemecb2b/models/cart_item.dart';
import 'package:intl/intl.dart';

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
      symbol: 'Rp.',
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

      // Simpan transaksi
      final success = await TransactionManager.createTransaction(
        cartItems: _cartItems,
        deliveryOption: widget.deliveryOption,
        alamat: widget.alamat,
      );

      if (success) {
        print('✅ Transaction created successfully');

        // ✅ HAPUS SEMUA ITEM DARI KERANJANG
        final clearSuccess = await CartManager.clearCart();
        print('🗑️ Cart cleared: $clearSuccess');

        if (!clearSuccess) {
          print('⚠️ Warning: Cart clearing failed, but transaction was saved');
        }

        if (mounted) {
          // ✅ Navigasi ke halaman sukses dan hapus semua route sebelumnya
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder:
                  (_) => PaymentSuccessScreen(
                    totalPembayaran: getTotal(),
                    metodePembayaran: paymentType,
                    tanggal: DateTime.now(),
                  ),
            ),
            (route) => false, // Hapus semua route (termasuk CheckoutScreen)
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
    } catch (e) {
      print('❌ ERROR CHECKOUT: $e');
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
                          // Hitung total
                          double total = getTotal();

                          // Debug: cek nilai total
                          print("💰 DEBUG - Total pembayaran: $total");
                          print("🛒 DEBUG - Cart items: ${_cartItems.length}");

                          // Validasi keranjang tidak kosong
                          if (_cartItems.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Keranjang masih kosong!'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          // Validasi total valid
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

                          // ✅ Navigasi ke halaman pilih metode pembayaran
                          print("🚀 Navigating to PaymentMethodScreen...");
                          final selectedPayment = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => PaymentMethodScreen(
                                    totalPembayaran: total,
                                  ),
                            ),
                          );

                          // ✅ Jika user memilih metode pembayaran, proses checkout
                          if (selectedPayment != null && mounted) {
                            print("✅ Metode dipilih: $selectedPayment");
                            print("🔄 Processing checkout...");
                            await _processCheckout(selectedPayment);
                          } else {
                            print(
                              "❌ Pembayaran dibatalkan atau tidak ada metode dipilih",
                            );
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
