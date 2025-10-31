import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import 'lacak.dart';
import 'package:indosemecb2b/models/tracking.dart';

class TransactionDetailScreen extends StatelessWidget {
  final Transaction transaction;

  TransactionDetailScreen({required this.transaction});

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

  // ✅ HITUNG SUBTOTAL PRODUK (SEBELUM ONGKIR & DISKON)
  double _getSubtotal() {
    return transaction.items.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  // ✅ HITUNG TOTAL SETELAH DISKON (YANG BENAR-BENAR DIBAYAR)
  double _getFinalTotal() {
    final subtotal = _getSubtotal();
    final shipping = 5000.0;
    final discount = transaction.voucherDiscount ?? 0.0;
    return subtotal + shipping - discount;
  }

  @override
  Widget build(BuildContext context) {
    final alamat = transaction.alamat ?? {};
    final subtotal = _getSubtotal();
    final shipping = 5000.0;
    final discount = transaction.voucherDiscount ?? 0.0;
    final finalTotal = _getFinalTotal();

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Transaksi'),
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
                    Navigator.pop(context);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => TrackingScreen(
                              trackingData: OrderTrackingModel(
                                transactionId: transaction.id,
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
                  side: BorderSide(color: Colors.blue[700]!),
                ),
                child: Text(
                  transaction.status == "Selesai" ? "Beli Lagi" : "Lacak",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
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
                      'Subtotal ${formatRupiah(subtotal)}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ===== VOUCHER INFO (JIKA ADA) =====
            if (transaction.voucherCode != null && discount > 0) ...[
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
                          formatRupiah(discount),
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

            // ===== RINCIAN PEMBAYARAN (UPDATED) =====
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
                  _buildDetailRow("Subtotal Produk", formatRupiah(subtotal)),
                  const SizedBox(height: 8),
                  _buildDetailRow("Biaya Pengiriman", formatRupiah(shipping)),

                  // ✅ TAMPILKAN DISKON VOUCHER
                  if (discount > 0) ...[
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
                            Text(
                              "Diskon Voucher",
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "- ${formatRupiah(discount)}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ],

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(height: 1),
                  ),

                  // ✅ TOTAL AKHIR (SETELAH DISKON)
                  _buildDetailRow(
                    "Total Pembayaran",
                    formatRupiah(finalTotal),
                    isBold: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? Colors.blue[700] : Colors.black,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ),
      ],
    );
  }
}
