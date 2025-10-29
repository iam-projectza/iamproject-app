import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam/src/widgets/small_text.dart';

import '../constants/colors.dart';
import '../controllers/category_product_controller.dart';
import '../controllers/wishlist_controller.dart';
import '../model/category_product_model.dart';
import '../model/single_product_model.dart';
import '../routes/route_helper.dart';
import '../utils/app_constants.dart';
import '../utils/dimensions.dart';
import 'app_column.dart';
import 'big_text.dart';
import 'interactive_favourite_button_widget.dart';

class CategoryScrollWidget extends StatefulWidget {
  const CategoryScrollWidget({super.key});

  @override
  State<CategoryScrollWidget> createState() => _CategoryScrollWidgetState();
}

class _CategoryScrollWidgetState extends State<CategoryScrollWidget> {
  PageController pageController = PageController(viewportFraction: 0.85);
  var _currentPageValue = 0.0;
  final double _scaleFactor = 0.7;
  final double _height = Dimensions.pageViewContainer;

  @override
  void initState() {
    super.initState();
    pageController.addListener(() {
      setState(() {
        _currentPageValue = pageController.page!;
      });
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  String getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return "";
    if (imagePath.startsWith("http")) return imagePath;
    return "${AppConstants.BASE_URL}/${imagePath.replaceAll(RegExp(r'^/+'), '')}";
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoryProductController>(builder: (categoryProducts) {
      return categoryProducts.isLoaded
          ? SizedBox(
        height: Dimensions.pageView,
        child: PageView.builder(
          controller: pageController,
          itemCount: categoryProducts.categoryProductList.length,
          itemBuilder: (context, position) {
            final categoryProduct = categoryProducts.categoryProductList[position];

            return _buildPageItem(position, categoryProduct);
          },
        ),
      )
          : const CircularProgressIndicator(
        color: AppColors.mainColor,
      );
    });
  }

  Widget _buildPageItem(int index, CategoryModel categoryProduct) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final imageUrl = getFullImageUrl(categoryProduct.image);

    Matrix4 matrix = Matrix4.identity();
    if (index == _currentPageValue.floor()) {
      var currScale = 1 - (_currentPageValue - index) * (1 - _scaleFactor);
      var currTrans = _height * (1 - currScale) / 2;
      matrix = Matrix4.diagonal3Values(1, currScale, 1)..setTranslationRaw(0, currTrans, 0);
    } else if (index == _currentPageValue.floor() + 1) {
      var currScale = _scaleFactor + (_currentPageValue - index + 1) * (1 - _scaleFactor);
      var currTrans = _height * (1 - currScale) / 2;
      matrix = Matrix4.diagonal3Values(1, currScale, 1)..setTranslationRaw(0, currTrans, 0);
    } else if (index == _currentPageValue.floor() - 1) {
      var currScale = 1 - (_currentPageValue - index) * (1 - _scaleFactor);
      var currTrans = _height * (1 - currScale) / 2;
      matrix = Matrix4.diagonal3Values(1, currScale, 1)..setTranslationRaw(0, currTrans, 0);
    } else {
      var currScale = _scaleFactor;
      matrix = Matrix4.diagonal3Values(1, currScale, 1)..setTranslationRaw(0, _height * (1 - _scaleFactor) / 2, 1);
    }

    return Transform(
      transform: matrix,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => Get.toNamed(RouteHelper.getCategoryFood(index, 'home')),
            child: Container(
              height: Dimensions.pageViewContainer,
              margin: EdgeInsets.symmetric(horizontal: Dimensions.width10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radius30),
                color: Colors.grey[200],
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: imageUrl.isNotEmpty
                      ? NetworkImage(imageUrl)
                      : const AssetImage("assets/images/placeholder.png") as ImageProvider,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: Dimensions.pageViewTextContainer + 20,
              margin: EdgeInsets.only(
                left: Dimensions.width30,
                right: Dimensions.width30,
                bottom: Dimensions.height15,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radius20),
                color: AppColors.gradient2,
                boxShadow: const [
                  BoxShadow(color: Color(0xffe8e8e8), blurRadius: 5, offset: Offset(0, 5)),
                  BoxShadow(color: Colors.white, offset: Offset(-5, 0)),
                  BoxShadow(color: Colors.white, offset: Offset(5, 0)),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: Dimensions.width10,
                  right: Dimensions.width10,
                  top: Dimensions.height15 - 10,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: BigText(
                              text: categoryProduct.name ?? "No Name",
                              color: AppColors.white,
                            ),
                          ),
                          // UPDATED: Using proper WishlistController with Firebase
                          GetBuilder<WishlistController>(
                            builder: (wishlistController) {
                              final bool isWishlisted = categoryProduct.id != null &&
                                  wishlistController.isInWishlist(categoryProduct.id!);

                              return GestureDetector(
                                onTap: () {
                                  if (categoryProduct.id != null) {
                                    // Convert CategoryModel to SingleProductModel for wishlist
                                    // Using only available properties from CategoryModel
                                    final product = SingleProductModel(
                                      id: categoryProduct.id,
                                      name: categoryProduct.name,
                                      // price: categoryProduct.price, // Not available in CategoryModel
                                      price: 0.0, // Default price for categories
                                      image: categoryProduct.image,
                                      description: categoryProduct.description,
                                      // category_id: categoryProduct.category_id, // Not available
                                      category_id: categoryProduct.id, // Use category id as category_id
                                      // category_name: categoryProduct.category_name, // Not available
                                      category_name: categoryProduct.name, // Use category name as category_name
                                      //rating: categoryProduct.rating ?? 0.0, // Use available rating
                                      // stock: categoryProduct.stock, // Not available
                                      stock: 100, // Default stock for categories
                                    );
                                    wishlistController.toggleWishlist(product);
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isWishlisted ? Icons.favorite : Icons.favorite_border,
                                    color: isWishlisted ? Colors.red : AppColors.white,
                                    size: 20,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.star_rounded, color: Colors.amber, size: 12),
                          const SizedBox(width: 4),
                          SmallText(
                            text: categoryProduct.rating != null
                                ? categoryProduct.rating!.toStringAsFixed(1)
                                : 'no rating',
                            color: AppColors.white,
                          ),
                          const SizedBox(width: 10),
                          Icon(Icons.local_fire_department, color: Colors.deepOrange, size: 16),
                          const SizedBox(width: 4),
                          SmallText(text: 'Trending', color: AppColors.white),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: Dimensions.height15 - 10, horizontal: 5),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppColumn(
                              text: categoryProduct.description ?? 'No description available.',
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: Dimensions.height45),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.orangeColor ?? Colors.orange,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: BigText(
                                      text: 'Popular',
                                      size: 12,
                                      color: AppColors.mainBlackColor ?? Colors.black,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.orangeColor ?? Colors.orange,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: BigText(
                                      text: 'Recommended',
                                      size: 12,
                                      color: AppColors.mainBlackColor ?? Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}