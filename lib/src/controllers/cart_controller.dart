import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';
import '../data/repository/cart_repo.dart';
import '../data/repository/orders_repo.dart';
import '../model/cart_model.dart';
import '../model/single_product_model.dart';
import '../routes/route_helper.dart';
import '../services/user_spending_service.dart';
import '../utils/app_constants.dart';
import '../widgets/order_confirmation_modal.dart';
import 'auth/firebase/authenication_repository.dart';
import 'wishlist_controller.dart';

class CartController extends GetxController {
  final CartRepo cartRepo;
  final OrderRepo orderRepo;
  CartController({
    required this.cartRepo,
    required this.orderRepo, // Update this
  });

  Map<int, CartModel> _items = {};
  Map<int, CartModel> get items => _items;
  List<CartModel> storageItems = [];

  final UserSpendingService _spendingService = Get.find<UserSpendingService>();

  // Enhanced method to get user data
  Map<String, dynamic> _getUserData() {
    print(' Starting user data retrieval process...');

    // First try: Get from local storage (most reliable)
    try {
      final sharedPreferences = Get.find<SharedPreferences>();
      String? storedName = sharedPreferences.getString('user_name');
      String? storedEmail = sharedPreferences.getString('user_email');

      if (storedEmail != null && storedEmail.isNotEmpty) {
        print(' User data found in local storage:');
        print('   - Name: $storedName');
        print('   - Email: $storedEmail');

        return {
          'name': storedName ?? 'Customer',
          'email': storedEmail,
        };
      }
    } catch (e) {
      print(' Error accessing local storage: $e');
    }

    // Second try: Get from Firebase Auth
    try {
      final authRepo = Get.find<AuthenticationRepository>();
      final user = authRepo.firebaseUser.value;

      if (user != null) {
        print(' Firebase user found:');
        print('   - UID: ${user.uid}');
        print('   - Display Name: ${user.displayName}');
        print('   - Email: ${user.email}');
        print('   - Email Verified: ${user.emailVerified}');

        String userName = user.displayName ?? 'Customer';
        String userEmail = user.email ?? 'customer@example.com';

        // Store this data locally for future use
        _storeUserDataLocally(userName, userEmail);

        return {
          'name': userName,
          'email': userEmail,
        };
      } else {
        print(' No Firebase user currently logged in');
      }
    } catch (e) {
      print(' Error getting Firebase user: $e');
    }

    // Final fallback
    print(' Using fallback customer data - no user data found');
    return {
      'name': 'Customer',
      'email': 'customer@example.com',
    };
  }

  // Helper method to store user data locally
  void _storeUserDataLocally(String name, String email) {
    try {
      final sharedPreferences = Get.find<SharedPreferences>();
      sharedPreferences.setString('user_name', name);
      sharedPreferences.setString('user_email', email);
      print(' User data stored locally: $name, $email');
    } catch (e) {
      print(' Error storing user data locally: $e');
    }
  }

  int get totalItemsCount {
    return _items.values.fold(0, (sum, item) => sum + (item.quantity ?? 0));
  }

  void debugCartState() {
    print('\n=== CART STATE DEBUG ===');
    print('Total items in cart: ${_items.length}');
    print('Total quantity: $totalItems');
    print('Storage items: ${storageItems.length}');

    if (_items.isEmpty) {
      print(' Cart is EMPTY');
    } else {
      print(' Cart contains items:');
      _items.forEach((id, item) {
        print('   - ${item.name}: ${item.quantity} x R${item.price}');
      });
    }

    print('GetX is registered: ${Get.isRegistered<CartController>()}');
    print('=== END CART DEBUG ===\n');
  }

  void addItem(SingleProductModel product, int quantity) {
    try {
      print('\n ADDING ITEM TO CART:');
      print('   Product: ${product.name}');
      print('   Product ID: ${product.id}');
      print('   Quantity: $quantity');
      print('   Stock: ${product.stock}');
      print('   Price: R${product.price}');

      // Check if product is in stock
      if ((product.stock ?? 0) <= 0) {
        print(' Cannot add item: Out of stock');
        Get.snackbar(
          'Out of Stock',
          '${product.name} is currently out of stock',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      var totalQuantity = 0;

      if (_items.containsKey(product.id!)) {
        print(' Updating existing item in cart');
        _items.update(product.id!, (value) {
          totalQuantity = (value.quantity ?? 0) + quantity;
          print('   New quantity: $totalQuantity');
          return CartModel(
            id: value.id,
            name: value.name,
            price: value.price,
            img: value.img,
            quantity: totalQuantity,
            isExist: true,
            time: DateTime.now().toString(),
            product: product,
          );
        });

        if (totalQuantity <= 0) {
          print(' Removing item (quantity <= 0)');
          _items.remove(product.id);
        }
      } else {
        if (quantity > 0) {
          print(' Adding new item to cart');
          _items.putIfAbsent(product.id!, () {
            return CartModel(
              id: product.id,
              name: product.name,
              price: product.price,
              img: product.image,
              quantity: quantity,
              isExist: true,
              time: DateTime.now().toString(),
              product: product,
            );
          });
        } else {
          print(' Invalid quantity: $quantity');
          Get.snackbar(
            'Item Count',
            'You should at least add 1 item',
            backgroundColor: AppColors.mainColor,
            colorText: Colors.white,
          );
          return;
        }
      }

      // Save to storage
      print(' Saving cart to storage...');
      cartRepo.addToCartList(getItems);

      // Force update
      update();

      print('Item added successfully!');
      print('   Cart now has ${_items.length} items');
      print('   Total quantity: $totalItems');

      // Show success feedback
      Get.snackbar(
        'Added to Cart',
        '${product.name} added to cart',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );

      _debugPrintCartItems('After adding item');

    } catch (e) {
      print(' ERROR in addItem: $e');
      Get.snackbar(
        'Error',
        'Failed to add item to cart',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> showOrderConfirmation() async {
    try {
      if (_items.isEmpty) {
        Get.snackbar(
          'Cart Empty',
          'Your cart is empty!',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Show the confirmation modal
      Get.dialog(
        OrderConfirmationModal(
          subtotal: totalAmount,
          onConfirm: (acceptDeliveryCost, deliveryType) async {
            if (acceptDeliveryCost) {
              // Proceed with order placement
              await placeOrderWithDelivery(deliveryType);
            }
          },
        ),
        barrierDismissible: false,
      );

    } catch (e) {
      print(' Error showing order confirmation: $e');
      Get.snackbar(
        'Error',
        'Failed to process order confirmation',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> placeOrderWithDelivery(String deliveryType) async {
    try {
      print(' Placing order with delivery type: $deliveryType');

      // Calculate delivery cost
      double deliveryCost = _calculateDeliveryCost(deliveryType);
      double finalTotal = totalAmount + deliveryCost;

      print('   Delivery cost: R$deliveryCost');
      print('   Final total: R$finalTotal');

      // Check spending limit first
      final spendingCheck = await checkSpendingLimit();

      if (!spendingCheck.canProceed) {
        print(' Order blocked: Monthly spending limit exceeded');
        // This will show the spending limit dialog and return early
        _showSpendingLimitExceededDialog(spendingCheck);
        return; // Return early without placing order
      }

      // If we get here, spending limit is OK - place the order
      final result = await placeOrder();

      if (result != null) {
        // Show payment instructions
        _showPaymentInstructions(finalTotal, deliveryType);
      }

    } catch (e) {
      print('Error placing order with delivery: $e');
      rethrow;
    }
  }
  bool existInCart(SingleProductModel product) {
    return _items.containsKey(product.id);
  }
  Future<bool> checkSpendingBeforeOrder() async {
    final spendingCheck = await checkSpendingLimit();

    if (!spendingCheck.canProceed) {
      print(' Order blocked by spending limit');
      _showSpendingLimitExceededDialog(spendingCheck);
      return false;
    }

    return true;
  }
  int getQuantity(SingleProductModel product) {
    var quantity = 0;
    if (_items.containsKey(product.id)) {
      _items.forEach((key, value) {
        if (key == product.id) {
          quantity = value.quantity ?? 0;
        }
      });
    }
    return quantity;
  }

  int get totalItems {
    var totalQuantity = 0;
    _items.forEach((key, value) {
      totalQuantity += value.quantity ?? 0;
    });
    return totalQuantity;
  }

  List<CartModel> get getItems {
    return _items.entries.map((e) => e.value).toList();
  }

  double get totalAmount {
    double total = 0;
    _items.forEach((key, value) {
      total += (value.quantity ?? 0) * (value.price ?? 0);
    });
    return total;
  }

  List<CartModel> getCartData() {
    setCart = cartRepo.getCartList();
    return storageItems;
  }

  set setCart(List<CartModel> items) {
    storageItems = items;
    print('Items in cart: ${storageItems.length}');

    _items.clear();
    for (int i = 0; i < storageItems.length; i++) {
      if (storageItems[i].product?.id != null) {
        _items.putIfAbsent(storageItems[i].product!.id!, () => storageItems[i]);
      }
    }

    _debugPrintCartItems('After setting cart from storage');
    update();
  }

  // Add spending limit check before placing order
  Future<SpendingCheckResult> checkSpendingLimit() async {
    return await _spendingService.checkOrderEligibility(totalAmount);
  }

  Future<Map<String, dynamic>?> placeOrder() async {
    try {
      print('STARTING ORDER PLACEMENT PROCESS');
      _debugPrintCartItems('Before placing order');

      // Check spending limit first
      final spendingCheck = await checkSpendingLimit();

      if (!spendingCheck.canProceed) {
        print(' Order blocked: Monthly spending limit exceeded');
        _showSpendingLimitExceededDialog(spendingCheck);
        return null;
      }

      if (_items.isEmpty) {
        print('Cannot place order: Cart is empty');
        Get.snackbar(
          'Order Failed',
          'Your cart is empty!',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return null;
      }

      // Get user address before placing order
      print(' Fetching user delivery address...');
      final userAddress = await getUserAddress();

      if (userAddress == 'Address not set' || userAddress == 'Address not available') {
        // Show dialog to set address
        Get.dialog(
          AlertDialog(
            title: Text('Address Required'),
            content: Text('Please set your delivery address in your profile before placing an order.'),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Get.back();
                  Get.toNamed(RouteHelper.getUserProfilePage());
                },
                child: Text('Set Address'),
              ),
            ],
          ),
        );
        return null;
      }

      Map<String, dynamic> orderData = _prepareOrderData();
      orderData['delivery_address'] = userAddress;

      print(' Using delivery address: $userAddress');

      print('Saving order to API database...');
      // Use orderRepo instead of ordersRepo
      final response = await orderRepo.placeOrder(orderData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Add this order amount to spending
        final spendingAdded = await _spendingService.addSpending(totalAmount);

        if (!spendingAdded) {
          print(' Warning: Could not update spending record');
        }

        print('ORDER PLACED SUCCESSFULLY IN DATABASE!');
        print('Order ID: ${response.body['order_id']}');
        print('Order Number: ${response.body['order_number']}');

        // Save to local history and clear cart
        await addToHistory();

        // Show success message
        Get.snackbar(
          'Order Placed!',
          'Your order #${response.body['order_number']} has been placed successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );

        return response.body;

      } else {
        print(' Order failed with status: ${response.statusCode}');
        print(' Response: ${response.body}');
        throw Exception('API returned status code: ${response.statusCode}');
      }

    } catch (e) {
      print('ERROR PLACING ORDER: $e');
      Get.snackbar(
        'Order Failed',
        'There was an error placing your order. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  void _showSpendingLimitExceededDialog(SpendingCheckResult spendingCheck) {
    Get.dialog(
      AlertDialog(
        title: Text('Monthly Spending Limit Exceeded'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You have reached your monthly spending limit of R${spendingCheck.monthlyLimit}.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text('📊 Spending Summary:'),
            SizedBox(height: 8),
            _buildSpendingRow('Current Spending:', 'R${spendingCheck.currentSpending.toStringAsFixed(2)}'),
            _buildSpendingRow('Order Total:', 'R${spendingCheck.orderTotal.toStringAsFixed(2)}'),
            _buildSpendingRow('Remaining Balance:', 'R${spendingCheck.remainingBalance.toStringAsFixed(2)}',
                color: Colors.red),
            _buildSpendingRow('Amount Over Limit:', 'R${spendingCheck.amountOverLimit.toStringAsFixed(2)}',
                color: Colors.red),
            SizedBox(height: 10),
            Text(
              'Please remove items totaling at least R${spendingCheck.amountOverLimit.toStringAsFixed(2)} to proceed.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Your spending limit will reset in ${spendingCheck.daysUntilReset} days.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close this dialog first
              _showMoveToWishlistSuggestions(spendingCheck.amountOverLimit);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.iSecondaryColor,
            ),
            child: Text('Move Items to Wishlist'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildSpendingRow(String label, String value, {Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14)),
          Text(value, style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          )),
        ],
      ),
    );
  }

// Add this method to your CartController
  void moveItemToWishlistAndRemoveFromCart(int productId, int quantityToRemove) {
    if (_items.containsKey(productId)) {
      final item = _items[productId]!;
      final currentQuantity = item.quantity ?? 0;

      if (currentQuantity <= quantityToRemove) {
        // Remove entire item if quantity to remove >= current quantity
        if (item.product != null) {
          final wishlistController = Get.find<WishlistController>();
          wishlistController.toggleWishlist(item.product!);
        }
        removeItem(productId);
      } else {
        // Remove only part of the quantity
        final newQuantity = currentQuantity - quantityToRemove;
        updateQuantity(productId, newQuantity);

        // Add to wishlist (you might want to create a method to add without removing)
        if (item.product != null) {
          final wishlistController = Get.find<WishlistController>();
          // This will add the product to wishlist
          wishlistController.addToWishlist(item.product!);
        }
      }

      update();
    }
  }

// Update the wishlist suggestion item to handle partial removal
  Widget _buildWishlistSuggestionItem(CartModel item, double amountToRemove) {
    final wishlistController = Get.find<WishlistController>();
    final itemTotal = (item.price ?? 0) * (item.quantity ?? 1);

    return Card(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: item.img != null && item.img!.isNotEmpty
              ? NetworkImage(item.img!)
              : null,
          child: item.img == null || item.img!.isEmpty
              ? Icon(Icons.fastfood)
              : null,
        ),
        title: Text(item.name ?? 'Unknown Product'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('R${item.price?.toStringAsFixed(2)} each'),
            if (item.quantity != null && item.quantity! > 1)
              Text('Quantity: ${item.quantity}', style: TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Option to remove one item
            if (item.quantity != null && item.quantity! > 1)
              IconButton(
                icon: Icon(Icons.remove_circle_outline, color: Colors.orange),
                onPressed: () {
                  if (item.product != null) {
                    moveItemToWishlistAndRemoveFromCart(item.id!, 1);
                    wishlistController.addToWishlist(item.product!);
                    Get.snackbar(
                      'Moved to Wishlist',
                      '1 ${item.name} moved to wishlist',
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                    Get.back(); // Close the bottom sheet
                  }
                },
                tooltip: 'Move 1 to wishlist',
              ),
            // Option to remove all items
            IconButton(
              icon: Icon(Icons.favorite_border, color: Colors.red),
              onPressed: () {
                if (item.product != null) {
                  final quantityToRemove = item.quantity ?? 1;
                  moveItemToWishlistAndRemoveFromCart(item.id!, quantityToRemove);
                  Get.snackbar(
                    'Moved to Wishlist',
                    '${quantityToRemove} ${item.name} moved to wishlist',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                  Get.back(); // Close the bottom sheet
                }
              },
              tooltip: 'Move all to wishlist',
            ),
          ],
        ),
      ),
    );
  }

// Update the method that shows wishlist suggestions
  void _showMoveToWishlistSuggestions(double amountToRemove) {
    // Sort items by price (highest first) to suggest removal
    final sortedItems = _items.values.toList()
      ..sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Move Items to Wishlist',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'You need to free up R${amountToRemove.toStringAsFixed(2)}. Move items to wishlist:',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 15),
            ...sortedItems.take(3).map((item) => _buildWishlistSuggestionItem(item, amountToRemove)),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    child: Text('Cancel'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      Get.toNamed(RouteHelper.wishlistPage);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.iSecondaryColor,
                    ),
                    child: Text('View Wishlist'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }



  // Add this to your debug methods
  void debugSpendingStatus() {
    _spendingService.debugSpendingStatus();
  }

  Map<String, dynamic> _prepareOrderData() {
    List<Map<String, dynamic>> itemsList = _items.values.map((cartItem) {
      return {
        'id': cartItem.id,
        'name': cartItem.name,
        'price': cartItem.price,
        'quantity': cartItem.quantity,
        'image': cartItem.img,
        'subtotal': (cartItem.price ?? 0) * (cartItem.quantity ?? 0),
      };
    }).toList();

    // Get user data with enhanced debug info
    print('👤 Getting user data for order...');
    Map<String, dynamic> userData = _getUserData();

    print('✅ User data retrieved:');
    print('   - Name: ${userData['name']}');
    print('   - Email: ${userData['email']}');

    // Dynamic category detection
    int categoryId = _getDynamicCategoryId();

    // Prepare the final order data with validation
    String customerName = userData['name']?.toString().trim() ?? 'Customer';
    String customerEmail = userData['email']?.toString().trim() ?? 'customer@example.com';

    // Validate and ensure data is not empty
    if (customerName.isEmpty) {
      print('⚠️ Customer name is empty after trimming, setting default');
      customerName = 'Customer';
    }

    if (customerEmail.isEmpty) {
      print('⚠️ Customer email is empty after trimming, setting default');
      customerEmail = 'customer@example.com';
    }

    Map<String, dynamic> orderData = {
      'category_id': categoryId,
      'customer_name': customerName,
      'customer_email': customerEmail,
      'status': 'pending',
      'total_amount': totalAmount,
      'order_date': DateTime.now().toIso8601String(),
      'item_count': totalItems,
      'items': itemsList,
      'delivery_address': '2118 Thornridge Cir, Syracuse',
      'user_id': 1,
    };

    print('📦 Final order data prepared:');
    print('   - Customer Name: ${orderData['customer_name']}');
    print('   - Customer Email: ${orderData['customer_email']}');
    print('   - Total Amount: R${orderData['total_amount']}');
    print('   - Item Count: ${orderData['item_count']}');

    return orderData;
  }

  // Dynamic category detection method
  int _getDynamicCategoryId() {
    if (_items.isEmpty) return 2; // Default to Vegetables

    final firstItem = _items.values.first;

    // Option 1: If your product has category_id field
    if (firstItem.product?.category_id != null) {
      return firstItem.product!.category_id!;
    }

    // Option 2: If your product has category information
    if (firstItem.product?.category?.id != null) {
      return firstItem.product!.category!.id!;
    }

    // Option 3: Smart category detection based on product name/type
    final productName = firstItem.name?.toLowerCase() ?? '';

    if (productName.contains('tomato') ||
        productName.contains('vegetable') ||
        productName.contains('carrot') ||
        productName.contains('potato') ||
        productName.contains('onion') ||
        productName.contains('spinach') ||
        productName.contains('lettuce')) {
      return 2; // Vegetables
    }
    else if (productName.contains('fruit') ||
        productName.contains('apple') ||
        productName.contains('orange') ||
        productName.contains('banana')) {
      return 9; // Fruits
    }
    else if (productName.contains('canned') ||
        productName.contains('tin') ||
        productName.contains('preserved')) {
      return 3; // Canned Foods
    }
    else if (productName.contains('rice') ||
        productName.contains('flour') ||
        productName.contains('pasta') ||
        productName.contains('grain')) {
      return 4; // Staples
    }
    else if (productName.contains('drink') ||
        productName.contains('juice') ||
        productName.contains('soda') ||
        productName.contains('water')) {
      return 5; // Beverages
    }
    else if (productName.contains('meat') ||
        productName.contains('chicken') ||
        productName.contains('beef') ||
        productName.contains('fish')) {
      return 6; // Protein & Meat
    }
    else if (productName.contains('cereal') ||
        productName.contains('breakfast') ||
        productName.contains('oat')) {
      return 7; // Breakfast & Cereal
    }
    else if (productName.contains('snack') ||
        productName.contains('chip') ||
        productName.contains('chocolate') ||
        productName.contains('candy')) {
      return 10; // Snacks & Treats
    }
    else if (productName.contains('sauce') ||
        productName.contains('condiment') ||
        productName.contains('spice')) {
      return 11; // Condiments & Sauces
    }
    else if (productName.contains('milk') ||
        productName.contains('cheese') ||
        productName.contains('yogurt') ||
        productName.contains('dairy')) {
      return 12; // Dairy & Dairy Alternatives
    }

    // Default fallback
    return 2; // Vegetables
  }

  Future<void> addToHistory() async {
    print('Adding cart items to local history...');
    cartRepo.addToCartHistoryList();

    final history = cartRepo.getCartHistoryList();
    print('Local cart history now contains ${history.length} orders');

    clear();
  }

  void clear() {
    print('Clearing cart...');
    _items = {};
    cartRepo.addToCartList(getItems);
    update();
    print('Cart cleared successfully');
  }

  List<CartModel> getCartHistoryList() {
    final history = cartRepo.getCartHistoryList();
    print('Retrieved ${history.length} orders from local history');
    return history;
  }

  void clearCartHistory() {
    print('Clearing cart history...');
    cartRepo.clearCartHistory();
    update();
    print('Cart history cleared');
  }

  void removeItem(int productId) {
    if (_items.containsKey(productId)) {
      print('Removing item with ID: $productId');
      _items.remove(productId);
      cartRepo.addToCartList(getItems);
      update();
      _debugPrintCartItems('After removing item');
    }
  }

  void updateQuantity(int productId, int newQuantity) {
    print('Updating quantity for product $productId to $newQuantity');

    if (_items.containsKey(productId)) {
      if (newQuantity <= 0) {
        removeItem(productId);
      } else {
        _items.update(productId, (value) {
          return CartModel(
            id: value.id,
            name: value.name,
            price: value.price,
            img: value.img,
            quantity: newQuantity,
            isExist: true,
            time: value.time,
            product: value.product,
          );
        });
        cartRepo.addToCartList(getItems);
        update();
        _debugPrintCartItems('After updating quantity');
      }
    }
  }

  void _debugPrintCartItems(String context) {
    print('\n=== CART DEBUG: $context ===');
    print('Total items in cart: ${_items.length}');
    print('Total quantity: $totalItems');
    print('Total amount: R${totalAmount.toStringAsFixed(0)}');

    // Get user data for debug info
    Map<String, dynamic> userData = _getUserData();
    print('Customer Name: ${userData['name']}');
    print('Customer Email: ${userData['email']}');

    if (_items.isEmpty) {
      print('Cart is empty');
    } else {
      _items.forEach((id, item) {
        print('Product: ${item.name}');
        print('   ID: ${item.id}');
        print('   Price: R${item.price}');
        print('   Quantity: ${item.quantity}');
        print('   Subtotal: R${(item.price ?? 0) * (item.quantity ?? 0)}');
        print('   Image: ${item.img}');
        print('   Detected Category ID: ${_getDynamicCategoryId()}');
      });
    }
    print('=== END CART DEBUG ===\n');
  }

  void printDebugInfo() {
    _debugPrintCartItems('Manual Debug Trigger');
  }

  // Method to get user address
  Future<String> getUserAddress() async {
    try {
      final authRepo = Get.find<AuthenticationRepository>();
      final userAddress = await authRepo.getUserAddress();

      if (userAddress != null && userAddress.isNotEmpty) {
        print('✅ User address found: $userAddress');
        return userAddress;
      } else {
        print('⚠️ No address found in user profile');
        return 'Address not set'; // Default message
      }
    } catch (e) {
      print('❌ Error getting user address: $e');
      return 'Address not available'; // Fallback message
    }
  }

  double _calculateDeliveryCost(String deliveryType) {
    if (totalAmount >= AppConstants.FREE_DELIVERY_THRESHOLD) {
      return 0.0;
    }

    return deliveryType == 'express'
        ? AppConstants.EXPRESS_DELIVERY_COST
        : AppConstants.STANDARD_DELIVERY_COST;
  }

  void _showPaymentInstructions(double totalAmount, String deliveryType) {
    Get.dialog(
      AlertDialog(
        title: Text('Payment Instructions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your order has been placed successfully!'),
            SizedBox(height: 10),
            Text('Total Amount: R${totalAmount.toStringAsFixed(2)}'),
            SizedBox(height: 10),
            Text('Please make payment to:'),
            SizedBox(height: 5),
            Text('Bank: Your Bank Name', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Account: 1234 5678 9012', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Reference: Order #${DateTime.now().millisecondsSinceEpoch}'),
            SizedBox(height: 10),
            Text('Delivery: ${deliveryType == 'express' ? 'Express' : 'Standard'}'),
            SizedBox(height: 10),
            Text(
              'Once payment is confirmed, your order will be processed and delivered.',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              // Here you would integrate with your payment gateway
              Get.back();
              Get.snackbar(
                'Payment',
                'Redirecting to payment gateway...',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
              // Add your payment gateway integration here
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.iSecondaryColor,
            ),
            child: Text('Pay Now'),
          ),
        ],
      ),
    );
  }
}