import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/single_product_model.dart';
import 'auth/firebase/authenication_repository.dart';

class WishlistController extends GetxController {
  static WishlistController get instance => Get.find();

  final AuthenticationRepository _authRepo = Get.find();

  // Reactive list for wishlist items
  var _wishlistItems = <SingleProductModel>[].obs;
  List<SingleProductModel> get wishlistItems => _wishlistItems;

  // Getter for item count
  int get wishlistCount => _wishlistItems.length;

  // Loading state
  var isLoading = true.obs;

  // Check if wishlist is empty
  bool get isWishlistEmpty => _wishlistItems.isEmpty;

  @override
  void onInit() {
    super.onInit();
    loadWishlist();
  }

  // Load wishlist from Firebase
  Future<void> loadWishlist() async {
    try {
      isLoading(true);
      final wishlist = await _authRepo.getWishlist();
      _wishlistItems.assignAll(wishlist);
      print('✅ Wishlist loaded: ${_wishlistItems.length} items');
    } catch (e) {
      print('❌ Error loading wishlist: $e');
      Get.snackbar(
        'Error',
        'Failed to load wishlist',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  // ADD THIS METHOD: Add to wishlist without checking if it exists
  Future<void> addToWishlist(SingleProductModel product) async {
    try {
      if (product.id == null) {
        throw 'Product ID is required';
      }

      final bool isCurrentlyInWishlist = await _authRepo.isInWishlist(product.id!);

      if (!isCurrentlyInWishlist) {
        // Add to wishlist only if not already there
        await _authRepo.addToWishlist(product);
        _wishlistItems.add(product);

        Get.snackbar(
          'Added to Wishlist',
          '${product.name} added to wishlist',
          backgroundColor: Colors.pink,
          colorText: Colors.white,
        );
      } else {
        print('ℹ️ Product already in wishlist: ${product.name}');
      }

      update(); // Notify listeners

    } catch (e) {
      print('❌ Error adding to wishlist: $e');
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Toggle wishlist item - UPDATED to use Firebase
  Future<void> toggleWishlist(SingleProductModel product) async {
    try {
      if (product.id == null) {
        throw 'Product ID is required';
      }

      final bool isCurrentlyInWishlist = await _authRepo.isInWishlist(product.id!);

      if (isCurrentlyInWishlist) {
        // Remove from wishlist
        await _authRepo.removeFromWishlist(product.id!);
        _wishlistItems.removeWhere((item) => item.id == product.id);

        Get.snackbar(
          'Removed from Wishlist',
          '${product.name} removed from wishlist',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        // Add to wishlist
        await _authRepo.addToWishlist(product);
        _wishlistItems.add(product);

        Get.snackbar(
          'Added to Wishlist',
          '${product.name} added to wishlist',
          backgroundColor: Colors.pink,
          colorText: Colors.white,
        );
      }

      update(); // Notify listeners

    } catch (e) {
      print('❌ Error toggling wishlist: $e');
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Check if a product is in wishlist - UPDATED to use Firebase
  bool isInWishlist(int productId) {
    return _wishlistItems.any((item) => item.id == productId);
  }

  // Clear entire wishlist - UPDATED to use Firebase
  Future<void> clearWishlist() async {
    try {
      isLoading(true);

      // Remove each item from Firebase
      for (final product in _wishlistItems) {
        if (product.id != null) {
          await _authRepo.removeFromWishlist(product.id!);
        }
      }

      _wishlistItems.clear();

      Get.snackbar(
        'Wishlist Cleared',
        'All items removed from wishlist',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

    } catch (e) {
      print('❌ Error clearing wishlist: $e');
      Get.snackbar(
        'Error',
        'Failed to clear wishlist',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  // Real-time wishlist updates
  void startWishlistListener() {
    _authRepo.getWishlistStream().listen((wishlist) {
      _wishlistItems.assignAll(wishlist);
      update();
    });
  }
}