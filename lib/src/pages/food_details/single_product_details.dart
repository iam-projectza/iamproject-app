import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/colors.dart';
import '../../controllers/single_product_controller.dart';
import '../../model/single_product_model.dart';
import '../../routes/route_helper.dart';
import '../../utils/app_constants.dart';
import '../../utils/dimensions.dart';
import '../../widgets/app_column.dart';
import '../../widgets/big_text.dart';
import '../../widgets/expandable_text_widget.dart';
import '../../widgets/helper_icon.dart';

class SingleProductDetails extends StatefulWidget {
  final int pageId;
  final String page;

  const SingleProductDetails({super.key, required this.pageId, required this.page});

  @override
  State<SingleProductDetails> createState() => _SingleProductDetailsState();
}

class _SingleProductDetailsState extends State<SingleProductDetails> {
  int quantity = 1;

  List<Map<String, dynamic>> recommendedGroceries = [
    {"image": 'assets/icons/grocery.jpg', "title": "Fresh Apples", "price": 15.99},
    {"image": 'assets/icons/vegies.jpg', "title": "Organic Bananas", "price": 10.50},
    {"image": 'assets/icons/takeway.jpg', "title": "Dairy Milk", "price": 12.75},
    {"image": 'assets/icons/sushi.jpg', "title": "Whole Wheat Bread", "price": 8.99},
  ];

  void _addToWishlist(SingleProductModel product) {
    Get.snackbar(
      'Wishlist',
      'Item added to wishlist!',
      backgroundColor: AppColors.mainColor,
      colorText: Colors.white,
    );
    Get.toNamed(RouteHelper.getInitialPage());
  }

  void _addToCart(SingleProductModel product) {
    Get.snackbar(
      'Cart',
      '${product.name} added to cart!',
      backgroundColor: AppColors.mainColor,
      colorText: Colors.white,
    );
  }

  String getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return "";
    if (imagePath.startsWith("http")) return imagePath;
    return "${AppConstants.BASE_URL}/${imagePath.replaceAll(RegExp(r'^/+'), '')}";
  }

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<SingleProductController>();

    // ADDED: Check if data is loaded and index is valid
    if (!controller.isLoaded) {
      return Scaffold(
        backgroundColor: AppColors.bg2Color,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // FIXED: Add bounds checking for the pageId
    if (widget.pageId < 0 || widget.pageId >= controller.singleProductList.length) {
      return Scaffold(
        backgroundColor: AppColors.bg2Color,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('Product not found', style: TextStyle(fontSize: 18)),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Get.back(),
                child: Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    var product = controller.singleProductList[widget.pageId];
    double price = product.price ?? 0.0;
    String imageUrl = getFullImageUrl(product.image);
    bool hasValidImage = imageUrl.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.bg2Color,
      body: Stack(
        children: [
          // Background Image with null safety
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: hasValidImage
                ? Image.network(
              imageUrl,
              height: Dimensions.popularFoodImgSize,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: Dimensions.popularFoodImgSize,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: Icon(Icons.error, color: Colors.red, size: 50),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: Dimensions.popularFoodImgSize,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
            )
                : Container(
              height: Dimensions.popularFoodImgSize,
              width: double.infinity,
              color: Colors.grey[300],
              child: Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
            ),
          ),

          // Scrollable content
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Rounded container that overlaps the image
                    Container(
                      margin: EdgeInsets.only(top: Dimensions.popularFoodImgSize - 50),
                      decoration: BoxDecoration(
                        color: AppColors.iPrimaryColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50),
                          topRight: Radius.circular(50),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: Dimensions.width15, vertical: Dimensions.height20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppColumn(
                              text: product.name ?? 'No Name',
                            ),
                            SizedBox(height: Dimensions.height20),
                            BigText(text: "Details:", color: AppColors.white),
                            SizedBox(height: Dimensions.height10),
                            Text(
                              product.name ?? 'No Name Available',
                              style: TextStyle(color: AppColors.white),
                            ),
                            SizedBox(height: Dimensions.height10),
                            ExpandableTextWidget(
                              text: product.description ?? 'No description available for this product.',
                            ),
                            SizedBox(height: Dimensions.height20),

                            // Quantity Controls
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white),
                                    borderRadius: BorderRadius.circular(45),
                                    color: AppColors.iCardBgColor,
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: Dimensions.width15, vertical: 5),
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () { if (quantity > 1) setState(() => quantity--); },
                                        child: Icon(Icons.remove, color: AppColors.white, size: 15),
                                      ),
                                      SizedBox(width: Dimensions.width20),
                                      Text('$quantity', style: TextStyle(color: AppColors.white, fontSize: 14)),
                                      SizedBox(width: Dimensions.width20),
                                      InkWell(
                                        onTap: () => setState(() => quantity++),
                                        child: Icon(Icons.add, color: AppColors.white, size: 15),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: Dimensions.height30),

                            // Recommended Groceries Slider
                            Text(
                              "Recommended Groceries",
                              style: TextStyle(
                                fontSize: Dimensions.font16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: Dimensions.height10),
                            SizedBox(
                              height: 150,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: recommendedGroceries.length,
                                itemBuilder: (context, index) {
                                  var item = recommendedGroceries[index];
                                  return Container(
                                    width: 130,
                                    margin: EdgeInsets.only(right: Dimensions.width10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Stack(
                                        children: [
                                          Image.asset(
                                            item["image"],
                                            width: double.infinity,
                                            height: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.grey[300],
                                                child: Icon(Icons.error, color: Colors.red),
                                              );
                                            },
                                          ),
                                          Container(
                                            width: double.infinity,
                                            height: double.infinity,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.bottomCenter,
                                                end: Alignment.topCenter,
                                                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 10,
                                            left: 10,
                                            right: 10,
                                            child: Text(
                                              item["title"],
                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
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

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width20,
                  vertical: Dimensions.height10,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: HelperIcon(
                          icon: Icons.arrow_back,
                          size: Dimensions.iconSize16,
                          color: AppColors.iWhiteColor,
                        ),
                      ),
                      Row(
                        children: [
                          HelperIcon(
                            icon: Icons.shopping_cart,
                            size: Dimensions.iconSize16,
                            color: AppColors.yellowColor,
                          ),
                          SizedBox(width: Dimensions.width10),
                          GestureDetector(
                            onTap: () => _addToWishlist(product),
                            child: HelperIcon(
                              icon: Icons.favorite_border,
                              size: Dimensions.iconSize16,
                              color: AppColors.iSecondaryColor,
                            ),
                          ),
                          SizedBox(width: Dimensions.width10),
                          HelperIcon(
                            icon: Icons.more_horiz,
                            size: Dimensions.iconSize16,
                            color: AppColors.iWhiteColor,
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

      // Bottom Add to Cart Bar
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(Dimensions.height20),
        color: AppColors.iPrimaryColor,
        child: ElevatedButton(
          onPressed: () => _addToCart(product),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: AppColors.mainColor),
            ),
            padding: EdgeInsets.symmetric(horizontal: Dimensions.width20, vertical: Dimensions.height10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Add $quantity to order • ', style: TextStyle(color: Colors.white)),
              Text('R ${(price * quantity).toStringAsFixed(2)}', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}