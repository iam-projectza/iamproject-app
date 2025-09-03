// Models for Single Products (list + item)
class SingleProductList {
  final List<SingleProductModel> singleProducts;

  SingleProductList({required this.singleProducts});

  /// Factory: accepts a Map response that may contain a "data" list,
  /// or a Map with a single item. If the API returns a raw List (not a Map)
  /// you can call fromJsonList instead.
  factory SingleProductList.fromJson(Map<String, dynamic> json) {
    final raw = json['data'] ?? json['items'] ?? [];
    final List<dynamic> list = raw is List ? raw : [];
    final products = list
        .map((e) => SingleProductModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return SingleProductList(singleProducts: products);
  }

  /// Use this if the endpoint returns a raw List (List<dynamic>) instead of a Map
  factory SingleProductList.fromJsonList(dynamic rawList) {
    final List<dynamic> list = rawList is List ? rawList : [];
    final products = list
        .map((e) => SingleProductModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return SingleProductList(singleProducts: products);
  }
}

class SingleProductModel {
  final int? id;
  final String? name;
  final String? description;
  final String? image; // matches JSON key 'image'
  final double? price; // parsed as double when possible
  final String? createdAt;

  SingleProductModel({
    this.id,
    this.name,
    this.description,
    this.image,
    this.price,
    this.createdAt,
  });

  factory SingleProductModel.fromJson(Map<String, dynamic> json) {
    double? parsedPrice;
    final rawPrice = json['price'];
    if (rawPrice != null) {
      // handle numeric or string price
      if (rawPrice is num) {
        parsedPrice = rawPrice.toDouble();
      } else if (rawPrice is String) {
        parsedPrice = double.tryParse(rawPrice);
      }
    }

    return SingleProductModel(
      id: json['id'] is int ? json['id'] as int : (json['id'] is String ? int.tryParse(json['id']) : null),
      name: json['name']?.toString(),
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
      "description": description,
      // keep key 'image' to match server
      "image": image,
      // output price as number if available
      "price": price,
      "created_at": createdAt,
    };
  }
}
