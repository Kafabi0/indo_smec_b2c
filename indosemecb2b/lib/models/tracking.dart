class OrderTrackingModel {
  final String? transactionId;
  final String? orderId;
  final String? courierName;
  final String? courierId;
  final String? statusMessage;
  final String? statusDesc;
  final DateTime? updatedAt;

  OrderTrackingModel({
    this.transactionId,
    this.orderId,
    this.courierName,
    this.courierId,
    this.statusMessage,
    this.statusDesc,
    this.updatedAt,
  });

  factory OrderTrackingModel.fromJson(Map<String, dynamic> json) {
    return OrderTrackingModel(
      transactionId: json["transaction_id"] ?? json["transactionId"],
      orderId: json["order_id"] ?? json["orderId"],
      courierName: json["courier_name"] ?? json["courierName"],
      courierId: json["courier_id"] ?? json["courierId"],
      statusMessage:
          json["status_message"] ?? json["status"] ?? json["statusMessage"],
      statusDesc: json["status_desc"] ?? json["statusDesc"],
      updatedAt:
          json["updated_at"] != null
              ? DateTime.tryParse(json["updated_at"])
              : (json["updatedAt"] != null
                  ? DateTime.tryParse(json["updatedAt"])
                  : null),
    );
  }
}
