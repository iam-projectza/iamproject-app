import 'order_item_model.dart';

class OrderModel {
  final int? id;
  final int? categoryId;
  final int? userId;
  final String orderNumber;
  final String? customerName;
  final String? customerEmail;
  final String status;
  final double totalAmount;
  final DateTime orderDate;
  final int itemCount;
  final List<OrderItem> items;
  final String deliveryAddress;

  OrderModel({
    this.id,
    this.categoryId,
    this.userId,
    required this.orderNumber,
    this.customerName,
    this.customerEmail,
    required this.status,
    required this.totalAmount,
    required this.orderDate,
    required this.itemCount,
    required this.items,
    required this.deliveryAddress,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Handle total_amount conversion safely
    double parseTotalAmount(dynamic amount) {
      if (amount == null) return 0.0;
      if (amount is double) return amount;
      if (amount is int) return amount.toDouble();
      if (amount is String) {
        return double.tryParse(amount) ?? 0.0;
      }
      return 0.0;
    }

    // Handle order_date conversion safely
    DateTime parseOrderDate(dynamic date) {
      if (date == null) return DateTime.now();
      if (date is DateTime) return date;
      if (date is String) {
        try {
          return DateTime.parse(date);
        } catch (e) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    // Handle items conversion safely
    List<OrderItem> parseItems(dynamic itemsData) {
      if (itemsData == null) return [];
      if (itemsData is List) {
        return itemsData.map((item) {
          if (item is Map<String, dynamic>) {
            return OrderItem.fromJson(item);
          }
          return OrderItem.fromJson({});
        }).toList();
      }
      return [];
    }

    // Handle item_count conversion safely
    int parseItemCount(dynamic count) {
      if (count == null) return 0;
      if (count is int) return count;
      if (count is String) return int.tryParse(count) ?? 0;
      return 0;
    }

    return OrderModel(
      id: json['id'],
      categoryId: json['category_id'],
      userId: json['user_id'],
      orderNumber: json['order_number'] ?? generateOrderNumber(),
      customerName: json['customer_name'],
      customerEmail: json['customer_email'],
      status: json['status'] ?? 'pending',
      totalAmount: parseTotalAmount(json['total_amount']),
      orderDate: parseOrderDate(json['order_date']),
      itemCount: parseItemCount(json['item_count']),
      items: parseItems(json['items']),
      deliveryAddress: json['delivery_address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (userId != null) 'user_id': userId,
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

  static String generateOrderNumber() {
    final now = DateTime.now();
    return 'IAM${now.millisecondsSinceEpoch}';
  }

  OrderModel copyWith({
    int? id,
    int? categoryId,
    int? userId,
    String? orderNumber,
    String? customerName,
    String? customerEmail,
    String? status,
    double? totalAmount,
    DateTime? orderDate,
    int? itemCount,
    List<OrderItem>? items,
    String? deliveryAddress,
  }) {
    return OrderModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      userId: userId ?? this.userId,
      orderNumber: orderNumber ?? this.orderNumber,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      orderDate: orderDate ?? this.orderDate,
      itemCount: itemCount ?? this.itemCount,
      items: items ?? this.items,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
    );
  }

  // Helper getters to handle null values
  String get displayName => customerName ?? 'Customer';
  String get displayEmail => customerEmail ?? 'No email provided';
}