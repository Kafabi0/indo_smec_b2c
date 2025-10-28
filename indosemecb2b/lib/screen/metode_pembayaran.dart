import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indosemecb2b/screen/pembayaran_berhasil.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class PaymentMethodScreen extends StatelessWidget {
  final double totalPembayaran;

  const PaymentMethodScreen({Key? key, required this.totalPembayaran})
    : assert(totalPembayaran > 0, 'Total pembayaran harus lebih dari 0'),
      super(key: key);

  static final _formatRupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    // Validasi tambahan
    if (totalPembayaran <= 0 ||
        totalPembayaran.isNaN ||
        totalPembayaran.isInfinite) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Error"),
          backgroundColor: Colors.white,
          elevation: 1,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.red),
              SizedBox(height: 16),
              Text(
                "Total pembayaran tidak valid",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "Total: ${totalPembayaran}",
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Kembali"),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pilih Metode Pembayaran"),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Total Pembayaran
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.blue.shade100],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Pembayaran",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  _formatRupiah.format(totalPembayaran),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // E-Wallet Section
          _sectionHeader("E-Wallet"),
          _paymentItem(
            context: context,
            icon: Icons.account_balance_wallet,
            title: "GoPay",
            subtitle: "Bayar dengan GoPay",
            badge: "Promo 50%",
            paymentType: "GoPay",
          ),
          _paymentItem(
            context: context,
            icon: Icons.account_balance_wallet,
            title: "OVO",
            subtitle: "Bayar dengan OVO",
            paymentType: "OVO",
          ),
          _paymentItem(
            context: context,
            icon: Icons.account_balance_wallet,
            title: "DANA",
            subtitle: "Bayar dengan DANA",
            paymentType: "DANA",
          ),
          _paymentItem(
            context: context,
            icon: Icons.account_balance_wallet,
            title: "ShopeePay",
            subtitle: "Bayar dengan ShopeePay",
            paymentType: "ShopeePay",
          ),
          _paymentItem(
            context: context,
            icon: Icons.account_balance_wallet,
            title: "LinkAja",
            subtitle: "Bayar dengan LinkAja",
            paymentType: "LinkAja",
          ),

          const SizedBox(height: 16),

          // Virtual Account Section
          _sectionHeader("Virtual Account"),
          _paymentItem(
            context: context,
            icon: Icons.account_balance,
            title: "BCA Virtual Account",
            subtitle: "Gratis biaya admin",
            paymentType: "BCA VA",
          ),
          _paymentItem(
            context: context,
            icon: Icons.account_balance,
            title: "Mandiri Virtual Account",
            subtitle: "Gratis biaya admin",
            paymentType: "Mandiri VA",
          ),
          _paymentItem(
            context: context,
            icon: Icons.account_balance,
            title: "BNI Virtual Account",
            subtitle: "Gratis biaya admin",
            paymentType: "BNI VA",
          ),
          _paymentItem(
            context: context,
            icon: Icons.account_balance,
            title: "BRI Virtual Account",
            subtitle: "Gratis biaya admin",
            paymentType: "BRI VA",
          ),
          _paymentItem(
            context: context,
            icon: Icons.account_balance,
            title: "Permata Virtual Account",
            subtitle: "Gratis biaya admin",
            paymentType: "Permata VA",
          ),

          const SizedBox(height: 16),

          // Transfer Bank Section
          _sectionHeader("Transfer Bank"),
          _paymentItem(
            context: context,
            icon: Icons.compare_arrows,
            title: "Transfer Bank Manual",
            subtitle: "BCA, Mandiri, BNI, BRI, dll",
            paymentType: "Transfer Bank",
          ),

          const SizedBox(height: 16),

          // Kartu Kredit/Debit Section
          _sectionHeader("Kartu Kredit/Debit"),
          _paymentItem(
            context: context,
            icon: Icons.credit_card,
            title: "Kartu Kredit",
            subtitle: "Visa, Mastercard, JCB",
            badge: "Cicilan 0%",
            paymentType: "Kartu Kredit",
          ),
          _paymentItem(
            context: context,
            icon: Icons.credit_card,
            title: "Kartu Debit",
            subtitle: "Semua bank",
            paymentType: "Kartu Debit",
          ),

          const SizedBox(height: 16),

          // Gerai Retail Section
          _sectionHeader("Gerai Retail"),
          _paymentItem(
            context: context,
            icon: Icons.store,
            title: "Indomaret",
            subtitle: "Bayar di kasir Indomaret",
            paymentType: "Indomaret",
          ),
          _paymentItem(
            context: context,
            icon: Icons.store,
            title: "Alfamart",
            subtitle: "Bayar di kasir Alfamart",
            paymentType: "Alfamart",
          ),

          const SizedBox(height: 16),

          // Paylater Section
          _sectionHeader("Paylater"),
          _paymentItem(
            context: context,
            icon: Icons.schedule,
            title: "Kredivo",
            subtitle: "Bayar dalam 30 hari",
            badge: "Bunga 0%",
            paymentType: "Kredivo",
          ),
          _paymentItem(
            context: context,
            icon: Icons.schedule,
            title: "Akulaku",
            subtitle: "Cicilan tanpa kartu kredit",
            paymentType: "Akulaku",
          ),
          _paymentItem(
            context: context,
            icon: Icons.schedule,
            title: "GoPayLater",
            subtitle: "Bayar bulan depan",
            paymentType: "GoPayLater",
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _paymentItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    String? badge,
    required String paymentType,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue, size: 28),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
        onTap: () async {
          // Navigasi ke detail pembayaran
          final selectedMethod = await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => PaymentDetailScreen(
                    paymentType: paymentType,
                    totalPembayaran: totalPembayaran,
                  ),
            ),
          );

          // ✅ Jika user klik "Saya Sudah Bayar", kembalikan metode ke CheckoutScreen
          if (selectedMethod != null && context.mounted) {
            // Pop kembali ke CheckoutScreen dengan membawa metode pembayaran
            Navigator.pop(context, selectedMethod);
          }
        },
      ),
    );
  }
}

// Payment Detail Screen
class PaymentDetailScreen extends StatefulWidget {
  final String paymentType;
  final double totalPembayaran;

  const PaymentDetailScreen({
    Key? key,
    required this.paymentType,
    required this.totalPembayaran,
  }) : assert(totalPembayaran > 0, 'Total pembayaran harus lebih dari 0'),
       super(key: key);

  @override
  State<PaymentDetailScreen> createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends State<PaymentDetailScreen> {
  static final _formatRupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  String _randomNumericString(int length) {
    final random = Random();
    final buffer = StringBuffer();
    for (int i = 0; i < length; i++) {
      buffer.write(random.nextInt(10)); // 0..9
    }
    return buffer.toString();
  }

  late String vaNumber;
  late String paymentCode;
  late DateTime expiredTime;

  @override
  void initState() {
    super.initState();
    // Generate nomor VA/kode pembayaran
    vaNumber = _generateVANumber();
    paymentCode = _generatePaymentCode();
    expiredTime = DateTime.now().add(const Duration(hours: 24));
  }

  String _generateVANumber() {
    final random = Random();
    if (widget.paymentType.contains("BCA")) {
      return "80777" + _randomNumericString(10);
    } else if (widget.paymentType.contains("Mandiri")) {
      return "8908" + _randomNumericString(10);
      ;
    } else if (widget.paymentType.contains("BNI")) {
      return "8808" + _randomNumericString(10);
      ;
    } else if (widget.paymentType.contains("BRI")) {
      return "26215" + _randomNumericString(10);
      ;
    } else if (widget.paymentType.contains("Permata")) {
      return "8528" + _randomNumericString(10);
      ;
    }
    return _randomNumericString(16);
  }

  String _generatePaymentCode() {
    return _randomNumericString(12);
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label berhasil disalin'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.paymentType),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule, color: Colors.orange.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Menunggu Pembayaran",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Selesaikan pembayaran sebelum ${DateFormat('dd MMM yyyy, HH:mm').format(expiredTime)} WIB",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Total Pembayaran
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.blue.shade100],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total Pembayaran",
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatRupiah.format(widget.totalPembayaran),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Nomor VA / Kode Pembayaran
          if (_isVirtualAccount())
            _buildVASection()
          else if (_isRetail())
            _buildRetailSection()
          else if (_isEwallet())
            _buildEwalletSection()
          else
            _buildOtherSection(),

          const SizedBox(height: 24),

          // Cara Pembayaran
          _buildInstructionsSection(),

          const SizedBox(height: 100),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              print(
                '💳 User clicked "Saya Sudah Bayar" for: ${widget.paymentType}',
              );
              // ✅ Pop dengan hasil metode pembayaran
              // Ini akan kembali ke PaymentMethodScreen
              Navigator.of(context).pop(widget.paymentType);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Saya Sudah Bayar",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _isVirtualAccount() {
    return widget.paymentType.contains("VA");
  }

  bool _isRetail() {
    return widget.paymentType == "Indomaret" ||
        widget.paymentType == "Alfamart";
  }

  bool _isEwallet() {
    return [
      "GoPay",
      "OVO",
      "DANA",
      "ShopeePay",
      "LinkAja",
    ].contains(widget.paymentType);
  }

  Widget _buildVASection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Nomor Virtual Account",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  vaNumber,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _copyToClipboard(vaNumber, "Nomor VA"),
                icon: Icon(Icons.copy, color: Colors.blue),
                tooltip: "Salin",
              ),
            ],
          ),
          const Divider(height: 24),
          Text(
            "Atas Nama: MERCHANT PAYMENT",
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildRetailSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Kode Pembayaran",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  paymentCode,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              IconButton(
                onPressed:
                    () => _copyToClipboard(paymentCode, "Kode Pembayaran"),
                icon: Icon(Icons.copy, color: Colors.blue),
                tooltip: "Salin",
              ),
            ],
          ),
          const Divider(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Tunjukkan kode ini ke kasir ${widget.paymentType}",
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEwalletSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(Icons.qr_code_2, size: 120, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            "Scan QR Code",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Buka aplikasi ${widget.paymentType} dan scan QR code di atas",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(Icons.payment, size: 80, color: Colors.blue),
          const SizedBox(height: 16),
          Text(
            "Instruksi pembayaran akan dikirim ke email Anda",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsSection() {
    List<Map<String, dynamic>> instructions = [];

    if (widget.paymentType.contains("BCA")) {
      instructions = [
        {
          "title": "ATM BCA",
          "steps": [
            "Masukkan kartu ATM dan PIN",
            "Pilih menu Transaksi Lainnya > Transfer > ke Rek BCA Virtual Account",
            "Masukkan nomor Virtual Account: $vaNumber",
            "Masukkan jumlah transfer sesuai tagihan",
            "Ikuti instruksi untuk menyelesaikan transaksi",
          ],
        },
        {
          "title": "m-BCA (BCA Mobile)",
          "steps": [
            "Login ke aplikasi m-BCA",
            "Pilih m-BCA > m-Transfer > BCA Virtual Account",
            "Masukkan nomor Virtual Account: $vaNumber",
            "Masukkan jumlah transfer sesuai tagihan",
            "Masukkan PIN m-BCA",
            "Klik OK untuk menyelesaikan transaksi",
          ],
        },
        {
          "title": "Klik BCA (Internet Banking)",
          "steps": [
            "Login ke KlikBCA",
            "Pilih Transfer Dana > Transfer ke BCA Virtual Account",
            "Masukkan nomor Virtual Account: $vaNumber",
            "Masukkan jumlah transfer sesuai tagihan",
            "Ikuti instruksi untuk menyelesaikan transaksi",
          ],
        },
      ];
    } else if (widget.paymentType.contains("Mandiri")) {
      instructions = [
        {
          "title": "ATM Mandiri",
          "steps": [
            "Masukkan kartu ATM dan PIN",
            "Pilih menu Bayar/Beli",
            "Pilih menu Lainnya > Multipayment",
            "Masukkan kode perusahaan: 88908",
            "Masukkan nomor Virtual Account: $vaNumber",
            "Masukkan angka 1 untuk memilih tagihan",
            "Masukkan jumlah transfer sesuai tagihan",
            "Ikuti instruksi untuk menyelesaikan transaksi",
          ],
        },
        {
          "title": "Livin' by Mandiri",
          "steps": [
            "Login ke aplikasi Livin' by Mandiri",
            "Pilih Bayar > Buat Pembayaran Baru",
            "Pilih Penyedia Jasa > Multipayment",
            "Pilih Penyedia Jasa: Midtrans",
            "Masukkan nomor Virtual Account: $vaNumber",
            "Konfirmasi pembayaran dan masukkan PIN",
          ],
        },
      ];
    } else if (widget.paymentType.contains("BNI")) {
      instructions = [
        {
          "title": "ATM BNI",
          "steps": [
            "Masukkan kartu ATM dan PIN",
            "Pilih menu Lainnya > Transfer > Rekening Tabungan",
            "Masukkan nomor rekening: $vaNumber",
            "Masukkan jumlah transfer sesuai tagihan",
            "Ikuti instruksi untuk menyelesaikan transaksi",
          ],
        },
        {
          "title": "BNI Mobile Banking",
          "steps": [
            "Login ke aplikasi BNI Mobile Banking",
            "Pilih Transfer > Virtual Account Billing",
            "Pilih rekening debet",
            "Masukkan nomor Virtual Account: $vaNumber",
            "Masukkan jumlah transfer",
            "Konfirmasi dan masukkan password transaksi",
          ],
        },
      ];
    } else if (widget.paymentType.contains("BRI")) {
      instructions = [
        {
          "title": "ATM BRI",
          "steps": [
            "Masukkan kartu ATM dan PIN",
            "Pilih menu Transaksi Lain > Pembayaran > Lainnya > BRIVA",
            "Masukkan nomor BRIVA: $vaNumber",
            "Masukkan jumlah yang akan dibayar",
            "Ikuti instruksi untuk menyelesaikan transaksi",
          ],
        },
        {
          "title": "BRImo (BRI Mobile)",
          "steps": [
            "Login ke aplikasi BRImo",
            "Pilih menu Pembayaran > BRIVA",
            "Masukkan nomor BRIVA: $vaNumber",
            "Masukkan jumlah pembayaran",
            "Masukkan PIN BRImo",
            "Klik Kirim untuk menyelesaikan transaksi",
          ],
        },
      ];
    } else if (widget.paymentType == "Indomaret") {
      instructions = [
        {
          "title": "Cara Bayar di Indomaret",
          "steps": [
            "Kunjungi gerai Indomaret terdekat",
            "Tunjukkan kode pembayaran: $paymentCode kepada kasir",
            "Kasir akan memproses pembayaran",
            "Bayar sesuai jumlah tagihan",
            "Simpan struk sebagai bukti pembayaran",
          ],
        },
      ];
    } else if (widget.paymentType == "Alfamart") {
      instructions = [
        {
          "title": "Cara Bayar di Alfamart",
          "steps": [
            "Kunjungi gerai Alfamart terdekat",
            "Tunjukkan kode pembayaran: $paymentCode kepada kasir",
            "Kasir akan memproses pembayaran",
            "Bayar sesuai jumlah tagihan",
            "Simpan struk sebagai bukti pembayaran",
          ],
        },
      ];
    } else if (_isEwallet()) {
      instructions = [
        {
          "title": "Cara Bayar dengan ${widget.paymentType}",
          "steps": [
            "Buka aplikasi ${widget.paymentType}",
            "Scan QR Code yang ditampilkan",
            "Periksa detail pembayaran",
            "Konfirmasi pembayaran dengan PIN/biometrik",
            "Pembayaran selesai, simpan bukti transaksi",
          ],
        },
      ];
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                "Cara Pembayaran",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...instructions.map(
            (instruction) => _buildInstructionItem(
              instruction["title"],
              instruction["steps"],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String title, List<String> steps) {
    return ExpansionTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(left: 16, bottom: 12),
      children:
          steps.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        "${entry.key + 1}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}
