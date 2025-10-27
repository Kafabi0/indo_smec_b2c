import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'notification_provider.dart';
import '../models/notification_model.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatelessWidget {
  final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');

  @override
  Widget build(BuildContext context) {
    final notifProvider = Provider.of<NotificationProvider>(context);
    final transaksiNotifs = notifProvider.getTransaksiNotifs();

    return DefaultTabController(
      length: 2, // <-- tambahkan ini supaya TabBar punya kontrol
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Notifikasi"),
          bottom: const TabBar(
            tabs: [Tab(text: "Informasi"), Tab(text: "Transaksi")],
          ),
        ),
        body: TabBarView(
          children: [
            _buildEmptyState(), // tab "Informasi"
            transaksiNotifs.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: transaksiNotifs.length,
                  itemBuilder: (context, index) {
                    final notif = transaksiNotifs[index];
                    return _buildNotifCard(notif);
                  },
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Icon(Icons.notifications_none, size: 80, color: Colors.grey),
        SizedBox(height: 10),
        Text("Belum Ada Notifikasi"),
        Text("Nanti notifikasimu akan muncul di sini"),
      ],
    ),
  );

  Widget _buildNotifCard(AppNotification notif) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Xpress", style: TextStyle(color: Colors.blue, fontSize: 12)),
            const SizedBox(height: 8),
            Text(
              notif.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(notif.message, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 12),
            if (notif.image != null)
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      notif.image!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => const Icon(
                            Icons.image_not_supported,
                            size: 60,
                            color: Colors.grey,
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Total ${currency.format(notif.total ?? 0)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text(notif.detailButtonText ?? "Lihat Detail"),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
