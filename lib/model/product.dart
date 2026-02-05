class Product {
  int? id;
  String? name;
  String? brand;
  String? category;
  String? size;
  String? color;
  double? price;
  int? stock;
  String? image;
  String? createdAt;
  String? updatedAt;

  Product({
    this.id,
    this.name,
    this.brand,
    this.category,
    this.size,
    this.color,
    this.price,
    this.stock,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  // Convert JSON to Dart object
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
      brand: json['brand'] ?? "",
      category: json['category'] ?? "",
      size: json['size'] ?? "",
      color: json['color'] ?? "",
      price: (json['price'] != null) ? (json['price'] as num).toDouble() : 0.0,
      stock: json['stock'] ?? 0,
      image: json['image'] ?? "",
      createdAt: json['created_at'] ?? "",
      updatedAt: json['updated_at'] ?? "",
    );
  }

  // Convert Dart object to JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "brand": brand,
      "category": category,
      "size": size,
      "color": color,
      "price": price,
      "stock": stock,
      "image": image,
      "created_at": createdAt,
      "updated_at": updatedAt,
    };
  }
}
