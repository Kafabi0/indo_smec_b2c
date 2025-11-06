import 'package:flutter/material.dart';
import 'package:indosemecb2b/models/tracking.dart';
import 'package:indosemecb2b/models/transaction.dart';
import 'package:indosemecb2b/screen/detail_produk.dart';
import 'package:indosemecb2b/screen/detail_transaksi.dart';
import 'package:indosemecb2b/screen/lacak.dart';
import 'package:indosemecb2b/screen/main_navigasi.dart';
import 'package:indosemecb2b/screen/transaksi.dart';
import 'package:indosemecb2b/utils/transaction_manager.dart';
import 'package:provider/provider.dart';
import 'notification_provider.dart';
import '../models/notification_model.dart';
import 'package:intl/intl.dart';
import 'detail_pembayaran.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<NotificationProvider>(
        context,
        listen: false,
      );
      provider.reloadForCurrentUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifProvider = Provider.of<NotificationProvider>(context);
    final transaksiNotifs = notifProvider.getTransaksiNotifs();
    final infoNotifs = notifProvider.getInfoNotifs();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: const Text(
            "Notifikasi",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          actions: [
            if (notifProvider.unreadCount > 0)
              TextButton(
                onPressed: () => notifProvider.markAllAsRead(),
                child: Text(
                  'Tandai Dibaca',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'clear') {
                  _showClearConfirmation(context, notifProvider);
                }
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'clear',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 20),
                          SizedBox(width: 8),
                          Text('Hapus Semua'),
                        ],
                      ),
                    ),
                  ],
            ),
          ],
          bottom: TabBar(
            labelColor: Colors.blue[700],
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue[700],
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: "Informasi (${infoNotifs.length})"),
              Tab(text: "Transaksi (${transaksiNotifs.length})"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            infoNotifs.isEmpty
                ? _buildEmptyState('Belum Ada Informasi')
                : _buildNotifList(infoNotifs, notifProvider),
            transaksiNotifs.isEmpty
                ? _buildEmptyState('Belum Ada Transaksi')
                : _buildNotifList(transaksiNotifs, notifProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Nanti notifikasimu akan muncul di sini",
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildNotifList(
    List<AppNotification> notifs,
    NotificationProvider provider,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: notifs.length,
      itemBuilder: (context, index) {
        final notif = notifs[index];
        return Dismissible(
          key: Key(notif.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white, size: 28),
          ),
          onDismissed: (_) {
            provider.deleteNotification(notif.id);
          },
          child: _buildNotifCard(notif, provider, context),
        );
      },
    );
  }

  Widget _buildNotifCard(
    AppNotification notif,
    NotificationProvider provider,
    context,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: notif.isRead ? Colors.white : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notif.isRead ? Colors.grey.shade200 : Colors.blue.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => provider.markAsRead(notif.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          notif.type == NotifType.transaksi
                              ? Colors.green.shade100
                              : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      notif.type == NotifType.transaksi ? 'Transaksi' : 'Info',
                      style: TextStyle(
                        color:
                            notif.type == NotifType.transaksi
                                ? Colors.green.shade800
                                : Colors.orange.shade800,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _getTimeAgo(notif.date),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  if (!notif.isRead) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.blue[700],
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Text(
                notif.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                notif.message,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
              if (notif.image != null || notif.total != null) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (notif.image != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          notif.image!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 30,
                                  color: Colors.grey[400],
                                ),
                              ),
                        ),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (notif.total != null) ...[
                            Text(
                              'Total Pembayaran',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currency.format(notif.total),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (notif.detailButtonText != null)
                      OutlinedButton(
                        onPressed: () {
                          provider.markAsRead(notif.id);
                          _navigateToDetail(context, notif);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue[700],
                          side: BorderSide(color: Colors.blue[700]!),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          notif.detailButtonText!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return dateFormat.format(date);
    }
  }

  void _showClearConfirmation(
    BuildContext context,
    NotificationProvider provider,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text(
              'Hapus Semua Notifikasi?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            content: const Text(
              'Semua notifikasi akan dihapus secara permanen.',
              style: TextStyle(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
              ),
              ElevatedButton(
                onPressed: () {
                  provider.clearAll();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Semua notifikasi telah dihapus'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Hapus Semua',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  // ✅ SOLUSI UTAMA - Gunakan transactionData dari notifikasi
  void _navigateToDetail(BuildContext context, AppNotification notif) async {
    print('🔍 [NotifScreen] Navigating to detail...');
    print('   Button: ${notif.detailButtonText}');
    print('   Order ID: ${notif.orderId}');
    print('   Has transactionData: ${notif.transactionData != null}');

    // ✅ STRATEGI 1: Jika ada transactionData, gunakan langsung
    if (notif.transactionData != null) {
      print('✅ Using transactionData from notification');

      switch (notif.detailButtonText) {
        case 'Lihat Detail':
          // Langsung ke detail pembayaran
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) =>
                      DetailPembayaranScreen(transaksi: notif.transactionData!),
            ),
          );
          return;

        case 'Lacak Pesanan':
        case 'Konfirmasi Penerimaan':
          // Coba cari di TransactionManager dulu
          break;
      }
    }

    // ✅ STRATEGI 2: Cari di TransactionManager
    if (notif.orderId == null || notif.orderId!.isEmpty) {
      print('❌ Order ID is null or empty');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ID transaksi tidak ditemukan'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Show loading
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
    }

    try {
      final allTransactions = await TransactionManager.getTransactions();
      print('📦 Total transactions in manager: ${allTransactions.length}');

      final transaction = allTransactions.firstWhere(
        (t) => t.id == notif.orderId,
        orElse: () => throw Exception('Transaction not found'),
      );

      print('✅ Transaction found: ${transaction.id}');

      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading

      // Navigate based on button type
      switch (notif.detailButtonText) {
        case 'Lihat Detail':
          // Fallback: convert transaction to map
          final transaksiMap = _convertTransactionToMap(transaction, notif);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailPembayaranScreen(transaksi: transaksiMap),
            ),
          );
          break;

        case 'Lacak Pesanan':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TransactionDetailScreen(transaction: transaction),
            ),
          );
          break;

        case 'Konfirmasi Penerimaan':
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const MainNavigationWithTransaction(),
            ),
            (route) => false,
          );
          break;

        default:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TransactionDetailScreen(transaction: transaction),
            ),
          );
      }
    } catch (e) {
      print('❌ Error finding transaction: $e');

      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading

      // ✅ STRATEGI 3: Jika tidak ditemukan tapi ada transactionData, gunakan itu
      if (notif.transactionData != null) {
        print('⚠️ Using fallback transactionData');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) =>
                    DetailPembayaranScreen(transaksi: notif.transactionData!),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transaksi tidak ditemukan: ${notif.orderId}'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Lihat Semua',
            textColor: Colors.white,
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainNavigationWithTransaction(),
                ),
                (route) => false,
              );
            },
          ),
        ),
      );
    }
  }

  // ✅ Helper method untuk convert Transaction ke Map
  Map<String, dynamic> _convertTransactionToMap(
    Transaction transaction,
    AppNotification notif,
  ) {
    return {
      'no_transaksi': transaction.id,
      'id': transaction.id,
      'tanggal': transaction.date,
      'date': transaction.date,
      'status': transaction.status,
      'metode_pembayaran':
          notif.transactionData?['metode_pembayaran'] ??
          transaction.metodePembayaran ??
          'N/A',
      'total_pembayaran': notif.total ?? transaction.totalPrice,
      'totalPrice': transaction.totalPrice,
      'voucher_code': transaction.voucherCode,
      'voucher_discount': transaction.voucherDiscount,
      'is_using_poin_cash': transaction.isUsingPoinCash,
      'poinCashUsed': transaction.poinCashUsed,
      'poin_cash_used': transaction.poinCashUsed,
      'items':
          transaction.items
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
          transaction.alamat?['nama_penerima'] ??
          transaction.alamat?['nama'] ??
          'N/A',
      'alamat': transaction.alamat,
      'metode_pengiriman':
          transaction.deliveryOption == 'xpress'
              ? 'Xpress (Rp5.000)'
              : 'Reguler (Rp5.000)',
      'deliveryOption': transaction.deliveryOption,
      'jadwal_pengiriman':
          'Dikirim : ${DateFormat('EEEE, d MMM yyyy, HH:mm').format(transaction.date)}',
      'biaya_pengiriman': 5000.0,
      'biaya_admin': 0.0,
      'catatan_pengiriman': transaction.catatanPengiriman,
    };
  }
}

class MainNavigationWithTransaction extends StatefulWidget {
  const MainNavigationWithTransaction({Key? key}) : super(key: key);

  @override
  State<MainNavigationWithTransaction> createState() =>
      _MainNavigationWithTransactionState();
}

class _MainNavigationWithTransactionState
    extends State<MainNavigationWithTransaction> {
  @override
  Widget build(BuildContext context) {
    return const MainNavigation(initialIndex: 3);
  }
}
