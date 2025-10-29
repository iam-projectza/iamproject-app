import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam/src/controllers/cart_controller.dart';
import 'package:iam/src/controllers/order_controller.dart';
import 'package:iam/src/controllers/auth/firebase/authenication_repository.dart';
import 'package:iam/src/model/cart_model.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final OrderController orderController = Get.find<OrderController>();
  final CartController cartController = Get.find<CartController>();
  final AuthenticationRepository authRepo = Get.find<AuthenticationRepository>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print('🛒 CHECKOUT PAGE INITIALIZED');

    // Pre-fill user data if available
    final user = authRepo.firebaseUser.value;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _emailController.text = user.email ?? '';
      print('👤 User data pre-filled: ${user.displayName}');
    } else {
      print('❌ No user logged in');
    }

    // Debug cart contents
    print('📦 Cart items at checkout: ${cartController.getItems.length}');
    print('💰 Cart total: R${cartController.totalAmount}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Order Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    ...cartController.getItems.map((item) => ListTile(
                      leading: CircleAvatar(
                        backgroundImage: item.img != null && item.img!.isNotEmpty
                            ? NetworkImage(item.img!)
                            : null,
                        child: item.img == null || item.img!.isEmpty
                            ? Icon(Icons.fastfood)
                            : null,
                      ),
                      title: Text(item.name ?? 'Unknown Product'),
                      subtitle: Text('Quantity: ${item.quantity ?? 0}'),
                      trailing: Text(
                        'R${((item.price ?? 0) * (item.quantity ?? 0)).toStringAsFixed(2)}',
                      ),
                    )).toList(),
                    Divider(),
                    ListTile(
                      title: Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Text(
                        'R${cartController.totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Customer Information Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Delivery Address *',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Place Order Button
            GetBuilder<OrderController>(
              builder: (controller) {
                return SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: controller.isLoading ? null : _placeOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: controller.isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                      'PLACE ORDER - R${cartController.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _placeOrder() {
    print('🔄 PLACE ORDER BUTTON CLICKED!');
    print('📝 Form Data:');
    print('   - Name: ${_nameController.text}');
    print('   - Email: ${_emailController.text}');
    print('   - Address: ${_addressController.text}');

    if (_nameController.text.isEmpty) {
      print('❌ VALIDATION FAILED: Name is empty');
      Get.snackbar('Error', 'Please enter your name');
      return;
    }
    if (_emailController.text.isEmpty) {
      print('❌ VALIDATION FAILED: Email is empty');
      Get.snackbar('Error', 'Please enter your email');
      return;
    }
    if (_addressController.text.isEmpty) {
      print('❌ VALIDATION FAILED: Address is empty');
      Get.snackbar('Error', 'Please enter delivery address');
      return;
    }

    print('✅ FORM VALIDATION PASSED - CALLING ORDER CONTROLLER');

    orderController.placeOrderFromCart(
      customerName: _nameController.text,
      customerEmail: _emailController.text,
      deliveryAddress: _addressController.text,
    ).then((_) {
      print('🔄 ORDER PLACEMENT COMPLETED - NAVIGATING TO ORDERS PAGE');
      // Navigate back to orders page after successful order
      Get.offAllNamed('/orders');
    }).catchError((error) {
      print('❌ ORDER PLACEMENT FAILED: $error');
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}