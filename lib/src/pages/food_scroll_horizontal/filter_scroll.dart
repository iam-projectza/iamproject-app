import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../constants/colors.dart';
import '../../controllers/category_product_controller.dart';
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
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5), // Added vertical padding
                child: GestureDetector(
                  onTap: () {
                    // Handle "All" filter selection
                  },
                  child: Container(
                    height: 45, // Slightly reduced container height
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: AppColors.orangeColor, // Red background for active state
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
                          width: 35, // Slightly reduced size
                          height: 35, // Slightly reduced size
                          margin: const EdgeInsets.only(left: 12), // Adjusted margin
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.white.withOpacity(0.3), // Semi-transparent white
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
                              'assets/icons/icons.png', // Your custom image path
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.all_inclusive, // Fallback icon
                                  size: 18, // Slightly smaller icon
                                  color: Colors.white,
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 6), // Reduced spacing
                        // "All" text
                        const Padding(
                          padding: EdgeInsets.only(left: 8, right: 16), // Adjusted padding
                          child: Text(
                            'All',
                            style: TextStyle(
                              color: Colors.white, // White text for better contrast on red
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

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5), // Added vertical padding
              child: GestureDetector(
                onTap: () {
                  // Handle category selection
                },
                child: Container(
                  height: 45, // Slightly reduced container height
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: AppColors.white,
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
                        width: 35, // Slightly reduced size
                        height: 35, // Slightly reduced size
                        margin: const EdgeInsets.only(left: 6), // Adjusted margin
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.grey[300],
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
                                size: 18, // Slightly smaller icon
                                color: Colors.grey[600],
                              );
                            },
                          )
                              : Icon(
                            Icons.fastfood,
                            size: 18, // Slightly smaller icon
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6), // Reduced spacing
                      // Category name
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Text(
                          category.name ?? 'No Name',
                          style: TextStyle(
                            color: AppColors.mainBlackColor,
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