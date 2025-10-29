import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iam/src/utils/app_constants.dart';
import '../../model/cart_model.dart';
import '../api/api_client.dart';

class CartRepo {
  final SharedPreferences sharedPreferences;
  final ApiClient apiClient;
  CartRepo({required this.sharedPreferences, required this.apiClient});

  List<String> cart = [];
  List<String> cartHistory = [];

  Future<void> addToCartList(List<CartModel> cartList) async {
    try {
      print('\n💾 CART REPO: Saving cart to storage...');
      print('   Items to save: ${cartList.length}');

      var time = DateTime.now().toString();
      cart = [];

      for (var element in cartList) {
        element.time = time;
        String jsonString = jsonEncode(element.toJson());
        print('   Saving item: ${element.name} -> $jsonString');
        cart.add(jsonString);
      }

      print('   Final cart list to save: $cart');

      bool success = await sharedPreferences.setStringList(AppConstants.CART_LIST, cart);

      if (success) {
        print('✅ CART REPO: Successfully saved ${cart.length} items to storage');

        // Verify the save worked
        List<String>? savedCart = sharedPreferences.getStringList(AppConstants.CART_LIST);
        print('   Verified saved cart: ${savedCart?.length ?? 0} items');
      } else {
        print('❌ CART REPO: Failed to save cart to storage');
      }

    } catch (e) {
      print('❌ CART REPO: Error saving cart: $e');
    }
  }

  List<CartModel> getCartList() {
    try {
      List<String> carts = [];

      if (sharedPreferences.containsKey(AppConstants.CART_LIST)) {
        carts = sharedPreferences.getStringList(AppConstants.CART_LIST)!;
        print('📥 CART REPO: Loaded ${carts.length} items from storage');

        for (int i = 0; i < carts.length; i++) {
          print('   Item $i: ${carts[i]}');
        }
      } else {
        print('📥 CART REPO: No cart data found in storage');
      }

      List<CartModel> cartList = [];
      for (var element in carts) {
        try {
          CartModel item = CartModel.fromJson(jsonDecode(element));
          cartList.add(item);
        } catch (e) {
          print('❌ CART REPO: Error parsing cart item: $e');
          print('   Problematic item: $element');
        }
      }

      print('📥 CART REPO: Successfully parsed ${cartList.length} items');
      return cartList;

    } catch (e) {
      print('❌ CART REPO: Error loading cart: $e');
      return [];
    }
  }

  List<CartModel> getCartHistoryList() {
    if (sharedPreferences.containsKey(AppConstants.CART_HISTORY_LIST)) {
      cartHistory = [];
      cartHistory = sharedPreferences.getStringList(AppConstants.CART_HISTORY_LIST)!;
    }
    List<CartModel> cartListHistory = [];
    for (var element in cartHistory) {
      cartListHistory.add(CartModel.fromJson(jsonDecode(element)));
    }
    return cartListHistory;
  }

  void addToCartHistoryList() {
    if (sharedPreferences.containsKey(AppConstants.CART_HISTORY_LIST)) {
      cartHistory = sharedPreferences.getStringList(AppConstants.CART_HISTORY_LIST)!;
    }
    for (int i = 0; i < cart.length; i++) {
      cartHistory.add(cart[i]);
    }
    removeCart();
    sharedPreferences.setStringList(AppConstants.CART_HISTORY_LIST, cartHistory);
    print('the length of history is ${getCartHistoryList().length}');
  }

  void removeCart() {
    cart = [];
    sharedPreferences.remove(AppConstants.CART_LIST);
    print('🗑️ CART REPO: Cart cleared from storage');
  }

  void clearCartHistory() {
    removeCart();
    cartHistory = [];
    sharedPreferences.remove(AppConstants.CART_HISTORY_LIST);
  }

  Future<Response> placeOrder(Map<String, dynamic> orderData) async {
    print('Sending order to API...');
    print('Order Data: ${jsonEncode(orderData)}');

    try {
      Response response = await apiClient.postData(
        AppConstants.ORDERS_URI,
        orderData,
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      return response;
    } catch (e) {
      print('API Error: $e');
      rethrow;
    }
  }

  Future<Response> getOrderHistory() async {
    return await apiClient.getData(AppConstants.ORDERS_HISTORY_URI);
  }

  Future<void> testApiConnection() async {
    try {
      print('🔍 Testing API connection...');

      // Test 1: Check if base URL is accessible
      print('🔍 Testing base URL...');
      Response testResponse = await apiClient.getData('/');
      print('🔍 Base URL Test Response Status: ${testResponse.statusCode}');

      // Test 2: Check if API endpoint exists
      print('🔍 Testing API endpoint...');
      Response apiResponse = await apiClient.getData('/api/single-products');
      print('🔍 API Endpoint Test Response Status: ${apiResponse.statusCode}');

      if (apiResponse.statusCode == 200) {
        print('✅ API connection successful');
      } else {
        print('❌ API connection failed with status: ${apiResponse.statusCode}');
        print('❌ Response body: ${apiResponse.body}');
      }
    } catch (e) {
      print('❌ API connection test failed: $e');
    }
  }

  Future<void> testAllApiEndpoints() async {
    final testEndpoints = [
      '/api/single-products',
      '/api/categories',
      '/api/orders',
      '/api/recommended',
    ];

    for (String endpoint in testEndpoints) {
      print('🔍 Testing endpoint: $endpoint');
      try {
        Response response = await apiClient.getData(endpoint);
        print('🔍 Response for $endpoint: ${response.statusCode}');
        if (response.statusCode == 200) {
          print('✅ Endpoint $endpoint is working');
        } else if (response.statusCode == 302) {
          print('❌ Endpoint $endpoint is redirecting - Server config issue');
        } else {
          print('❌ Endpoint $endpoint returned: ${response.statusCode}');
        }
      } catch (e) {
        print('❌ Error testing $endpoint: $e');
      }
      print('---');
    }
  }

  Future<void> testPostRequest() async {
    try {
      print('🔍 Testing POST request to /api/orders...');

      // Test with minimal data
      Map<String, dynamic> testData = {
        'category_id': 1,
        'customer_name': 'Test Customer',
        'customer_email': 'test@example.com',
        'status': 'pending',
        'total_amount': 10.0,
        'order_date': DateTime.now().toIso8601String(),
        'item_count': 1,
        'items': [
          {
            'id': 1,
            'name': 'Test Product',
            'price': 10.0,
            'quantity': 1,
            'image': 'test.jpg',
            'subtotal': 10.0
          }
        ],
        'delivery_address': 'Test Address',
      };

      Response response = await apiClient.postData(
        '/api/orders',
        testData,
      );

      print('🔍 POST test response: ${response.statusCode}');
      print('🔍 POST test body: ${response.body}');

    } catch (e) {
      print('❌ POST test failed: $e');
    }
  }

  // Add this method to test cart storage specifically
  Future<void> testCartStorage() async {
    print('\n🧪 TESTING CART STORAGE...');

    // Test 1: Check if SharedPreferences is working
    print('1. Testing SharedPreferences...');
    bool testSave = await sharedPreferences.setString('test_key', 'test_value');
    String? testValue = sharedPreferences.getString('test_key');
    print('   SharedPreferences test: ${testSave && testValue == 'test_value' ? '✅ PASS' : '❌ FAIL'}');

    // Test 2: Clear existing cart
    print('2. Clearing existing cart...');
    removeCart();

    // Test 3: Save test item
    print('3. Saving test item...');
    CartModel testItem = CartModel(
      id: 999,
      name: 'Test Product',
      price: 10.0,
      img: 'test.jpg',
      quantity: 1,
      isExist: true,
      time: DateTime.now().toString(),
    );

    addToCartList([testItem]);

    // Test 4: Load and verify
    print('4. Loading and verifying...');
    List<CartModel> loadedItems = getCartList();
    print('   Loaded ${loadedItems.length} items');

    if (loadedItems.isNotEmpty && loadedItems.first.id == 999) {
      print('✅ CART STORAGE TEST: PASSED');
    } else {
      print('❌ CART STORAGE TEST: FAILED');
    }

    // Clean up
    removeCart();
    sharedPreferences.remove('test_key');
  }
}