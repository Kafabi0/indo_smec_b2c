import 'package:flutter/material.dart';
import 'package:indosemecb2b/screen/main_navigasi.dart';
import 'package:indosemecb2b/screen/pin_poin.dart';
import 'package:indosemecb2b/screen/voucher.dart';
import 'package:indosemecb2b/utils/pin_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/product_service.dart';
import 'package:indosemecb2b/utils/transaction_manager.dart';
import 'package:indosemecb2b/models/transaction.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';
import 'package:indosemecb2b/utils/poin_cash_manager.dart';
import 'package:indosemecb2b/models/voucher_model.dart';
import 'package:indosemecb2b/utils/voucher_manager.dart'; // ✅ TAMBAHKAN IMPORT INI di bagian atas file

// Fungsi helper untuk format mata uang Indonesia
String formatCurrency(int amount) {
  return 'Rp${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
}

// ==== POINKU MAIN SCREEN DENGAN BOTTOM NAV SENDIRI ====
class PoinkuMainScreen extends StatefulWidget {
  const PoinkuMainScreen({super.key});

  @override
  State<PoinkuMainScreen> createState() => _PoinkuMainScreenState();
}

class _PoinkuMainScreenState extends State<PoinkuMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const PoinkuScreen(),
    const RiwayatScreen(),
    const PengaturanScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[700]!, Colors.blue[900]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white60,
              selectedFontSize: 13,
              unselectedFontSize: 12,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.card_giftcard, size: 26),
                  label: 'Poinku',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history, size: 26),
                  label: 'Riwayat',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings, size: 26),
                  label: 'Pengaturan',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==== SCREEN 1: POINKU ====
class PoinkuScreen extends StatefulWidget {
  const PoinkuScreen({super.key});

  @override
  State<PoinkuScreen> createState() => _PoinkuScreenState();
}

class _PoinkuScreenState extends State<PoinkuScreen>
    with WidgetsBindingObserver {
  bool _isPointsVisible = true;
  String userName = '';
  String memberTier = 'Blue';
  String userPoinId = '';

  int totalPoin = 0;
  int totalStamp = 0;
  int totalPoinCash = 0;
  List<Transaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // ⭐ TAMBAHKAN

    _loadUserData();
    _calculateTotalPoints();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // ⭐ TAMBAHKAN
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _calculateTotalPoints();
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load ID Poinku atau generate jika belum ada
    String? poinId = prefs.getString('user_poin_id');
    if (poinId == null || poinId.isEmpty) {
      final userPhone = prefs.getString('userPhone') ?? '08xxxxxxxxxx';
      final lastPhone =
          userPhone.length >= 4
              ? userPhone.substring(userPhone.length - 4)
              : '0000';
      poinId = 'INDOSMEC-${DateTime.now().year}-$lastPhone';
      await prefs.setString('user_poin_id', poinId);
    }

    setState(() {
      userName = prefs.getString('userName') ?? 'User';
      memberTier = 'Blue';
      userPoinId = poinId!;
    });
  }

  Future<void> _calculateTotalPoints() async {
    print('🔍 [POINKU] _calculateTotalPoints() dipanggil');

    // ✅ 1. HITUNG POIN UMKM (SUDAH DIKURANGI VOUCHER)
    final poinUMKM = await VoucherManager.getUserPoinUMKM();
    print('📊 [POINKU] Total Poin UMKM: $poinUMKM');

    // ✅ 2. HITUNG POIN CASH (SUDAH DIKURANGI PENGGUNAAN)
    final poinCashValue = await PoinCashManager.getTotalPoinCash();
    print('💰 [POINKU] Total Poin Cash: $poinCashValue');

    // ✅ 3. HITUNG STAMP (dari transaksi selesai, kecuali Poin Cash usage & Top-Up)
    final transactions = await TransactionManager.getFilteredTransactions(
      status: 'Selesai',
      dateFilter: 'Semua Tanggal',
      category: 'Semua',
    );

    int stampCount = 0;
    for (var transaction in transactions) {
      // Skip transaksi penggunaan Poin Cash & Top-Up untuk stamp
      if (transaction.deliveryOption != 'poin_cash_usage' &&
          transaction.deliveryOption != 'topup') {
        stampCount++;
      }
    }

    print('📦 [POINKU] Total Stamp: $stampCount');
    print('✅ [POINKU] Update UI dengan data baru');

    if (mounted) {
      setState(() {
        totalPoin = poinUMKM;
        totalStamp = stampCount;
        totalPoinCash = poinCashValue.toInt();
      });
    }
  }

  void _togglePointsVisibility() {
    setState(() {
      _isPointsVisible = !_isPointsVisible;
    });
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // ==== PREMIUM CURVED HEADER ====
            Stack(
              children: [
                // Background Gradient dengan Curve
                Container(
                  height: 360,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[700]!, Colors.blue[900]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Pattern overlay
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.1,
                          child: CustomPaint(painter: PatternPainter()),
                        ),
                      ),
                    ],
                  ),
                ),

                // Curve Shape
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      // Top Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 24,
                            ),
                            onPressed: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) => const MainNavigation(),
                                ),
                                (route) => false,
                              );
                            },
                          ),
                          Text(
                            'Poinku',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                              size: 24,
                            ),
                            onPressed: () {
                              // Refresh poin
                              _calculateTotalPoints();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Poin diperbarui!'),
                                  duration: Duration(seconds: 1),
                                  backgroundColor: Colors.green[700],
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ==== PREMIUM MEMBER CARD ====
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.white, Colors.blue[50]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header dengan Badge & Visibility Toggle
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Member Badge
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.blue[400]!,
                                            Colors.blue[700]!,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.blue.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.workspace_premium,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          userName,
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          'Member $memberTier',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue[900],
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                // Toggle Visibility
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      _isPointsVisible
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: Colors.blue[700],
                                      size: 20,
                                    ),
                                    onPressed: _togglePointsVisibility,
                                    tooltip:
                                        _isPointsVisible
                                            ? 'Sembunyikan Saldo'
                                            : 'Tampilkan Saldo',
                                    padding: const EdgeInsets.all(8),
                                    constraints: const BoxConstraints(),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // Member ID
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.blue[100]!,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.credit_card,
                                    size: 13,
                                    color: Colors.blue[700],
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'ID: ${userPoinId.isNotEmpty ? userPoinId : "Loading..."}',
                                    style: GoogleFonts.robotoMono(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue[800],
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ==== 3 KARTU POIN HORIZONTAL (DENGAN DATA REAL) ====
                      Row(
                        children: [
                          _buildPointCard(
                            'Poin UMKM',
                            _formatNumber(totalPoin),
                            Icons.stars_rounded,
                            Colors.blue[700]!,
                            Colors.blue[50]!,
                          ),
                          const SizedBox(width: 10),
                          _buildPointCard(
                            'Stamp',
                            totalStamp.toString(),
                            Icons.local_offer_rounded,
                            Colors.orange[700]!,
                            Colors.orange[50]!,
                          ),
                          const SizedBox(width: 10),
                          _buildPointCard(
                            'Poin Cash',
                            _formatNumber(totalPoinCash),
                            Icons.account_balance_wallet_rounded,
                            Colors.green[700]!,
                            Colors.green[50]!,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ==== CONTENT ====
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==== QR CODE CARD ====
                    Transform.translate(
                      offset: const Offset(0, -43),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.qr_code_scanner,
                                  color: Colors.blue[700],
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Scan untuk Belanja',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // QR Code
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey[200]!,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.qr_code_2_rounded,
                                size: 140,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 12),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                'Tunjukkan ke kasir untuk dapat promo & bayar pakai Poin Cash.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  color: Colors.grey[600],
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tukar Poin dengan Voucher',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => VoucherStoreScreen(
                                            userPoints: totalPoin,
                                            onVoucherRedeemed: () {
                                              _calculateTotalPoints();
                                            },
                                          ),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.store, size: 18),
                                label: Text(
                                  'Lihat Semua',
                                  style: GoogleFonts.poppins(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildVoucherPreview(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),

                    // ==== METODE PEMBAYARAN ====
                    Text(
                      'Metode Pembayaran',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildPaymentMethod(
                      'Poin Cash',
                      formatCurrency(totalPoinCash),
                      Icons.account_balance_wallet_rounded,
                      Colors.green[700]!,
                      true,
                    ),
                    const SizedBox(height: 10),
                    _buildPaymentMethod(
                      'i.Saku',
                      'Terhubung',
                      Icons.payment_rounded,
                      Colors.red[700]!,
                      false,
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointCard(
    String title,
    String value,
    IconData icon,
    Color color,
    Color bgColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _isPointsVisible ? value : '••••',
              style: GoogleFonts.poppins(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoucherPreview() {
    return FutureBuilder<List<UserVoucher>>(
      future: VoucherManager.getUserVouchers(onlyValid: true),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final userVouchers = snapshot.data ?? [];

        if (userVouchers.isEmpty) {
          // Tampilkan promo card untuk tukar voucher
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => VoucherStoreScreen(
                        userPoints: totalPoin,
                        onVoucherRedeemed: () {
                          _calculateTotalPoints();
                        },
                      ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange[400]!, Colors.orange[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.redeem,
                      color: Colors.orange[700],
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tukar Poin Jadi Voucher!',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Dapatkan diskon hingga Rp 100.000',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
                ],
              ),
            ),
          );
        }

        // Tampilkan voucher yang dimiliki (max 3)
        return Column(
          children: [
            ...userVouchers.take(3).map((voucher) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.local_offer,
                        color: Colors.green[700],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            voucher.name,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            voucher.code,
                            style: GoogleFonts.robotoMono(
                              fontSize: 11,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[700],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        formatCurrency(voucher.discountAmount),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            if (userVouchers.length > 3)
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => VoucherStoreScreen(
                            userPoints: totalPoin,
                            onVoucherRedeemed: () {
                              _calculateTotalPoints();
                            },
                          ),
                    ),
                  );
                },
                child: Text(
                  'Lihat ${userVouchers.length - 3} voucher lainnya',
                  style: GoogleFonts.poppins(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildPaymentMethod(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool isActive,
  ) {
    // ⭐ Format poin cash dengan benar (sebagai mata uang)
    String displaySubtitle = subtitle;
    if (title == 'Poin Cash' && _isPointsVisible) {
      displaySubtitle = formatCurrency(totalPoinCash);
    } else if (title == 'Poin Cash' && !_isPointsVisible) {
      displaySubtitle = '••••••';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? color.withOpacity(0.3) : Colors.grey[200]!,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  displaySubtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Aktif',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
        ],
      ),
    );
  }
}

// Custom Painter untuk pattern decorative
class PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    for (var i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.3 + (i * 30)),
        20 + (i * 10),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ==== SCREEN 2: RIWAYAT ====
class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  int _selectedTab = 0;
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  String _currentUserName = '';
  String _currentUserPhone = '';
  String _metodePembayaran = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadTransactions();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserName = prefs.getString('userName') ?? 'Customer';
      _currentUserPhone = prefs.getString('userPhone') ?? '08xxxxxxxxxx';
    });
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });

    final transactions = await TransactionManager.getFilteredTransactions(
      status: 'Semua Status',
      dateFilter: 'Semua Tanggal',
      category: 'Semua',
    );

    setState(() {
      _transactions = transactions;
      _isLoading = false;
    });
  }

  int _calculatePoints(double amount) {
    return (amount / 1000).floor();
  }

  String _formatDate(DateTime date) {
    final months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month];
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day $month $year, $hour:$minute';
  }

  String _formatDateStruk(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString().substring(2);
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day.$month.$year-$hour:$minute';
  }

  String formatCurrency(int amount) {
    return 'Rp${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  // ✅ FUNGSI GENERATE PDF
  Future<File> _generatePDF(Transaction transaction) async {
    final pdf = pw.Document();
    final ongkir = 5000.0;
    final subtotal = transaction.totalPrice - ongkir;

    // Menggunakan format kertas yang lebih sempit seperti struk kasir
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80.copyWith(
          marginTop: 10,
          marginBottom: 10,
          marginLeft: 5,
          marginRight: 5,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Header - lebih kecil dan di tengah
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(5),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue700,
                  borderRadius: pw.BorderRadius.circular(3),
                ),
                child: pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'INDOSMEC',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.SizedBox(height: 1),
                      pw.Text(
                        'BELANJA LEBIH MUDAH',
                        style: pw.TextStyle(
                          fontSize: 7,
                          color: PdfColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              pw.SizedBox(height: 5),

              // Info Toko - lebih kecil dan di tengah
              pw.Column(
                children: [
                  pw.Text(
                    'KOPERASI MERAH PUTIH ANTAPANI',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.Text(
                    'Jl. AH. Nasution No.928 Blok E',
                    style: const pw.TextStyle(fontSize: 6),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.Text(
                    'Antapani Wetan, Kec. Antapani',
                    style: const pw.TextStyle(fontSize: 6),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.Text(
                    'Kota Bandung, Jawa Barat 40291',
                    style: const pw.TextStyle(fontSize: 6),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'NPWP: 001.337.994.6-092.000',
                    style: const pw.TextStyle(fontSize: 5),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.Text(
                    'Telp: 0811.1500.280',
                    style: const pw.TextStyle(fontSize: 5),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
              ),

              pw.SizedBox(height: 5),
              pw.Divider(thickness: 0.3),
              pw.SizedBox(height: 3),

              // Info Transaksi - lebih kecil
              _buildPdfInfoRow('NO. TRANSAKSI', transaction.id, bold: true),
              _buildPdfInfoRow('TANGGAL', _formatDateStruk(transaction.date)),
              _buildPdfInfoRow(
                'KASIR',
                transaction.deliveryOption == 'xpress'
                    ? 'ONLINE XPRESS'
                    : 'ONLINE REGULER',
              ),

              pw.SizedBox(height: 3),
              pw.Divider(thickness: 0.3),
              pw.SizedBox(height: 3),

              // Alamat Pengiriman - lebih kecil
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: pw.BorderRadius.circular(3),
                  border: pw.Border.all(color: PdfColors.blue200),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'ALAMAT PENGIRIMAN',
                      style: pw.TextStyle(
                        fontSize: 7,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 1),
                    pw.Text(
                      transaction.alamat?['nama_penerima'] ?? _currentUserName,
                      style: pw.TextStyle(
                        fontSize: 7,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      transaction.alamat?['nomor_hp'] ?? _currentUserPhone,
                      style: const pw.TextStyle(fontSize: 6),
                    ),
                    pw.SizedBox(height: 1),
                    pw.Text(
                      transaction.alamat?['alamat_lengkap'] ??
                          'Alamat tidak tersedia',
                      style: const pw.TextStyle(fontSize: 6),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 3),
              _buildPdfInfoRow(
                'METODE BAYAR',
                transaction.metodePembayaran ??
                    transaction.alamat?['metode_pembayaran'] ??
                    'Tidak Diketahui',
              ),

              pw.SizedBox(height: 3),
              pw.Divider(thickness: 0.3),
              pw.SizedBox(height: 3),

              // Daftar Belanja - lebih kecil
              pw.Text(
                'DAFTAR BELANJA',
                style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 2),

              // Header Tabel Produk - lebih kecil
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 1),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(width: 0.2, color: PdfColors.grey300),
                  ),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 5,
                      child: pw.Text(
                        'NAMA PRODUK',
                        style: pw.TextStyle(
                          fontSize: 5,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Text(
                        'QTY',
                        style: pw.TextStyle(
                          fontSize: 5,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        'TOTAL',
                        style: pw.TextStyle(
                          fontSize: 5,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),

              // Daftar Produk - lebih kecil
              pw.Column(
                children:
                    transaction.items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final hargaSatuan = item.totalPrice / item.quantity;

                      return pw.Container(
                        padding: const pw.EdgeInsets.symmetric(vertical: 1),
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            bottom: pw.BorderSide(
                              width: 0.1,
                              color: PdfColors.grey200,
                            ),
                          ),
                        ),
                        child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Expanded(
                              flex: 5,
                              child: pw.Text(
                                '${index + 1}. ${item.name}',
                                style: const pw.TextStyle(fontSize: 5),
                                maxLines: 1,
                                overflow: pw.TextOverflow.clip,
                              ),
                            ),
                            pw.Expanded(
                              flex: 1,
                              child: pw.Text(
                                '${item.quantity}',
                                style: const pw.TextStyle(fontSize: 5),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            pw.Expanded(
                              flex: 2,
                              child: pw.Text(
                                formatCurrency(item.totalPrice.toInt()),
                                style: pw.TextStyle(
                                  fontSize: 5,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                                textAlign: pw.TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),

              pw.SizedBox(height: 3),
              pw.Divider(thickness: 0.3),
              pw.SizedBox(height: 3),

              // Ringkasan - lebih kecil
              _buildPdfTotalRow(
                'Subtotal Produk',
                formatCurrency(subtotal.toInt()),
              ),
              _buildPdfTotalRow('Ongkos Kirim', formatCurrency(ongkir.toInt())),
              if (transaction.voucherDiscount != null &&
                  transaction.voucherDiscount! > 0) ...[
                pw.SizedBox(height: 2),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Row(
                      children: [
                        pw.Container(
                          width: 10,
                          height: 10,
                          decoration: pw.BoxDecoration(
                            color: PdfColors.green700,
                            shape: pw.BoxShape.circle,
                          ),
                        ),
                        pw.SizedBox(width: 4),
                        pw.Text(
                          'Diskon Voucher',
                          style: pw.TextStyle(
                            fontSize: 7,
                            color: PdfColors.green700,
                          ),
                        ),
                      ],
                    ),
                    pw.Text(
                      '- ${formatCurrency(transaction.voucherDiscount!.toInt())}',
                      style: pw.TextStyle(
                        fontSize: 7,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green700,
                      ),
                    ),
                  ],
                ),
              ],

              if (transaction.poinCashUsed != null &&
                  transaction.poinCashUsed! > 0) ...[
                pw.SizedBox(height: 2),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Row(
                      children: [
                        pw.Container(
                          width: 10,
                          height: 10,
                          decoration: pw.BoxDecoration(
                            color: PdfColors.orange700,
                            shape: pw.BoxShape.circle,
                          ),
                        ),
                        pw.SizedBox(width: 4),
                        pw.Text(
                          'Poin Cash',
                          style: pw.TextStyle(
                            fontSize: 7,
                            color: PdfColors.orange700,
                          ),
                        ),
                      ],
                    ),
                    pw.Text(
                      '- ${formatCurrency(transaction.poinCashUsed!.toInt())}',
                      style: pw.TextStyle(
                        fontSize: 7,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.orange700,
                      ),
                    ),
                  ],
                ),
              ],

              pw.SizedBox(height: 3),

              // Total - lebih kecil
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green50,
                  borderRadius: pw.BorderRadius.circular(3),
                  border: pw.Border.all(color: PdfColors.green200),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'TOTAL BAYAR',
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      formatCurrency(transaction.totalPrice.toInt()),
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 5),
              pw.Divider(thickness: 0.3),
              pw.SizedBox(height: 3),

              // Footer sederhana seperti struk kasir
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'TERIMA KASIH TELAH BERBELANJA',
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'www.indosmec.com',
                      style: const pw.TextStyle(fontSize: 6),
                      textAlign: pw.TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    // Simpan ke file
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/struk_${transaction.id}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  // Helper functions untuk PDF - disesuaikan dengan ukuran struk kasir
  pw.Widget _buildPdfInfoRow(String label, String value, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 6)),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 6,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfTotalRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 7)),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Riwayat',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _loadTransactions,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildTabButton('Struk', 0, Icons.receipt_long),
                const SizedBox(width: 10),
                _buildTabButton('Aktivasi', 1, Icons.card_membership),
                const SizedBox(width: 10),
                _buildTabButton('i.Saku', 2, Icons.account_balance_wallet),
              ],
            ),
          ),
          Expanded(child: _buildTabContent()),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index, IconData icon) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTab = index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue[700] : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                    : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildStrukContent();
      case 1:
        return _buildAktivasiContent();
      case 2:
        return _buildISakuContent();
      default:
        return _buildStrukContent();
    }
  }

  Widget _buildStrukContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada transaksi',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Yuk mulai belanja!',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTransactions,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          final transaction = _transactions[index];
          return _buildStrukItem(transaction);
        },
      ),
    );
  }

  Widget _buildStrukItem(Transaction transaction) {
    final points = _calculatePoints(transaction.totalPrice);
    final isPoinCashUsage = transaction.deliveryOption == 'poin_cash_usage';
    final totalVoucherDiscount = transaction.voucherDiscount ?? 0;
    final totalPoinCashUsed = transaction.poinCashUsed ?? 0;
    final totalSetelahDiskon =
        transaction.totalPrice - totalVoucherDiscount - totalPoinCashUsed;
    final deliveryIcon =
        isPoinCashUsage
            ? Icons
                .account_balance_wallet // ✅ Icon wallet untuk Poin Cash
            : transaction.deliveryOption == 'xpress'
            ? Icons.flash_on
            : Icons.inventory_2_outlined;

    final deliveryColor =
        isPoinCashUsage
            ? Colors.red[700]! // ✅ Warna merah untuk penggunaan
            : transaction.deliveryOption == 'xpress'
            ? Colors.orange[700]!
            : Colors.green[700]!;

    final firstProductImage =
        transaction.items.isNotEmpty && transaction.items.first.imageUrl != null
            ? transaction.items.first.imageUrl!
            : '';

    return InkWell(
      onTap: () => _showStrukDetail(transaction),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: deliveryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(deliveryIcon, color: deliveryColor, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        isPoinCashUsage
                            ? 'Poin Cash' // ✅ Label khusus
                            : transaction.deliveryOption == 'xpress'
                            ? 'Xpress'
                            : 'Xtra',
                        style: TextStyle(
                          color: deliveryColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      transaction.status,
                    ).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    transaction.status,
                    style: TextStyle(
                      color: _getStatusColor(transaction.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Divider(color: Colors.grey[200], height: 1),
            const SizedBox(height: 12),

            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 70,
                    height: 70,
                    color: Colors.grey[200],
                    child:
                        firstProductImage.isNotEmpty
                            ? Image.network(
                              firstProductImage,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.image,
                                  color: Colors.grey[400],
                                  size: 30,
                                );
                              },
                            )
                            : Icon(
                              isPoinCashUsage
                                  ? Icons
                                      .account_balance_wallet // ✅ Icon khusus
                                  : Icons.shopping_bag,
                              color: Colors.grey[400],
                              size: 30,
                            ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.id,
                        style: GoogleFonts.robotoMono(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isPoinCashUsage
                            ? 'Penggunaan Poin Cash' // ✅ Deskripsi khusus
                            : transaction.items.isNotEmpty
                            ? transaction.items.first.name
                            : 'Produk',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!isPoinCashUsage && transaction.items.length > 1) ...[
                        const SizedBox(height: 2),
                        Text(
                          '+${transaction.items.length - 1} produk lainnya',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Divider(color: Colors.grey[200], height: 1),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPoinCashUsage ? 'Saldo Digunakan' : 'Total Belanja',
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                    ),
                    const SizedBox(height: 3),

                    // ✅ PERBAIKAN: Tampilkan total yang sudah terpotong
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Jika ada diskon, tampilkan harga asli yang dicoret
                        if (!isPoinCashUsage &&
                            (totalVoucherDiscount > 0 ||
                                totalPoinCashUsed > 0)) ...[
                          Text(
                            formatCurrency(transaction.totalPrice.toInt()),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                              color: Colors.grey[400],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(height: 2),
                        ],

                        // Total setelah diskon
                        Text(
                          formatCurrency(
                            isPoinCashUsage
                                ? transaction.totalPrice.toInt()
                                : totalSetelahDiskon
                                    .toInt(), // ✅ GUNAKAN TOTAL SETELAH DISKON
                          ),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color:
                                isPoinCashUsage
                                    ? Colors.red[700]
                                    : Colors.black87,
                          ),
                        ),

                        // Info hemat (opsional)
                        if (!isPoinCashUsage &&
                            (totalVoucherDiscount > 0 ||
                                totalPoinCashUsed > 0)) ...[
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Hemat ${formatCurrency((totalVoucherDiscount + totalPoinCashUsed).toInt())}',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),

                // ✅ UBAH BADGE POIN
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          isPoinCashUsage
                              ? [
                                Colors.red[600]!,
                                Colors.red[800]!,
                              ] // ✅ Merah untuk minus
                              : [Colors.green[600]!, Colors.green[800]!],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: (isPoinCashUsage ? Colors.red : Colors.green)
                            .withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isPoinCashUsage ? Icons.remove_circle : Icons.stars,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isPoinCashUsage
                            ? '-${formatCurrency(transaction.totalPrice.toInt())}' // ✅ MINUS untuk penggunaan
                            : '+$points Poin',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  _formatDate(transaction.date),
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Selesai':
        return Colors.green;
      case 'Diproses':
        return Colors.orange;
      case 'Dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showStrukDetail(Transaction transaction) {
    final isPoinCashUsage = transaction.deliveryOption == 'poin_cash_usage';
    final points = _calculatePoints(transaction.totalPrice);
    int pointsEarned =
        isPoinCashUsage ? 0 : _calculatePoints(transaction.totalPrice);
    int cashPointsEarned = pointsEarned * 10;
    final ongkir = isPoinCashUsage ? 0.0 : 5000.0;
    final subtotal = transaction.totalPrice - ongkir;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.95,
          minChildSize: 0.5,
          maxChildSize: 0.98,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color:
                                        isPoinCashUsage
                                            ? Colors.red[50]
                                            : Colors.blue[50],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    isPoinCashUsage
                                        ? Icons.account_balance_wallet
                                        : Icons.receipt_long,
                                    color:
                                        isPoinCashUsage
                                            ? Colors.red[700]
                                            : Colors.blue[700],
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  isPoinCashUsage
                                      ? 'Penggunaan Poin Cash'
                                      : 'Struk Belanja',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(
                                Icons.close_rounded,
                                color: Colors.grey[600],
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.grey[100],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // ✅ BADGE KHUSUS UNTUK POIN CASH
                                if (isPoinCashUsage)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.red[50],
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16),
                                      ),
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.red[200]!,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.red[100],
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.info_outline,
                                            color: Colors.red[700],
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Transaksi Penggunaan Poin Cash',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red[900],
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Poin Cash digunakan untuk potongan pembayaran',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.red[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 24,
                                    horizontal: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        isPoinCashUsage
                                            ? Colors.red[700]!
                                            : Colors.blue[700]!,
                                        isPoinCashUsage
                                            ? Colors.red[900]!
                                            : Colors.blue[900]!,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius:
                                        isPoinCashUsage
                                            ? BorderRadius.zero
                                            : const BorderRadius.vertical(
                                              top: Radius.circular(16),
                                            ),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.2,
                                              ),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          'INDOSMEC',
                                          style: GoogleFonts.poppins(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w900,
                                            color:
                                                isPoinCashUsage
                                                    ? Colors.red[800]
                                                    : Colors.blue[800],
                                            letterSpacing: 3,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        isPoinCashUsage
                                            ? 'TRANSAKSI POIN CASH'
                                            : 'BELANJA LEBIH MUDAH',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Column(
                                          children: [
                                            Text(
                                              'KOPERASI MERAH PUTIH ANTAPANI',
                                              style: GoogleFonts.robotoMono(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                height: 1.6,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            Text(
                                              'Jl. AH. Nasution No.928 Blok E',
                                              style: GoogleFonts.robotoMono(
                                                fontSize: 11,
                                                height: 1.5,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            Text(
                                              'Antapani Wetan, Kec. Antapani',
                                              style: GoogleFonts.robotoMono(
                                                fontSize: 11,
                                                height: 1.5,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            Text(
                                              'Kota Bandung, Jawa Barat 40291',
                                              style: GoogleFonts.robotoMono(
                                                fontSize: 11,
                                                height: 1.5,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'NPWP: 001.337.994.6-092.000',
                                              style: GoogleFonts.robotoMono(
                                                fontSize: 10,
                                                height: 1.5,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            Text(
                                              'Telp: 0811.1500.280',
                                              style: GoogleFonts.robotoMono(
                                                fontSize: 10,
                                                height: 1.5,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),

                                      _buildDivider(),

                                      _buildInfoRow(
                                        'NO. TRANSAKSI',
                                        transaction.id,
                                        isBold: true,
                                      ),
                                      _buildInfoRow(
                                        'TANGGAL',
                                        _formatDateStruk(transaction.date),
                                      ),
                                      _buildInfoRow(
                                        'KASIR',
                                        isPoinCashUsage
                                            ? 'SISTEM POIN CASH'
                                            : transaction.deliveryOption ==
                                                'xpress'
                                            ? 'ONLINE XPRESS'
                                            : 'ONLINE REGULER',
                                      ),

                                      _buildDivider(),

                                      // ✅ ALAMAT - Skip jika Poin Cash
                                      if (!isPoinCashUsage)
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: Colors.blue[50],
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            border: Border.all(
                                              color: Colors.blue[200]!,
                                              width: 1,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.location_on,
                                                    size: 16,
                                                    color: Colors.blue[700],
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    'ALAMAT PENGIRIMAN',
                                                    style:
                                                        GoogleFonts.robotoMono(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Colors.blue[900],
                                                        ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                transaction
                                                        .alamat?['nama_penerima'] ??
                                                    _currentUserName,
                                                style: GoogleFonts.robotoMono(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                transaction
                                                        .alamat?['nomor_hp'] ??
                                                    _currentUserPhone,
                                                style: GoogleFonts.robotoMono(
                                                  fontSize: 10,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                transaction
                                                        .alamat?['alamat_lengkap'] ??
                                                    'Alamat tidak tersedia',
                                                style: GoogleFonts.robotoMono(
                                                  fontSize: 10,
                                                  height: 1.5,
                                                  color: Colors.grey[800],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                      if (!isPoinCashUsage) _buildDivider(),

                                      // ✅ DAFTAR BELANJA/ITEM
                                      Row(
                                        children: [
                                          Icon(
                                            isPoinCashUsage
                                                ? Icons.account_balance_wallet
                                                : Icons.shopping_cart,
                                            size: 16,
                                            color:
                                                isPoinCashUsage
                                                    ? Colors.red[700]
                                                    : Colors.grey[700],
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            isPoinCashUsage
                                                ? 'DETAIL PENGGUNAAN'
                                                : 'DAFTAR BELANJA',
                                            style: GoogleFonts.robotoMono(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  isPoinCashUsage
                                                      ? Colors.red[900]
                                                      : Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),

                                      ...transaction.items.asMap().entries.map((
                                        entry,
                                      ) {
                                        final index = entry.key;
                                        final item = entry.value;
                                        final hargaSatuan =
                                            item.totalPrice / item.quantity;

                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 10,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${index + 1}. ${item.name.toUpperCase()}',
                                                style: GoogleFonts.robotoMono(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  height: 1.4,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    '${item.quantity}x @ ${formatCurrency(hargaSatuan.toInt())}',
                                                    style:
                                                        GoogleFonts.robotoMono(
                                                          fontSize: 10,
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                  ),
                                                  Text(
                                                    formatCurrency(
                                                      item.totalPrice.toInt(),
                                                    ),
                                                    style:
                                                        GoogleFonts.robotoMono(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              isPoinCashUsage
                                                                  ? Colors
                                                                      .red[900]
                                                                  : Colors
                                                                      .black,
                                                        ),
                                                  ),
                                                ],
                                              ),

                                              if (index !=
                                                  transaction.items.length - 1)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 8,
                                                      ),
                                                  child: Divider(
                                                    color: Colors.grey[200],
                                                    height: 1,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        );
                                      }).toList(),

                                      _buildDivider(),

                                      // ✅ RINGKASAN - Berbeda untuk Poin Cash
                                      if (!isPoinCashUsage) ...[
                                        _buildTotalRow(
                                          'Subtotal Produk',
                                          formatCurrency(subtotal.toInt()),
                                        ),
                                        _buildTotalRow(
                                          'Ongkos Kirim',
                                          formatCurrency(ongkir.toInt()),
                                        ),
                                        if (transaction.voucherDiscount !=
                                                null &&
                                            transaction.voucherDiscount! >
                                                0) ...[
                                          const SizedBox(height: 6),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 6,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.local_offer,
                                                      size: 14,
                                                      color: Colors.green[700],
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Diskon Voucher',
                                                          style: GoogleFonts.robotoMono(
                                                            fontSize: 11,
                                                            color:
                                                                Colors
                                                                    .green[700],
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        if (transaction
                                                                .voucherCode !=
                                                            null)
                                                          Text(
                                                            transaction
                                                                .voucherCode!,
                                                            style: GoogleFonts.robotoMono(
                                                              fontSize: 9,
                                                              color:
                                                                  Colors
                                                                      .grey[600],
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  '- ${formatCurrency(transaction.voucherDiscount!.toInt())}',
                                                  style: GoogleFonts.robotoMono(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.green[700],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],

                                        // ✅ TAMBAHKAN POIN CASH (jika digunakan)
                                        if (transaction.poinCashUsed != null &&
                                            transaction.poinCashUsed! > 0) ...[
                                          const SizedBox(height: 6),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 6,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .account_balance_wallet,
                                                      size: 14,
                                                      color: Colors.orange[700],
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      'Poin Cash',
                                                      style:
                                                          GoogleFonts.robotoMono(
                                                            fontSize: 11,
                                                            color:
                                                                Colors
                                                                    .orange[700],
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  '- ${formatCurrency(transaction.poinCashUsed!.toInt())}',
                                                  style: GoogleFonts.robotoMono(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.orange[700],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],

                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.green[50],
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.green[200]!,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'TOTAL BAYAR',
                                                style: GoogleFonts.robotoMono(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.green[900],
                                                ),
                                              ),
                                              Text(
                                                // ✅ HITUNG TOTAL SETELAH DIKURANGI VOUCHER & POIN CASH
                                                formatCurrency(
                                                  (transaction.totalPrice -
                                                          (transaction
                                                                  .voucherDiscount ??
                                                              0) -
                                                          (transaction
                                                                  .poinCashUsed ??
                                                              0))
                                                      .toInt(),
                                                ),
                                                style: GoogleFonts.robotoMono(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.green[900],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // ✅ TAMBAHKAN INFO PENGHEMATAN (jika ada diskon atau poin cash)
                                        if ((transaction.voucherDiscount !=
                                                    null &&
                                                transaction.voucherDiscount! >
                                                    0) ||
                                            (transaction.poinCashUsed != null &&
                                                transaction.poinCashUsed! >
                                                    0)) ...[
                                          const SizedBox(height: 12),
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.blue[50],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Colors.blue[200]!,
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.savings,
                                                  color: Colors.blue[700],
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Total Penghematan',
                                                        style:
                                                            GoogleFonts.robotoMono(
                                                              fontSize: 10,
                                                              color:
                                                                  Colors
                                                                      .blue[900],
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        formatCurrency(
                                                          ((transaction.voucherDiscount ??
                                                                      0) +
                                                                  (transaction
                                                                          .poinCashUsed ??
                                                                      0))
                                                              .toInt(),
                                                        ),
                                                        style:
                                                            GoogleFonts.poppins(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w900,
                                                              color:
                                                                  Colors
                                                                      .blue[900],
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.check_circle,
                                                  color: Colors.green[600],
                                                  size: 24,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ] else ...[
                                        // ✅ UNTUK POIN CASH - Tampilan Minus
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.red[50],
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.red[200]!,
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'SALDO DIKURANGI',
                                                style: GoogleFonts.robotoMono(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.red[900],
                                                ),
                                              ),
                                              Text(
                                                '- ${formatCurrency(transaction.totalPrice.toInt())}',
                                                style: GoogleFonts.robotoMono(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.red[900],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],

                                      _buildDivider(),

                                      // ✅ METODE PEMBAYARAN
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.payment,
                                              size: 18,
                                              color: Colors.grey[700],
                                            ),
                                            const SizedBox(width: 8),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'METODE PEMBAYARAN',
                                                  style: GoogleFonts.robotoMono(
                                                    fontSize: 10,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  transaction
                                                          .metodePembayaran ??
                                                      transaction
                                                          .alamat?['metode_pembayaran'] ??
                                                      'Tidak Diketahui',
                                                  style: GoogleFonts.robotoMono(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      _buildDivider(thick: true),

                                      // ✅ REWARD SECTION - Berbeda untuk Poin Cash
                                      if (!isPoinCashUsage)
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.amber[100]!,
                                                Colors.orange[100]!,
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Colors.orange[300]!,
                                              width: 2,
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.stars,
                                                color: Colors.orange[800],
                                                size: 36,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'POIN REWARD ANDA',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.orange[900],
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '+ $pointsEarned POIN UMKM',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.orange[900],
                                                ),
                                              ),
                                              Text(
                                                '+ ${formatCurrency(cashPointsEarned)} POIN CASH',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.green[700],
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Selamat! Poin akan masuk ke akun Anda',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 10,
                                                  color: Colors.orange[800],
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        )
                                      else
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.red[100]!,
                                                Colors.red[200]!,
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Colors.red[300]!,
                                              width: 2,
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.remove_circle,
                                                color: Colors.red[800],
                                                size: 36,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'SALDO POIN CASH DIKURANGI',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red[900],
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '- ${formatCurrency(transaction.totalPrice.toInt())}',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.red[900],
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Poin Cash Anda telah digunakan untuk potongan pembayaran',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 10,
                                                  color: Colors.red[800],
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),

                                      _buildDivider(thick: true),

                                      Center(
                                        child: Column(
                                          children: [
                                            Text(
                                              'TERIMA KASIH TELAH BERBELANJA',
                                              style: GoogleFonts.robotoMono(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'CEK STATUS PESANAN DI',
                                              style: GoogleFonts.robotoMono(
                                                fontSize: 10,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            Text(
                                              'www.indosmec.com',
                                              style: GoogleFonts.robotoMono(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue[700],
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 12),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 8,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[100],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    'LAYANAN KONSUMEN 24/7',
                                                    style:
                                                        GoogleFonts.robotoMono(
                                                          fontSize: 9,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'WA: 0811.1500.280 | Email: kontak@indosmec.co.id',
                                                    style:
                                                        GoogleFonts.robotoMono(
                                                          fontSize: 9,
                                                        ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              '© 2025 INDOSMEC - All Rights Reserved',
                                              style: GoogleFonts.robotoMono(
                                                fontSize: 8,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ✅ ACTION BUTTONS dengan PDF & Share
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    try {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder:
                                            (context) => const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                      );

                                      final pdfFile = await _generatePDF(
                                        transaction,
                                      );

                                      Navigator.pop(context);

                                      await Share.shareXFiles(
                                        [XFile(pdfFile.path)],
                                        text:
                                            'Struk Belanja INDOSMEC\nNo. Transaksi: ${transaction.id}\nTotal: ${formatCurrency(transaction.totalPrice.toInt())}',
                                      );
                                    } catch (e) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Gagal: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.share, size: 20),
                                  label: Text(
                                    'BAGIKAN',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.blue[700],
                                    side: BorderSide(
                                      color: Colors.blue[700]!,
                                      width: 2,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    try {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder:
                                            (context) => const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                      );

                                      final pdfFile = await _generatePDF(
                                        transaction,
                                      );

                                      Navigator.pop(context);

                                      // Buka file PDF setelah diunduh
                                      final result = await OpenFile.open(
                                        pdfFile.path,
                                      );

                                      if (result.type != ResultType.done) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'PDF berhasil diunduh tapi tidak bisa dibuka: ${result.message}',
                                            ),
                                            backgroundColor: Colors.orange,
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'PDF berhasil diunduh dan dibuka!',
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Gagal: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.download, size: 20),
                                  label: Text(
                                    'DOWNLOAD PDF',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[700],
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDivider({bool thick = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child:
          thick
              ? Column(
                children: [
                  Divider(color: Colors.grey[400], thickness: 2),
                  const SizedBox(height: 2),
                  Divider(color: Colors.grey[300], thickness: 1),
                ],
              )
              : Divider(color: Colors.grey[300], thickness: 1),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: GoogleFonts.robotoMono(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ),
          Text(': ', style: GoogleFonts.robotoMono(fontSize: 10)),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.robotoMono(
                fontSize: 10,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.robotoMono(fontSize: 11)),
          Text(
            value,
            style: GoogleFonts.robotoMono(
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ==== AKTIVASI CONTENT ====
  Widget _buildAktivasiContent() {
    final completedTransactions =
        _transactions.where((t) => t.status == 'Selesai').toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildAktivasiItem(
          'Aktivasi Member Blue',
          'Selamat! Kamu berhasil menjadi Member Blue',
          '+ 1000 Poin Bonus',
          '01 Jan 2025, 10:00',
          Colors.blue[700]!,
          Icons.card_membership,
        ),

        ...completedTransactions.map((transaction) {
          // ✅ CEK JENIS TRANSAKSI
          if (transaction.deliveryOption == 'poin_cash_usage') {
            // Transaksi penggunaan Poin Cash
            final amount = transaction.totalPrice.toInt();
            return _buildAktivasiItem(
              'Penggunaan Poin Cash',
              'Digunakan untuk potongan pembayaran - ${transaction.id}',
              '- ${formatCurrency(amount)}', // ✅ MINUS
              _formatDate(transaction.date),
              Colors.red[700]!,
              Icons.remove_circle_outline,
            );
          } else if (transaction.deliveryOption == 'topup') {
            // Transaksi Top-Up Saldo
            final amount = transaction.totalPrice.toInt();
            return _buildAktivasiItem(
              'Top-Up Saldo Klik',
              'Isi saldo berhasil - ${transaction.id}',
              '+ ${formatCurrency(amount)}',
              _formatDate(transaction.date),
              Colors.green[700]!,
              Icons.add_circle_outline,
            );
          } else {
            // Transaksi belanja biasa
            final points = _calculatePoints(transaction.totalPrice);
            final cashPoints = points * 10;
            return _buildAktivasiItem(
              'Transaksi Selesai',
              '${transaction.deliveryOption == 'xpress' ? 'Belanja Xpress' : 'Belanja Xtra'} - ${transaction.id}',
              '+ $points Poin UMKM\n+ ${formatCurrency(cashPoints)} Poin Cash',
              _formatDate(transaction.date),
              Colors.green[700]!,
              Icons.shopping_bag,
            );
          }
        }).toList(),

        _buildAktivasiItem(
          'Verifikasi Email',
          'Email berhasil diverifikasi',
          '+ 100 Poin Bonus',
          '01 Jan 2025, 10:05',
          Colors.orange[700]!,
          Icons.email,
        ),
      ],
    );
  }

  Widget _buildAktivasiItem(
    String title,
    String desc,
    String badge,
    String date,
    Color color,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      date,
                      style: TextStyle(color: Colors.grey[500], fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==== I.SAKU CONTENT ====
  Widget _buildISakuContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red[600]!, Colors.red[800]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  color: Colors.red[700],
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'i.Saku Terhubung',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Status: Aktif',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),

        _buildISakuTransaction(
          'Top Up Poin Cash',
          'Transfer dari i.Saku',
          '+ Rp 100.000',
          '23 Okt 2025, 15:20',
          Colors.green[700]!,
          Icons.arrow_downward,
        ),
        _buildISakuTransaction(
          'Bayar Belanja',
          'Pembayaran di Indosmec',
          '- Rp 50.000',
          '22 Okt 2025, 14:30',
          Colors.red[700]!,
          Icons.arrow_upward,
        ),
        _buildISakuTransaction(
          'Top Up Poin Cash',
          'Transfer dari i.Saku',
          '+ Rp 200.000',
          '18 Okt 2025, 10:15',
          Colors.green[700]!,
          Icons.arrow_downward,
        ),
        _buildISakuTransaction(
          'Bayar Belanja',
          'Pembayaran di Indosmec',
          '- Rp 125.000',
          '15 Okt 2025, 16:45',
          Colors.red[700]!,
          Icons.arrow_upward,
        ),
      ],
    );
  }

  Widget _buildISakuTransaction(
    String title,
    String desc,
    String amount,
    String date,
    Color color,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  date,
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ==== SCREEN 3: PENGATURAN ====
class PengaturanScreen extends StatefulWidget {
  const PengaturanScreen({super.key});

  @override
  State<PengaturanScreen> createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  String userName = '';
  String userPhone = '';
  String memberTier = 'Blue';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? 'User';
      userPhone = prefs.getString('userPhone') ?? '08xxxxxxxxxx';
      memberTier = 'Blue';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Pengaturan Poinku',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ==== PREMIUM MEMBER INFO CARD ====
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[600]!, Colors.blue[800]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                // Member Badge
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.workspace_premium,
                      color: Colors.blue[700],
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Member $memberTier',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            color: Colors.white.withOpacity(0.9),
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            userPhone,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
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
          const SizedBox(height: 24),

          // ==== MENU ITEMS ====
          _buildMenuItem(
            Icons.lock_outline,
            'Pengaturan Kode PIN',
            'Ubah atau reset PIN Poinku',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PinSettingsScreen()),
              );
            },
          ),
          const SizedBox(height: 12),

          _buildMenuItem(
            Icons.help_outline,
            'FAQ',
            'Pertanyaan yang sering ditanyakan',
            () {},
          ),
          const SizedBox(height: 12),

          _buildMenuItem(
            Icons.phone_outlined,
            'Hubungi Kami',
            'Butuh bantuan? Hubungi customer service',
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.blue[700], size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 22),
          ],
        ),
      ),
    );
  }
}
