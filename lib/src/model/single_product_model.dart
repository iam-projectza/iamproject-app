class SingleProductModel {
  final int? id;
  final String? name;
  final int? category_id;
  final String? category_name; // ADD THIS
  final String? description;
  final String? image;
  final double? price;
  final String? createdAt;

  SingleProductModel({
    this.id,
    this.name,
    this.category_id,
    this.category_name, // ADD THIS
    this.description,
    this.image,
    this.price,
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

    return SingleProductModel(
      id: json['id'] is int ? json['id'] as int : (json['id'] is String ? int.tryParse(json['id']) : null),
      name: json['name']?.toString(),
      category_id: json['category_id'] is int ? json['category_id'] as int : (json['category_id'] is String ? int.tryParse(json['category_id']) : null),
      category_name: json['category']?.toString(), // GET CATEGORY NAME FROM API
      description: json['description']?.toString(),
      image: json['image']?.toString(),
      price: parsedPrice,
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "category_id": category_id,
      "category_name": category_name, // ADD THIS
      "description": description,
      "image": image,
      "price": price,
      "created_at": createdAt,
    };
  }
}