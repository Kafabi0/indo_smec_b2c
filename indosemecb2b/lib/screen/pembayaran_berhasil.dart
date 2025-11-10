import 'package:flutter/material.dart';
import 'package:indosemecb2b/screen/detail_pembayaran.dart';
import 'package:indosemecb2b/utils/transaction_manager.dart';
import 'package:intl/intl.dart';
import 'main_navigasi.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final double totalPembayaran;
  final String metodePembayaran;
  final DateTime tanggal;
  final double? voucherDiscount;
  final double? poinCashUsed; // ✅ TAMBAHKAN

  const PaymentSuccessScreen({
    Key? key,
    required this.totalPembayaran,
    required this.metodePembayaran,
    required this.tanggal,
    this.voucherDiscount,
    this.poinCashUsed, // ✅ TAMBAHKAN
  }) : super(key: key);

  String formatRupiah(double value) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return format.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.cancel, color: Colors.grey),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainNavigation()),
              (route) => false,
            );
          },
        ),
        title: const Text(
          "Pembayaran Berhasil",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.check_circle,
                  color: Color(0xFF1976D2),
                  size: 70,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Pembayaran Kamu\nBerhasil Terkonfirmasi.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            _buildSectionDetail(),
            const SizedBox(height: 12),

            _buildPoinSection(),
            const SizedBox(height: 12),
            _buildHelpSection(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final transactions =
                      await TransactionManager.getTransactions();

                  if (transactions.isNotEmpty) {
                    final latestTransaction = transactions.first;

                    // ✅ KONVERSI Transaction ke Map LENGKAP
                    final transaksiMap = {
                      'no_transaksi': latestTransaction.id,
                      'id': latestTransaction.id,
                      'tanggal': latestTransaction.date,
                      'date': latestTransaction.date,
                      'status': latestTransaction.status,
                      'metode_pembayaran': metodePembayaran,
                      'metodePembayaran': metodePembayaran,
                      'total_pembayaran': totalPembayaran,
                      'totalPrice': latestTransaction.totalPrice,

                      // ✅ VOUCHER FIELDS
                      'voucher_code': latestTransaction.voucherCode,
                      'voucherCode': latestTransaction.voucherCode,
                      'voucher_discount': latestTransaction.voucherDiscount,
                      'voucherDiscount': latestTransaction.voucherDiscount,

                      // ✅ POIN CASH FIELDS (PENTING!)
                      'poin_cash_used': latestTransaction.poinCashUsed,
                      'poinCashUsed': latestTransaction.poinCashUsed,
                      'is_using_poin_cash': latestTransaction.isUsingPoinCash,

                      'items':
                          latestTransaction.items
                              .map(
                                (item) => {
                                  'nama': item.name,
                                  'name': item.name,
                                  'quantity': item.quantity,
                                  'harga': item.price,
                                  'price': item.price,
                                  'image': item.imageUrl,
                                  'imageUrl': item.imageUrl,
                                },
                              )
                              .toList(),
                      'penerima':
                          latestTransaction.alamat?['nama_penerima'] ??
                          latestTransaction.alamat?['nama'] ??
                          'N/A',
                      'alamat': latestTransaction.alamat,
                      'metode_pengiriman':
                          latestTransaction.deliveryOption == 'xpress'
                              ? 'Xpress (Gratis)'
                              : 'Reguler (Gratis)',
                      'deliveryOption': latestTransaction.deliveryOption,
                      'jadwal_pengiriman':
                          'Dikirim : ${DateFormat('EEEE, d MMM yyyy, HH:mm').format(latestTransaction.date)}',
                      'biaya_pengiriman': 0.0,
                      'biaya_admin': 0.0,
                      'catatan_pengiriman': latestTransaction.catatanPengiriman,
                      'catatanPengiriman': latestTransaction.catatanPengiriman,
                    };

                    // ✅ DEBUG
                    print('🎟️ [PaymentSuccess] Sending to DetailPembayaran:');
                    print('   - voucher_code: ${transaksiMap['voucher_code']}');
                    print(
                      '   - voucher_discount: ${transaksiMap['voucher_discount']}',
                    );
                    print(
                      '   - poin_cash_used: ${transaksiMap['poin_cash_used']}',
                    );

                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder:
                              (_) => DetailPembayaranScreen(
                                transaksi: transaksiMap,
                              ),
                        ),
                        (route) => false,
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Lihat Detail Pembayaran",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionDetail() {
    final discount = voucherDiscount ?? 0.0;
    final poinCash = poinCashUsed ?? 0.0;
    final subtotal = totalPembayaran - discount - poinCash; // ✅ HITUNG ULANG

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: const Text(
          "Detail Pembayaran",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        children: [
          _buildDetailRow("Tanggal", DateFormat("d MMM yyyy").format(tanggal)),
          _buildDetailRow("Waktu", DateFormat("HH:mm").format(tanggal)),
          _buildDetailRow("Metode Pemesanan", "Reguler"),
          _buildDetailRow("Subtotal Produk", formatRupiah(subtotal)),
          // _buildDetailRow("Biaya Pengiriman", "Rp5.000"),

          // ✅ Diskon Voucher
          if (discount > 0) ...[
            _buildDetailRow(
              "Diskon Voucher",
              "- ${formatRupiah(discount)}",
              color: Colors.green[700],
            ),
          ],

          // ✅ Poin Cash
          if (poinCash > 0) ...[
            _buildDetailRow(
              "Poin Cash",
              "- ${formatRupiah(poinCash)}",
              color: Colors.orange[700],
            ),
          ],

          _buildDetailRow("Metode Pembayaran", metodePembayaran),
          _buildDetailRow(
            "Total Pembayaran",
            formatRupiah(totalPembayaran),
            bold: true,
            color: Colors.blue[800],
          ),
          // _buildDetailRow(
          //   "note",
          //   "Subtotal sudah termasuk biaya pengiriman",
          //   fontSize: 11,
          // ),

          // ✅ Info Penghematan
          if (discount > 0 || poinCash > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700], size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Anda hemat ${formatRupiah(discount + poinCash)} dari transaksi ini',
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
    );
  }

  Widget _buildPoinSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F7FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDCE3F3)),
      ),
      child: Row(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFE0EDFF),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(6),
            child: const Icon(Icons.stars, color: Color(0xFF1976D2), size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Kamu berpotensi mendapat Poin Cash atau Poin Loyalty",
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFE3F2FD),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(6),
            child: const Icon(Icons.help, color: Color(0xFF1976D2), size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Butuh Bantuan\nKunjungi halaman Bantuan Klik Indomaret",
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String title,
    String value, {
    bool bold = false,
    Color? color,
    double? fontSize, // ✅ UBAH dari TextStyle menjadi double?
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize ?? 13, // ✅ Tambahkan default value
              color: color ?? Colors.black87,
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
