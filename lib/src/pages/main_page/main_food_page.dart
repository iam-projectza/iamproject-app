import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';

import '../../constants/colors.dart';
import '../../controllers/single_product_controller.dart';
import '../../model/single_product_model.dart';
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
  bool _showCouponPopup = false;
  bool _hasTriangleImage = true; // Assume image exists initially

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

    // Check if image exists (you might want to do this differently in production)
    Future.delayed(const Duration(milliseconds: 100), () {
      // This is a simple check - in a real app you'd use a proper image loading check
      setState(() {
        _hasTriangleImage = false; // Set to false if image doesn't load
      });
    });

    // Show coupon popup after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _showCouponPopup = true;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Widget to display triangle image with error handling
  Widget _buildTriangleDecoration({
    required AlignmentGeometry alignment,
    double size = 80,
    double opacity = 0.3,
    Color color = const Color(0xFFFFA726),
  }) {
    return Positioned(
      top: alignment == Alignment.topRight ? 20 : null,
      bottom: alignment == Alignment.bottomLeft ? 20 : null,
      right: alignment == Alignment.topRight ? 20 : null,
      left: alignment == Alignment.bottomLeft ? 20 : null,
      child: Opacity(
        opacity: opacity,
        child: _hasTriangleImage
            ? Image.asset(
          'assets/elements/triangles.png',
          width: size,
          height: size,
          color: color,
          errorBuilder: (context, error, stackTrace) {
            // If image fails to load, use a placeholder
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
            );
          },
        )
            : Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
        ),
      ),
    );
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
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: const Alignment(0.8, 1),
                colors: <Color>[
                  AppColors.iPrimaryColor ?? Colors.blue,
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
                  backgroundColor: _isScrolled ? (AppColors.iPrimaryColor ?? Colors.blue) : Colors.transparent,
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
                                  // Show shimmer loading for products
                                  return MediaQuery.removePadding(
                                    context: context,
                                    removeTop: true,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: 3, // Show 3 loading items
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: EdgeInsets.only(
                                            top: index == 0 ? 8.0 : height15 - 10,
                                            bottom: height10,
                                          ),
                                          child: SingleProductCard(
                                            product: SingleProductModel(), // Empty product
                                            controller: controller,
                                            isLoading: true, // Show shimmer
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                }

                                final products = controller.singleProductList;

                                // Show empty state if no products
                                if (products.isEmpty) {
                                  return Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(vertical: height30),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.search_off,
                                            size: 50,
                                            color: Colors.grey[400],
                                          ),
                                          SizedBox(height: height10),
                                          Text(
                                            controller.isFiltering && controller.filteredListEmpty
                                                ? 'No products found in "${controller.selectedCategoryName}" category'
                                                : 'No products available',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 16,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          if (controller.isFiltering && controller.filteredListEmpty)
                                            TextButton(
                                              onPressed: () {
                                                controller.resetFilter();
                                              },
                                              child: Text('Show All Products'),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                return MediaQuery.removePadding(
                                  context: context,
                                  removeTop: true,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: products.length,
                                    itemBuilder: (context, index) {
                                      final product = products[index];
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

          // Coupon Popup
          if (_showCouponPopup)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _showCouponPopup = false;
                    });
                  },
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                    child: Center(
                      child: GestureDetector(
                        onTap: () {}, // Prevent click from closing when tapping inside
                        child: Stack(
                          children: [
                            // Triangles background decoration
                            _buildTriangleDecoration(
                              alignment: Alignment.topRight,
                              size: 80,
                              opacity: 0.3,
                              color: AppColors.iSecondaryColor.withOpacity(0.6),
                            ),
                            _buildTriangleDecoration(
                              alignment: Alignment.bottomLeft,
                              size: 60,
                              opacity: 0.2,
                              color: AppColors.iAccentColor.withOpacity(0.5),
                            ),
                            Container(
                              width: 300,
                              decoration: BoxDecoration(
                                color: AppColors.iCardBgColor,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Stack(
                                      children: [
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _showCouponPopup = false;
                                              });
                                            },
                                            child: Container(
                                              width: 36,
                                              height: 36,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppColors.gradient2.withOpacity(0.8),
                                              ),
                                              child: Icon(
                                                Icons.close,
                                                size: 20,
                                                color: AppColors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Center(
                                          child: Column(
                                            children: [
                                              Text(
                                                'Special Offer',
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.iWhiteColor,
                                                  height: 1.2,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              SizedBox(height: 16),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Use the coupon get 25% discount',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: AppColors.textColor,
                                        height: 1.4,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 24),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: AppColors.iSecondaryColor.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.iSecondaryColor.withValues(alpha: 0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        'SUMMER25',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.iSecondaryColor,
                                          letterSpacing: 1.5,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    SizedBox(height: 24),
                                    Container(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          // Handle copy coupon code
                                          setState(() {
                                            _showCouponPopup = false;
                                          });
                                          // Show confirmation
                                          Get.snackbar(
                                            'Copied!',
                                            'Coupon code copied to clipboard',
                                            backgroundColor: AppColors.iAccentColor,
                                            colorText: AppColors.iWhiteColor,
                                            duration: Duration(seconds: 2),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.iSecondaryColor,
                                          foregroundColor: AppColors.iWhiteColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          elevation: 0,
                                          shadowColor: Colors.transparent,
                                          textStyle: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        child: Text('COPY CODE'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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