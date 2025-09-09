import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';

import '../../constants/colors.dart';
import '../../controllers/single_product_controller.dart';
import '../../utils/dimensions.dart';
import '../../widgets/app_icon.dart';
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
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 10 && !_isScrolled) {
        setState(() {
          _isScrolled = true;
        });
      } else if (_scrollController.offset <= 10 && _isScrolled) {
        setState(() {
          _isScrolled = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Add null safety checks for Dimensions
    final width20 = Dimensions.width20 ?? 20.0;
    final width10 = Dimensions.width10 ?? 10.0;
    final width15 = Dimensions.width15 ?? 15.0;
    final height30 = Dimensions.height30 ?? 30.0;
    final height15 = Dimensions.height15 ?? 15.0;
    final height10 = Dimensions.height10 ?? 10.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: const Alignment(0.8, 1),
            colors: <Color>[
              AppColors.iSecondaryColor ?? Colors.blue,
              const Color(0xffffffff),
              const Color(0xffffffff),
            ],
            tileMode: TileMode.mirror,
          ),
        ),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Pinned AppBar with Dynamic Background
            SliverAppBar(
              pinned: true,
              expandedHeight: 40.0,
              backgroundColor: _isScrolled ? (AppColors.iSecondaryColor ?? Colors.blue) : Colors.transparent,
              elevation: 0,
              title: Padding(
                padding: EdgeInsets.only(
                  left: width10,
                  right: width10,
                  top: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: AppColors.gradient2 ?? Colors.grey,
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/icons/menus.png',
                              width: 20,
                              height: 20,
                              fit: BoxFit.contain,
                              color: AppColors.white ?? Colors.white,
                            ),
                          ),
                        ),
                        Gap(width15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BigText(text: 'Location', color: AppColors.white ?? Colors.white),
                            SmallText(
                              text: 'Bilzen, Tanjungbalai',
                              color: AppColors.white ?? Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: AppColors.gradient1 ?? Colors.grey,
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
              ),
            ),
            // Scrollable Content
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Search Bar with horizontal padding
                  Padding(
                    padding: EdgeInsets.only(
                      left: width20,
                      right: width20,
                      top: height30,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xff242424),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  Icon(Icons.search, size: 20, color: Color(0xFF999999)),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Search coffee',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF999999),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: AppColors.orangeColor ?? Colors.orange,
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
                  ),
                  // Category Scroll Widget
                  Gap(height30),
                  CategoryScrollWidget(),
                  // Lower Section
                  Container(
                    padding: EdgeInsets.only(
                      left: width20,
                      right: width20,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            BigText(
                              text: 'All Categories',
                              color: AppColors.mainBlackColor ?? Colors.black,
                              size: 18,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SmallText(text: 'See All', size: 16),
                                Image.asset(
                                  'assets/icons/right-arrow.png',
                                  width: 20,
                                  height: 20,
                                  fit: BoxFit.contain,
                                  color: AppColors.orangeColor ?? Colors.orange,
                                ),
                              ],
                            ),
                          ],
                        ),
                        Gap(10),
                        FilterScroll(),
                      ],
                    ),
                  ),
                  Gap(30),
                  // Single Products
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: width20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            BigText(
                              text: 'Single Products',
                              color: AppColors.mainBlackColor ?? Colors.black,
                              size: 18,
                            ),
                            Row(
                              children: [
                                SmallText(text: 'See All', size: 16),
                                Image.asset(
                                  'assets/icons/right-arrow.png',
                                  width: 20,
                                  height: 20,
                                  color: AppColors.orangeColor ?? Colors.orange,
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Product List
                        GetBuilder<SingleProductController>(
                          builder: (controller) {
                            if (!controller.isLoaded) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (controller.singleProductList.isEmpty) {
                              return const Center(child: Text('No products available'));
                            }

                            return MediaQuery.removePadding(
                              context: context,
                              removeTop: true,
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: controller.singleProductList.length,
                                itemBuilder: (context, index) {
                                  final product = controller.singleProductList[index];
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      top: index == 0 ? 8.0 : height15 - 10,
                                      bottom: height10,
                                    ),
                                    child: SingleProductCard(
                                      product: product,
                                      controller: controller,
                                    ),
                                  );
                                },
                              ),
                            );
                          },
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
    );
  }
}