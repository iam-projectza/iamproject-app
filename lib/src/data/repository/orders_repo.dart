import 'package:get/get.dart';
import '../../utils/app_constants.dart';
import '../api/api_client.dart';

class OrderRepo extends GetxService {
  final ApiClient apiClient;
  OrderRepo({required this.apiClient});

  Future<Response> placeOrder(Map<String, dynamic> orderData) async {
    print('🚀 ========== ORDER API CALL START ==========');
    print('📡 API ENDPOINT: ${AppConstants.BASE_URL}${AppConstants.ORDERS_URI}');
    print('📦 ORDER PAYLOAD BEING SENT TO DATABASE:');
    print('   - Method: POST');
    print('   - Headers: ${apiClient.mainHeaders}'); // ✅ FIXED: Use public getter

    // Detailed breakdown of order data
    print('   📋 ORDER DETAILS:');
    print('      • Customer Name: ${orderData['customer_name']}');
    print('      • Customer Email: ${orderData['customer_email']}');
    print('      • Status: ${orderData['status']}');
    print('      • Total Amount: R${orderData['total_amount']}');
    print('      • Item Count: ${orderData['item_count']}');
    print('      • Order Date: ${orderData['order_date']}');
    print('      • Delivery Address: ${orderData['delivery_address']}');
    if (orderData['user_id'] != null) {
      print('      • User ID: ${orderData['user_id']}');
    }
    if (orderData['category_id'] != null) {
      print('      • Category ID: ${orderData['category_id']}');
    }

    // Detailed items breakdown
    print('   🛒 ORDER ITEMS (${orderData['items']?.length ?? 0} items):');
    if (orderData['items'] != null && orderData['items'] is List) {
      final items = orderData['items'] as List;
      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        print('      ${i + 1}. ${item['name']}');
        print('         - Product ID: ${item['product_id']}');
        print('         - Price: R${item['price']}');
        print('         - Quantity: ${item['quantity']}');
        print('         - Subtotal: R${(item['price'] * item['quantity']).toStringAsFixed(2)}');
        if (item['image'] != null) {
          print('         - Image: ${item['image']}');
        }
      }
    }

    print('   💰 ORDER SUMMARY:');
    print('      • Total Items: ${orderData['item_count']}');
    print('      • Total Amount: R${orderData['total_amount']}');

    print('📤 SENDING REQUEST TO SERVER...');

    try {
      final response = await apiClient.postData(AppConstants.ORDERS_URI, orderData);

      print('📥 ========== API RESPONSE RECEIVED ==========');
      print('   - Status Code: ${response.statusCode}');
      print('   - Response Body Type: ${response.body.runtimeType}');
      print('   - Response Body:');
      print('      ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ ORDER SUCCESSFULLY SAVED TO DATABASE!');
        if (response.body is Map && response.body.containsKey('id')) {
          print('   • Database Order ID: ${response.body['id']}');
        }
        if (response.body is Map && response.body.containsKey('order_number')) {
          print('   • Order Number: ${response.body['order_number']}');
        }
      } else {
        print('❌ ORDER FAILED TO SAVE TO DATABASE');
        print('   • Error Status: ${response.statusCode}');
        print('   • Error Message: ${response.statusText}');
      }

      print('📊 RESPONSE HEADERS:');
      response.headers?.forEach((key, value) {
        print('   • $key: $value');
      });

      print('🏁 ========== ORDER API CALL COMPLETE ==========');
      return response; // ✅ FIXED: Return response here

    } catch (e, stackTrace) {
      print('💥 ========== API CALL FAILED ==========');
      print('   - Error: $e');
      print('   - Stack Trace: $stackTrace');
      print('🏁 ========== ORDER API CALL COMPLETE ==========');
      rethrow; // ✅ FIXED: Just rethrow, don't return anything
    }
  }

  Future<Response> getOrders() async {
    print('📡 FETCHING ORDERS FROM: ${AppConstants.BASE_URL}${AppConstants.ORDERS_URI}');
    print('   - Method: GET');
    return await apiClient.getData(AppConstants.ORDERS_URI);
  }

  Future<Response> getOrderHistory() async {
    print('📜 FETCHING ORDER HISTORY FROM: ${AppConstants.BASE_URL}${AppConstants.ORDERS_URI}/history');
    return await apiClient.getData('${AppConstants.ORDERS_URI}/history');
  }

  Future<Response> updateOrderStatus(int orderId, String status) async {
    print('🔄 UPDATING ORDER STATUS:');
    print('   - Order ID: $orderId');
    print('   - New Status: $status');
    print('   - Endpoint: ${AppConstants.BASE_URL}${AppConstants.ORDERS_URI}/$orderId/status');

    final data = {'status': status};
    print('   - Update Data: $data');

    return await apiClient.putData(
      '${AppConstants.ORDERS_URI}/$orderId/status',
      data,
    );
  }

  Future<Response> getOrderById(int orderId) async {
    print('🔍 GETTING ORDER BY ID: $orderId');
    print('   - Endpoint: ${AppConstants.BASE_URL}${AppConstants.ORDERS_URI}/$orderId');
    return await apiClient.getData('${AppConstants.ORDERS_URI}/$orderId');
  }

  Future<Response> deleteOrder(int orderId) async {
    print('🗑️ DELETING ORDER: $orderId');
    print('   - Endpoint: ${AppConstants.BASE_URL}${AppConstants.ORDERS_URI}/$orderId');
    return await apiClient.deleteData('${AppConstants.ORDERS_URI}/$orderId');
  }
}