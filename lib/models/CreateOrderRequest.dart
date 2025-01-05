import 'OrderDetailRequest.dart';

class CreateOrderRequest {
  final String userId;
  final double totalPrice;
  final String shippingAddress;
  final String? notes;
  final List<OrderDetailRequest> orderDetails;

  CreateOrderRequest({
    required this.userId,
    required this.totalPrice,
    required this.shippingAddress,
    this.notes,
    required this.orderDetails,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'totalPrice': totalPrice,
      'shippingAddress': shippingAddress,
      'notes': notes ?? '',
      'orderDetails': orderDetails.map((e) => e.toJson()).toList(),
    };
  }
}