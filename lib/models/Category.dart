class Category {
  final int id;
  final String name;

  Category({
    required this.id,
    required this.name,
  });

  // Phương thức khởi tạo Category từ JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  // Phương thức chuyển Category thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
