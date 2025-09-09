import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/colors.dart';
import '../controllers/single_product_controller.dart';
import '../helper/services/category_service.dart';
import '../model/single_product_model.dart';
import '../routes/route_helper.dart';
import '../utils/app_constants.dart';
import '../utils/dimensions.dart';
import 'big_text.dart';
import 'small_text.dart';

class SingleProductCard extends StatelessWidget {
  final SingleProductModel product;
  final SingleProductController controller;
  final bool isLoading;

  const SingleProductCard({
    Key? key,
    required this.product,
    required this.controller,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use getters directly since Dimensions now uses getters
    final width20 = Dimensions.width20;
    final height15 = Dimensions.height15;
    final height10 = Dimensions.height10;
    final radius15 = Dimensions.radius15;
    final listViewImgSize = Dimensions.listViewImgSize;
    final iconSize24 = Dimensions.iconSize24;
    final font16 = Dimensions.font16;
    final font14 = Dimensions.font16;

    // If loading, show shimmer effect
    if (isLoading) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: Dimensions.height15,
          right: Dimensions.width10,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius15),
          boxShadow: [
            BoxShadow(
              color: (AppColors.iSecondaryColor ?? Colors.orange).withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Popular tag and category shimmer
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    margin: EdgeInsets.only(left: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Container(
                      width: 60,
                      height: 14,
                      color: Colors.white,
                    ),
                  ),
                  Gap(15),
                  Container(
                    width: 80,
                    height: 14,
                    color: Colors.white,
                  ),
                ],
              ),
              Gap(height10),

              // Product row (image + details) shimmer
              Row(
                children: [
                  // Product Image shimmer
                  Container(
                    width: listViewImgSize,
                    height: listViewImgSize,
                    margin: EdgeInsets.all(Dimensions.width10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(radius15),
                      color: Colors.grey[300],
                    ),
                  ),

                  // Product Details shimmer
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: Dimensions.height10,
                        horizontal: Dimensions.width10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Restaurant Name shimmer
                          Container(
                            width: 150,
                            height: 18,
                            color: Colors.white,
                          ),
                          Gap(height10),

                          // Subtitle shimmer
                          Container(
                            width: double.infinity,
                            height: 14,
                            color: Colors.white,
                          ),
                          Gap(height10),

                          // Rating, Delivery Info, Wishlist Icon shimmer
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Rating + Delivery shimmer
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey[300],
                                      ),
                                    ),
                                    Gap(width20 / 4),
                                    Container(
                                      width: 20,
                                      height: 14,
                                      color: Colors.white,
                                    ),
                                    Gap(width20 / 2),
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey[300],
                                      ),
                                    ),
                                    Gap(width20 / 4),
                                    Container(
                                      width: 40,
                                      height: 14,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),

                              // Wishlist Button shimmer
                              Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey[300],
                                    ),
                                  ),
                                  Gap(width20 / 4),
                                  Container(
                                    width: 50,
                                    height: 14,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Tags container at the bottom shimmer
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(radius15),
                    bottomRight: Radius.circular(radius15),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Add to Cart Button with Counter shimmer
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 28, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                          Gap(8),
                          Container(
                            width: 60,
                            height: 14,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),

                    // Price Display shimmer
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Container(
                        width: 60,
                        height: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Mock rating and delivery time
    final double rating = 4.7;
    final String deliveryTime = "20 min";

    // Check if image URL is already complete or needs base URL
    String? imageUrl;
    if (product.image != null && product.image!.isNotEmpty) {
      if (product.image!.startsWith('http')) {
        imageUrl = product.image; // Already full URL
      } else {
        imageUrl = '${AppConstants.BASE_URL}/${product.image!}'; // Construct URL
      }
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: Dimensions.height15,
        right: Dimensions.width10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius15),
        boxShadow: [
          BoxShadow(
            color: (AppColors.iSecondaryColor ?? Colors.orange).withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                margin: EdgeInsets.only(left: 20),
                decoration: BoxDecoration(
                  color: AppColors.orangeColor ?? Colors.orange,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: BigText(
                  text: 'Popular',
                  size: 14,
                  color: AppColors.mainBlackColor ?? Colors.black,
                ),
              ),
              Gap(15),
              // Show category name instead of hardcoded text
              GetBuilder<CategoryService>(
                builder: (categoryService) {
                  final categoryName = controller.getCategoryName(product);
                  return SmallText(
                    text: categoryName,
                    size: 14,
                    color: AppColors.textColor ?? Colors.black54,
                  );
                },
              ),
            ],
          ),
          Gap(height10),

          // Product row (image + details)
          Row(
            children: [
              // Product Image with GestureDetector
              GestureDetector(
                onTap: () => Get.toNamed(RouteHelper.getSingleProduct(product.id!, 'home')),
                child: Container(
                  width: listViewImgSize,
                  height: listViewImgSize,
                  margin: EdgeInsets.all(Dimensions.width10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radius15),
                    color: (AppColors.darkColor ?? Colors.grey).withOpacity(0.1),
                    image: imageUrl != null
                        ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: imageUrl == null
                      ? Icon(
                    Icons.fastfood,
                    color: AppColors.mainColor ?? Colors.orange,
                    size: iconSize24,
                  )
                      : null,
                ),
              ),
              // Product Details
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: Dimensions.height10,
                    horizontal: Dimensions.width10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Restaurant Name
                      BigText(
                        text: product.name ?? 'Unknown Restaurant',
                        size: 18,
                      ),
                      Gap(height10),
                      // Subtitle (Categories)
                      SmallText(
                        text: product.description ?? 'No categories available',
                        size: font14,
                        color: AppColors.textColor ?? Colors.black54,
                      ),
                      Gap(height10),
                      // Rating, Delivery Info, Wishlist Icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Rating + Delivery
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: AppColors.iSecondaryColor ?? Colors.orange,
                                  size: iconSize24,
                                ),
                                Gap(width20 / 4),
                                SmallText(
                                  text: rating.toString(),
                                  size: font14,
                                ),
                                Gap(width20 / 2),
                                Icon(
                                  Icons.local_shipping,
                                  color: AppColors.iPrimaryColor ?? Colors.orange,
                                  size: iconSize24,
                                ),
                                Gap(width20 / 4),
                                Expanded(
                                  child: SmallText(
                                    text: deliveryTime,
                                    size: font14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Wishlist Button
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  // controller.addToWishlist(product);
                                },
                                child: Icon(
                                  Icons.favorite_border,
                                  color: AppColors.orangeColor ?? Colors.red,
                                  size: iconSize24,
                                ),
                              ),
                              Gap(width20 / 4),
                              SmallText(
                                text: 'Wishlist',
                                size: font14,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Tags container at the bottom
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(radius15),
                bottomRight: Radius.circular(radius15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Add to Cart Button with Counter
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 28, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.iCardBgColor ?? Colors.orange,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    children: [
                      // Decrement Button
                      Icon(
                        Icons.shopping_cart_outlined,
                        color: AppColors.white ?? Colors.red,
                        size: iconSize24,
                      ),
                      Gap(8),
                      // Quantity Display
                      BigText(
                        text: 'Add to cart',
                        size: 14,
                        color: AppColors.white ?? Colors.black,
                      ),
                    ],
                  ),
                ),

                // Price Display
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: BigText(
                    text: 'R${(product.price ?? 0).toStringAsFixed(2)}',
                    size: 18,
                    color: AppColors.mainBlackColor ?? Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}