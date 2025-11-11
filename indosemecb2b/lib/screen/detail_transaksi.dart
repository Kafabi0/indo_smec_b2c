import 'package:flutter/material.dart';
import 'package:indosemecb2b/utils/transaction_manager.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import 'lacak.dart';
import 'package:indosemecb2b/models/tracking.dart';
import 'package:indosemecb2b/utils/cart_manager.dart';
import 'package:indosemecb2b/screen/main_navigasi.dart';

class TransactionDetailScreen extends StatefulWidget {
  final Transaction transaction;

  const TransactionDetailScreen({Key? key, required this.transaction})
    : super(key: key);

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  Transaction get transaction => widget.transaction;

  Future<void> _handleBeliLagi() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (_) => Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Menambahkan produk ke keranjang...',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
      );

      int successCount = 0;
      int failedCount = 0;

      for (var item in transaction.items) {
        final success = await CartManager.addToCart(
          productId: item.productId,
          name: item.name,
          price: item.price,
          imageUrl: item.imageUrl,
          category: item.category,
          quantity: item.quantity,
        );

        if (success) {
          successCount++;
        } else {
          failedCount++;
        }
      }

      if (!mounted) return;
      Navigator.of(context).pop();

      if (successCount > 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainNavigation(initialIndex: 1)),
        );

        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        failedCount > 0
                            ? '$successCount produk berhasil ditambahkan ke keranjang'
                            : '${transaction.items.length} produk berhasil ditambahkan ke keranjang',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.green[600],
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Gagal menambahkan produk ke keranjang',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red[600]),
      );
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Selesai':
        return Colors.green;
      case 'Dibatalkan':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('d MMM yyyy, HH:mm').format(date);
  }

  String formatRupiah(double number) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatCurrency.format(number);
  }

  @override
  @override
  Widget build(BuildContext context) {
    final alamat = transaction.alamat ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[300]!)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  if (transaction.status == "Selesai") {
                    _handleBeliLagi();
                  } else {
                    // ⭐ GUNAKAN METHOD ASYNC
                    _openTracking(transaction);
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.blue[700]!),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      transaction.status == "Selesai"
                          ? Icons.shopping_cart_outlined
                          : Icons.location_on_outlined,
                      size: 20,
                      color: Colors.blue[700],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      transaction.status == "Selesai" ? "Beli Lagi" : "Lacak",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== HEADER TRANSAKSI =====
            _buildDetailRow("No.Transaksi", transaction.id),
            const SizedBox(height: 6),
            _buildDetailRow("Tanggal Transaksi", formatDate(transaction.date)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Status", style: TextStyle(fontSize: 14)),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(transaction.status).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    transaction.status,
                    style: TextStyle(
                      color: _statusColor(transaction.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ===== PRODUK =====
            const Text(
              'Belanja Xpress',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var item in transaction.items) _buildProductItem(item),
                  const Divider(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Subtotal ${formatRupiah(transaction.subtotal)}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ===== VOUCHER INFO (JIKA ADA) =====
            if (transaction.hasVoucher) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.local_offer, color: Colors.green[700], size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Voucher Digunakan',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            transaction.voucherCode!,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[900],
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Hemat',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          formatRupiah(transaction.voucherDiscount!),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
            ],

            // ===== DETAIL PENGIRIMAN =====
            const Text(
              'Detail Pengiriman',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              "Penerima",
              "${alamat['nama_penerima'] ?? alamat['nama'] ?? 'N/A'}",
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              "Alamat",
              alamat['alamat_lengkap'] ?? alamat['alamat'] ?? "-",
            ),
            if (transaction.catatanPengiriman != null &&
                transaction.catatanPengiriman!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.edit_note, color: Colors.blue[700], size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Catatan Pengiriman',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[900],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            transaction.catatanPengiriman!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 18),

            // ✅ WIDGET RINCIAN BELANJA
            _buildRincianBelanja(),
          ],
        ),
      ),
    );
  }

  // ⭐ TAMBAHKAN METHOD ASYNC INI DI CLASS TransactionDetailScreen
  Future<void> _openTracking(Transaction transaction) async {
    print('📍 Opening tracking for: ${transaction.id}');

    try {
      // Ambil tracking data dari TransactionManager
      final trackingModel = await TransactionManager.getOrderTrackingModel(
        transaction.id,
      );

      if (!mounted) return;

      if (trackingModel != null) {
        print('✅ Tracking data found, opening with real coordinates');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TrackingScreen(trackingData: trackingModel),
          ),
        );
      } else {
        // Fallback jika tidak ada tracking data
        print('⚠️ No tracking data, using fallback');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => TrackingScreen(
                  trackingData: OrderTrackingModel(
                    transactionId: transaction.id,
                    orderId: transaction.id,
                    courierName: "Tryan Gumilar",
                    courierId: "D 4563 ADP",
                    statusMessage: transaction.status,
                    statusDesc: "Pesananmu sedang diproses",
                    updatedAt: transaction.date,
                  ),
                ),
          ),
        );
      }
    } catch (e) {
      print('❌ Error opening tracking: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuka tracking: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ✅ WIDGET BARU: Rincian Belanja dengan Poin Cash
  Widget _buildRincianBelanja() {
    final subtotal = transaction.subtotal;
    final shipping = transaction.shippingCost;
    final voucherDiscount = transaction.voucherDiscount ?? 0.0;
    final poinCashUsed = transaction.poinCashUsed ?? 0.0;
    final finalTotal = transaction.finalTotal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rincian Belanja',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              // Metode Pembayaran
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.payment, size: 16, color: Colors.blue[700]),
                      const SizedBox(width: 6),
                      const Text(
                        'Metode Pembayaran',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  Text(
                    transaction.metodePembayaran ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const Divider(height: 24),

              // Subtotal Produk
              _buildDetailRow("Subtotal Produk", formatRupiah(subtotal)),
              const SizedBox(height: 8),

              // Biaya Pengiriman
              _buildDetailRow("Biaya Pengiriman", formatRupiah(shipping)),

              // ✅ Diskon Voucher (jika ada)
              if (voucherDiscount > 0) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.local_offer,
                          size: 16,
                          color: Colors.green[700],
                        ),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Diskon Voucher",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.green[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (transaction.voucherCode != null)
                              Text(
                                transaction.voucherCode!,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                  fontFamily: 'monospace',
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      "- ${formatRupiah(voucherDiscount)}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ],

              // ✅ Poin Cash Used (jika ada)
              if (poinCashUsed > 0) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          size: 16,
                          color: Colors.orange[700],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Poin Cash",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.orange[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "- ${formatRupiah(poinCashUsed)}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
              ],

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(height: 1),
              ),

              // Total Pembayaran
              _buildDetailRow(
                "Total Pembayaran",
                formatRupiah(finalTotal),
                isBold: true,
              ),
            ],
          ),
        ),

        // ✅ Info Box untuk penghematan
        if (voucherDiscount > 0 || poinCashUsed > 0) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Anda hemat ${formatRupiah(voucherDiscount + poinCashUsed)} dari transaksi ini',
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
    );
  }

  Widget _buildProductItem(TransactionItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.imageUrl ?? "",
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
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "${item.name}\n${item.quantity} pcs x ${formatRupiah(item.price)}",
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: isBold ? 16 : 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isBold ? Colors.blue[700] : Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
