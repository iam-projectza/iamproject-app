class CategoryModel {
  final int? id;
  final String? name;
  final String? description;
  final String? image;
  final String? createdAt;
  bool? isFavorite;
  final double? rating;// Add this property

  CategoryModel({
    this.id,
    this.name,
    this.description,
    this.image,
    this.createdAt,
    this.isFavorite,
    this.rating
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      image: json['image'] as String?,
      createdAt: json['created_at'] as String?,
      isFavorite: json['is_favorite'] as bool? ?? false,
      rating:json['rating'],// Initialize from JSON if available
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
      "rating":rating
    };
  }
}