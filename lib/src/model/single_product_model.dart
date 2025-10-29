class SingleProductModel {
  final int? id;
  final String? name;
  final int? category_id;
  final String? category_name;
  final String? description;
  final String? image;
  final double? price;
  final int? stock; // ADD THIS FIELD
  final String? createdAt;

  SingleProductModel({
    this.id,
    this.name,
    this.category_id,
    this.category_name,
    this.description,
    this.image,
    this.price,
    this.stock, // ADD THIS FIELD
    this.createdAt,
  });

  factory SingleProductModel.fromJson(Map<String, dynamic> json) {
    double? parsedPrice;
    final rawPrice = json['price'];
    if (rawPrice != null) {
      if (rawPrice is num) {
        parsedPrice = rawPrice.toDouble();
      } else if (rawPrice is String) {
        parsedPrice = double.tryParse(rawPrice);
      }
    }

    // Parse stock field
    int? parsedStock;
    final rawStock = json['stock'];
    if (rawStock != null) {
      if (rawStock is int) {
        parsedStock = rawStock;
      } else if (rawStock is String) {
        parsedStock = int.tryParse(rawStock);
      } else if (rawStock is num) {
        parsedStock = rawStock.toInt();
      }
    }

    return SingleProductModel(
      id: json['id'] is int ? json['id'] as int : (json['id'] is String ? int.tryParse(json['id']) : null),
      name: json['name']?.toString(),
      category_id: json['category_id'] is int ? json['category_id'] as int : (json['category_id'] is String ? int.tryParse(json['category_id']) : null),
      category_name: json['category']?.toString() ?? json['category_name']?.toString(), // Try both field names
      description: json['description']?.toString(),
      image: json['image']?.toString(),
      price: parsedPrice,
      stock: parsedStock, // ADD THIS
      createdAt: json['created_at']?.toString(),
    );
  }

  get category => null;

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "category_id": category_id,
      "category_name": category_name,
      "description": description,
      "image": image,
      "price": price,
      "stock": stock, // ADD THIS
      "created_at": createdAt,
    };
  }
}