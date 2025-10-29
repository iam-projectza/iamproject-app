class CategoryModel {
  final int? id;
  final String? name;
  final String? description;
  final String? image;
  final String? createdAt;
  bool? isFavorite;
  final double? rating;
  final double? price; // Added
  final int? category_id; // Added
  final String? category_name; // Added
  final int? stock; // Added

  CategoryModel({
    this.id,
    this.name,
    this.description,
    this.image,
    this.createdAt,
    this.isFavorite,
    this.rating,
    this.price, // Added
    this.category_id, // Added
    this.category_name, // Added
    this.stock, // Added
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      image: json['image'] as String?,
      createdAt: json['created_at'] as String?,
      isFavorite: json['is_favorite'] as bool? ?? false,
      rating: json['rating'] != null ? double.tryParse(json['rating'].toString()) : null,
      price: json['price'] != null ? double.tryParse(json['price'].toString()) : null, // Added
      category_id: json['category_id'] as int?, // Added
      category_name: json['category_name'] as String?, // Added
      stock: json['stock'] as int?, // Added
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "image": image,
      "created_at": createdAt,
      "is_favorite": isFavorite,
      "rating": rating,
      "price": price, // Added
      "category_id": category_id, // Added
      "category_name": category_name, // Added
      "stock": stock, // Added
    };
  }
}