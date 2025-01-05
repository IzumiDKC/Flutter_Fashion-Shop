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