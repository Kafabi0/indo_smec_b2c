import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'notification_provider.dart';
import '../models/notification_model.dart';
import 'package:intl/intl.dart';
import 'detail_pembayaran.dart';

class NotificationScreen extends StatelessWidget {
  final currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

  NotificationScreen({Key? key}) : super(key: key);

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

  // ✅ PERBAIKAN - Langsung gunakan transactionData dari notifikasi
  void _navigateToDetail(BuildContext context, AppNotification notif) async {
    print('🔍 Navigating to detail for Order ID: ${notif.orderId}');
    print('📦 Transaction data: ${notif.transactionData}');

    // ✅ Cek apakah transactionData ada
    if (notif.transactionData == null || notif.transactionData!.isEmpty) {
      print('❌ Transaction data is null or empty');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data transaksi tidak ditemukan'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // ✅ Langsung gunakan data dari notifikasi dengan validasi tipe data
    final transaksiMap = Map<String, dynamic>.from(notif.transactionData!);

    // ✅ Debug: print setiap field dan tipe datanya
    print('✅ Using transaction data from notification');
    transaksiMap.forEach((key, value) {
      print('📋 $key: ${value.runtimeType} = $value');
    });

    if (context.mounted) {
      // Navigate ke DetailPembayaranScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailPembayaranScreen(transaksi: transaksiMap),
        ),
      );
    }
  }
}
