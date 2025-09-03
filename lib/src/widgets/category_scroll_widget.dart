import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:iam/src/widgets/small_text.dart';


import '../constants/colors.dart';
import '../controllers/category_product_controller.dart';
import '../model/category_product_model.dart';
import '../routes/route_helper.dart';
import '../utils/app_constants.dart';
import '../utils/dimensions.dart';
import 'app_column.dart';
import 'big_text.dart';
import 'expandable_text_widget.dart';
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

  late bool isFavorite;
  late VoidCallback onFavorite;

  @override
  void initState() {
    super.initState();
    pageController.addListener(() {
      setState(() {
        _currentPageValue = pageController.page!;
      });
    });
    // Initialize isFavorite and onFavorite here
    isFavorite = false; // Set to true if the item is favorited
    onFavorite = () {
      // Define what happens when the favorite state changes
      setState(() {
        isFavorite = !isFavorite;
      });
    };
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  // Helper function to get full image URL
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
            // Initialize isFavorite and onFavorite for each item
            bool itemIsFavorite = categoryProduct.isFavorite ?? false;
            itemOnFavorite() {
              // Define what happens when the favorite state changes for this item
              CategoryProductController categoryProductController = Get.find<CategoryProductController>();
              if (itemIsFavorite) {
                //categoryProductController.removeFromWishlist(categoryProduct);
              } else {
                categoryProductController.addToWishlist(categoryProduct);
              }
              setState(() {
                itemIsFavorite = !itemIsFavorite;
              });
            }
            return _buildPageItem(
              position,
              categoryProduct,
              itemIsFavorite,
              itemOnFavorite,
            );
          },
        ),
      )
          : const CircularProgressIndicator(
        color: AppColors.mainColor,
      );
    });
  }

  Widget _buildPageItem(int index, CategoryModel categoryProduct, bool isFavorite, VoidCallback onFavorite) {
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
          Container(
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
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: Dimensions.pageViewTextContainer,
              margin: EdgeInsets.only(
              left: Dimensions.width30, right: Dimensions.width30, bottom: Dimensions.height30),
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
                padding: EdgeInsets.only(left: Dimensions.width10, right: Dimensions.width10, top: Dimensions.height15-10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: BigText(text: categoryProduct.name ?? "No Name", color: AppColors.white,),
                        ),
                        InteractiveFavoriteButton(isFavorite: isFavorite, onToggle: onFavorite, activeColor: AppColors.orangeColor, inactiveColor: AppColors.iSecondaryColor),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(children: [
                      Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      SmallText(text: categoryProduct.rating != null ? categoryProduct.rating!.toStringAsFixed(1) :'no rating', color: AppColors.white,),
                      const SizedBox(width: 10),
                      Icon(Icons.local_fire_department, color: Colors.deepOrange, size: 16),
                      const SizedBox(width: 4),
                      SmallText(text: 'Trending', color: AppColors.white,),
                    ]),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: Dimensions.height15-10, horizontal: 5),
                      child: Column(
                        children: [
                          AppColumn(
                            text: categoryProduct.description ?? 'No description available.',

                          ),

                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addToWishlist(CategoryModel product) {
    CategoryProductController categoryProductController = Get.find<CategoryProductController>();
    if (categoryProductController.isInWishlist(product)) {
      Get.snackbar(
        'Wishlist',
        'Item already in wishlist!',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } else {
      categoryProductController.addToWishlist(product);
      Get.toNamed(RouteHelper.getInitialPage());
      Get.snackbar(
        'Wishlist',
        'Item added to wishlist!',
        backgroundColor: AppColors.mainColor,
        colorText: Colors.white,
      );
    }
  }
}