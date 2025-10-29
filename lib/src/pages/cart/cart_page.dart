import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam/src/controllers/cart_controller.dart';
import 'package:iam/src/utils/dimensions.dart';
import 'package:iam/src/utils/app_constants.dart';
import 'package:iam/src/routes/route_helper.dart';

import '../../constants/colors.dart';
import '../../widgets/order_confirmation_modal.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String _userAddress = 'Loading address...';
  bool _isLoadingAddress = true;

  @override
  void initState() {
    super.initState();
    _loadUserAddress();
  }

  Future<void> _loadUserAddress() async {
    try {
      final cartController = Get.find<CartController>();
      final address = await cartController.getUserAddress();
      setState(() {
        _userAddress = address;
        _isLoadingAddress = false;
      });
    } catch (e) {
      setState(() {
        _userAddress = 'Address not available';
        _isLoadingAddress = false;
      });
    }
  }

  // Helper method to get complete image URL
  String _getCompleteImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';

    if (imagePath.startsWith('http')) {
      return imagePath;
    }

    String cleanPath = imagePath.startsWith('/')
        ? imagePath.substring(1)
        : imagePath;

    return '${AppConstants.BASE_URL}/$cleanPath';
  }

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Cart',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              cartController.printDebugInfo();
              Get.snackbar(
                'Debug Info',
                'Check console for cart details',
                backgroundColor: Colors.blue,
                colorText: Colors.white,
              );
            },
            icon: Icon(Icons.bug_report, color: Colors.blue),
          ),
        ],
      ),
      body: GetBuilder<CartController>(
        builder: (cartController) {
          final cartItems = cartController.getItems;

          if (cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart, size: 64, color: Colors.grey),
                  SizedBox(height: Dimensions.height20),
                  Text('Your cart is empty', style: TextStyle(fontSize: 18)),
                  SizedBox(height: Dimensions.height20),
                  ElevatedButton(
                    onPressed: () {
                      Get.offAllNamed(RouteHelper.getInitialPage());
                    },
                    child: Text('Continue Shopping'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Cart Items List
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    final imageUrl = _getCompleteImageUrl(item.img);
                    final description = item.product?.description ?? '';

                    return GestureDetector(
                      onTap: () {
                        if (item.product?.id != null) {
                          Get.toNamed(
                            RouteHelper.getSingleProduct(item.product!.id!, 'cart'),
                          );
                        }
                      },
                      child: Container(
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
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Product Image
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.grey[200],
                                    ),
                                    child: imageUrl.isNotEmpty
                                        ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        imageUrl,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Icon(Icons.fastfood, size: 30, color: Colors.grey);
                                        },
                                      ),
                                    )
                                        : Icon(Icons.fastfood, size: 30, color: Colors.grey),
                                  ),
                                  SizedBox(width: 16),

                                  // Product Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name ?? 'Unknown Product',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4),
                                        if (description.isNotEmpty)
                                          Text(
                                            description.length > 30
                                                ? '${description.substring(0, 30)}...'
                                                : description,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'R${(item.price ?? 0).toStringAsFixed(0)}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              '14\'\'',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Quantity Controls
                                  GestureDetector(
                                    onTap: () {},
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.remove, size: 18),
                                            onPressed: () {
                                              if (item.product?.id != null) {
                                                cartController.updateQuantity(
                                                    item.product!.id!, (item.quantity ?? 1) - 1);
                                              }
                                            },
                                          ),
                                          Text(
                                            '${item.quantity}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.add, size: 18),
                                            onPressed: () {
                                              if (item.product?.id != null) {
                                                cartController.updateQuantity(
                                                    item.product!.id!, (item.quantity ?? 0) + 1);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            if (index < cartItems.length - 1)
                              Divider(height: 1, color: Colors.grey[300]),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Delivery Address Section
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'DELIVERY ADDRESS',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to profile to edit address
                            Get.toNamed(RouteHelper.getUserProfilePage());
                          },
                          child: Text(
                            'EDIT',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    _isLoadingAddress
                        ? Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Loading address...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    )
                        : Text(
                      _userAddress,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _userAddress == 'Address not set' || _userAddress == 'Address not available'
                            ? Colors.orange
                            : Colors.black,
                      ),
                    ),
                    if (_userAddress == 'Address not set' || _userAddress == 'Address not available')
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Please set your delivery address to place an order',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Total and Checkout Section
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TOTAL: R${cartController.totalAmount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _showBreakdownDialog(context, cartController);
                          },
                          child: Text(
                            'Breakdown >',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _userAddress == 'Address not set' || _userAddress == 'Address not available'
                            ? () {
                          Get.snackbar(
                            'Address Required',
                            'Please set your delivery address first',
                            backgroundColor: Colors.orange,
                            colorText: Colors.white,
                          );
                          Get.toNamed(RouteHelper.getUserProfilePage());
                        }
                            : () async {
                          // Show the order confirmation modal instead of directly placing order
                          Get.dialog(
                            OrderConfirmationModal(
                              subtotal: cartController.totalAmount,
                              onConfirm: (acceptDeliveryCost, deliveryType) async {
                                if (acceptDeliveryCost) {
                                  // Show loading dialog
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );

                                  try {
                                    // Place order with delivery information - NOW USING PUBLIC METHOD
                                    await cartController.placeOrderWithDelivery(deliveryType);
                                    Navigator.pop(context); // Close loading dialog

                                    if (cartController.getItems.isEmpty) {
                                      Get.offAll(() => OrderSuccessPage());
                                    }
                                  } catch (e) {
                                    Navigator.pop(context); // Close loading dialog
                                    Get.snackbar(
                                      'Order Failed',
                                      'Failed to place order. Please try again.',
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                    );
                                  }
                                }
                              },
                            ),
                            barrierDismissible: false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _userAddress == 'Address not set' || _userAddress == 'Address not available'
                              ? Colors.grey
                              : AppColors.iSecondaryColor ?? Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          _userAddress == 'Address not set' || _userAddress == 'Address not available'
                              ? 'SET ADDRESS TO ORDER'
                              : 'PLACE ORDER',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showBreakdownDialog(BuildContext context, CartController cartController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order Breakdown'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final item in cartController.getItems)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${item.name} x${item.quantity}'),
                    Text('R${(item.price ?? 0) * (item.quantity ?? 1)}'),
                  ],
                ),
              ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  'R${cartController.totalAmount.toStringAsFixed(0)}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

class OrderSuccessPage extends StatelessWidget {
  const OrderSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 80,
            ),
            SizedBox(height: 24),
            Text(
              'Order Placed Successfully!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Your order has been confirmed and saved to the database.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Get.offAllNamed(RouteHelper.getInitialPage());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text('Continue Shopping'),
            ),
          ],
        ),
      ),
    );
  }
}