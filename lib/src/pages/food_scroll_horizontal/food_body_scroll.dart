import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../../constants/colors.dart';
import '../../controllers/category_product_controller.dart';
import '../../controllers/single_product_controller.dart';
import '../../model/category_product_model.dart';
import '../../model/single_product_model.dart';
import '../../routes/route_helper.dart';
import '../../utils/app_constants.dart';
import '../../utils/dimensions.dart';
import '../../widgets/app_column.dart';
import '../../widgets/big_text.dart';
import '../../widgets/small_text.dart';

class FoodBodyScroll extends StatefulWidget {
  const FoodBodyScroll({super.key});

  @override
  State<FoodBodyScroll> createState() => _FoodBodyScrollState();
}

class _FoodBodyScrollState extends State<FoodBodyScroll> {
  PageController pageController = PageController(viewportFraction: 0.85);
  var _currentPageValue = 0.0;
  final double _scaleFactor = 0.8;
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

  // Helper function to get full image URL
  String getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return "";
    if (imagePath.startsWith("http")) return imagePath;
    return "${AppConstants.BASE_URL}/${imagePath.replaceAll(RegExp(r'^/+'), '')}";
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Container(
            margin: EdgeInsets.only(left: Dimensions.width30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tailored To Your Liking',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: Dimensions.font16,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
                SizedBox(width: Dimensions.width10),
                Padding(
                  padding: EdgeInsets.only(right: Dimensions.width30),
                  child: Icon(Icons.arrow_circle_right_outlined),
                ),
              ],
            ),
          ),
          Gap(20),

          // Horizontal Category PageView
          GetBuilder<CategoryProductController>(builder: (categoryProducts) {
            return categoryProducts.isLoaded
                ? SizedBox(
              height: Dimensions.pageView,
              child: PageView.builder(
                controller: pageController,
                itemCount: categoryProducts.categoryProductList.length,
                itemBuilder: (context, position) {
                  return _buildPageItem(
                    position,
                    categoryProducts.categoryProductList[position],
                  );
                },
              ),
            )
                : const CircularProgressIndicator(
              color: AppColors.mainColor,
            );
          }),

          // Single Products Header
          Container(
            margin: EdgeInsets.only(left: Dimensions.width30, bottom: 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Single Products',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: Dimensions.font16,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
                SizedBox(width: Dimensions.width10),
                BigText(text: ':', color: Colors.black26),
                SizedBox(width: Dimensions.width10),
                SmallText(text: 'You can pick a single item'),
              ],
            ),
          ),

          // Single Products List
          GetBuilder<SingleProductController>(builder: (controller) {
            if (controller.isLoaded) {
              return ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: controller.singleProductList.length,
                itemBuilder: (context, index) {
                  return _buildRestaurantCard(
                    controller.singleProductList[index],
                  );
                },
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.mainColor),
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildRestaurantCard(SingleProductModel singleProduct) {
    final imageUrl = getFullImageUrl(singleProduct.image);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: Dimensions.width20, vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Background Content (Image + Text)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                GestureDetector(
                  onTap: () => Get.toNamed(RouteHelper.getSingleProduct(singleProduct.id!, 'home')),
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Container(
                          height: 140,
                          width: constraints.maxWidth,
                          color: Colors.grey[200],
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(child: CircularProgressIndicator(color: AppColors.mainColor));
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                alignment: Alignment.center,
                                child: Icon(Icons.image_not_supported, size: 50),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Text Content
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BigText(text: singleProduct.name ?? "Unnamed Product", size: Dimensions.font16),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.delivery_dining, color: Colors.amber, size: 18),
                          SizedBox(width: 4),
                          Text(
                            "R${singleProduct.price ?? 0} Delivery Fee",
                            style: TextStyle(fontSize: 14, color: Colors.grey?[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),


            Positioned(
              top: 10,
              right: 10,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 16,
                child: Icon(Icons.favorite_border, color: Colors.grey?[600], size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageItem(int index, CategoryModel categoryProduct) {
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
              height: Dimensions.pageViewTextContainer,
              margin: EdgeInsets.only(
                  left: Dimensions.width30, right: Dimensions.width30, bottom: Dimensions.height30),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radius20),
                color: AppColors.bgColor,
                boxShadow: const [
                  BoxShadow(color: Color(0xffe8e8e8), blurRadius: 5, offset: Offset(0, 5)),
                  BoxShadow(color: Colors.white, offset: Offset(-5, 0)),
                  BoxShadow(color: Colors.white, offset: Offset(5, 0)),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: Dimensions.height15, horizontal: 15),
                    child: Column(
                      children: [
                        BigText(text: categoryProduct.name ?? "No Name", color: AppColors.white),
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