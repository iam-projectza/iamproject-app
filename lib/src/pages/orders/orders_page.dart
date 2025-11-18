import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam/src/controllers/order_controller.dart';
import '../../data/repository/orders_repo.dart';
import '../../model/order_model.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize controller and fetch orders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeController();
    });
  }

  void _initializeController() {
    try {
      final OrderController orderController = Get.find<OrderController>();

      // Debug the controller state
      orderController.debugController();

      // Fetch orders
      orderController.fetchOrders();
    } catch (e) {
      print(' Error getting OrderController: $e');
      // Try to reinitialize if controller is not found
      Get.lazyPut(() => OrderRepo(apiClient: Get.find(), sharedPreferences: Get.find(), ));
      Get.lazyPut(() => OrderController(orderRepo: Get.find()));

      final OrderController orderController = Get.find<OrderController>();
      orderController.fetchOrders();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Debug button
          IconButton(
            icon: Icon(Icons.bug_report),
            onPressed: () {
              try {
                final orderController = Get.find<OrderController>();
                orderController.debugController();
                Get.snackbar(
                  'Debug Info',
                  'Check console for controller status',
                  backgroundColor: Colors.blue,
                  colorText: Colors.white,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Controller not found: $e',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
          ),
          // Refresh button
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              try {
                final orderController = Get.find<OrderController>();
                orderController.refreshOrders();
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Cannot refresh: $e',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'All Orders'),
            Tab(text: 'Ongoing'),
            Tab(text: 'Completed'),
          ],
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
        ),
      ),
      body: SafeArea(
        child: GetBuilder<OrderController>(
          builder: (orderController) {
            // Show error if controller is not working
            if (!Get.isRegistered<OrderController>()) {
              return _buildErrorState('Order controller not initialized');
            }

            return RefreshIndicator(
              onRefresh: () async {
                await orderController.refreshOrders();
              },
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAllOrdersTab(orderController),
                  _buildOngoingTab(orderController),
                  _buildCompletedTab(orderController),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAllOrdersTab(OrderController controller) {
    if (controller.isLoading && controller.orders.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    if (controller.orders.isEmpty) {
      return _buildEmptyState('No orders yet', 'Your orders will appear here');
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: controller.orders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(controller.orders[index]);
      },
    );
  }

  Widget _buildOngoingTab(OrderController controller) {
    final ongoingOrders = controller.ongoingOrders;

    if (controller.isLoading && ongoingOrders.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    if (ongoingOrders.isEmpty) {
      return _buildEmptyState('No ongoing orders', 'You have no pending orders');
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: ongoingOrders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(ongoingOrders[index]);
      },
    );
  }

  Widget _buildCompletedTab(OrderController controller) {
    final completedOrders = controller.completedOrders;

    if (controller.isLoading && completedOrders.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    if (completedOrders.isEmpty) {
      return _buildEmptyState('No completed orders', 'Your completed orders will appear here');
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: completedOrders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(completedOrders[index]);
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Get.offAllNamed('/');
            },
            child: Text('Start Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'Error',
            style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Try to reinitialize
              Get.lazyPut(() => OrderRepo(apiClient: Get.find(), sharedPreferences: Get.find()));
              Get.lazyPut(() => OrderController(orderRepo: Get.find()));
              setState(() {});
            },
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.orderNumber}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _formatDate(order.orderDate),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    order.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            // Customer Info
            if (order.customerName != null || order.customerEmail != null) ...[
              Text(
                '${order.displayName} • ${order.displayEmail}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8),
            ],

            // Order Summary
            Row(
              children: [
                Text(
                  '${order.itemCount} item${order.itemCount > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                Text(
                  'R${order.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            // Delivery Address
            if (order.deliveryAddress.isNotEmpty) ...[
              Text(
                ' ${order.deliveryAddress}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12),
            ],

            // Order Items Preview
            if (order.items.isNotEmpty) ...[
              Text(
                'Items: ${order.items.take(2).map((item) => '${item.name} x${item.quantity}').join(', ')}${order.items.length > 2 ? '...' : ''}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 16),
            ],

            // Action Buttons
            Row(
              children: [
                if (order.status == 'completed')
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final orderController = Get.find<OrderController>();
                        orderController.reorder(order);
                      },
                      icon: Icon(Icons.replay, size: 18),
                      label: Text('Reorder'),
                    ),
                  ),
                if (order.status == 'completed') SizedBox(width: 8),
                if (order.status == 'pending' || order.status.toLowerCase() == 'ongoing')
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final orderController = Get.find<OrderController>();
                        orderController.updateOrderStatus(order.id!, 'cancelled');
                      },
                      icon: Icon(Icons.cancel, size: 18),
                      label: Text('Cancel'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'ongoing':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
      case 'canceled':
        return Colors.red;
      case 'processing':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}