import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_constants.dart';
import '../api/api_client.dart';

class OrderRepo extends GetxService {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  OrderRepo({required this.apiClient, required this.sharedPreferences});

  // Get current user ID
  String? get _currentUserId {
    return sharedPreferences.getString('current_user_id');
  }

  // Get current user email
  String? get _currentUserEmail {
    return sharedPreferences.getString('user_email');
  }

  // Get orders for current user only - WITH FRONTEND FILTERING
  Future<Response> getOrders() async {
    String endpoint = AppConstants.ORDERS_URI;

    // Add user filter if user is logged in
    if (_currentUserId != null) {
      endpoint = '${AppConstants.ORDERS_URI}?user_id=$_currentUserId';
    } else if (_currentUserEmail != null) {
      endpoint = '${AppConstants.ORDERS_URI}?email=$_currentUserEmail';
    }

    print('🚨 DEBUG - USER ORDER REQUEST:');
    print('   📡 ENDPOINT: $endpoint');
    print('   👤 CURRENT USER ID: $_currentUserId');
    print('   📧 CURRENT USER EMAIL: $_currentUserEmail');

    final response = await apiClient.getData(endpoint);

    print('🚨 DEBUG - USER ORDER RESPONSE:');
    print('   📊 STATUS CODE: ${response.statusCode}');

    // Apply frontend filtering since backend isn't working
    if (response.statusCode == 200 && response.body != null && response.body is Map) {
      final responseData = response.body as Map;
      if (responseData.containsKey('data') && responseData['data'] is List) {
        final allOrders = responseData['data'] as List;

        print('   🔍 ORDERS BEFORE FILTERING: ${allOrders.length}');

        // Filter orders by current user on frontend
        final userOrders = allOrders.where((order) {
          final orderUserId = order['firebase_user_id']?.toString();
          final orderUserEmail = order['customer_email']?.toString().toLowerCase();
          final currentUserId = _currentUserId?.toString();
          final currentUserEmail = _currentUserEmail?.toString().toLowerCase();

          final matches = (orderUserId != null && orderUserId == currentUserId) ||
              (orderUserEmail != null && orderUserEmail == currentUserEmail);

          if (!matches) {
            print('   🚫 FILTERED OUT ORDER:');
            print('      • Order #${order['order_number']}');
            print('      • Order Email: $orderUserEmail');
            print('      • Order User ID: $orderUserId');
            print('      • Current Email: $currentUserEmail');
            print('      • Current User ID: $currentUserId');
          }

          return matches;
        }).toList();

        print('   ✅ ORDERS AFTER FILTERING: ${userOrders.length}');

        // Create new response with filtered data
        final filteredResponse = Response(
          statusCode: response.statusCode,
          body: {
            'data': userOrders,
            'message': 'Filtered user orders',
            'total_orders': userOrders.length,
            'filtered_from': allOrders.length,
          },
          statusText: response.statusText,
          headers: response.headers,
        );

        return filteredResponse;
      }
    }

    return response;
  }

  // Place order - ensure user ID is included
  Future<Response> placeOrder(Map<String, dynamic> orderData) async {
    print('🚀 ========== ORDER API CALL START ==========');

    // Add user ID to order data if available
    if (_currentUserId != null) {
      orderData['firebase_user_id'] = _currentUserId;
      print('   👤 Firebase User ID: $_currentUserId');
    }

    if (_currentUserEmail != null) {
      orderData['customer_email'] = _currentUserEmail;
      print('   📧 Customer Email: $_currentUserEmail');
    }

    print('📦 ORDER PAYLOAD BEING SENT TO DATABASE:');
    print('   - Customer Name: ${orderData['customer_name']}');
    print('   - Customer Email: ${orderData['customer_email']}');
    print('   - Firebase User ID: ${orderData['firebase_user_id'] ?? 'Not set'}');

    print('📤 SENDING REQUEST TO SERVER...');

    try {
      final response = await apiClient.postData(AppConstants.ORDERS_URI, orderData);

      print('📥 ========== API RESPONSE RECEIVED ==========');
      print('   - Status Code: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ ORDER SUCCESSFULLY SAVED TO DATABASE!');
        if (response.body is Map) {
          print('   • Order ID: ${response.body['id'] ?? response.body['order_id']}');
          print('   • Order Number: ${response.body['order_number']}');
        }
      } else {
        print('❌ ORDER FAILED TO SAVE TO DATABASE');
        print('   • Error Status: ${response.statusCode}');
        print('   • Error Message: ${response.statusText}');
      }

      return response;

    } catch (e, stackTrace) {
      print('💥 ========== API CALL FAILED ==========');
      print('   - Error: $e');
      print('   - Stack Trace: $stackTrace');
      rethrow;
    }
  }

  // Get order history for current user only - WITH FRONTEND FILTERING
  Future<Response> getOrderHistory() async {
    String endpoint = '${AppConstants.ORDERS_URI}/history';

    // Add user filter if user is logged in
    if (_currentUserId != null) {
      endpoint = '${AppConstants.ORDERS_URI}/history?user_id=$_currentUserId';
    } else if (_currentUserEmail != null) {
      endpoint = '${AppConstants.ORDERS_URI}/history?email=$_currentUserEmail';
    }

    print('📜 FETCHING USER-SPECIFIC ORDER HISTORY');
    print('   - User ID: $_currentUserId');
    print('   - User Email: $_currentUserEmail');

    final response = await apiClient.getData(endpoint);

    // Apply frontend filtering for history too
    if (response.statusCode == 200 && response.body != null && response.body is Map) {
      final responseData = response.body as Map;
      if (responseData.containsKey('data') && responseData['data'] is List) {
        final allHistory = responseData['data'] as List;

        // Filter history by current user
        final userHistory = allHistory.where((order) {
          final orderUserId = order['firebase_user_id']?.toString();
          final orderUserEmail = order['customer_email']?.toString().toLowerCase();
          final currentUserId = _currentUserId?.toString();
          final currentUserEmail = _currentUserEmail?.toString().toLowerCase();

          return (orderUserId != null && orderUserId == currentUserId) ||
              (orderUserEmail != null && orderUserEmail == currentUserEmail);
        }).toList();

        // Create new response with filtered data
        return Response(
          statusCode: response.statusCode,
          body: {
            'data': userHistory,
            'message': 'Filtered user order history',
            'total_history': userHistory.length,
          },
          statusText: response.statusText,
          headers: response.headers,
        );
      }
    }

    return response;
  }

  // Other methods remain the same...
  Future<Response> updateOrderStatus(int orderId, String status) async {
    print('🔄 UPDATING ORDER STATUS:');
    print('   - Order ID: $orderId');
    print('   - New Status: $status');
    print('   - User ID: $_currentUserId');

    final data = {'status': status};
    if (_currentUserId != null) {
      data['user_id'] = _currentUserId!;
    }

    return await apiClient.putData(
      '${AppConstants.ORDERS_URI}/$orderId/status',
      data,
    );
  }

  Future<Response> getOrderById(int orderId) async {
    String endpoint = '${AppConstants.ORDERS_URI}/$orderId';

    if (_currentUserId != null) {
      endpoint = '${AppConstants.ORDERS_URI}/$orderId?user_id=$_currentUserId';
    }

    print('🔍 GETTING ORDER BY ID: $orderId');
    print('   - User ID: $_currentUserId');

    return await apiClient.getData(endpoint);
  }

  Future<Response> deleteOrder(int orderId) async {
    String endpoint = '${AppConstants.ORDERS_URI}/$orderId';

    if (_currentUserId != null) {
      endpoint = '${AppConstants.ORDERS_URI}/$orderId?user_id=$_currentUserId';
    }

    print('🗑️ DELETING ORDER: $orderId');
    print('   - User ID: $_currentUserId');

    return await apiClient.deleteData(endpoint);
  }

  // Check if user has any orders
  Future<bool> hasOrders() async {
    try {
      final response = await getOrders();
      if (response.statusCode == 200) {
        final responseData = response.body;
        final hasOrders = responseData != null &&
            responseData is Map &&
            responseData['data'] is List &&
            (responseData['data'] as List).isNotEmpty;
        print('📊 USER ORDER CHECK:');
        print('   - User ID: $_currentUserId');
        print('   - Has Orders: $hasOrders');
        print('   - Number of Orders: ${hasOrders ? (responseData['data'] as List).length : 0}');
        return hasOrders;
      }
      return false;
    } catch (e) {
      print('❌ ERROR CHECKING USER ORDERS: $e');
      return false;
    }
  }
}