class OrderItem {
  final int productId;
  final String name;
  final double price;
  final int quantity;
  final String? image;

  OrderItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.image,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    // Safe parsing for price
    double parsePrice(dynamic price) {
      if (price == null) return 0.0;
      if (price is double) return price;
      if (price is int) return price.toDouble();
      if (price is String) return double.tryParse(price) ?? 0.0;
      return 0.0;
    }

    // Safe parsing for quantity
    int parseQuantity(dynamic quantity) {
      if (quantity == null) return 0;
      if (quantity is int) return quantity;
      if (quantity is String) return int.tryParse(quantity) ?? 0;
      return 0;
    }

    // Safe parsing for productId
    int parseProductId(dynamic id) {
      if (id == null) return 0;
      if (id is int) return id;
      if (id is String) return int.tryParse(id) ?? 0;
      return 0;
    }

    return OrderItem(
      productId: parseProductId(json['id'] ?? json['product_id']),
      name: json['name'] ?? 'Unknown Product',
      price: parsePrice(json['price']),
      quantity: parseQuantity(json['quantity']),
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      if (image != null) 'image': image,
    };
  }

  double get subtotal => price * quantity;
}