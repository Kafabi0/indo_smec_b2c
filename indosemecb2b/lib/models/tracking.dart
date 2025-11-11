import 'package:latlong2/latlong.dart';

class OrderTrackingModel {
  final String? transactionId;
  final String? orderId;
  final String? courierName;
  final String? courierId;
  final String? statusMessage;
  final String? statusDesc;
  final DateTime? updatedAt;

  // ⭐ TAMBAHAN: Data Koperasi & Alamat
  final String? koperasiId;
  final String? koperasiName;
  final LatLng? koperasiLocation; // Titik jemput (Koperasi)
  final LatLng? deliveryLocation; // Titik tujuan (Alamat User)
  final Map<String, dynamic>? deliveryAddress; // Detail alamat lengkap

  OrderTrackingModel({
    this.transactionId,
    this.orderId,
    this.courierName,
    this.courierId,
    this.statusMessage,
    this.statusDesc,
    this.updatedAt,
    this.koperasiId,
    this.koperasiName,
    this.koperasiLocation,
    this.deliveryLocation,
    this.deliveryAddress,
  });

  factory OrderTrackingModel.fromJson(Map<String, dynamic> json) {
    return OrderTrackingModel(
      transactionId: json["transaction_id"],
      orderId: json["order_id"],
      courierName: json["courier_name"],
      courierId: json["courier_id"],
      statusMessage: json["status_message"],
      statusDesc: json["status_desc"],
      updatedAt:
          json["updated_at"] != null
              ? DateTime.parse(json["updated_at"])
              : null,

      // ⭐ Parse data koperasi & alamat
      koperasiId: json["koperasi_id"],
      koperasiName: json["koperasi_name"],
      koperasiLocation:
          json["koperasi_lat"] != null && json["koperasi_lon"] != null
              ? LatLng(json["koperasi_lat"], json["koperasi_lon"])
              : null,
      deliveryLocation:
          json["delivery_lat"] != null && json["delivery_lon"] != null
              ? LatLng(json["delivery_lat"], json["delivery_lon"])
              : null,
      deliveryAddress: json["delivery_address"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "transaction_id": transactionId,
      "order_id": orderId,
      "courier_name": courierName,
      "courier_id": courierId,
      "status_message": statusMessage,
      "status_desc": statusDesc,
      "updated_at": updatedAt?.toIso8601String(),
      "koperasi_id": koperasiId,
      "koperasi_name": koperasiName,
      "koperasi_lat": koperasiLocation?.latitude,
      "koperasi_lon": koperasiLocation?.longitude,
      "delivery_lat": deliveryLocation?.latitude,
      "delivery_lon": deliveryLocation?.longitude,
      "delivery_address": deliveryAddress,
    };
  }
}
