class OrderModel {
  final int? id;
  final int categoryId;
  final int? userId; // Will be null for now until user system is implemented
  final String orderNumber;
  final String customerName;
  final String customerEmail;
  final String status; // 'ongoing', 'completed', 'canceled'
  final double totalAmount;
  final DateTime orderDate;
  final int itemCount;
  final List<OrderItem> items;
  final String deliveryAddress;

  OrderModel({
    this.id,
    required this.categoryId,
    this.userId,
    required this.orderNumber,
    required this.customerName,
    required this.customerEmail,
    required this.status,
    required this.totalAmount,
    required this.orderDate,
    required this.itemCount,
    required this.items,
    required this.deliveryAddress,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      categoryId: json['category_id'] ?? 0,
      userId: json['user_id'],
      orderNumber: json['order_number'] ?? _generateOrderNumber(),
      customerName: json['customer_name'] ?? '',
      customerEmail: json['customer_email'] ?? '',
      status: json['status'] ?? 'ongoing',
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      orderDate: DateTime.parse(json['order_date'] ?? DateTime.now().toString()),
      itemCount: json['item_count'] ?? 0,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      deliveryAddress: json['delivery_address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'user_id': userId,
      'order_number': orderNumber,
      'customer_name': customerName,
      'customer_email': customerEmail,
      'status': status,
      'total_amount': totalAmount,
      'order_date': orderDate.toIso8601String(),
      'item_count': itemCount,
      'items': items.map((item) => item.toJson()).toList(),
      'delivery_address': deliveryAddress,
    };
  }

  static String _generateOrderNumber() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    return 'IAM${timestamp}';
  }
}

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
    return OrderItem(
      productId: json['product_id'] ?? 0,
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'image': image,
    };
  }
}