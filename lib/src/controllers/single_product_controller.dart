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

  bool _isFiltering = false;
  bool get isFiltering => _isFiltering;

  bool _filteredListEmpty = false;
  bool get filteredListEmpty => _filteredListEmpty;

  final List<SingleProductModel> _wishlist = [];
  List<SingleProductModel> get wishlist => _wishlist;
  final List<CartItem> _cartItems = [];
  List<CartItem> get cartItems => _cartItems;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  int _quantity = 0;
  int get quantity => _quantity;

  final int _inCartItems = 0;
  int get inCartItems => _inCartItems + _quantity;

  final Map<int, int> _productQuantities = {};

  // ADDED: Better context handling
  BuildContext? get safeContext {
    try {
      return Get.context;
    } catch (e) {
      return null;
    }
  }

  // ADDED: Check if controller is ready to build widgets
  bool get isReady => _isLoaded && safeContext != null && safeContext!.mounted;

  void filterProductsByCategory(int? categoryId, String categoryName) {
    _selectedCategoryId = categoryId;
    _selectedCategoryName = categoryName;
    _isFiltering = categoryId != null;

    if (categoryId == null) {
      _filteredProducts.clear();
      _filteredListEmpty = false;
    } else {
      final categoryService = Get.find<CategoryService>();
      final categoryName = categoryService.getCategoryName(categoryId);

      _filteredProducts = _singleProductList.where((product) {
        return product.category_name == categoryName;
      }).toList();

      _filteredListEmpty = _filteredProducts.isEmpty;

      if (_filteredListEmpty) {
        _showNoProductsPopup(categoryName);
      }
    }
    update();
  }

  void _showNoProductsPopup(String categoryName) {
    if (safeContext == null || !safeContext!.mounted) return;

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
                  SizedBox(
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

  void resetFilter() {
    _selectedCategoryId = null;
    _selectedCategoryName = null;
    _isFiltering = false;
    _filteredListEmpty = false;
    _filteredProducts.clear();
    update();
  }

  bool isCategorySelected(int categoryId) {
    return _selectedCategoryId == categoryId;
  }

  bool isAllSelected() {
    return _selectedCategoryId == null;
  }

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
    final cartController = Get.find<CartController>();
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
    for (var item in _cartItems) {
      if (item.product.price != null) {
        total += item.product.price! * item.quantity;
      }
    }
    return total;
  }

  int getTotalItems() {
    int total = 0;
    for (var item in _cartItems) {
      total += item.quantity;
    }
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
          break;
        }
        await Future.delayed(Duration(seconds: 1));
      }
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
          print("Loaded ${_singleProductList.length} single products");

          if (_selectedCategoryId != null && _selectedCategoryName != null) {
            filterProductsByCategory(_selectedCategoryId, _selectedCategoryName!);
          }

          // Use delayed image preloading to avoid context issues
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_singleProductList.isNotEmpty && safeContext != null && safeContext!.mounted) {
              preloadImagesWithConcurrency(_singleProductList);
            }
          });
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
    if (safeContext == null || !safeContext!.mounted) {
      print("Context not available for image preloading");
      return;
    }

    int maxConcurrentRequests = 3;
    Queue<SingleProductModel> queue = Queue.from(singleProduct);
    List<Future<void>> activeTasks = [];

    Future<void> preloadNext() async {
      if (queue.isEmpty) return;
      final product = queue.removeFirst();

      try {
        if (product.image != null && product.image!.isNotEmpty) {
          final imageUrl = '${AppConstants.BASE_URL}/${product.image!}';
          print("Preloading image: $imageUrl");
          if (safeContext != null && safeContext!.mounted) {
            await precacheImageWithRetry(imageUrl, safeContext!, maxRetries: 2);
          }
        }
      } catch (e) {
        print("Failed to preload image for product ${product.name}: $e");
      }
      if (queue.isNotEmpty) {
        await preloadNext();
      }
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
    if (product.category_name != null && product.category_name!.isNotEmpty) {
      return product.category_name!;
    }

    if (product.category_id != null) {
      if (Get.isRegistered<CategoryService>()) {
        final service = Get.find<CategoryService>();
        if (service.isLoaded) {
          return service.getCategoryName(product.category_id);
        }
      }
    }

    return 'Uncategorized';
  }

  void setQuantity(bool isIncrement) {
    if (isIncrement) {
      _quantity = checkQuantity(_quantity + 1);
    } else {
      _quantity = checkQuantity(_quantity - 1);
    }
    update();
  }

  int checkQuantity(int quantity) {
    if ((_inCartItems + quantity) < 0) {
      Get.snackbar(
        'Item Count',
        'You cant reduce more',
        backgroundColor: AppColors.mainColor,
        colorText: Colors.white,
      );
      if (_inCartItems > 0) {
        _quantity = -_inCartItems;
        return _quantity;
      }
      return 0;
    } else if ((_inCartItems + quantity) > 20) {
      Get.snackbar(
        'Item Count',
        'You cant add more',
        backgroundColor: AppColors.mainColor,
        colorText: Colors.white,
      );
      return 20;
    } else {
      return quantity;
    }
  }
}