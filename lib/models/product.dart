class Product {
  String id;
  String name;
  String category;
  double price;

  Product({
    this.id = '',
    required this.name,
    required this.category,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
    };
  }

  factory Product.fromMap(String id, Map<String, dynamic> map) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
    );
  }
}
