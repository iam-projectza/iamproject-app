import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/api/api_client.dart';
import '../data/repository/orders_repo.dart';
import '../model/order_model.dart';
import '../model/order_item_model.dart';
import '../model/single_product_model.dart';
import '../model/cart_model.dart';
import '../utils/app_constants.dart';
import 'cart_controller.dart';
import 'auth/firebase/authenication_repository.dart';

class OrderController extends GetxController {
  final OrderRepo orderRepo;

  OrderController({required this.orderRepo}) {
    print('🎯 ORDER CONTROLLER CREATED AND INITIALIZED');
  }

  List<OrderModel> _orders = [];
  List<OrderModel> get orders => _orders;

  List<OrderModel> get ongoingOrders =>
      _orders.where((order) => order.status == 'pending' || order.status == 'ongoing').toList();

  List<OrderModel> get completedOrders =>
      _orders.where((order) => order.status == 'completed').toList();

  List<OrderModel> get canceledOrders =>
      _orders.where((order) => order.status == 'cancelled' || order.status == 'canceled').toList();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchOrders() async {
    _isLoading = true;
    update();

    print('📡 FETCHING ORDERS FROM API...');

    try {
      Response response = await orderRepo.getOrders();

      print('📥 ORDERS API RESPONSE:');
      print('   - Status Code: ${response.statusCode}');
      print('   - Response Type: ${response.body.runtimeType}');

      if (response.statusCode == 200) {
        dynamic responseBody = response.body;

        List<dynamic> ordersList = [];

        if (responseBody is Map && responseBody.containsKey('data')) {
          // If response has 'data' field
          ordersList = responseBody['data'] as List;
        } else if (responseBody is List) {
          // If response is directly a list
          ordersList = responseBody;
        } else {
          print('❌ UNEXPECTED RESPONSE FORMAT: $responseBody');
          ordersList = [];
        }

        // Convert each order item safely
        _orders = ordersList.map((item) {
          try {
            return OrderModel.fromJson(item);
          } catch (e) {
            print('❌ ERROR PARSING ORDER: $e');
            print('❌ PROBLEMATIC ORDER DATA: $item');
            // Return a default order to prevent complete failure
            return OrderModel(
              orderNumber: 'ERROR-${DateTime.now().millisecondsSinceEpoch}',
              status: 'error',
              totalAmount: 0.0,
              orderDate: DateTime.now(),
              itemCount: 0,
              items: [],
              deliveryAddress: '',
            );
          }
        }).toList();

        print('✅ ORDERS FETCHED SUCCESSFULLY:');
        print('   - Total Orders: ${_orders.length}');
        print('   - Ongoing: ${ongoingOrders.length}');
        print('   - Completed: ${completedOrders.length}');
        print('   - Canceled: ${canceledOrders.length}');

        // Debug: Print order details
        for (var i = 0; i < _orders.length; i++) {
          final order = _orders[i];
          print('   ${i + 1}. #${order.orderNumber} - ${order.status} - R${order.totalAmount}');
        }
      } else {
        print('❌ FAILED TO FETCH ORDERS: ${response.statusCode}');
        print('❌ Response Body: ${response.body}');

        Get.snackbar(
          'Error',
          'Failed to fetch orders: ${response.statusCode}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e, stackTrace) {
      print('💥 ERROR FETCHING ORDERS:');
      print('   - Error: $e');
      print('   - Stack Trace: $stackTrace');

      Get.snackbar(
        'Error',
        'Failed to fetch orders: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    _isLoading = false;
    update();
  }
  // Add a method to refresh orders
  Future<void> refreshOrders() async {
    await fetchOrders();
  }

  // ... rest of your existing methods (placeOrderFromCart, updateOrderStatus, reorder, etc.)
  Future<void> placeOrderFromCart({
    required String customerName,
    required String customerEmail,
    required String deliveryAddress,
  }) async {
    _isLoading = true;
    update();

    try {
      final cartController = Get.find<CartController>();

      final cartItems = cartController.getItems;
      final totalAmount = cartController.totalAmount;
      final itemCount = cartController.totalItems;

      if (cartItems.isEmpty) {
        Get.snackbar('Error', 'Your cart is empty');
        _isLoading = false;
        update();
        return;
      }

      // Convert cart items to order items
      final orderItems = cartItems.map((cartItem) {
        return OrderItem(
          productId: cartItem.product?.id ?? 0,
          name: cartItem.name ?? 'Unknown Product',
          price: cartItem.price ?? 0.0,
          quantity: cartItem.quantity ?? 0,
          image: cartItem.img,
        );
      }).toList();

      // Create order data
      final orderData = {
        'category_id': 2, // Default category
        'customer_name': customerName,
        'customer_email': customerEmail,
        'status': 'pending',
        'total_amount': totalAmount,
        'order_date': DateTime.now().toIso8601String(),
        'item_count': itemCount,
        'items': orderItems.map((item) => item.toJson()).toList(),
        'delivery_address': deliveryAddress,
        'user_id': 1, // Default user ID
      };

      Response response = await orderRepo.placeOrder(orderData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Refresh orders list after placing new order
        await fetchOrders();

        // Clear the cart
        cartController.clear();

        Get.snackbar(
          'Success',
          'Order placed successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Navigate to orders page
        Get.offAllNamed('/orders');
      } else {
        Get.snackbar(
          'Order Failed',
          'Failed to place order',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Order Error',
        'Failed to place order: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    _isLoading = false;
    update();
  }

  void reorder(OrderModel order) {
    final cartController = Get.find<CartController>();

    for (var item in order.items) {
      final product = SingleProductModel(
        id: item.productId,
        name: item.name,
        price: item.price,
        image: item.image,
        category_id: 1,
        category_name: 'General',
        description: 'Product from previous order',
      );

      cartController.addItem(product, item.quantity);
    }

    Get.snackbar(
      'Reorder',
      'Added ${order.items.length} items to cart',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  Future<void> updateOrderStatus(int orderId, String status) async {
    try {
      Response response = await orderRepo.updateOrderStatus(orderId, status);

      if (response.statusCode == 200) {
        final index = _orders.indexWhere((order) => order.id == orderId);
        if (index != -1) {
          _orders[index] = _orders[index].copyWith(status: status);
          update();
          Get.snackbar(
            'Success',
            'Order status updated to $status',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update order status: $e');
    }
  }
  // Add this to your OrderController class
  void debugController() {
    print('=== ORDER CONTROLLER DEBUG ===');
    print('✅ OrderController is registered: ${Get.isRegistered<OrderController>()}');
    print('✅ OrderRepo is registered: ${Get.isRegistered<OrderRepo>()}');
    print('✅ ApiClient is registered: ${Get.isRegistered<ApiClient>()}');
    print('📊 Current orders count: ${_orders.length}');
    print('🔄 Is loading: $_isLoading');
    print('🏁 === DEBUG COMPLETE ===');
  }
}

