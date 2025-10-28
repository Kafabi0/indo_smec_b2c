import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indosemecb2b/screen/main_navigasi.dart';
import 'package:intl/intl.dart';

class DetailPembayaranScreen extends StatelessWidget {
  final Map<String, dynamic> transaksi;

  const DetailPembayaranScreen({Key? key, required this.transaksi})
    : super(key: key);

  String formatRupiah(double value) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return format.format(value);
  }

  String formatTanggal(dynamic tanggal) {
    DateTime dateTime;
    if (tanggal is String) {
      dateTime = DateTime.parse(tanggal);
    } else if (tanggal is DateTime) {
      dateTime = tanggal;
    } else {
      dateTime = DateTime.now();
    }
    return DateFormat('d MMM yyyy - HH:mm').format(dateTime);
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nomor transaksi berhasil disalin'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pembayaran lunas':
      case 'selesai':
        return Colors.green;
      case 'menunggu pembayaran':
      case 'pending':
        return Colors.orange;
      case 'dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  double _hitungSubtotal() {
    double subtotal = 0.0;
    final items = transaksi['items'] as List? ?? [];
    for (var item in items) {
      final quantity = item['quantity'] ?? 0;
      final harga =
          (item['harga'] ?? 0.0) is int
              ? (item['harga'] as int).toDouble()
              : item['harga'] ?? 0.0;
      subtotal += (quantity * harga);
    }
    return subtotal;
  }

  double _hitungTotal() {
    final subtotal = _hitungSubtotal();
    final biayaPengiriman = transaksi['biaya_pengiriman'] ?? 0.0;
    final biayaAdmin = transaksi['biaya_admin'] ?? 0.0;
    return subtotal + biayaPengiriman + biayaAdmin;
  }

  // ✅ Helper function untuk extract alamat (jika masih berbentuk Map)
  String _getAlamatString() {
    final alamat = transaksi['alamat'];

    // Jika sudah String, langsung return
    if (alamat is String) {
      return alamat;
    }

    // Jika Map, konversi ke String
    if (alamat is Map) {
      final List<String> parts = [];

      if (alamat['alamat_lengkap'] != null) {
        parts.add(alamat['alamat_lengkap'].toString());
      }
      if (alamat['kelurahan'] != null) {
        parts.add('Kel. ${alamat['kelurahan']}');
      }
      if (alamat['kecamatan'] != null) {
        parts.add('Kec. ${alamat['kecamatan']}');
      }
      if (alamat['kota'] != null) {
        parts.add(alamat['kota'].toString());
      }
      if (alamat['provinsi'] != null) {
        parts.add(alamat['provinsi'].toString());
      }
      if (alamat['kodepos'] != null) {
        parts.add(alamat['kodepos'].toString());
      }

      return parts.isNotEmpty ? parts.join(', ') : 'Alamat tidak tersedia';
    }

    return 'Alamat tidak tersedia';
  }

  // ✅ Helper function untuk extract nama penerima
  String _getPenerimaString() {
    final penerima = transaksi['penerima'];

    if (penerima is String) {
      return penerima;
    }

    if (penerima is Map) {
      return penerima['nama_penerima']?.toString() ??
          penerima['nama']?.toString() ??
          'N/A';
    }

    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = _hitungSubtotal();
    final total = _hitungTotal();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainNavigation()),
              (route) => false,
            );
          },
        ),
        title: const Text(
          'Detail Transaksi',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoRow(
                    'No. Transaksi',
                    transaksi['no_transaksi'] ?? 'N/A',
                    showCopy: true,
                    context: context,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'Tanggal Transaksi',
                    formatTanggal(transaksi['tanggal'] ?? DateTime.now()),
                  ),
                  const SizedBox(height: 12),
                  _buildStatusRow(
                    'Status',
                    transaksi['status'] ?? 'Pembayaran Lunas',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Belanja Xpress Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // const Text(
                  //   'Belanja Xpress',
                  //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  // ),
                  // const SizedBox(height: 16),
                  // Row(
                  //   children: [
                  //     Container(
                  //       padding: const EdgeInsets.all(8),
                  //       decoration: BoxDecoration(
                  //         color: Colors.blue[50],
                  //         borderRadius: BorderRadius.circular(8),
                  //       ),
                  //       child: Icon(
                  //         Icons.shopping_cart,
                  //         color: Colors.blue[700],
                  //         size: 24,
                  //       ),
                  //     ),
                  //     const SizedBox(width: 12),
                  //     const Text(
                  //       'Grocery',
                  //       style: TextStyle(
                  //         fontSize: 14,
                  //         fontWeight: FontWeight.w500,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(height: 16),
                  // const Divider(height: 1),
                  const SizedBox(height: 16),
                  ...(transaksi['items'] as List? ?? []).map(
                    (item) => _buildProductItem(item),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        formatRupiah(subtotal),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Detail Pengiriman Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detail Pengiriman',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailItem('Penerima', _getPenerimaString()),
                  const SizedBox(height: 12),
                  _buildDetailItem('Alamat', _getAlamatString()),
                  const SizedBox(height: 16),
                  const Text(
                    'Metode Pengiriman',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaksi['metode_pengiriman'] ?? 'Reguler',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          transaksi['jadwal_pengiriman'] ??
                              'Dikirim : ${DateFormat('EEEE, d MMM yyyy, HH:mm').format(DateTime.now())}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Rincian Belanja Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rincian Belanja',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildRincianRow(
                    'Metode Pembayaran',
                    transaksi['metode_pembayaran'] ?? 'N/A',
                    showIcon: true,
                  ),
                  const SizedBox(height: 12),
                  _buildRincianRow('Belanja Xpress', formatRupiah(subtotal)),
                  const SizedBox(height: 8),
                  _buildRincianRow('Subtotal', formatRupiah(subtotal)),
                  const SizedBox(height: 8),
                  _buildRincianRow(
                    'Biaya Pengiriman',
                    formatRupiah(transaksi['biaya_pengiriman'] ?? 0.0),
                  ),
                  const SizedBox(height: 8),
                  _buildRincianRow(
                    'Biaya Admin',
                    formatRupiah(transaksi['biaya_admin'] ?? 0.0),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  _buildRincianRow(
                    'Total Pembayaran',
                    formatRupiah(total),
                    isBold: true,
                  ),
                  const SizedBox(height: 8),
                  _buildRincianRow(
                    transaksi['metode_pembayaran'] ?? 'N/A',
                    formatRupiah(total),
                    isBold: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Poin Loyalty Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.stars, color: Colors.blue[700], size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Kamu berpotensi mendapat Poin Cash atau Poin Loyalty',
                      style: TextStyle(fontSize: 13, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Bantuan',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool showCopy = false,
    BuildContext? context,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 150),
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
              ),
            ),
            if (showCopy && context != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _copyToClipboard(context, value),
                child: Icon(Icons.copy, size: 18, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        Row(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _getStatusColor(value),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 18, color: Colors.grey[400]),
          ],
        ),
      ],
    );
  }

  Widget _buildProductItem(Map<String, dynamic> item) {
    final quantity = item['quantity'] ?? 0;
    final harga =
        (item['harga'] ?? 0.0) is int
            ? (item['harga'] as int).toDouble()
            : item['harga'] ?? 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                item['image'] != null && item['image'].toString().isNotEmpty
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item['image'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.image,
                            color: Colors.grey[400],
                            size: 30,
                          );
                        },
                      ),
                    )
                    : Icon(Icons.image, color: Colors.grey[400], size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['nama'] ?? item['name'] ?? 'Produk',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$quantity pcs x ${formatRupiah(harga)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildRincianRow(
    String label,
    String value, {
    bool isBold = false,
    bool showIcon = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isBold ? Colors.black : Colors.grey[700],
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (showIcon) ...[
              const SizedBox(width: 4),
              Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
            ],
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
