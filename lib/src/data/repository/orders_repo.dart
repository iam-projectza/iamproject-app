import 'package:get/get.dart';
import '../../utils/app_constants.dart';
import '../api/api_client.dart';

class OrderRepo extends GetxService {
  final ApiClient apiClient;
  OrderRepo({required this.apiClient});

  Future<Response> placeOrder(Map<String, dynamic> orderData) async {
    return await apiClient.postData(AppConstants.ORDERS_URI, orderData);
  }

  Future<Response> getOrders() async {
    return await apiClient.getData(AppConstants.ORDERS_URI);
  }

  Future<Response> getOrderHistory() async {
    return await apiClient.getData('${AppConstants.ORDERS_URI}/history');
  }

  Future<Response> updateOrderStatus(int orderId, String status) async {
    return await apiClient.putData(
      '${AppConstants.ORDERS_URI}/$orderId/status',
      {'status': status},
    );
  }

  // Optional: Add method to get a single order
  Future<Response> getOrderById(int orderId) async {
    return await apiClient.getData('${AppConstants.ORDERS_URI}/$orderId');
  }

  // Optional: Add method to delete an order
  Future<Response> deleteOrder(int orderId) async {
    return await apiClient.deleteData('${AppConstants.ORDERS_URI}/$orderId');
  }
}