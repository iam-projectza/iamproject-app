import 'dart:collection';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/colors.dart';
import '../data/repository/single_product_repo.dart';
import '../helper/services/category_service.dart';
import '../model/single_product_model.dart';
import '../utils/app_constants.dart';
import 'cart_controller.dart';

// Cart Item model
class CartItem {
  final SingleProductModel product;
  final int quantity;

  CartItem({required this.product, required this.quantity});
}

class SingleProductController extends GetxController {
  final SingleProductRepo singleProductRepo;

  SingleProductController({required this.singleProductRepo});

  List<SingleProductModel> _singleProductList = [];
  List<SingleProductModel> get singleProductList => _filteredProducts.isEmpty ? _singleProductList : _filteredProducts;

  List<SingleProductModel> _filteredProducts = [];
  int? _selectedCategoryId;
  String? _selectedCategoryName;

  // ADDED: Track filter status
  bool _isFiltering = false;
  bool get isFiltering => _isFiltering;

  // ADDED: Track if filtered list is empty
  bool _filteredListEmpty = false;
  bool get filteredListEmpty => _filteredListEmpty;

  List<SingleProductModel> _wishlist = [];
  List<SingleProductModel> get wishlist => _wishlist;
  List<CartItem> _cartItems = [];
  List<CartItem> get cartItems => _cartItems;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  int _quantity = 0;
  int get quantity => _quantity;

  int _inCartItems = 0;
  int get inCartItems => _inCartItems + _quantity;

  final Map<int, int> _productQuantities = {};



  // ADDED: Filter methods
  void filterProductsByCategory(int? categoryId, String categoryName) {
    _selectedCategoryId = categoryId;
    _selectedCategoryName = categoryName;
    _isFiltering = categoryId != null;

    if (categoryId == null) {
      // Show all products
      _filteredProducts.clear();
      _filteredListEmpty = false;
    } else {
      // Filter products by category - FIXED: Use category name lookup
      final categoryService = Get.find<CategoryService>();
      final categoryName = categoryService.getCategoryName(categoryId);

      _filteredProducts = _singleProductList.where((product) {
        return product.category_name == categoryName;
      }).toList();

      // Check if filtered list is empty
      _filteredListEmpty = _filteredProducts.isEmpty;

      // Show popup if no products in this category
      if (_filteredListEmpty) {
        _showNoProductsPopup(categoryName);
      }
    }

    update(); // Notify listeners about the change
  }

  // ADDED: Show popup when no products in category
  void _showNoProductsPopup(String categoryName) {
    Get.dialog(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(20),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.iCardBgColor,
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: AssetImage('assets/elements/triangles.png'), // Update with your actual path
                fit: BoxFit.cover,
                opacity: 0.1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () {
                            Get.back();
                            resetFilter();
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.iSecondaryColor.withOpacity(0.8),
                            ),
                            child: Icon(
                              Icons.close,
                              size: 20,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'No Products',
                              style: TextStyle(
                                fontSize: 41,
                                fontWeight: FontWeight.w700,
                                color: AppColors.iWhiteColor,
                                height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Available',
                              style: TextStyle(
                                fontSize: 41,
                                fontWeight: FontWeight.w700,
                                color: AppColors.iWhiteColor,
                                height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Text(
                    'There are no products available in the "$categoryName" category right now.',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textColor,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        resetFilter();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.iSecondaryColor,
                        foregroundColor: AppColors.iWhiteColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        textStyle: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: Text('OK'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // ADDED: Reset filter to show all products
  void resetFilter() {
    _selectedCategoryId = null;
    _selectedCategoryName = null;
    _isFiltering = false;
    _filteredListEmpty = false;
    _filteredProducts.clear();
    update();
  }

  // ADDED: Check if category is selected
  bool isCategorySelected(int categoryId) {
    return _selectedCategoryId == categoryId;
  }

  // ADDED: Check if "All" is selected
  bool isAllSelected() {
    return _selectedCategoryId == null;
  }

  // ADDED: Get current filter status
  int? get selectedCategoryId => _selectedCategoryId;
  String? get selectedCategoryName => _selectedCategoryName;

  bool isInWishlist(SingleProductModel single) {
    return wishlist.contains(single);
  }

  int getProductQuantity(int productId) {
    return _productQuantities[productId] ?? 0;
  }

  void updateProductQuantity(int productId, int quantity) {
    _productQuantities[productId] = quantity;
    update();
  }

  void addToCart(SingleProductModel product, int quantity) {
    // Get the CartController instance
    final cartController = Get.find<CartController>();

    // Use CartController to add the item
    cartController.addItem(product, quantity);

    Get.snackbar(
      'Success',
      'Added $quantity ${product.name} to cart',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );

    update();
  }

  void removeFromCart(int productId) {
    _cartItems.removeWhere((item) => item.product.id == productId);
    update();
  }

  void clearCart() {
    _cartItems.clear();
    update();
  }

  double getTotalPrice() {
    double total = 0;
    _cartItems.forEach((item) {
      if (item.product.price != null) {
        total += item.product.price! * item.quantity;
      }
    });
    return total;
  }

  int getTotalItems() {
    int total = 0;
    _cartItems.forEach((item) {
      total += item.quantity;
    });
    return total;
  }

  Future<void> precacheImageWithRetry(String imageUrl, BuildContext context, {int maxRetries = 2}) async {
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final imageProvider = NetworkImage(imageUrl);
        await precacheImage(imageProvider, context);
        print("Successfully preloaded image: $imageUrl");
        return;
      } catch (e) {
        print("Attempt ${attempt + 1} failed to preload image: $e");
        if (attempt == maxRetries - 1) {
          print("All attempts failed for image: $imageUrl");
          rethrow;
        }
        await Future.delayed(Duration(seconds: 1));
      }
    }
  }

  Future<void> precacheImageWithTimeout(String imageUrl, BuildContext context) async {
    final HttpClient httpClient = HttpClient();
    httpClient.connectionTimeout = const Duration(seconds: 10);

    try {
      final imageProvider = NetworkImage(imageUrl);
      await precacheImage(imageProvider, context);
    } catch (e) {
      print("Failed to preload image: $e");
    } finally {
      httpClient.close();
    }
  }

  @override
  void onInit() {
    super.onInit();
    print("SingleProductController initialized!");
    getSingleProductList();
  }

  Future<void> getSingleProductList() async {
    try {
      print("Fetching single product list...");
      Response response = await singleProductRepo.getSingleProductList();

      if (response.statusCode == 200) {
        var responseData = Map<String, dynamic>.from(response.body);

        if (responseData.containsKey('data')) {
          List<dynamic> dataList = responseData['data'];

          _singleProductList = dataList
              .where((item) => item != null)
              .map<SingleProductModel>((item) => SingleProductModel.fromJson(item))
              .where((product) => product != null)
              .toList();

          _isLoaded = true;
          print("Loaded ${_singleProductList.length} single products:");
          _singleProductList.forEach((product) {
            print('Product: ${product.name}, Category ID: ${product.category_id}, Category Name: ${product.category_name}');
          });

          // ADDED: Reapply current filter after loading new data
          if (_selectedCategoryId != null && _selectedCategoryName != null) {
            filterProductsByCategory(_selectedCategoryId, _selectedCategoryName!);
          }

          if (_singleProductList.isNotEmpty && Get.context != null) {
            await preloadImagesWithConcurrency(_singleProductList);
          }
        } else {
          print("Invalid response structure: 'data' key is missing.");
          _isLoaded = false;
        }
      } else {
        print("Failed to fetch data. Status Code: ${response.statusCode}");
        _isLoaded = false;
      }
    } catch (e) {
      print("Error fetching single product list: $e");
      _isLoaded = false;
    }
    update();
  }

  Future<void> preloadImagesWithConcurrency(List<SingleProductModel> singleProduct) async {
    int maxConcurrentRequests = 3;
    Queue<SingleProductModel> queue = Queue.from(singleProduct);
    List<Future<void>> activeTasks = [];

    Future<void> preloadNext() async {
      if (queue.isEmpty) return;
      final product = queue.removeFirst();

      try {
        if (product.image != null && product.image!.isNotEmpty) {
          final imageUrl = AppConstants.BASE_URL + '/' + product.image!;
          print("Preloading image: $imageUrl");
          if (Get.context != null) {
            await precacheImageWithRetry(imageUrl, Get.context!, maxRetries: 2);
          }
        }
      } catch (e) {
        print("Failed to preload image for product ${product.name}: $e");
      }
      await preloadNext();
    }

    for (int i = 0; i < maxConcurrentRequests && queue.isNotEmpty; i++) {
      activeTasks.add(preloadNext());
    }
    await Future.wait(activeTasks);
  }

  SingleProductModel? getProductByIndex(int index) {
    if (index >= 0 && index < _singleProductList.length) {
      return _singleProductList[index];
    }
    return null;
  }

  CartItem? getCartItem(int productId) {
    try {
      return _cartItems.firstWhere((item) => item.product.id == productId);
    } catch (e) {
      return null;
    }
  }

  void updateCartItemQuantity(int productId, int newQuantity) {
    final index = _cartItems.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      if (newQuantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index] = CartItem(
          product: _cartItems[index].product,
          quantity: newQuantity,
        );
      }
      update();
    }
  }

  bool isInCart(int productId) {
    return _cartItems.any((item) => item.product.id == productId);
  }

  int getCartQuantity(int productId) {
    final item = getCartItem(productId);
    return item?.quantity ?? 0;
  }

  String getCategoryName(SingleProductModel product) {
    try {
      final categoryService = Get.find<CategoryService>();

      // First try to use category_id if available
      if (product.category_id != null) {
        return categoryService.getCategoryName(product.category_id);
      }

      // If category_id is null, try to find ID by category name
      if (product.category_name != null) {
        final categoryId = categoryService.getCategoryIdByName(product.category_name);
        if (categoryId != null) {
          return categoryService.getCategoryName(categoryId);
        }
      }

      return 'Uncategorized';
    } catch (e) {
      print("Error getting category name: $e");
      return 'Loading...';
    }
  }

  void setQuantity(bool isIncrement){
    if(isIncrement){
      _quantity = checkQuantity(_quantity +1);
      //print('number if items '+_quantity.toString());
    }else{
      _quantity = checkQuantity(_quantity -1);
      //print('decrement '+_quantity.toString());
    }
    update();
  }
  int checkQuantity(int quantity){
    if((_inCartItems+quantity)<0){
      Get.snackbar('Item Count', 'You cant reduce more',
        backgroundColor: AppColors.mainColor,
        colorText: Colors.white,
      );
      if(_inCartItems>0){
        _quantity = -_inCartItems;
        return _quantity;
      }
      return 0;
    } else if ((_inCartItems+quantity)>20){
      Get.snackbar('Item Count', 'You cant add more',
        backgroundColor: AppColors.mainColor,
        colorText: Colors.white,
      );
      return 20;
    } else {
      return quantity;
    }
  }
}