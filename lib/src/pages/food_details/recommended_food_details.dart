import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/colors.dart';
import '../../routes/route_helper.dart';
import '../../utils/dimensions.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/big_text.dart';
import '../../widgets/expandable_text_widget.dart';
import '../../widgets/helper_icon.dart';


class RecommendedFoodDetails extends StatefulWidget {
  const RecommendedFoodDetails({super.key});

  @override
  State<RecommendedFoodDetails> createState() => _RecommendedFoodDetailsState();
}

class _RecommendedFoodDetailsState extends State<RecommendedFoodDetails> {
  List<Map<String, dynamic>> recommendedGroceries = [
    {
      "image": 'assets/icons/grocery.jpg',
      "title": "Fresh Apples",
      "price": 15.99,
    },
    {
      "image": 'assets/icons/vegies.jpg',
      "title": "Organic Bananas",
      "price": 10.50,
    },
    {
      "image": 'assets/icons/takeway.jpg',
      "title": "Dairy Milk",
      "price": 12.75,
    },
    {
      "image": 'assets/icons/sushi.jpg',
      "title": "Whole Wheat Bread",
      "price": 8.99,
    },
  ];
  int quantity = 1;
  double price = 20.99; // Example base price

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

  void _addToCart() {
    Get.snackbar(
      'Cart',
      'Item added to cart!',
      backgroundColor: AppColors.mainColor,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: 80,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    //Get.toNamed(RouteHelper.Initial());
                  },
                  child: AppIcon(icon: Icons.clear),
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

                  ],
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(20),
              child: Container(
                width: double.maxFinite,
                padding: EdgeInsets.only(top: 5, bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(Dimensions.radius20),
                    topRight: Radius.circular(Dimensions.radius20),
                  ),
                ),
                child: Center(
                  child: BigText(text: ("Grocery list"), size: Dimensions.font26),
                ),
              ),
            ),
            pinned: true,
            backgroundColor: AppColors.yellowColor,
            expandedHeight: 300,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                "assets/images/grocery_image.jpg",
                width: double.maxFinite,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: Dimensions.width20),
                  child: ExpandableTextWidget(
                    text:
                    "The information shown here may not be current, complete or accurate. "
                        'Always check the item\'s packaging for product information and warnings. If you have any food allergies or special dietary requirements, '
                        'please notify the restaurant directly before ordering.',
                  ),
                ),
                SizedBox(height: Dimensions.height20),

                // Counter + Wishlist Row
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Counter (Left)
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
                      // Wishlist Icon (Right)
                      GestureDetector(
                        onTap: () {
                          Get.snackbar(
                            'Wishlist',
                            'Item added to wishlist!',
                            backgroundColor: AppColors.mainColor,
                            colorText: Colors.white,
                          );
                        },
                        child: Icon(
                          Icons.favorite_border,
                          color: AppColors.mainColor,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: Dimensions.height20),

                Padding(
                  padding: EdgeInsets.only(left: Dimensions.width20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Recommended Groceries",
                        style: TextStyle(
                          fontSize: Dimensions.font16,
                          fontWeight: FontWeight.bold,
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
                            return Stack(
                              children: [
                                // Grocery Item Container
                                Container(
                                  width: 130,
                                  margin: EdgeInsets.only(right: Dimensions.width10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.shade300,
                                        blurRadius: 5,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Stack(
                                      children: [
                                        // Background Image
                                        Image.asset(
                                          item["image"],
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        ),

                                        // Dark Gradient Overlay
                                        Container(
                                          width: double.infinity,
                                          height: double.infinity,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                              colors: [
                                                Colors.black.withOpacity(0.6),
                                                Colors.transparent,
                                              ],
                                            ),
                                          ),
                                        ),

                                        // Content (Price & Wishlist)
                                        Positioned(
                                          top: 10,
                                          left: 10,
                                          right: 10,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              // Price Tag
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: Colors.redAccent,
                                                  borderRadius: BorderRadius.circular(5),
                                                ),
                                                child: Text(
                                                  "R ${item["price"].toStringAsFixed(2)}",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),

                                              // Wishlist Button
                                              GestureDetector(
                                                onTap: () {
                                                  Get.snackbar(
                                                    'Wishlist',
                                                    '${item["title"]} added to wishlist!',
                                                    backgroundColor: AppColors.mainColor,
                                                    colorText: Colors.white,
                                                  );
                                                },
                                                child: Icon(
                                                  Icons.favorite_border,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Grocery Title at Bottom
                                        Positioned(
                                          bottom: 10,
                                          left: 10,
                                          right: 10,
                                          child: Text(
                                            item["title"],
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),


                SizedBox(height: Dimensions.height20),
                Padding(
                  padding: EdgeInsets.only(left: Dimensions.width20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Popular Single Items",
                        style: TextStyle(
                          fontSize: Dimensions.font16,
                          fontWeight: FontWeight.bold,
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
                            return Stack(
                              children: [
                                // Grocery Item Container
                                Container(
                                  width: 130,
                                  margin: EdgeInsets.only(right: Dimensions.width10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.shade300,
                                        blurRadius: 5,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Stack(
                                      children: [
                                        // Background Image
                                        Image.asset(
                                          item["image"],
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        ),

                                        // Dark Gradient Overlay
                                        Container(
                                          width: double.infinity,
                                          height: double.infinity,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                              colors: [
                                                Colors.black.withOpacity(0.6),
                                                Colors.transparent,
                                              ],
                                            ),
                                          ),
                                        ),

                                        // Content (Price & Wishlist)
                                        Positioned(
                                          top: 10,
                                          left: 10,
                                          right: 10,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              // Price Tag
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: Colors.redAccent,
                                                  borderRadius: BorderRadius.circular(5),
                                                ),
                                                child: Text(
                                                  "R ${item["price"].toStringAsFixed(2)}",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),

                                              // Wishlist Button
                                              GestureDetector(
                                                onTap: () {
                                                  Get.snackbar(
                                                    'Wishlist',
                                                    '${item["title"]} added to wishlist!',
                                                    backgroundColor: AppColors.mainColor,
                                                    colorText: Colors.white,
                                                  );
                                                },
                                                child: Icon(
                                                  Icons.favorite_border,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Grocery Title at Bottom
                                        Positioned(
                                          bottom: 10,
                                          left: 10,
                                          right: 10,
                                          child: Text(
                                            item["title"],
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
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
                padding: EdgeInsets.symmetric(horizontal: Dimensions.width20, vertical: Dimensions.height10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Add $quantity to order • ',
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
