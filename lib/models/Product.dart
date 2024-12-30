class Product {
  final int id;
  final String name;
  final String imageUrl;
  final double price;
  final bool isHot;
  final double? promotionPrice;
  final String? hotStartDate;
  final String? hotEndDate;
  final int brandId;
  final int categoryId;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.isHot,
    this.promotionPrice,
    this.hotStartDate,
    this.hotEndDate,
    required this.brandId,
    required this.categoryId,
  });

  // Method to calculate final price
  double get finalPrice {
    if (promotionPrice != null && promotionPrice! > 0) {
      return price - (price * (promotionPrice! / 100));
    } else {
      return price;
    }
  }

  // Factory method to create Product instance from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      price: json['price'] as double,
      isHot: json['isHot'] as bool,
      promotionPrice: json['promotionPrice'] != null
          ? json['promotionPrice'] as double
          : null,
      hotStartDate: json['hotStartDate'] as String?,
      hotEndDate: json['hotEndDate'] as String?,
      brandId: json['brandId'] as int,
      categoryId: json['categoryId'] as int,
    );
  }

  // Method to convert Product instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'isHot': isHot,
      'promotionPrice': promotionPrice,
      'hotStartDate': hotStartDate,
      'hotEndDate': hotEndDate,
      'brandId': brandId,
      'categoryId': categoryId,
    };
  }
}
