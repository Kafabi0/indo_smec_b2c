class AppNotification {
  final String title;
  final String message;
  final String category; // misalnya: "Transaksi", "Promo", dll
  final DateTime dateTime;
  final double? total;
  final String? image;
  final String? detailButtonText;

  AppNotification({
    required this.title,
    required this.message,
    required this.category,
    required this.dateTime,
    this.total,
    this.image,
    this.detailButtonText,
  });
}
