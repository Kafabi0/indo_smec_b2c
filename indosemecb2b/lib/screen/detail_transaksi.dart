import 'package:flutter/material.dart';
import 'package:indosemecb2b/models/tracking.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import 'lacak.dart';

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
      symbol: 'Rp.',
      decimalDigits: 0,
    );
    return formatCurrency.format(number);
  }

  @override
  Widget build(BuildContext context) {
    final alamat = transaction.alamat ?? {};

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
                      'Total ${formatRupiah(transaction.totalPrice)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ===== DETAIL PEMGIRIMAN =====
            const Text(
              'Detail Pengiriman',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              "Penerima",
              "${alamat['nama_penerima'] ?? alamat['nama'] ?? 'N/A'}" ,
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              "Alamat",
              alamat['alamat_lengkap'] ?? alamat['alamat'] ?? "-",
            ),

            const SizedBox(height: 18),

            // ===== DETAIL PEMBAYARAN =====
            const Text(
              'Rincian Belanja',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              "Belanja Xpress",
              formatRupiah(transaction.totalPrice),
            ),
            _buildDetailRow("Biaya Pengiriman", "Rp5.000"),
            const Divider(),
            _buildDetailRow(
              "Total Pembayaran",
              formatRupiah(transaction.totalPrice + 5000),
              isBold: true,
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
        Text(title),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
