import 'package:get/get.dart';
import '../data/repository/orders_repo.dart';
import '../model/order_model.dart';

class OrderController extends GetxController {
  final OrderRepo orderRepo;
  OrderController({required this.orderRepo});

  List<OrderModel> _orders = [];
  List<OrderModel> get orders => _orders;

  List<OrderModel> get ongoingOrders =>
      _orders.where((order) => order.status == 'ongoing').toList();

  List<OrderModel> get completedOrders =>
      _orders.where((order) => order.status == 'completed').toList();

  List<OrderModel> get canceledOrders =>
      _orders.where((order) => order.status == 'canceled').toList();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> placeOrder(OrderModel order) async {
    _isLoading = true;
    update();

    try {
      // Prepare data for API
      final orderData = {
        'category_id': order.categoryId,
        'customer_name': order.customerName,
        'customer_email': order.customerEmail,
        'status': order.status,
        'total_amount': order.totalAmount,
        'order_date': order.orderDate.toIso8601String(),
        'item_count': order.itemCount,
        'items': order.items.map((item) => item.toJson()).toList(),
        'delivery_address': order.deliveryAddress,
      };

      Response response = await orderRepo.placeOrder(orderData);

      if (response.statusCode == 200) {
        // Add the order to local list with the ID from server
        final serverOrder = OrderModel.fromJson(response.body);
        _orders.insert(0, serverOrder);
        Get.snackbar('Success', 'Order placed successfully!');
      } else {
        Get.snackbar('Error', 'Failed to place order: ${response.statusText}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to place order: $e');
    }

    _isLoading = false;
    update();
  }

  Future<void> fetchOrders() async {
    _isLoading = true;
    update();

    try {
      Response response = await orderRepo.getOrders();
      if (response.statusCode == 200) {
        _orders = (response.body as List)
            .map((item) => OrderModel.fromJson(item))
            .toList();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch orders: $e');
    }

    _isLoading = false;
    update();
  }

  Future<void> updateOrderStatus(int orderId, String status) async {
    try {
      Response response = await orderRepo.updateOrderStatus(orderId, status);
      if (response.statusCode == 200) {
        final index = _orders.indexWhere((order) => order.id == orderId);
        if (index != -1) {
          _orders[index] = _orders[index].copyWith(status: status);
          update();
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update order status: $e');
    }
  }

  void reorder(OrderModel order) {
    // Implement reorder logic here
    Get.snackbar('Reorder', 'Adding items from order #${order.orderNumber} to cart');
  }

  void rateOrder(OrderModel order) {
    // Implement rating logic here
    Get.snackbar('Rate Order', 'Rating order #${order.orderNumber}');
  }
}

extension OrderModelExtension on OrderModel {
  OrderModel copyWith({
    String? status,
    double? totalAmount,
    DateTime? orderDate,
    int? itemCount,
    List<OrderItem>? items,
    String? deliveryAddress,
  }) {
    return OrderModel(
      id: id,
      categoryId: categoryId,
      userId: userId,
      orderNumber: orderNumber,
      customerName: customerName,
      customerEmail: customerEmail,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      orderDate: orderDate ?? this.orderDate,
      itemCount: itemCount ?? this.itemCount,
      items: items ?? this.items,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
    );
  }
}