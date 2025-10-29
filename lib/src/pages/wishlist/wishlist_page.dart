// lib/src/pages/wishlist/wishlist_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import '../../constants/colors.dart';
import '../../controllers/wishlist_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../model/single_product_model.dart';
import '../../routes/route_helper.dart';
import '../../utils/app_constants.dart';
import '../../utils/dimensions.dart';
import '../../widgets/big_text.dart';
import '../../widgets/small_text.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: BigText(
          text: 'My Wishlist',
          color: AppColors.mainBlackColor ?? Colors.black,
          size: 20,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: AppColors.mainBlackColor ?? Colors.black,
        ),
      ),
      body: GetBuilder<WishlistController>(
        builder: (wishlistController) {
          if (wishlistController.isLoading.value) {
            return _buildLoadingState();
          }

          if (wishlistController.isWishlistEmpty) {
            return _buildEmptyState();
          }

          return _buildWishlistItems(wishlistController);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.iSecondaryColor ?? Colors.blue,
          ),
          Gap(Dimensions.height20 ?? 20),
          SmallText(text: 'Loading your wishlist...'),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey[400],
          ),
          Gap(Dimensions.height20 ?? 20),
          BigText(
            text: 'Your wishlist is empty',
            color: Colors.grey[600],
            size: 18,
          ),
          Gap(Dimensions.height10 ?? 10),
          SmallText(
            text: 'Start adding products you love!',
            color: Colors.grey[500],
          ),
          Gap(Dimensions.height30 ?? 30),
          ElevatedButton(
            onPressed: () {
              Get.offAllNamed(RouteHelper.getInitialPage());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.iSecondaryColor ?? Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width20 ?? 20,
                vertical: Dimensions.height15 ?? 15,
              ),
            ),
            child: Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistItems(WishlistController wishlistController) {
    final width20 = Dimensions.width20 ?? 20.0;
    final height15 = Dimensions.height15 ?? 15.0;
    final height10 = Dimensions.height10 ?? 10.0;

    return Column(
      children: [
        // Header with item count
        Container(
          padding: EdgeInsets.symmetric(horizontal: width20, vertical: height15),
          color: Colors.grey[50],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SmallText(
                text: '${wishlistController.wishlistCount} items',
                color: Colors.grey[600],
              ),
              if (wishlistController.wishlistCount > 0)
                TextButton(
                  onPressed: () {
                    _showClearWishlistDialog(wishlistController);
                  },
                  child: SmallText(
                    text: 'Clear All',
                    color: Colors.red,
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(width20),
            itemCount: wishlistController.wishlistItems.length,
            itemBuilder: (context, index) {
              final product = wishlistController.wishlistItems[index];
              return _buildWishlistItem(product, wishlistController, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWishlistItem(
      SingleProductModel product, WishlistController wishlistController, int index) {
    final width20 = Dimensions.width20 ?? 20.0;
    final height15 = Dimensions.height15 ?? 15.0;
    final height10 = Dimensions.height10 ?? 10.0;
    final radius15 = Dimensions.radius15 ?? 15.0;

    // Check if product is out of stock
    final bool isOutOfStock = (product.stock ?? 0) <= 0;
    final bool canAddToCart = !isOutOfStock;

    // Safe image URL construction
    String? imageUrl;
    final rawImage = product.image;
    if (rawImage != null && rawImage.isNotEmpty && rawImage != 'null') {
      if (rawImage.startsWith('http')) {
        imageUrl = rawImage;
      } else {
        imageUrl = '${AppConstants.BASE_URL}/$rawImage';
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: height15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image
          GestureDetector(
            onTap: () => Get.toNamed(RouteHelper.getSingleProduct(product.id ?? 0, 'wishlist')),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(radius15),
                  bottomLeft: Radius.circular(radius15),
                ),
                color: Colors.grey[100],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(radius15),
                  bottomLeft: Radius.circular(radius15),
                ),
                child: Stack(
                  children: [
                    imageUrl != null
                        ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.fastfood,
                          color: Colors.grey[400],
                          size: 40,
                        );
                      },
                    )
                        : Icon(
                      Icons.fastfood,
                      color: Colors.grey[400],
                      size: 40,
                    ),
                    // Out of stock overlay
                    if (isOutOfStock)
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.black.withOpacity(0.5),
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'OUT OF STOCK',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(width20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name ?? 'Product Name',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mainBlackColor ?? Colors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          wishlistController.toggleWishlist(product);
                        },
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap(height10),
                  Text(
                    product.description ?? 'Product description',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Gap(height10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'R${(product.price ?? 0).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.iSecondaryColor ?? Colors.blue,
                            ),
                          ),
                          // Stock information
                          if (isOutOfStock)
                            Text(
                              'Out of Stock',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          else if (product.stock != null && product.stock! > 0)
                            Text(
                              '${product.stock} in stock',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                      // Add to Cart Button - Only show if product is in stock
                      if (canAddToCart)
                        ElevatedButton(
                          onPressed: () {
                            _addToCart(product);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.iSecondaryColor ?? Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Add to Cart',
                            style: TextStyle(fontSize: 12),
                          ),
                        )
                      else
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Out of Stock',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // FIXED: Proper Add to Cart functionality
// In WishlistPage - Update the _addToCart method
  void _addToCart(SingleProductModel product) {
    try {
      print('\n🎯 ATTEMPTING TO ADD TO CART FROM WISHLIST:');
      print('   Product: ${product.name}');
      print('   Product ID: ${product.id}');
      print('   Stock: ${product.stock}');

      // Check if CartController is registered
      if (!Get.isRegistered<CartController>()) {
        print('❌ CartController not registered!');
        Get.snackbar(
          'Error',
          'Cart service not available. Please restart the app.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final cartController = Get.find<CartController>();

      // Debug current cart state
      cartController.debugCartState();

      // Check if product is in stock
      if ((product.stock ?? 0) <= 0) {
        print('❌ Product is out of stock');
        Get.snackbar(
          'Out of Stock',
          '${product.name} is currently out of stock',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      print('✅ Adding item to cart...');

      // Add item to cart
      cartController.addItem(product, 1);

      // Verify it was added
      Future.delayed(Duration(milliseconds: 500), () {
        cartController.debugCartState();
      });

    } catch (e) {
      print('❌ ERROR in _addToCart: $e');
      Get.snackbar(
        'Error',
        'Failed to add item to cart: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  void _showClearWishlistDialog(WishlistController wishlistController) {
    Get.dialog(
      AlertDialog(
        title: Text('Clear Wishlist'),
        content: Text('Are you sure you want to remove all items from your wishlist?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: AppColors.iSecondaryColor)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              wishlistController.clearWishlist();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text('Clear All'),
          ),
        ],
      ),
    );
  }
}