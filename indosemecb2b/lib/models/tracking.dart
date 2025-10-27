class OrderTrackingModel {
  final String? orderId;
  final String? courierName;
  final String? courierId;
  final String? statusMessage;
  final String? statusDesc;
  final DateTime? updatedAt;

  OrderTrackingModel({
    this.orderId,
    this.courierName,
    this.courierId,
    this.statusMessage,
    this.statusDesc,
    this.updatedAt,
  });

  factory OrderTrackingModel.fromJson(Map<String, dynamic> json) {
    return OrderTrackingModel(
      orderId: json["order_id"],
      courierName: json["courier_name"],
      courierId: json["courier_id"],
      statusMessage: json["status_message"],
      statusDesc: json["status_desc"],
      updatedAt:
          json["updated_at"] != null
              ? DateTime.parse(json["updated_at"])
              : null,
    );
  }
}
