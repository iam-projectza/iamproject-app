import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/colors.dart';
import '../../controllers/cart_controller.dart';
import '../../model/single_product_model.dart';
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
  // ✅ FIXED: Removed extra spaces in image URLs
  List<SingleProductModel> recommendedGroceries = [
    SingleProductModel(
      id: 9991,
      name: "Fresh Apples",
      price: 15.99,
      image: "https://via.placeholder.com/150?text=Apple",
      description: "Fresh red apples from local farm",
    ),
    SingleProductModel(
      id: 9992,
      name: "Organic Bananas",
      price: 10.50,
      image: "https://via.placeholder.com/150?text=Banana", // ✅ No spaces
      description: "Organic bananas, rich in potassium",
    ),
    SingleProductModel(
      id: 9993,
      name: "Dairy Milk",
      price: 12.75,
      image: "https://via.placeholder.com/150?text=Milk", // ✅ No spaces
      description: "Full cream dairy milk, 1L",
    ),
    SingleProductModel(
      id: 9994,
      name: "Whole Wheat Bread",
      price: 8.99,
      image: "https://via.placeholder.com/150?text=Bread", // ✅ No spaces
      description: "Freshly baked whole wheat bread",
    ),
  ];

  int quantity = 1;
  final double price = 20.99;

  void _increaseQuantity() => setState(() => quantity++);
  void _decreaseQuantity() {
    if (quantity > 1) setState(() => quantity--);
  }

  void _addToCart() {
    try {
      final cartController = Get.find<CartController>();

      final tempProduct = SingleProductModel(
        id: 10000,
        name: "Grocery Bundle",
        price: price,
        image: "https://via.placeholder.com/300?text=Grocery", // ✅ No spaces
        description: "Special grocery bundle",
      );

      print('🔍 DEBUG: Adding main item to cart:');
      print('   ID: ${tempProduct.id}');
      print('   Name: ${tempProduct.name}');
      print('   Price: ${tempProduct.price}');
      print('   Image: ${tempProduct.image}');

      cartController.addItem(tempProduct, quantity);

      // 🔍 DEBUG: Log current cart state
      _logCartState(cartController, 'After adding main item');

      Get.snackbar('Added', 'Item added to cart', backgroundColor: AppColors.mainColor, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to add item', backgroundColor: Colors.red, colorText: Colors.white);
      print('❌ Add to cart error: $e');
    }
  }

  void _addToCartFromRecommended(SingleProductModel product) {
    try {
      final cartController = Get.find<CartController>();

      print('🔍 DEBUG: Adding recommended item to cart:');
      print('   ID: ${product.id}');
      print('   Name: ${product.name}');
      print('   Price: ${product.price}');
      print('   Image: ${product.image}');

      cartController.addItem(product, 1);

      // 🔍 DEBUG: Log current cart state
      _logCartState(cartController, 'After adding recommended item: ${product.name}');

      Get.snackbar('Added', '${product.name} added', backgroundColor: AppColors.mainColor, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Could not add item', backgroundColor: Colors.red, colorText: Colors.white);
      print('❌ Add recommended item error: $e');
    }
  }

  // 🔍 Helper to log full cart state
  void _logCartState(CartController controller, String context) {
    print('\n=== CART DEBUG: $context ===');
    final items = controller.getItems;
    print('Total items in cart: ${items.length}');
    print('Total quantity: ${controller.totalItems}');
    print('Total amount: R${controller.totalAmount.toStringAsFixed(2)}');

    if (items.isEmpty) {
      print('⚠️ Cart is EMPTY');
    } else {
      for (var item in items) {
        print('📦 Item:');
        print('   ID: ${item.id}');
        print('   Name: ${item.name}');
        print('   Price: ${item.price}');
        print('   Quantity: ${item.quantity}');
        print('   Image: ${item.img}');
        print('   Product ID: ${item.product?.id}');
      }
    }
    print('=== END DEBUG ===\n');
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
                GestureDetector(onTap: Get.back, child: AppIcon(icon: Icons.clear)),
                Row(
                  children: [
                    HelperIcon(icon: Icons.shopping_cart, size: Dimensions.iconSize16, color: AppColors.yellowColor),
                    SizedBox(width: Dimensions.width10),
                    HelperIcon(icon: Icons.favorite_border, size: Dimensions.iconSize16, color: AppColors.iSecondaryColor),
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
                child: Center(child: BigText(text: "Grocery list", size: Dimensions.font26)),
              ),
            ),
            pinned: true,
            backgroundColor: AppColors.yellowColor,
            expandedHeight: 300,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset("assets/images/grocery_image.jpg", fit: BoxFit.cover),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: Dimensions.width20),
                  child: ExpandableTextWidget(
                    text: "The information shown here may not be current, complete or accurate. Always check the item's packaging for product information and warnings. If you have any food allergies or special dietary requirements, please notify the restaurant directly before ordering.",
                  ),
                ),
                SizedBox(height: Dimensions.height20),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            InkWell(onTap: _decreaseQuantity, child: Icon(Icons.remove, color: AppColors.white, size: 15)),
                            SizedBox(width: Dimensions.width20),
                            Text('$quantity', style: TextStyle(color: AppColors.white, fontSize: 14)),
                            SizedBox(width: Dimensions.width20),
                            InkWell(onTap: _increaseQuantity, child: Icon(Icons.add, color: AppColors.white, size: 15)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.snackbar('Wishlist', 'Added!', backgroundColor: AppColors.mainColor, colorText: Colors.white),
                        child: Icon(Icons.favorite_border, color: AppColors.mainColor, size: 30),
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
                      Text("Recommended Groceries", style: TextStyle(fontSize: Dimensions.font16, fontWeight: FontWeight.bold)),
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
                                boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5, spreadRadius: 2)],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Stack(
                                  children: [
                                    Image.network(
                                      item.image!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        color: Colors.grey[300],
                                        child: Icon(Icons.image, color: Colors.grey),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 10,
                                      left: 10,
                                      right: 10,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                            decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(5)),
                                            child: Text("R ${item.price?.toStringAsFixed(2)}", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                          ),
                                          GestureDetector(
                                            onTap: () => _addToCartFromRecommended(item),
                                            child: Icon(Icons.shopping_cart, color: Colors.white, size: 20),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 10,
                                      left: 10,
                                      right: 10,
                                      child: Text(
                                        item.name.toString(),
                                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
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
                    ],
                  ),
                ),

                SizedBox(height: Dimensions.height20),

                Padding(
                  padding: EdgeInsets.only(left: Dimensions.width20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Popular Single Items", style: TextStyle(fontSize: Dimensions.font16, fontWeight: FontWeight.bold)),
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
                                boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5, spreadRadius: 2)],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Stack(
                                  children: [
                                    Image.network(
                                      item.image!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        color: Colors.grey[300],
                                        child: Icon(Icons.image, color: Colors.grey),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 10,
                                      left: 10,
                                      right: 10,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                            decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(5)),
                                            child: Text("R ${item.price?.toStringAsFixed(2)}", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                          ),
                                          GestureDetector(
                                            onTap: () => _addToCartFromRecommended(item),
                                            child: Icon(Icons.shopping_cart, color: Colors.white, size: 20),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 10,
                                      left: 10,
                                      right: 10,
                                      child: Text(
                                        item.name.toString(),
                                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
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
        child: ElevatedButton(
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
            mainAxisSize: MainAxisSize.min,
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