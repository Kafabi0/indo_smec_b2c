
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indosemecb2b/models/voucher_model.dart';
import 'package:indosemecb2b/utils/voucher_manager.dart';
import 'package:intl/intl.dart';

String formatCurrency(int amount) {
  return 'Rp${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
}

class VoucherStoreScreen extends StatefulWidget {
  final int userPoints;
  final Function()? onVoucherRedeemed;

  const VoucherStoreScreen({
    Key? key,
    required this.userPoints,
    this.onVoucherRedeemed,
  }) : super(key: key);

  @override
  State<VoucherStoreScreen> createState() => _VoucherStoreScreenState();
}

class _VoucherStoreScreenState extends State<VoucherStoreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'Semua';
  List<Voucher> _vouchers = [];
  bool _isLoading = true;

  final List<String> _categories = [
    'Semua',
    'Food',
    'Grocery',
    'Fashion',
    'Herbal'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadVouchers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadVouchers() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(Duration(milliseconds: 300));

    setState(() {
      _vouchers = VoucherManager.getVouchersByCategory(_selectedCategory);
      _isLoading = false;
    });
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _loadVouchers();
  }

  Future<void> _redeemVoucher(Voucher voucher) async {
    // Konfirmasi
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.redeem, color: Colors.orange[700]),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Tukar Voucher?',
                style: GoogleFonts.poppins(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              voucher.name,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            SizedBox(height: 8),
            Text(
              voucher.description,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.stars, color: Colors.orange[700], size: 20),
                  SizedBox(width: 8),
                  Text(
                    '${voucher.pointCost} Poin UMKM',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[900],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Poin Anda: ${widget.userPoints}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Tukar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    // Proses penukaran
    final result = await VoucherManager.redeemVoucher(
      voucher.id,
      widget.userPoints,
    );

    Navigator.pop(context); // Close loading

    if (result['success']) {
      // Success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green[700],
                  size: 64,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Berhasil!',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                result['message'],
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      voucher.code,
                      style: GoogleFonts.robotoMono(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[900],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Kode voucher Anda',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (widget.onVoucherRedeemed != null) {
                  widget.onVoucherRedeemed!();
                }
              },
              child: Text('OK'),
            ),
          ],
        ),
      );

      _loadVouchers();
    } else {
      // Error dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Toko Voucher',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.stars, color: Colors.orange[700], size: 24),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Poin UMKM Anda',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    Text(
                      '${widget.userPoints} Poin',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.orange[900],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue[700],
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Colors.blue[700],
              labelStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              tabs: [
                Tab(text: 'Voucher Tersedia'),
                Tab(text: 'Voucher Saya'),
              ],
            ),
          ),

          // Tab View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAvailableVouchersTab(),
                _buildMyVouchersTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableVouchersTab() {
    return Column(
      children: [
        // Category Filter
        Container(
          height: 50,
          color: Colors.white,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = category == _selectedCategory;

              return Padding(
                padding: EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) _onCategoryChanged(category);
                  },
                  selectedColor: Colors.blue[700],
                  backgroundColor: Colors.grey[100],
                  labelStyle: GoogleFonts.poppins(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              );
            },
          ),
        ),

        // Voucher List
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : _vouchers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.card_giftcard_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Tidak ada voucher tersedia',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadVouchers,
                      child: ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _vouchers.length,
                        itemBuilder: (context, index) {
                          final voucher = _vouchers[index];
                          return _buildVoucherCard(voucher);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildMyVouchersTab() {
    return FutureBuilder<List<UserVoucher>>(
      future: VoucherManager.getUserVouchers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final vouchers = snapshot.data ?? [];

        if (vouchers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16),
                Text(
                  'Belum ada voucher',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Tukar poin Anda dengan voucher',
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: vouchers.length,
          itemBuilder: (context, index) {
            final voucher = vouchers[index];
            return _buildUserVoucherCard(voucher);
          },
        );
      },
    );
  }

  Widget _buildVoucherCard(Voucher voucher) {
    final canAfford = widget.userPoints >= voucher.pointCost;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header dengan gradient
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange[400]!, Colors.orange[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.local_offer,
                    color: Colors.orange[700],
                    size: 28,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        voucher.name,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        voucher.code,
                        style: GoogleFonts.robotoMono(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (voucher.category != 'Semua')
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      voucher.category,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  voucher.description,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 12),

                // Info Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.payments_outlined,
                        'Diskon',
                        formatCurrency(voucher.discountAmount),
                        Colors.green,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.shopping_cart_outlined,
                        'Min. Belanja',
                        formatCurrency(voucher.minPurchase),
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.access_time,
                        'Berlaku hingga',
                        DateFormat('dd MMM yyyy').format(voucher.validUntil),
                        Colors.orange,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.inventory_outlined,
                        'Stok',
                        '${voucher.stock} tersisa',
                        Colors.purple,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),
                Divider(),
                SizedBox(height: 12),

                // Redeem Button
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.stars, color: Colors.orange[700], size: 20),
                          SizedBox(width: 6),
                          Text(
                            '${voucher.pointCost} Poin',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[900],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    ElevatedButton(
                      onPressed: canAfford ? () => _redeemVoucher(voucher) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canAfford ? Colors.blue[700] : Colors.grey[300],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Tukar',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),

                if (!canAfford)
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Poin tidak cukup (butuh ${voucher.pointCost - widget.userPoints} poin lagi)',
                      style: TextStyle(
                        color: Colors.red[600],
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserVoucherCard(UserVoucher voucher) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: voucher.canBeUsed ? Colors.green[200]! : Colors.grey[300]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                    voucher.canBeUsed
                        ? [Colors.green[400]!, Colors.green[600]!]
                        : [Colors.grey[400]!, Colors.grey[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Icon(
                  voucher.canBeUsed ? Icons.check_circle : Icons.block,
                  color: Colors.white,
                  size: 28,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        voucher.name,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        voucher.code,
                        style: GoogleFonts.robotoMono(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    voucher.isUsed
                        ? 'Terpakai'
                        : voucher.isExpired
                        ? 'Kadaluarsa'
                        : 'Aktif',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.payments_outlined, color: Colors.green[700], size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Diskon: ${formatCurrency(voucher.discountAmount)}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.shopping_cart_outlined, color: Colors.blue[700], size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Min. Belanja: ${formatCurrency(voucher.minPurchase)}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.orange[700], size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Berlaku: ${DateFormat('dd MMM yyyy').format(voucher.validUntil)}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),

                if (voucher.isUsed) ...[
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.grey[600], size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Digunakan pada ${DateFormat('dd MMM yyyy, HH:mm').format(voucher.usedAt!)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}