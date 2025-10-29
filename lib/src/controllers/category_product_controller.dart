import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/colors.dart';
import '../data/repository/category_product_repo.dart';

import '../helper/services/category_service.dart';
import '../model/category_product_model.dart';
import '../routes/route_helper.dart';
import '../utils/app_constants.dart';

class CategoryProductController extends GetxController {
  final CategoryProductRepo categoryProductRepo;

  CategoryProductController({required this.categoryProductRepo});

  List<CategoryModel> _categoryProductList = [];
  List<CategoryModel> get categoryProductList => _categoryProductList;

  final List<CategoryModel> _wishlist = [];
  List<CategoryModel> get wishlist => _wishlist;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  final int _quantity = 0;
  int get quantity => _quantity;

  final int _inCartItems = 0;
  int get inCartItems => _inCartItems + _quantity;

  bool isInWishlist(CategoryModel category) {
    return wishlist.contains(category);
  }

  Future<void> precacheImageWithTimeout(String imageUrl, BuildContext context) async {
    final HttpClient httpClient = HttpClient();
    httpClient.connectionTimeout = const Duration(seconds: 60);
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
    print("CategoryProductController initialized!");
    getCategoryProductList();
  }

  Future<void> getCategoryProductList() async {
    try {
      print("Fetching category product list...");
      Response response = await categoryProductRepo.getCategoryProductList();

      if (response.statusCode == 200) {
        var responseData = Map<String, dynamic>.from(response.body);

        if (responseData.containsKey('data')) {
          List<dynamic> dataList = responseData['data'];

          _categoryProductList = dataList
              .map((item) => CategoryModel.fromJson(item))
              .toList();

          _isLoaded = true;

          // ADD THIS: Load categories into the service
          final categoryService = Get.find<CategoryService>();
          categoryService.loadCategories(_categoryProductList);

          await preloadImagesWithConcurrency(_categoryProductList);
        } else {
          print("Invalid response structure: 'data' key is missing.");
          _isLoaded = false;
        }
      } else {
        print("Failed to fetch data. Status Code: ${response.statusCode}");
        _isLoaded = false;
      }
    } catch (e) {
      print("Error fetching category product list: $e");
      _isLoaded = false;
    }
    update();
  }

  Future<void> preloadImagesWithConcurrency(List<CategoryModel> categoryProducts) async {
    int maxConcurrentRequests = 3;
    Queue<CategoryModel> queue = Queue.from(categoryProducts);
    List<Future<void>> activeTasks = [];

    Future<void> preloadNext() async {
      if (queue.isEmpty) return;
      final product = queue.removeFirst();

      try {
        if (product.image != null && product.image!.isNotEmpty) {
          final imageUrl = '${AppConstants.BASE_URL}/${product.image!}';
          print("Preloading image: $imageUrl");
          await precacheImageWithRetry(imageUrl, Get.context!);
        }
      } catch (e) {
        print(" Failed to preload image: $e");
      }
      await preloadNext();
    }

    for (int i = 0; i < maxConcurrentRequests && queue.isNotEmpty; i++) {
      activeTasks.add(preloadNext());
    }
    await Future.wait(activeTasks);
  }

  Future<void> precacheImageWithRetry(String imageUrl, BuildContext context) async {
    int retries = 3;
    while (retries > 0) {
      try {
        final imageProvider = NetworkImage(imageUrl);
        await precacheImage(imageProvider, context);
        print("Successfully preloaded image: $imageUrl");
        return;
      } catch (e) {
        retries--;
        if (retries == 0) {
          print(" Failed to preload image after multiple attempts: $imageUrl");
        } else {
          print(" Retrying image preload ($retries attempts left): $imageUrl");
          await Future.delayed(Duration(milliseconds: 500));
        }
      }
    }
  }

  void addToWishlist(CategoryModel product) {
    if (!_wishlist.contains(product)) {
      _wishlist.add(product);
      Get.snackbar(
        'Wishlist',
        'Item added to wishlist!',
        backgroundColor: AppColors.mainColor,
        colorText: Colors.white,
      );
      update();
      Get.toNamed(RouteHelper.getInitialPage());
    } else {
      Get.snackbar(
        'Wishlist',
        'Item already in wishlist!',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}