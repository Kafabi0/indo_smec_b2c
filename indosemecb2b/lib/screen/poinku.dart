import 'package:flutter/material.dart';
import 'package:indosemecb2b/screen/main_navigasi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/product_service.dart';
import 'package:indosemecb2b/utils/transaction_manager.dart';
import 'package:indosemecb2b/models/transaction.dart';
import 'package:intl/intl.dart';

// Fungsi helper untuk format mata uang Indonesia
String formatCurrency(int amount) {
  return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
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

class _PoinkuScreenState extends State<PoinkuScreen> {
  bool _isPointsVisible = true;
  String userName = '';
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
      memberTier = 'Blue';
    });
  }

  void _togglePointsVisibility() {
    setState(() {
      _isPointsVisible = !_isPointsVisible;
    });
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
                              Icons.notifications_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                            onPressed: () {},
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
                                    'ID: INDOSMEC-2025-001',
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

                      // ==== 3 KARTU POIN HORIZONTAL (DI HEADER) ====
                      Row(
                        children: [
                          _buildPointCard(
                            'Poin',
                            '1.250',
                            Icons.stars_rounded,
                            Colors.blue[700]!,
                            Colors.blue[50]!,
                          ),
                          const SizedBox(width: 10),
                          _buildPointCard(
                            'Stamp',
                            '5',
                            Icons.local_offer_rounded,
                            Colors.orange[700]!,
                            Colors.orange[50]!,
                          ),
                          const SizedBox(width: 10),
                          _buildPointCard(
                            'Poin Cash',
                            '25K',
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
                    // ==== QR CODE CARD (LEBIH COMPACT) ====
                    Transform.translate(
                      offset: const Offset(0, -40),
                      child: Container(
                        padding: const EdgeInsets.all(20),
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

                            // QR Code lebih besar
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
                      'Rp 25.000',
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

  Widget _buildPaymentMethod(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool isActive,
  ) {
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
                  _isPointsVisible ? subtitle : '••••••',
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

  @override
  void initState() {
    super.initState();
    _loadTransactions();
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
    final months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
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

  Future<String> _getUserPoinId() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('userName') ?? 'User';
    final userPhone = prefs.getString('userPhone') ?? '08xxxxxxxxxx';
    
    final lastPhone = userPhone.length >= 4 ? userPhone.substring(userPhone.length - 4) : '0000';
    final firstNameChar = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
    
    return 'xxxxxxxx$lastPhone/${firstNameChar}ux**** Nx****';
  }

  String formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
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
            boxShadow: isSelected
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
              Icon(icon, color: isSelected ? Colors.white : Colors.grey[600], size: 18),
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
            Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[400]),
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
    final deliveryIcon = transaction.deliveryOption == 'xpress'
        ? Icons.flash_on
        : Icons.inventory_2_outlined;
    final deliveryColor = transaction.deliveryOption == 'xpress'
        ? Colors.orange[700]!
        : Colors.green[700]!;

    return InkWell(
      onTap: () => _showStrukDetail(transaction),
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: deliveryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(deliveryIcon, color: deliveryColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.id,
                          style: GoogleFonts.robotoMono(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          transaction.deliveryOption == 'xpress'
                              ? 'Belanja Xpress'
                              : 'Belanja Xtra',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(transaction.status).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    transaction.status,
                    style: TextStyle(
                      color: _getStatusColor(transaction.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
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
                    Text('Total Belanja', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                    const SizedBox(height: 3),
                    Text(
                      formatCurrency(transaction.totalPrice.toInt()),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green[700]!.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+ $points Poin',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(transaction.date),
              style: TextStyle(color: Colors.grey[500], fontSize: 11),
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
    final points = _calculatePoints(transaction.totalPrice);
    final ppn = transaction.totalPrice * 0.11;
    final subtotal = transaction.totalPrice - ppn;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Struk Transaksi',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
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
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
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
                                // Header
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[700],
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'INDOSMEC',
                                          style: GoogleFonts.poppins(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[700],
                                            letterSpacing: 2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Content Struk
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    children: [
                                      Text(
                                        'KOPERASI MERAH PUTIH ANTAPANI',
                                        style: GoogleFonts.courierPrime(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          height: 1.5,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        'Jl. AH. Nasution No.928 Blok E, Antapani Wetan, Kec. Antapani,',
                                        style: GoogleFonts.courierPrime(
                                          fontSize: 12,
                                          height: 1.5,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        'Kota Bandung, Jawa Barat 40291',
                                        style: GoogleFonts.courierPrime(
                                          fontSize: 12,
                                          height: 1.5,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        'NPWP:001.337.994.6-092.000',
                                        style: GoogleFonts.courierPrime(
                                          fontSize: 12,
                                          height: 1.5,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),

                                      const SizedBox(height: 20),

                                      // Alamat Pengiriman
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'KIRIM KE',
                                              style: GoogleFonts.courierPrime(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              transaction.alamat?['alamat_lengkap'] ??
                                                  'Alamat tidak tersedia',
                                              style: GoogleFonts.courierPrime(
                                                fontSize: 11,
                                                height: 1.5,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 20),

                                      Text(
                                        'www.indosmec.com',
                                        style: GoogleFonts.courierPrime(
                                          fontSize: 12,
                                          height: 1.5,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        child: Text(
                                          '--------------------------------------',
                                          style: GoogleFonts.courierPrime(fontSize: 12),
                                        ),
                                      ),

                                      Text(
                                        '${_formatDateStruk(transaction.date)}/${transaction.id}',
                                        style: GoogleFonts.courierPrime(
                                          fontSize: 11,
                                          height: 1.5,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        child: Text(
                                          '--------------------------------------',
                                          style: GoogleFonts.courierPrime(fontSize: 12),
                                        ),
                                      ),

                                      // Daftar Item
                                      ...transaction.items.map((item) {
                                        final hargaSatuan = item.totalPrice / item.quantity;
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 8),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.name.toUpperCase(),
                                                style: GoogleFonts.courierPrime(
                                                  fontSize: 11,
                                                  height: 1.4,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    '  ${item.quantity}',
                                                    style: GoogleFonts.courierPrime(
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                  Text(
                                                    hargaSatuan.toStringAsFixed(0),
                                                    style: GoogleFonts.courierPrime(
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                  Text(
                                                    item.totalPrice.toStringAsFixed(0),
                                                    style: GoogleFonts.courierPrime(
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),

                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        child: Text(
                                          '--------------------------------------',
                                          style: GoogleFonts.courierPrime(fontSize: 12),
                                        ),
                                      ),

                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'TOTAL BELANJA :',
                                            style: GoogleFonts.courierPrime(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            subtotal.toStringAsFixed(0),
                                            style: GoogleFonts.courierPrime(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        child: Text(
                                          '--------------------------------------',
                                          style: GoogleFonts.courierPrime(fontSize: 12),
                                        ),
                                      ),

                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'NON TUNAI :',
                                            style: GoogleFonts.courierPrime(fontSize: 12),
                                          ),
                                          Text(
                                            transaction.totalPrice.toStringAsFixed(0),
                                            style: GoogleFonts.courierPrime(fontSize: 12),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 8),

                                      Text(
                                        'PPN  : DPP= ${subtotal.toStringAsFixed(0)} PPN= ${ppn.toStringAsFixed(0)}',
                                        style: GoogleFonts.courierPrime(fontSize: 11),
                                      ),
                                      Text(
                                        'NON PPN : DPP= ${subtotal.toStringAsFixed(0)}',
                                        style: GoogleFonts.courierPrime(fontSize: 11),
                                      ),

                                      const SizedBox(height: 8),

                                      Text(
                                        'HARGA JUAL : ${transaction.totalPrice.toStringAsFixed(0)}',
                                        style: GoogleFonts.courierPrime(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 12),

                                      Text(
                                        'Mandiri VIRTUAL ACCOUNT',
                                        style: GoogleFonts.courierPrime(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        formatCurrency(transaction.totalPrice.toInt()),
                                        style: GoogleFonts.courierPrime(fontSize: 11),
                                      ),

                                      const SizedBox(height: 12),

                                      // Data Customer
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 4),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 80,
                                              child: Text(
                                                'Nama',
                                                style: GoogleFonts.courierPrime(fontSize: 11),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                ': ${transaction.alamat?['nama_penerima'] ?? 'Customer'}',
                                                style: GoogleFonts.courierPrime(fontSize: 11),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 4),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 80,
                                              child: Text(
                                                'No. Telp',
                                                style: GoogleFonts.courierPrime(fontSize: 11),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                ': ${transaction.alamat?['no_telepon'] ?? '-'}',
                                                style: GoogleFonts.courierPrime(fontSize: 11),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 4),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 80,
                                              child: Text(
                                                'KdPesanan',
                                                style: GoogleFonts.courierPrime(fontSize: 11),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                ': ${transaction.id}',
                                                style: GoogleFonts.courierPrime(fontSize: 11),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 4),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 80,
                                              child: Text(
                                                'Metode',
                                                style: GoogleFonts.courierPrime(fontSize: 11),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                ': ${transaction.deliveryOption == 'xpress' ? 'Xpress (1 Jam)' : 'Xtra (Reguler)'}',
                                                style: GoogleFonts.courierPrime(fontSize: 11),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 12),

                                      FutureBuilder<String>(
                                        future: _getUserPoinId(),
                                        builder: (context, snapshot) {
                                          final poinId = snapshot.data ?? 'Loading...';
                                          return Text(
                                            'ID POINKU : $poinId',
                                            style: GoogleFonts.courierPrime(fontSize: 11),
                                            textAlign: TextAlign.center,
                                          );
                                        },
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 15),
                                        child: Text(
                                          '======================================',
                                          style: GoogleFonts.courierPrime(fontSize: 12),
                                        ),
                                      ),

                                      // Poin Reward
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.green[50],
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Colors.green[300]!,
                                            width: 1,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.stars_rounded,
                                              color: Colors.green[700],
                                              size: 32,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'POIN REWARD',
                                              style: GoogleFonts.courierPrime(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green[700],
                                              ),
                                            ),
                                            Text(
                                              '+ $points POIN',
                                              style: GoogleFonts.courierPrime(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    // Footer Info
                                    Text(
                                      'CEK PESANAN ANDA DI',
                                      style: GoogleFonts.courierPrime(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      'APLIKASI/WEB INDOSMEC',
                                      style: GoogleFonts.courierPrime(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      'LAYANAN KONSUMEN',
                                      style: GoogleFonts.courierPrime(
                                        fontSize: 11,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      'SMS/WA 0811.1500.280 TELP 1500280',
                                      style: GoogleFonts.courierPrime(
                                        fontSize: 11,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      'KONTAK@INDOSMEC.CO.ID',
                                      style: GoogleFonts.courierPrime(
                                        fontSize: 11,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      'BELANJA LEBIH MUDAH DI INDOSMEC',
                                      style: GoogleFonts.courierPrime(
                                        fontSize: 11,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      'GRATIS ONGKIR 1 JAM SAMPAI',
                                      style: GoogleFonts.courierPrime(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),

                                    const SizedBox(height: 20),

                                    Text(
                                      'www.indosmec.com',
                                      style: GoogleFonts.courierPrime(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),

                                    const SizedBox(height: 15),

                                    Text(
                                      'Jika terdapat kesalahan atau kendala, silakan hubungi',
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        color: Colors.grey[600],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        // TODO: Implement customer service action
                                      },
                                      child: Text(
                                        'Customer Service.',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          color: Colors.blue[700],
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Download Button
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // TODO: Implement download functionality
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Fitur download akan segera hadir'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.download, color: Colors.white),
                              label: Text(
                                'DOWNLOAD STRUK',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[700],
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
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

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // ==== AKTIVASI CONTENT ====
  Widget _buildAktivasiContent() {
    // Generate aktivasi dari transaksi yang selesai
    final completedTransactions = _transactions
        .where((t) => t.status == 'Selesai')
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Aktivasi awal member
        _buildAktivasiItem(
          'Aktivasi Member Blue',
          'Selamat! Kamu berhasil menjadi Member Blue',
          '+ 1000 Poin Bonus',
          '01 Jan 2025, 10:00',
          Colors.blue[700]!,
          Icons.card_membership,
        ),

        // Aktivasi dari transaksi
        ...completedTransactions.map((transaction) {
          final points = _calculatePoints(transaction.totalPrice);
          return _buildAktivasiItem(
            'Transaksi Selesai',
            '${transaction.deliveryOption == 'xpress' ? 'Belanja Xpress' : 'Belanja Xtra'} - ${transaction.id}',
            '+ $points Poin',
            _formatDate(transaction.date),
            Colors.green[700]!,
            Icons.shopping_bag,
          );
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
        // Status Card
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

        // Transaction List
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
            () {},
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
