import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam/src/controllers/order_controller.dart';
import 'package:iam/src/utils/dimensions.dart';
import 'package:iam/src/widgets/big_text.dart';

import '../../model/order_model.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final OrderController orderController = Get.find<OrderController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    orderController.fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders'),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Ongoing'),
            Tab(text: 'History'),
          ],
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOngoingTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildOngoingTab() {
    return GetBuilder<OrderController>(
      builder: (controller) {
        if (controller.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        final ongoingOrders = controller.ongoingOrders;
        if (ongoingOrders.isEmpty) {
          return Center(child: Text('No ongoing orders'));
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: ongoingOrders.length,
          itemBuilder: (context, index) {
            return _buildOrderCard(ongoingOrders[index]);
          },
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: 'Completed'),
              Tab(text: 'Canceled'),
            ],
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildCompletedOrders(),
                _buildCanceledOrders(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedOrders() {
    return GetBuilder<OrderController>(
      builder: (controller) {
        final completedOrders = controller.completedOrders;
        if (completedOrders.isEmpty) {
          return Center(child: Text('No completed orders'));
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: completedOrders.length,
          itemBuilder: (context, index) {
            return _buildOrderCard(completedOrders[index]);
          },
        );
      },
    );
  }

  Widget _buildCanceledOrders() {
    return GetBuilder<OrderController>(
      builder: (controller) {
        final canceledOrders = controller.canceledOrders;
        if (canceledOrders.isEmpty) {
          return Center(child: Text('No canceled orders'));
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: canceledOrders.length,
          itemBuilder: (context, index) {
            return _buildOrderCard(canceledOrders[index]);
          },
        );
      },
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.orderNumber}', // Show order number instead of type
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(12),
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
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.customerName, // Show customer name instead of restaurant
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${order.itemCount} Items',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'R${order.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatDate(order.orderDate),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (order.status == 'completed')
                  ElevatedButton(
                    onPressed: () => orderController.rateOrder(order),
                    child: Text('Rate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ElevatedButton(
                  onPressed: () => orderController.reorder(order),
                  child: Text('Re-Order'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
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
    switch (status) {
      case 'ongoing':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthAbbreviation(date.month)}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getMonthAbbreviation(int month) {
    final months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return months[month - 1];
  }
}