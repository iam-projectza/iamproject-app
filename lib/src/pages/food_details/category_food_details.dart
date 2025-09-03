import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/colors.dart';
import '../../controllers/category_product_controller.dart';
import '../../model/category_product_model.dart';
import '../../routes/route_helper.dart';
import '../../utils/app_constants.dart';
import '../../utils/dimensions.dart';
import '../../widgets/app_column.dart';
import '../../widgets/big_text.dart';
import '../../widgets/expandable_text_widget.dart';
import '../../widgets/helper_icon.dart';

class CategoryFoodDetails extends StatefulWidget {
  final int pageId;
  final String page;

  const CategoryFoodDetails({super.key, required this.pageId, required this.page});

  @override
  State<CategoryFoodDetails> createState() => _CategoryFoodDetailsState();
}

class _CategoryFoodDetailsState extends State<CategoryFoodDetails> {
  int quantity = 1;
  double price = 20.99;

  // Static list of recommended groceries
  List<Map<String, dynamic>> recommendedGroceries = [
    {"image": 'assets/icons/grocery.jpg', "title": "Fresh Apples", "price": 15.99},
    {"image": 'assets/icons/vegies.jpg', "title": "Organic Bananas", "price": 10.50},
    {"image": 'assets/icons/takeway.jpg', "title": "Dairy Milk", "price": 12.75},
    {"image": 'assets/icons/sushi.jpg', "title": "Whole Wheat Bread", "price": 8.99},
  ];

  void _addToWishlist(CategoryModel product) {
    Get.find<CategoryProductController>().addToWishlist(product);
    Get.snackbar(
      'Wishlist',
      'Item added to wishlist!',
      backgroundColor: AppColors.mainColor,
      colorText: Colors.white,
    );
    Get.toNamed(RouteHelper.getInitialPage());
  }

  void _addToCart() {
    Get.snackbar(
      'Cart',
      'Item added to cart!',
      backgroundColor: AppColors.mainColor,
      colorText: Colors.white,
    );
  }

  void _increaseQuantity() {
    setState(() {
      quantity++;
    });
  }

  void _decreaseQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
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
    var product = Get.find<CategoryProductController>().categoryProductList[widget.pageId];

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
                  image: NetworkImage(getFullImageUrl(product.image)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // 2. Top Action Icons

          // 3. Scrollable Content (CustomScrollView)
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
                              text: product.name ?? 'No Name',

                            ),
                            SizedBox(height: Dimensions.height20),
                            BigText(text: "Details:", color: AppColors.white),
                            SizedBox(height: Dimensions.height10),
                            Text(
                              product.name ?? 'No name available',
                              style: TextStyle(color: AppColors.white),
                            ),
                            SizedBox(height: Dimensions.height10),
                            ExpandableTextWidget(
                              text: product.description ?? 'No description available.',
                            ),
                            SizedBox(height: Dimensions.height20),

                            // Quantity Buttons
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white),
                                    borderRadius: BorderRadius.circular(45),
                                    color: AppColors.iCardBgColor,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Dimensions.width15,
                                    vertical: 5,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      InkWell(
                                        onTap: _decreaseQuantity,
                                        child: Icon(Icons.remove, color: AppColors.white, size: 15),
                                      ),
                                      SizedBox(width: Dimensions.width20),
                                      Text(
                                        '$quantity',
                                        style: TextStyle(color: AppColors.white, fontSize: 14),
                                      ),
                                      SizedBox(width: Dimensions.width20),
                                      InkWell(
                                        onTap: _increaseQuantity,
                                        child: Icon(Icons.add, color: AppColors.white, size: 15),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: Dimensions.height20),

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
                          Get.toNamed(RouteHelper.getInitialPage());
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
                          HelperIcon(
                            icon: Icons.favorite_border,
                            size: Dimensions.iconSize16,
                            color: AppColors.iSecondaryColor,
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

          // ✅ 4. Circular Logo - Now correctly placed as direct child of main Stack
          Positioned(
            top: Dimensions.popularFoodImgSize - 47 - 50,
            left: MediaQuery.of(context).size.width / 2 - Dimensions.radius40,
            child: CircleAvatar(
              radius: Dimensions.radius40,
              backgroundColor: AppColors.iWhiteColor,
              child: CircleAvatar(
                radius: Dimensions.radius35,
                backgroundImage: getFullImageUrl(product.image).isNotEmpty
                    ? NetworkImage(getFullImageUrl(product.image))
                    : AssetImage("assets/images/placeholder.png") as ImageProvider,
                onBackgroundImageError: (_, __) {},
              ),
            ),
          ),
        ],
      ),

      // Bottom Bar
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(Dimensions.height20),
        color: AppColors.iPrimaryColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _addToCart,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: AppColors.mainColor),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width20,
                  vertical: Dimensions.height10,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Add $quantity to cart • ',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    'R ${(price * quantity).toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}