import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';

import '../../constants/colors.dart';
import '../../controllers/single_product_controller.dart';
import '../../utils/dimensions.dart';
import '../../widgets/big_text.dart';
import '../../widgets/category_scroll_widget.dart';
import '../../widgets/single_product_card_widget.dart';
import '../../widgets/small_text.dart';
import '../food_scroll_horizontal/filter_scroll.dart';

class MainFoodPage extends StatefulWidget {
  const MainFoodPage({super.key});

  @override
  State<MainFoodPage> createState() => _MainFoodPageState();
}

class _MainFoodPageState extends State<MainFoodPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryHeight = (Dimensions.pageViewTextContainer + 220) ?? 250;
    final filterHeight = 60;
    final headerHeight = 300;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: headerHeight.toDouble(),
              floating: false,
              pinned: false,
              backgroundColor: Colors.transparent, // FIX: Make app bar background transparent
              elevation: 0, // FIX: Remove shadow
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.orangeColor,
                        AppColors.gradient2,
                      ],
                    ),
                  ),
                  padding: EdgeInsets.only(
                    left: Dimensions.width20,
                    right: Dimensions.width20,
                    top: Dimensions.height45 + 20,
                  ),
                  child: Column(
                    children: [
                      // Location + cart row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: AppColors.gradient2,
                                ),
                                child: Center(
                                  child: Image.asset(
                                    'assets/icons/menus.png',
                                    width: 20,
                                    height: 20,
                                    fit: BoxFit.contain,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                              Gap(Dimensions.width15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  BigText(text: 'Location', color: AppColors.white),
                                  SmallText(text: 'Bitsen, Tanjungbalai', color: AppColors.white),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: AppColors.gradient1,
                            ),
                            child: Center(
                              child: Image.asset(
                                'assets/icons/shopping-cart.png',
                                width: 20,
                                height: 20,
                                fit: BoxFit.contain,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      Gap(Dimensions.height30),

                      // Search row
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xff242424),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  children: [
                                    Icon(Icons.search, size: 20, color: const Color(0xFF999999)),
                                    SizedBox(width: Dimensions.width10),
                                    Expanded(
                                      child: Text(
                                        'Search coffee',
                                        style: TextStyle(
                                          fontSize: Dimensions.font16,
                                          color: const Color(0xFF999999),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: Dimensions.width10),
                          Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: AppColors.orangeColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: Image.asset(
                                'assets/icons/address-card.png',
                                width: 18,
                                height: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: Stack(
          children: [
            // Main content area
            SingleChildScrollView(
              child: Column(
                children: [
                  // Spacer to account for the overlapping category
                  SizedBox(height: categoryHeight * 0.6),

                  // Filter section
                  Container(
                    height: filterHeight.toDouble(),
                    margin: EdgeInsets.symmetric(horizontal: Dimensions.width20),
                    child: FilterScroll(),
                  ),

                  // Product List
                  Container(
                    margin: EdgeInsets.only(
                      top: Dimensions.height20,
                      left: Dimensions.width20,
                      right: Dimensions.width20,
                    ),
                    child: GetBuilder<SingleProductController>(
                      builder: (singleProductController) {
                        if (!singleProductController.isLoaded) {
                          return Container(
                            height: 200,
                            child: const Center(child: CircularProgressIndicator()),
                          );
                        }

                        return ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: singleProductController.singleProductList.length,
                          itemBuilder: (context, index) {
                            return SingleProductCard(
                              product: singleProductController.singleProductList[index],
                              controller: singleProductController,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Overlapping Category Section
            Positioned(
              top: -categoryHeight * 0.4, // This creates the overlap effect
              left: Dimensions.width20,
              right: Dimensions.width20,
              child: Container(
                height: categoryHeight,
                // REMOVED: White background and shadow
                child: const CategoryScrollWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}