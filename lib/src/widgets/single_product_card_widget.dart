import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/colors.dart';
import '../controllers/cart_controller.dart';
import '../controllers/single_product_controller.dart';
import '../controllers/wishlist_controller.dart';
import '../helper/services/category_service.dart';
import '../model/single_product_model.dart';
import '../routes/route_helper.dart';
import '../utils/app_constants.dart';
import '../utils/dimensions.dart';

class SingleProductCard extends StatelessWidget {
  final SingleProductModel product;
  final SingleProductController controller;
  final bool isLoading;

  const SingleProductCard({
    super.key,
    required this.product,
    required this.controller,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final width20 = Dimensions.width20 ?? 20.0;
    final height15 = Dimensions.height15 ?? 15.0;
    final height10 = Dimensions.height10 ?? 10.0;
    final radius20 = Dimensions.radius20 ?? 20.0;

    if (isLoading) {
      return _buildShimmerCard(width20, height15, height10, radius20);
    }

    return _buildProductCard(context, width20, height15, height10, radius20);
  }

  Widget _buildShimmerCard(double width20, double height15, double height10, double radius20) {
    return Container(
      margin: EdgeInsets.only(bottom: height15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.grey[100]!,
        child: Padding(
          padding: EdgeInsets.all(width20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius20),
                  color: Colors.grey[300],
                ),
              ),
              SizedBox(height: height15),
              Container(width: 150, height: 22, color: Colors.white),
              SizedBox(height: height10),
              Container(width: double.infinity, height: 16, color: Colors.white),
              SizedBox(height: height15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(width: 16, height: 16, color: Colors.grey[300]),
                      SizedBox(width: 4),
                      Container(width: 30, height: 16, color: Colors.white),
                    ],
                  ),
                  Container(width: 70, height: 20, color: Colors.white),
                ],
              ),
              SizedBox(height: height15),
              Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, double width20, double height15, double height10, double radius20) {
    final mainColor = AppColors.mainColor ?? Colors.orange;
    final cardBgColor = AppColors.iCardBgColor ?? const Color(0xFFF8F9FA);
    final secondaryColor = AppColors.iSecondaryColor ?? const Color(0xFF2196F3);
    final whiteColor = AppColors.white ?? Colors.white;
    final textColor = AppColors.textColor ?? const Color(0xFF666666);
    final accentColor = AppColors.iAccentColor ?? const Color(0xFF4CAF50);
    final primaryColor = AppColors.iPrimaryColor ?? const Color(0xFF1A1A1A);

    return GetBuilder<WishlistController>(
      init: WishlistController(), // ✅ Safe fallback
      builder: (wishlistController) {
        final bool isWishlisted = product.id != null && wishlistController.isInWishlist(product.id!);

        return Container(
          margin: EdgeInsets.only(bottom: height15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(radius20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(
                context,
                isWishlisted,
                wishlistController,
                radius20,
                cardBgColor,
                secondaryColor,
                mainColor,
                whiteColor,
              ),
              _buildDetailsSection(
                context,
                width20,
                height10,
                height15,
                radius20,
                product,
                controller,
                secondaryColor,
                whiteColor,
                textColor,
                accentColor,
                primaryColor,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageSection(
      BuildContext context,
      bool isWishlisted,
      WishlistController wishlistController,
      double radius20,
      Color cardBgColor,
      Color secondaryColor,
      Color mainColor,
      Color whiteColor,
      ) {
    String? imageUrl;
    final rawImage = product.image;
    // ✅ Prevent "null" string and empty values
    if (rawImage != null &&
        rawImage.isNotEmpty &&
        rawImage != 'null' &&
        rawImage.trim() != '') {
      if (rawImage.startsWith('http')) {
        imageUrl = rawImage;
      } else if (AppConstants.BASE_URL != null) {
        imageUrl = '${AppConstants.BASE_URL}/$rawImage';
      }
    }

    // Check if product is out of stock
    final bool isOutOfStock = (product.stock ?? 0) <= 0;

    return GestureDetector(
      onTap: () => Get.toNamed(RouteHelper.getSingleProduct(product.id ?? 0, 'home')),
      child: Container(
        width: double.infinity,
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(radius20),
            topRight: Radius.circular(radius20),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              cardBgColor.withOpacity(0.1),
              cardBgColor.withOpacity(0.05),
            ],
          ),
        ),
        child: Stack(
          children: [
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(radius20),
                  topRight: Radius.circular(radius20),
                ),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                        strokeWidth: 2,
                        color: secondaryColor,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(child: Icon(Icons.fastfood, color: mainColor, size: 60));
                  },
                ),
              )
            else
              Center(child: Icon(Icons.fastfood, color: mainColor, size: 60)),

            // Out of Stock Overlay
            if (isOutOfStock)
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(radius20),
                    topRight: Radius.circular(radius20),
                  ),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'OUT OF STOCK',
                      style: TextStyle(
                        color: whiteColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),

            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [secondaryColor, secondaryColor.withOpacity(0.8)]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: secondaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text('🔥 Popular', style: TextStyle(color: whiteColor, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ),

            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text('4.7', style: TextStyle(color: whiteColor, fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),

            // Stock Badge
            Positioned(
              bottom: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isOutOfStock ? Colors.red : Colors.green,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  isOutOfStock ? 'Out of Stock' : 'In Stock',
                  style: TextStyle(
                    color: whiteColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            // Wishlist Button - Always enabled even when out of stock
            // Wishlist Button - Updated to use the proper controller
            Positioned(
              bottom: 12,
              right: 12,
              child: GestureDetector(
                onTap: () {
                  if (product.id != null) {
                    // Use the main WishlistController instance
                    final wishlistController = Get.find<WishlistController>();
                    wishlistController.toggleWishlist(product);
                  }
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: whiteColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Obx(() {
                    final wishlistController = Get.find<WishlistController>();
                    final bool isWishlisted = product.id != null &&
                        wishlistController.isInWishlist(product.id!);

                    return Icon(
                      isWishlisted ? Icons.favorite : Icons.favorite_border,
                      color: isWishlisted ? Colors.red : Colors.grey[600],
                      size: 20,
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection(
      BuildContext context,
      double width20,
      double height10,
      double height15,
      double radius20,
      SingleProductModel product,
      SingleProductController controller,
      Color secondaryColor,
      Color whiteColor,
      Color textColor,
      Color accentColor,
      Color primaryColor,
      ) {
    // Check if product is out of stock
    final bool isOutOfStock = (product.stock ?? 0) <= 0;

    return Container(
      padding: EdgeInsets.all(width20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, primaryColor],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(radius20),
          bottomRight: Radius.circular(radius20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name ?? 'Premium Product',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: whiteColor, height: 1.3),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: height10),

          // Stock information
          if (isOutOfStock)
            Container(
              margin: EdgeInsets.only(bottom: height10),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Currently unavailable',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          Text(
            product.description ?? 'Exquisite culinary experience crafted with premium ingredients',
            style: TextStyle(
              fontSize: Dimensions.font16 ?? 16.0,
              color: whiteColor.withOpacity(0.8),
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: height15),
          _buildCategoryTag(controller, product, accentColor),
          SizedBox(height: height15),
          _buildPriceAndCartRow(product, secondaryColor, whiteColor, textColor),
        ],
      ),
    );
  }

  Widget _buildCategoryTag(SingleProductController controller, SingleProductModel product, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.3), width: 1),
      ),
      child: GetBuilder<CategoryService>(
        init: CategoryService(), // ✅ Safe fallback since it's a GetxController
        builder: (categoryService) {
          final categoryName = controller.getCategoryName(product);
          return Text(
            categoryName,
            style: TextStyle(fontSize: 12, color: accentColor, fontWeight: FontWeight.w600),
          );
        },
      ),
    );
  }

  Widget _buildPriceAndCartRow(
      SingleProductModel product,
      Color secondaryColor,
      Color whiteColor,
      Color textColor,
      ) {
    // Check if product is out of stock
    final bool isOutOfStock = (product.stock ?? 0) <= 0;
    final bool canAddToCart = !isOutOfStock;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price',
              style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.7), fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              'R${(product.price ?? 0).toStringAsFixed(2)}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: secondaryColor),
            ),
            // Stock quantity display
            if (!isOutOfStock && (product.stock ?? 0) > 0)
              Container(
                margin: EdgeInsets.only(top: 4),
                child: Text(
                  '${product.stock} in stock',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        GestureDetector(
          onTap: canAddToCart
              ? () {
            if (Get.isRegistered<CartController>()) {
              try {
                final cartController = Get.find<CartController>();
                cartController.addItem(product, 1);
                Get.snackbar(
                  'Added to Cart',
                  '${product.name ?? "Product"} added to cart',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } catch (e) {
                Get.snackbar('Error', 'Failed to add item', backgroundColor: Colors.red, colorText: Colors.white);
              }
            } else {
              Get.snackbar('Error', 'Cart not ready', backgroundColor: Colors.red, colorText: Colors.white);
            }
          }
              : null, // Disable tap when out of stock
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              gradient: canAddToCart
                  ? LinearGradient(colors: [secondaryColor, secondaryColor.withOpacity(0.8)])
                  : LinearGradient(colors: [Colors.grey, Colors.grey.withOpacity(0.6)]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.add_shopping_cart_rounded,
                  color: canAddToCart ? whiteColor : Colors.grey[300],
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  canAddToCart ? 'Add to Cart' : 'Out of Stock',
                  style: TextStyle(
                    color: canAddToCart ? whiteColor : Colors.grey[300],
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}