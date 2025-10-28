enum NotifType { transaksi, informasi }

class AppNotification {
  final String id;
  final NotifType type;
  final String title;
  final String message;
  final DateTime date;
  final bool isRead;
  final String? image;
  final double? total;
  final String? detailButtonText;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.date,
    this.isRead = false,
    this.image,
    this.total,
    this.detailButtonText,
  });

  // CopyWith method untuk update properties
  AppNotification copyWith({
    String? id,
    NotifType? type,
    String? title,
    String? message,
    DateTime? date,
    bool? isRead,
    String? image,
    double? total,
    String? detailButtonText,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      date: date ?? this.date,
      isRead: isRead ?? this.isRead,
      image: image ?? this.image,
      total: total ?? this.total,
      detailButtonText: detailButtonText ?? this.detailButtonText,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type == NotifType.transaksi ? 'transaksi' : 'informasi',
      'title': title,
      'message': message,
      'date': date.toIso8601String(),
      'isRead': isRead,
      'image': image,
      'total': total,
      'detailButtonText': detailButtonText,
    };
  }

  // From JSON
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      type:
          json['type'] == 'transaksi'
              ? NotifType.transaksi
              : NotifType.informasi,
      title: json['title'] as String,
      message: json['message'] as String,
      date: DateTime.parse(json['date'] as String),
      isRead: json['isRead'] as bool? ?? false,
      image: json['image'] as String?,
      total: json['total'] as double?,
      detailButtonText: json['detailButtonText'] as String?,
    );
  }
}
