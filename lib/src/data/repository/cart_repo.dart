import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';
import '../../model/cart_model.dart'; // Fixed import path

class CartRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  CartRepo({required this.apiClient, required this.sharedPreferences});

  // Get current user ID for storage keys
  String get _userKey {
    final userId = sharedPreferences.getString('current_user_id') ?? 'anonymous';
    return 'cart_$userId';
  }

  String get _cartHistoryKey {
    final userId = sharedPreferences.getString('current_user_id') ?? 'anonymous';
    return 'cart_history_$userId';
  }

  // Add to cart list - USER SPECIFIC
  Future<void> addToCartList(List<CartModel> cartList) async {
    try {
      List<String> carts = [];
      for (var cart in cartList) {
        carts.add(cart.toJson()); // This should return String
      }
      await sharedPreferences.setStringList(_userKey, carts);
      print('🛒 Cart saved for user: ${_userKey}');
      print('   Items saved: ${cartList.length}');
    } catch (e) {
      print('❌ Error saving cart: $e');
      throw e;
    }
  }

  // Get cart list - USER SPECIFIC
  List<CartModel> getCartList() {
    List<String> carts = [];
    if (sharedPreferences.containsKey(_userKey)) {
      carts = sharedPreferences.getStringList(_userKey)!;
    }
    List<CartModel> cartList = [];

    for (var cart in carts) {
      cartList.add(CartModel.fromJson(cart)); // This should accept String
    }
    print('🛒 Cart loaded for user: ${_userKey}');
    print('   Items loaded: ${cartList.length}');
    return cartList;
  }

  // Add to cart history - USER SPECIFIC
  Future<void> addToCartHistoryList() async {
    try {
      if (sharedPreferences.containsKey(_userKey)) {
        // Get current cart
        List<String> currentCart = sharedPreferences.getStringList(_userKey)!;

        // Get existing history
        List<String> history = [];
        if (sharedPreferences.containsKey(_cartHistoryKey)) {
          history = sharedPreferences.getStringList(_cartHistoryKey)!;
        }

        // Add current cart to history
        history.addAll(currentCart);

        // Save updated history
        await sharedPreferences.setStringList(_cartHistoryKey, history);

        print('📦 Cart history saved for user: ${_cartHistoryKey}');
        print('   History items: ${history.length}');
      }
    } catch (e) {
      print('❌ Error saving cart history: $e');
      throw e;
    }
  }

  // Get cart history - USER SPECIFIC
  List<CartModel> getCartHistoryList() {
    List<String> history = [];
    if (sharedPreferences.containsKey(_cartHistoryKey)) {
      history = sharedPreferences.getStringList(_cartHistoryKey)!;
    }
    List<CartModel> historyList = [];

    for (var item in history) {
      historyList.add(CartModel.fromJson(item)); // This should accept String
    }
    print('📦 Cart history loaded for user: ${_cartHistoryKey}');
    print('   History items: ${historyList.length}');
    return historyList;
  }

  // Clear cart history - USER SPECIFIC
  void clearCartHistory() {
    sharedPreferences.remove(_cartHistoryKey);
    print('🗑️ Cart history cleared for user: ${_cartHistoryKey}');
  }

  // Clear current cart - USER SPECIFIC
  void clearCart() {
    sharedPreferences.remove(_userKey);
    print('🗑️ Cart cleared for user: ${_userKey}');
  }
}