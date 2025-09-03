
import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/colors.dart';
import '../data/repository/category_product_repo.dart';
import '../model/category_product_model.dart';
import '../routes/route_helper.dart';
import '../utils/app_constants.dart';
import '../utils/precache_image_with_timeout.dart';
import 'package:async/async.dart' as async_package;
class CategoryProductController extends GetxController {
  final CategoryProductRepo categoryProductRepo;

  CategoryProductController({required this.categoryProductRepo});

  //FIXED: Use correct type here
  List<CategoryModel> _categoryProductList = [];
  List<CategoryModel> get categoryProductList => _categoryProductList;

  List<CategoryModel> _wishlist = [];
  List<CategoryModel> get wishlist => _wishlist;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  int _quantity = 0;
  int get quantity => _quantity;

  int _inCartItems = 0;
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

          //FIXED: Assigning correctly to List<CategoryModel>
          _categoryProductList = dataList
              .map((item) => CategoryModel.fromJson(item))
              .toList();

          _isLoaded = true;

          // Preload images with concurrency
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

    update(); // Notify UI
  }



  /// Preloads images with retry logic and limits concurrent requests
  Future<void> preloadImagesWithConcurrency(List<CategoryModel> categoryProducts) async {
    int maxConcurrentRequests = 3; // Reduced from 5 to 3
    Queue<CategoryModel> queue = Queue.from(categoryProducts);
    List<Future<void>> activeTasks = [];

    Future<void> preloadNext() async {
      if (queue.isEmpty) return;

      final product = queue.removeFirst();

      try {
        if (product.image != null && product.image!.isNotEmpty) {
          final imageUrl = AppConstants.BASE_URL + '/' + product.image!;
          print("Preloading image: $imageUrl");
          await precacheImageWithRetry(imageUrl, Get.context!);
        }
      } catch (e) {
        print(" Failed to preload image: $e");
      }

      await preloadNext(); // Recursively go to the next image
    }

    // Start up to [maxConcurrentRequests] preload tasks
    for (int i = 0; i < maxConcurrentRequests && queue.isNotEmpty; i++) {
      activeTasks.add(preloadNext());
    }

    // Wait until all tasks are finished
    await Future.wait(activeTasks);
  }


  Future<void> precacheImageWithRetry(String imageUrl, BuildContext context) async {
    int retries = 3; // Maximum number of retries
    while (retries > 0) {
      try {
        final imageProvider = NetworkImage(imageUrl);
        await precacheImage(imageProvider, context);
        print("Successfully preloaded image: $imageUrl");
        return; // Exit if successful
      } catch (e) {
        retries--;
        if (retries == 0) {
          print(" Failed to preload image after multiple attempts: $imageUrl");
        } else {
          print(" Retrying image preload ($retries attempts left): $imageUrl");
          await Future.delayed(Duration(milliseconds: 500)); // Add a small delay before retrying
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
