import 'OrderDetail.dart';

class Order {
  final int id;
  final String orderDate;
  final double totalPrice;
  final String shippingAddress;
  final String status;
  final String? notes;
  final List<OrderDetail> orderDetails;

  Order({
    required this.id,
    required this.orderDate,
    required this.totalPrice,
    required this.shippingAddress,
    required this.status,
    this.notes,
    required this.orderDetails,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      orderDate: json['orderDate'],
      totalPrice: json['totalPrice'],
      shippingAddress: json['shippingAddress'],
      status: json['status'],
      notes: json['notes'],
      orderDetails: (json['orderDetails'] as List)
          .map((e) => OrderDetail.fromJson(e))
          .toList(),
    );
  }
}