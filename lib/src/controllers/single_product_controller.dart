import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/repository/single_product_repo.dart';
import '../model/single_product_model.dart';
import '../utils/app_constants.dart';

class SingleProductController extends GetxController {
  final SingleProductRepo singleProductRepo;

  SingleProductController({required this.singleProductRepo});

  List<SingleProductModel> _singleProductList = [];
  List<SingleProductModel> get singleProductList => _singleProductList;
  List<SingleProductModel> _wishlist = [];
  List<SingleProductModel> get wishlist => _wishlist;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  int _quantity = 0;
  int get quantity => _quantity;

  int _inCartItems = 0;
  int get inCartItems => _inCartItems + _quantity;

  bool isInWishlist(SingleProductModel single) {
    return wishlist.contains(single);
  }

  // ADDED: precacheImageWithRetry method that was missing
  Future<void> precacheImageWithRetry(String imageUrl, BuildContext context, {int maxRetries = 2}) async {
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final imageProvider = NetworkImage(imageUrl);
        await precacheImage(imageProvider, context);
        print("Successfully preloaded image: $imageUrl");
        return; // Success, exit the function
      } catch (e) {
        print("Attempt ${attempt + 1} failed to preload image: $e");
        if (attempt == maxRetries - 1) {
          print("All attempts failed for image: $imageUrl");
          rethrow;
        }
        await Future.delayed(Duration(seconds: 1)); // Wait before retry
      }
    }
  }

  Future<void> precacheImageWithTimeout(String imageUrl, BuildContext context) async {
    final HttpClient httpClient = HttpClient();
    httpClient.connectionTimeout = const Duration(seconds: 10); // Reduced timeout

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

          // FIXED: Added null safety for each item
          _singleProductList = dataList
              .where((item) => item != null) // Filter out null items
              .map<SingleProductModel>((item) => SingleProductModel.fromJson(item))
              .where((product) => product != null) // Filter out null products
              .toList();

          _isLoaded = true;
          print("Loaded ${_singleProductList.length} products");

          // Preload images only if we have products and context is available
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

    update(); // Notify UI
  }

  /// Preloads images with retry logic and limits concurrent requests
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
          // FIXED: Removed null assertion and added null check
          if (Get.context != null) {
            await precacheImageWithRetry(imageUrl, Get.context!, maxRetries: 2);
          }
        }
      } catch (e) {
        print("Failed to preload image for product ${product.name}: $e");
      }

      await preloadNext();
    }

    // Start up to [maxConcurrentRequests] preload tasks
    for (int i = 0; i < maxConcurrentRequests && queue.isNotEmpty; i++) {
      activeTasks.add(preloadNext());
    }

    // Wait until all tasks are finished
    await Future.wait(activeTasks);
  }

  // ADDED: Helper method to get product by index with bounds checking
  SingleProductModel? getProductByIndex(int index) {
    if (index >= 0 && index < _singleProductList.length) {
      return _singleProductList[index];
    }
    return null;
  }
}