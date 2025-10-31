import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indosemecb2b/screen/pembayaran_berhasil.dart';
import 'package:indosemecb2b/screen/input_pin.dart'; // ✅ ADD
import 'package:indosemecb2b/screen/poinku.dart';
import 'package:indosemecb2b/utils/pin_manager.dart';
import 'package:indosemecb2b/utils/poin_cash_manager.dart';
import 'package:indosemecb2b/utils/user_data_manager.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:indosemecb2b/utils/saldo_klik_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentMethodScreen extends StatefulWidget {
  final double totalPembayaran;

  const PaymentMethodScreen({Key? key, required this.totalPembayaran})
    : assert(totalPembayaran > 0, 'Total pembayaran harus lebih dari 0'),
      super(key: key);

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  bool _isLoadingSaldo = true;
  bool _isSaldoKlikActive = false;
  double _saldoKlik = 0.0;
  double _poinCash = 0.0;

  static final _formatRupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadPoinCash();
    _checkSaldoKlik();
  }

  Future<void> _loadPoinCash() async {
    final poinCash = await PoinCashManager.getTotalPoinCash();
    setState(() {
      _poinCash = poinCash;
    });
  }

  Future<void> _checkSaldoKlik() async {
    final isActive = await SaldoKlikManager.isActive();
    final saldo = await SaldoKlikManager.getSaldo();

    setState(() {
      _isSaldoKlikActive = isActive;
      _saldoKlik = saldo;
      _isLoadingSaldo = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Validasi tambahan
    if (widget.totalPembayaran <= 0 ||
        widget.totalPembayaran.isNaN ||
        widget.totalPembayaran.isInfinite) {
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
                "Total: ${widget.totalPembayaran}",
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
                  _formatRupiah.format(widget.totalPembayaran),
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
          if (_isSaldoKlikActive) ...[
            _sectionHeader("Saldo Klik"),
            _paymentItem(
              context: context,
              imageUrl:
                  "https://i.pinimg.com/736x/65/c4/1d/65c41db5a939f1e45c5f1ff1244689f5.jpg",
              title: "Saldo Klik",
              subtitle: "Saldo: ${_formatRupiah.format(_saldoKlik)}",
              badge:
                  _saldoKlik >= widget.totalPembayaran
                      ? "Tersedia"
                      : "Tidak Cukup",
              paymentType: "Saldo Klik",
              isEnabled: _saldoKlik >= widget.totalPembayaran,
            ),
            const SizedBox(height: 16),
          ],
          _paymentItem(
            context: context,
            imageUrl:
                "https://i.pinimg.com/736x/65/c4/1d/65c41db5a939f1e45c5f1ff1244689f5.jpg",
            title: "Poin Cash",
            subtitle: "Saldo: ${formatCurrency(_poinCash.toInt())}",
            badge:
                _poinCash >= widget.totalPembayaran
                    ? "Tersedia"
                    : "Tidak Cukup",
            paymentType: "Poin Cash",
            isEnabled:
                _poinCash >
                0, // Bisa dipakai meski tidak cukup (untuk potongan)
          ),

          // E-Wallet Section
          _sectionHeader("E-Wallet"),
          _paymentItem(
            context: context,
            imageUrl:
                "https://i.pinimg.com/736x/c7/40/65/c74065540ccade0683a869b622cdc4a6.jpg",
            title: "GoPay",
            subtitle: "Bayar dengan GoPay",
            badge: "Promo 50%",
            paymentType: "GoPay",
          ),
          _paymentItem(
            context: context,
            imageUrl:
                "https://i.pinimg.com/736x/c1/0a/d6/c10ad6ece8ee01e5d2eacc07bc2c1490.jpg",
            title: "OVO",
            subtitle: "Bayar dengan OVO",
            paymentType: "OVO",
          ),
          _paymentItem(
            context: context,
            imageUrl:
                "https://i.pinimg.com/1200x/2b/1f/11/2b1f11dec29fe28b5137b46fffa0b25f.jpg",
            title: "DANA",
            subtitle: "Bayar dengan DANA",
            paymentType: "DANA",
          ),
          _paymentItem(
            context: context,
            imageUrl:
                "https://i.pinimg.com/736x/d4/9f/70/d49f702b94f54a479ff6a44525650537.jpg",
            title: "ShopeePay",
            subtitle: "Bayar dengan ShopeePay",
            paymentType: "ShopeePay",
          ),
          _paymentItem(
            context: context,
            imageUrl:
                "https://i.pinimg.com/736x/a3/ac/dc/a3acdc5237d8c3cd9634b8eb7561c16f.jpg",
            title: "LinkAja",
            subtitle: "Bayar dengan LinkAja",
            paymentType: "LinkAja",
          ),

          const SizedBox(height: 16),

          // Virtual Account Section
          _sectionHeader("Virtual Account"),
          _paymentItem(
            context: context,
            imageUrl:
                "https://i.pinimg.com/736x/0b/ed/5c/0bed5c44c43dc1efd1cbf6acf3aa1d89.jpg",
            title: "BCA Virtual Account",
            subtitle: "Gratis biaya admin",
            paymentType: "BCA VA",
          ),
          _paymentItem(
            context: context,
            imageUrl:
                "https://i.pinimg.com/1200x/41/5f/61/415f6193712cbf8e90613921937aa86b.jpg",
            title: "Mandiri Virtual Account",
            subtitle: "Gratis biaya admin",
            paymentType: "Mandiri VA",
          ),
          _paymentItem(
            context: context,
            imageUrl:
                "https://i.pinimg.com/736x/13/16/5f/13165f728ca28d89ac144c599dca049b.jpg",
            title: "BNI Virtual Account",
            subtitle: "Gratis biaya admin",
            paymentType: "BNI VA",
          ),
          _paymentItem(
            context: context,
            imageUrl:
                "https://i.pinimg.com/736x/f8/89/3c/f8893c524e737a00d7aabc02a1737ce9.jpg",
            title: "BRI Virtual Account",
            subtitle: "Gratis biaya admin",
            paymentType: "BRI VA",
          ),
          _paymentItem(
            context: context,
            imageUrl:
                "https://i.pinimg.com/1200x/62/6d/d1/626dd13e3b9db99ed728f6363d2ca274.jpg",
            title: "Permata Virtual Account",
            subtitle: "Gratis biaya admin",
            paymentType: "Permata VA",
          ),

          const SizedBox(height: 16),

          // Transfer Bank Section
          _sectionHeader("Transfer Bank"),
          _paymentItem(
            context: context,
            imageUrl:
                "https://i.pinimg.com/1200x/a2/9d/29/a29d290535c8a5fd55f67631c7e454f1.jpg",
            title: "Transfer Bank Manual",
            subtitle: "BCA, Mandiri, BNI, BRI, dll",
            paymentType: "Transfer Bank",
          ),

          const SizedBox(height: 16),

          // Kartu Kredit/Debit Section
          _sectionHeader("Kartu Kredit/Debit"),
          _paymentItem(
            context: context,
            imageUrl:
                "https://i.pinimg.com/736x/65/c4/1d/65c41db5a939f1e45c5f1ff1244689f5.jpg",
            title: "Kartu Kredit",
            subtitle: "Visa, Mastercard, JCB",
            badge: "Cicilan 0%",
            paymentType: "Kartu Kredit",
          ),
          _paymentItem(
            context: context,
            imageUrl:
                "https://i.pinimg.com/736x/4e/56/b0/4e56b0a53d2857bcb414c6fe67d76b06.jpg",
            title: "Kartu Debit",
            subtitle: "Semua bank",
            paymentType: "Kartu Debit",
          ),

          const SizedBox(height: 16),

          // Gerai Retail Section
          _sectionHeader("Gerai Retail"),
          _paymentItem(
            context: context,
            imageUrl:
                "https://i.pinimg.com/736x/e7/26/25/e72625c9daad5afee9521ecfb2abec53.jpg",
            title: "Indomaret",
            subtitle: "Bayar di kasir Indomaret",
            paymentType: "Indomaret",
          ),
          _paymentItem(
            context: context,
            imageUrl:
                "https://i.pinimg.com/1200x/4e/59/af/4e59afc6923d959e8ebc9d10d7f66c33.jpg",
            title: "Alfamart",
            subtitle: "Bayar di kasir Alfamart",
            paymentType: "Alfamart",
          ),

          const SizedBox(height: 16),

          // Paylater Section
          _sectionHeader("Paylater"),
          _paymentItem(
            context: context,
            imageUrl:
                "https://i.pinimg.com/736x/69/77/da/6977da92f7d18a2f667de0b575a4d1b6.jpg",
            title: "Kredivo",
            subtitle: "Bayar dalam 30 hari",
            badge: "Bunga 0%",
            paymentType: "Kredivo",
          ),
          _paymentItem(
            context: context,
            imageUrl:
                "https://i.pinimg.com/736x/d5/16/b5/d516b5226688dccc16ba2bfa3b32230e.jpg",
            title: "Akulaku",
            subtitle: "Cicilan tanpa kartu kredit",
            paymentType: "Akulaku",
          ),
          _paymentItem(
            context: context,
            imageUrl:
                "https://i.pinimg.com/1200x/7c/50/f0/7c50f0b7ebf83989a200063ed2605d15.jpg",
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
    required String imageUrl,
    required String title,
    required String subtitle,
    String? badge,
    required String paymentType,
    bool isEnabled = true,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Image.network(imageUrl, fit: BoxFit.cover),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        badge == "Tidak Cukup"
                            ? Colors.red.shade100
                            : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color:
                          badge == "Tidak Cukup"
                              ? Colors.red.shade800
                              : Colors.orange.shade800,
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
          enabled: isEnabled,
          onTap:
              isEnabled
                  ? () async {
                    final userLogin =
                        await UserDataManager.getCurrentUserLogin();
                    if (userLogin == null) return;

                    // ✅ Cek apakah PIN sudah diset untuk metode yang memerlukan PIN
                    if (paymentType == "Poin Cash" ||
                        paymentType == "Saldo Klik") {
                      final isPinSet = await PinManager.isPinSet(userLogin);
                      if (!isPinSet) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Anda belum mengatur PIN. Silakan atur PIN terlebih dahulu.',
                            ),
                            backgroundColor: Colors.orange,
                            duration: Duration(seconds: 3),
                          ),
                        );
                        return;
                      }
                    }

                    // ✅ Logika Pembayaran Poin Cash
                    if (paymentType == "Poin Cash") {
                      // Cek apakah PIN sudah diset
                      final userLogin =
                          await UserDataManager.getCurrentUserLogin();
                      if (userLogin == null) return;

                      final isPinSet = await PinManager.isPinSet(userLogin);

                      if (!isPinSet) {
                        // Redirect ke pengaturan untuk set PIN
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Anda belum mengatur PIN. Silakan atur PIN terlebih dahulu.',
                            ),
                            backgroundColor: Colors.orange,
                            duration: Duration(seconds: 3),
                          ),
                        );
                        return;
                      }
                      final double amountToUse =
                          _poinCash >= widget.totalPembayaran
                              ? widget.totalPembayaran
                              : _poinCash;

                      final double remaining =
                          widget.totalPembayaran - amountToUse;

                      // Show confirmation dialog
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: Row(
                                children: [
                                  Icon(
                                    Icons.account_balance_wallet,
                                    color: Colors.green[700],
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Gunakan Poin Cash'),
                                ],
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Total Belanja:'),
                                            Text(
                                              formatCurrency(
                                                widget.totalPembayaran.toInt(),
                                              ),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Divider(height: 16),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Poin Cash Digunakan:'),
                                            Text(
                                              formatCurrency(
                                                amountToUse.toInt(),
                                              ),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (remaining > 0) ...[
                                          const Divider(height: 16),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'Sisa yang Harus Dibayar:',
                                              ),
                                              Text(
                                                formatCurrency(
                                                  remaining.toInt(),
                                                ),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.orange[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.green[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.green[200]!,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: Colors.green[700],
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            remaining > 0
                                                ? 'Anda perlu memilih metode pembayaran lain untuk sisa pembayaran'
                                                : 'Pembayaran akan lunas dengan Poin Cash',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.green[900],
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
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: const Text('Batal'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[700],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Lanjutkan',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                      );

                      if (confirmed != true || !context.mounted) return;

                      // Request PIN
                      final pin = await Navigator.push<String>(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => const InputPinScreen(
                                title: 'Masukkan PIN Poin Cash',
                                subtitle: 'Konfirmasi penggunaan Poin Cash',
                              ),
                        ),
                      );

                      if (pin == null || !context.mounted) return;

                      // Show loading
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder:
                            (context) => Dialog(
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              child: Container(
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.green[400]!,
                                            Colors.green[700]!,
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.account_balance_wallet,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    const CircularProgressIndicator(),
                                    const SizedBox(height: 24),
                                    const Text(
                                      'Memproses Pembayaran',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Menggunakan Poin Cash...',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      );

                      await Future.delayed(const Duration(seconds: 1));

                      // Use Poin Cash
                          'TRX${DateTime.now().millisecondsSinceEpoch}';
                      // ✅ SIMPLIFIED: Hanya validasi PIN & saldo
                      // Transaction save akan dilakukan di checkout.dart
                      final result =
                          await PoinCashManager.validatePoinCashUsage(
                            amount: amountToUse,
                            pin: pin,
                          );

                      if (context.mounted) {
                        Navigator.pop(context); // Close loading
                      }

                      if (result['success'] == true) {
                        if (remaining > 0) {
                          // Masih ada sisa, perlu metode pembayaran lain
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '✅ Poin Cash Rp${formatCurrency(amountToUse.toInt())} berhasil digunakan!\nSilakan pilih metode pembayaran untuk sisa Rp${formatCurrency(remaining.toInt())}',
                                ),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 4),
                              ),
                            );

                            // Return data kombinasi
                            Navigator.pop(context, {
                              'type': 'Kombinasi Poin Cash',
                              'poinCashUsed': amountToUse,
                              'remaining': remaining,
                            });
                          }
                        } else {
                          // Lunas dengan Poin Cash
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  '✅ Pembayaran lunas dengan Poin Cash!',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );

                            Navigator.pop(context, {
                              'type': 'Poin Cash',
                              'poinCashUsed': amountToUse,
                              'remaining': 0.0,
                            });
                          }
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('❌ ${result['message']}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                    // ✅ Logika Pembayaran Saldo Klik
                    else if (paymentType == "Saldo Klik") {
                      // Step 1: Konfirmasi
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: const Text('Konfirmasi Pembayaran'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Total Pembayaran:'),
                                  Text(
                                    _formatRupiah.format(
                                      widget.totalPembayaran,
                                    ),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Divider(),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Saldo Saat Ini:'),
                                      Text(
                                        _formatRupiah.format(_saldoKlik),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Saldo Setelah:'),
                                      Text(
                                        _formatRupiah.format(
                                          _saldoKlik - widget.totalPembayaran,
                                        ),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.lock_outline,
                                          color: Colors.blue[700],
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        const Expanded(
                                          child: Text(
                                            'Anda akan diminta memasukkan PIN untuk konfirmasi',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.blue,
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
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: const Text('Batal'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[700],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Lanjutkan',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                      );

                      if (confirmed != true || !context.mounted) return;

                      // Step 2: Input PIN
                      final pin = await Navigator.push<String>(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => const InputPinScreen(
                                title: 'Masukkan PIN',
                                subtitle:
                                    'Masukkan PIN untuk konfirmasi pembayaran',
                              ),
                        ),
                      );

                      if (pin == null || !context.mounted) return;

                      // Step 3: Loading Dialog
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder:
                            (context) => Dialog(
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 36,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 30,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Animated Payment Icon
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.green[400]!,
                                            Colors.green[700]!,
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.green.withOpacity(
                                              0.3,
                                            ),
                                            blurRadius: 15,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.payment,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                    ),
                                    const SizedBox(height: 28),

                                    // Loading Indicator
                                    SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.green[700]!,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // Title
                                    const Text(
                                      'Memproses Pembayaran',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Subtitle
                                    Text(
                                      'Mohon jangan tutup aplikasi\nProses akan selesai sebentar lagi',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      );

                      // Step 4: Proses Pembayaran
                      await Future.delayed(const Duration(seconds: 1));
                      final transactionId =
                          'TRX${DateTime.now().millisecondsSinceEpoch}';
                      final success = await SaldoKlikManager.deductSaldo(
                        widget.totalPembayaran,
                        'Pembayaran Transaksi $transactionId',
                        pin,
                      );

                      if (context.mounted)
                        Navigator.pop(context); // Tutup loading

                      if (success && context.mounted) {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('should_refresh_poin', true);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Pembayaran berhasil!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context, paymentType);
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('❌ PIN salah atau pembayaran gagal'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                    // ✅ Metode Pembayaran Lain
                    else {
                      final selectedMethod = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => PaymentDetailScreen(
                                paymentType: paymentType,
                                totalPembayaran: widget.totalPembayaran,
                              ),
                        ),
                      );

                      if (selectedMethod != null && context.mounted) {
                        Navigator.pop(context, selectedMethod);
                      }
                    }
                  }
                  : null,
        ),
      ),
    );
  }
}

// Payment Detail Screen (unchanged from original)
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
    symbol: 'Rp',
    decimalDigits: 0,
  );

  String _randomNumericString(int length) {
    final random = Random();
    final buffer = StringBuffer();
    for (int i = 0; i < length; i++) {
      buffer.write(random.nextInt(10));
    }
    return buffer.toString();
  }

  late String vaNumber;
  late String paymentCode;
  late DateTime expiredTime;

  @override
  void initState() {
    super.initState();
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
    } else if (widget.paymentType.contains("BNI")) {
      return "8808" + _randomNumericString(10);
    } else if (widget.paymentType.contains("BRI")) {
      return "26215" + _randomNumericString(10);
    } else if (widget.paymentType.contains("Permata")) {
      return "8528" + _randomNumericString(10);
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

          if (_isVirtualAccount())
            _buildVASection()
          else if (_isRetail())
            _buildRetailSection()
          else if (_isEwallet())
            _buildEwalletSection()
          else
            _buildOtherSection(),

          const SizedBox(height: 24),

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
            onPressed: () async {
              print(
                '💳 User clicked "Saya Sudah Bayar" for: ${widget.paymentType}',
              );

              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('should_refresh_poin', true);

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
