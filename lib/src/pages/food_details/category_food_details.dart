import 'package:flutter/material.dart';
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
import '../../widgets/expandable_text_widget.dart';
import '../../widgets/helper_icon.dart';
import '../../widgets/single_product_card_widget.dart';

class CategoryFoodDetails extends StatefulWidget {
  final int pageId;
  final String page;

  const CategoryFoodDetails({super.key, required this.pageId, required this.page});

  @override
  State<CategoryFoodDetails> createState() => _CategoryFoodDetailsState();
}

class _CategoryFoodDetailsState extends State<CategoryFoodDetails> {
  late CategoryModel categoryProduct;
  late List<SingleProductModel> categorySingleProducts = [];

  @override
  void initState() {
    super.initState();

    // Get the category product
    final categoryController = Get.find<CategoryProductController>();
    categoryProduct = categoryController.categoryProductList[widget.pageId];

    // Filter single products by this category
    _filterProductsByCategory();
  }

  void _filterProductsByCategory() {
    final singleProductController = Get.find<SingleProductController>();

    // Get category name from the category product
    final categoryName = categoryProduct.name;

    if (categoryName != null) {
      // Filter single products that belong to this category
      categorySingleProducts = singleProductController.singleProductList
          .where((product) => product.category_name == categoryName)
          .toList();
    }
  }

  // Helper function to get full image URL
  String getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return "";
    if (imagePath.startsWith("http")) return imagePath;
    return "${AppConstants.BASE_URL}${AppConstants.UPLOAD_PRODUCT_URI}$imagePath";
  }

  @override
  Widget build(BuildContext context) {
    final singleProductController = Get.find<SingleProductController>();

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Stack(
        children: [
          // 1. Background Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              width: double.maxFinite,
              height: Dimensions.popularFoodImgSize,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(getFullImageUrl(categoryProduct.image)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // 3. Scrollable Content (CustomScrollView) - MOVED UP IN ORDER TO PREVENT OVERLAP BLOCKING TOUCHES
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Rounded container with content
                    Container(
                      margin: EdgeInsets.only(top: Dimensions.popularFoodImgSize - 50),
                      decoration: BoxDecoration(
                        color: AppColors.iPrimaryColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(Dimensions.radius30),
                          topRight: Radius.circular(Dimensions.radius30),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.width15,
                          vertical: Dimensions.height20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: Dimensions.height20),
                            AppColumn(
                              text: categoryProduct.name ?? 'No Name',
                            ),
                            SizedBox(height: Dimensions.height20),
                            BigText(text: "Details:", color: AppColors.white),
                            SizedBox(height: Dimensions.height10),
                            Text(
                              categoryProduct.name ?? 'No name available',
                              style: TextStyle(color: AppColors.white),
                            ),
                            SizedBox(height: Dimensions.height10),
                            ExpandableTextWidget(
                              text: categoryProduct.description ?? 'No description available.',
                            ),
                            SizedBox(height: Dimensions.height20),

                            // Products in this category section
                            _buildProductsSection(singleProductController),

                            SizedBox(height: Dimensions.height20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 2. Top Action Icons - FIXED: Made this more prominent and ensured proper touch area (NOW LAST IN PAINT ORDER TO SIT ON TOP)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: kToolbarHeight + MediaQuery.of(context).padding.top,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width20,
                    vertical: Dimensions.height10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button with larger touch area
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.3),
                        ),
                        child: IconButton(
                          onPressed: () {
                            Get.back();
                          },
                          icon: Icon(
                            Icons.arrow_back_ios_rounded,
                            size: 20,
                            color: AppColors.iWhiteColor,
                          ),
                          padding: EdgeInsets.zero,
                          splashRadius: 20,
                        ),
                      ),
                      Row(
                        children: [
                          // Cart icon
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.3),
                            ),
                            child: IconButton(
                              onPressed: () => Get.toNamed(RouteHelper.getCartPage()),
                              icon: Icon(
                                Icons.shopping_cart,
                                size: 20,
                                color: AppColors.yellowColor,
                              ),
                              padding: EdgeInsets.zero,
                              splashRadius: 20,
                            ),
                          ),
                          SizedBox(width: Dimensions.width10),
                          // Wishlist icon
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.3),
                            ),
                            child: IconButton(
                              onPressed: () => Get.toNamed(RouteHelper.wishlistPage),
                              icon: Icon(
                                Icons.favorite_border,
                                size: 20,
                                color: AppColors.iSecondaryColor,
                              ),
                              padding: EdgeInsets.zero,
                              splashRadius: 20,
                            ),
                          ),
                          SizedBox(width: Dimensions.width10),
                          // More options icon
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.3),
                            ),
                            child: IconButton(
                              onPressed: () {
                                // Add more options functionality here
                              },
                              icon: Icon(
                                Icons.more_horiz,
                                size: 20,
                                color: AppColors.iWhiteColor,
                              ),
                              padding: EdgeInsets.zero,
                              splashRadius: 20,
                            ),
                          ),
                        ],
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

  Widget _buildProductsSection(SingleProductController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BigText(
              text: 'Products in this Category',
              color: AppColors.white,
              size: 18,
            ),
            Text(
              '${categorySingleProducts.length} items',
              style: TextStyle(
                color: AppColors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
        SizedBox(height: Dimensions.height15),

        // Products list
        if (categorySingleProducts.isEmpty)
          _buildEmptyState()
        else
          _buildProductsList(controller),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(Dimensions.height20),
      decoration: BoxDecoration(
        color: AppColors.iCardBgColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Dimensions.radius20),
        border: Border.all(color: AppColors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.fastfood_outlined,
            size: 50,
            color: AppColors.white.withOpacity(0.5),
          ),
          SizedBox(height: Dimensions.height10),
          Text(
            'No products available in this category',
            style: TextStyle(
              color: AppColors.white.withOpacity(0.7),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: Dimensions.height10),
          Text(
            'Check back later for new additions',
            style: TextStyle(
              color: AppColors.white.withOpacity(0.5),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(SingleProductController controller) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: categorySingleProducts.length,
      itemBuilder: (context, index) {
        final product = categorySingleProducts[index];
        return Padding(
          padding: EdgeInsets.only(bottom: Dimensions.height15),
          child: SingleProductCard(
            product: product,
            controller: controller,
          ),
        );
      },
    );
  }
}