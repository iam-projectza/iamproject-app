import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../constants/colors.dart';
import '../../controllers/category_product_controller.dart';
import '../../controllers/single_product_controller.dart';
import '../../utils/app_constants.dart';

class FilterScroll extends StatelessWidget {
  const FilterScroll({super.key});

  String getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return "";
    if (imagePath.startsWith("http")) return imagePath;
    return "${AppConstants.BASE_URL}/${AppConstants.UPLOAD_PRODUCT_URI}$imagePath";
  }

  @override
  Widget build(BuildContext context) {
    // Get the SingleProductController instance
    final singleProductController = Get.find<SingleProductController>();

    return GetBuilder<CategoryProductController>(builder: (controller) {
      if (!controller.isLoaded) {
        return SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 6, // Show 6 shimmer items
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  period: const Duration(milliseconds: 1500),
                  child: Container(
                    width: index == 0 ? 100 : 120, // Different width for "All" button
                    height: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Shimmer circle for image
                        Container(
                          width: 35,
                          height: 35,
                          margin: EdgeInsets.only(left: index == 0 ? 12 : 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(index == 0 ? 0.1 : 0.4),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Shimmer text
                        Container(
                          width: 40,
                          height: 14,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }

      return SizedBox(
        height: 60, // Increased height to accommodate shadow
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.categoryProductList.length + 1, // +1 for "All" button
          itemBuilder: (context, index) {
            // First item is the "All" button
            if (index == 0) {
              final isAllSelected = singleProductController.isAllSelected();

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                child: GestureDetector(
                  onTap: () {
                    // Handle "All" filter selection - show all products
                    singleProductController.resetFilter();
                  },
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: isAllSelected
                          ? AppColors.orangeColor // Selected state
                          : AppColors.white, // Default state
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Custom image for "All" button
                        Container(
                          width: 35,
                          height: 35,
                          margin: const EdgeInsets.only(left: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: isAllSelected
                                ? Colors.white.withOpacity(0.3)
                                : Colors.grey[300],
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.asset(
                              'assets/icons/icons.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.all_inclusive,
                                  size: 18,
                                  color: isAllSelected ? Colors.white : Colors.grey[600],
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // "All" text
                        Padding(
                          padding: const EdgeInsets.only(left: 8, right: 16),
                          child: Text(
                            'All',
                            style: TextStyle(
                              color: isAllSelected ? Colors.white : AppColors.mainBlackColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // Adjust index for category list (subtract 1 because we added "All" button)
            final categoryIndex = index - 1;
            final category = controller.categoryProductList[categoryIndex];
            final imageUrl = getFullImageUrl(category.image);
            final isCategorySelected = singleProductController.isCategorySelected(category.id!);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
              child: GestureDetector(
                onTap: () {
                  // Handle category selection - filter products by this category
                  singleProductController.filterProductsByCategory(category.id, category.name!);
                },
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: isCategorySelected
                        ? AppColors.orangeColor // Selected state
                        : AppColors.white, // Default state
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Image container
                      Container(
                        width: 35,
                        height: 35,
                        margin: const EdgeInsets.only(left: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: isCategorySelected
                              ? Colors.white.withOpacity(0.3)
                              : Colors.grey[300],
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: imageUrl.isNotEmpty
                              ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.fastfood,
                                size: 18,
                                color: isCategorySelected ? Colors.white : Colors.grey[600],
                              );
                            },
                          )
                              : Icon(
                            Icons.fastfood,
                            size: 18,
                            color: isCategorySelected ? Colors.white : Colors.grey[600],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Category name
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Text(
                          category.name ?? 'No Name',
                          style: TextStyle(
                            color: isCategorySelected ? Colors.white : AppColors.mainBlackColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}