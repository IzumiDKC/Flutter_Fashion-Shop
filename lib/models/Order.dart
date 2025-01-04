class OrderDetail {
  final String name;
  final double originalPrice;
  final double finalPrice;
  final int quantity;

  OrderDetail({
    required this.name,
    required this.originalPrice,
    required this.finalPrice,
    required this.quantity,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      name: json['name'],
      originalPrice: json['originalPrice'],
      finalPrice: json['finalPrice'],
      quantity: json['quantity'],
    );
  }
}

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
    var orderDetailsList = (json['orderDetails'] as List)
        .map((e) => OrderDetail.fromJson(e))
        .toList();
    return Order(
      id: json['id'],
      orderDate: json['orderDate'],
      totalPrice: json['totalPrice'],
      shippingAddress: json['shippingAddress'],
      status: json['status'],
      notes: json['notes'],
      orderDetails: orderDetailsList,
    );
  }
}
