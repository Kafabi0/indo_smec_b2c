class FlashSaleSchedule {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final List<String> productIds; // ID produk flash sale
  final double discountPercentage;

  FlashSaleSchedule({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.productIds,
    required this.discountPercentage,
  });

  bool get isUpcoming => DateTime.now().isBefore(startTime);
  bool get isActive => DateTime.now().isAfter(startTime) && DateTime.now().isBefore(endTime);
  bool get isEnded => DateTime.now().isAfter(endTime);

  Duration get timeUntilStart => startTime.difference(DateTime.now());
  Duration get timeUntilEnd => endTime.difference(DateTime.now());
}