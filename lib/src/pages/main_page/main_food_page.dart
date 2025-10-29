import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import '../../constants/colors.dart';
import '../../controllers/single_product_controller.dart';
import '../../controllers/wishlist_controller.dart';
import '../../helper/coupon_manager.dart';
import '../../model/single_product_model.dart';
import '../../routes/route_helper.dart';
import '../../utils/dimensions.dart';
import '../../widgets/big_text.dart';
import '../../widgets/category_scroll_widget.dart';
import '../../widgets/single_product_card_widget.dart';
import '../../widgets/small_text.dart';
import '../food_scroll_horizontal/filter_scroll.dart';
import 'package:iam/src/controllers/auth/firebase/authenication_repository.dart';

class MainFoodPage extends StatefulWidget {
  const MainFoodPage({super.key});

  @override
  State<MainFoodPage> createState() => _MainFoodPageState();
}

class _MainFoodPageState extends State<MainFoodPage> {
  final ScrollController _scrollController = ScrollController();
  late AuthenticationRepository authRepo; // ← Changed from final Get.find()

  bool _isScrolled = false;
  bool _showCouponPopup = false;
  bool _hasTriangleImage = true;
  bool _isCheckingCouponStatus = true;

  // Add user data state
  Map<String, dynamic> _userData = {
    'name': 'Loading...',
    'email': 'Loading...',
    'phone': 'Loading...',
    'address': 'Loading...',
  };
  bool _isLoadingUserData = true;

  @override
  void initState() {
    super.initState();

    // ✅ Safely initialize authRepo AFTER GetX bindings are ready
    authRepo = Get.find<AuthenticationRepository>();

    _scrollController.addListener(_onScroll);

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _hasTriangleImage = false;
        });
      }
    });

    _checkCouponStatus();
    _loadUserData();
  }

  void _onScroll() {
    if (_scrollController.offset > 10 && !_isScrolled) {
      setState(() {
        _isScrolled = true;
      });
    } else if (_scrollController.offset <= 10 && _isScrolled) {
      setState(() {
        _isScrolled = false;
      });
    }
  }

  Future<void> _loadUserData() async {
    try {
      final user = authRepo.firebaseUser.value;
      if (user != null) {
        final userDataFromFirestore = await authRepo.getUserData(user.uid);
        if (userDataFromFirestore != null) {
          setState(() {
            _userData = {
              'name': userDataFromFirestore['name'] ?? 'User',
              'email': userDataFromFirestore['email'] ?? 'No email provided',
              'phone': userDataFromFirestore['phone'] ?? 'No phone number',
              'address': userDataFromFirestore['address'] ?? 'Update your address',
            };
          });
        } else {
          _updateUserDataFromFirebase();
        }
      }
    } catch (e) {
      print('Error loading user data in MainFoodPage: $e');
      _updateUserDataFromFirebase();
    } finally {
      setState(() {
        _isLoadingUserData = false;
      });
    }
  }

  void _updateUserDataFromFirebase() {
    final user = authRepo.firebaseUser.value;
    if (user != null) {
      setState(() {
        _userData = {
          'name': user.displayName ?? 'User',
          'email': user.email ?? 'No email provided',
          'phone': 'No phone number',
          'address': 'Update your address',
        };
      });
    }
  }

  String get _userAddress {
    if (_isLoadingUserData) return 'Loading...';
    final address = _userData['address'];
    if (address != null && address != 'Loading...' && address != 'Update your address') {
      return address;
    }
    return 'Update your address in profile';
  }

  String get _userDisplayName {
    if (_userData['name'] != null && _userData['name'] != 'Loading...') {
      return _userData['name'];
    }
    final user = authRepo.firebaseUser.value;
    final displayName = user?.displayName;
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }
    final email = user?.email;
    if (email != null && email.isNotEmpty) {
      return email.split('@').first;
    }
    return 'User';
  }

  Future<void> _checkCouponStatus() async {
    final hasCopied = await CouponManager.hasCopiedCoupon();
    if (!hasCopied) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showCouponPopup = true;
            _isCheckingCouponStatus = false;
          });
        }
      });
    } else {
      setState(() {
        _isCheckingCouponStatus = false;
      });
    }
  }

  Future<void> _copyCouponCode() async {
    await CouponManager.setCouponCopied();
    setState(() {
      _showCouponPopup = false;
    });
    Get.snackbar(
      'Copied!',
      'Coupon code copied to clipboard',
      backgroundColor: AppColors.iAccentColor ?? Colors.green,
      colorText: AppColors.iWhiteColor ?? Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildAppBarContent() {
    final width10 = Dimensions.width10 ?? 10.0;
    final width15 = Dimensions.width15 ?? 15.0;

    return SafeArea(
      bottom: false,
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
                    text: _userAddress,
                    color: AppColors.white ?? Colors.white,
                    size: 12,
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              GetBuilder<WishlistController>(
                init: WishlistController(), // ✅ Ensure controller exists
                builder: (wishlistController) {
                  return GestureDetector(
                    onTap: () => Get.toNamed(RouteHelper.wishlistPage),
                    child: Container(
                      width: 45,
                      height: 45,
                      margin: EdgeInsets.only(right: width10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: (AppColors.gradient1 ?? Colors.grey).withOpacity(0.8),
                      ),
                      child: Center(
                        child: Stack(
                          children: [
                            Icon(
                              Icons.favorite_outline,
                              size: 20,
                              color: AppColors.white ?? Colors.white,
                            ),
                            if (wishlistController.wishlistCount > 0)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    wishlistController.wishlistCount > 9
                                        ? '9+'
                                        : wishlistController.wishlistCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              GestureDetector(
                onTap: () => Get.toNamed(RouteHelper.getCartPage()),
                child: Container(
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
              ),
            ],
          ),
        ],
      ),
    );
  }

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
            return Container(width: size, height: size);
          },
        )
            : Container(width: size, height: size),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  floating: false,
                  snap: false,
                  expandedHeight: 0.0,
                  backgroundColor: _isScrolled ? (AppColors.iPrimaryColor ?? Colors.blue) : Colors.transparent,
                  elevation: 0,
                  toolbarHeight: kToolbarHeight,
                  title: _isScrolled ? _buildAppBarContent() : null,
                  flexibleSpace: _isScrolled
                      ? null
                      : FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: Container(
                      color: Colors.transparent,
                      child: _buildAppBarContent(),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      if (_isScrolled) SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top),
                      Padding(
                        padding: EdgeInsets.only(
                          left: width20,
                          right: width20,
                          top: _isScrolled ? height15 : height30,
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
                                          style: TextStyle(fontSize: 16, color: Color(0xFF999999)),
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
                      Gap(height30),
                      const CategoryScrollWidget(),
                      Container(
                        padding: EdgeInsets.only(left: width20, right: width20),
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
                            Gap(10),
                            const FilterScroll(),
                          ],
                        ),
                      ),
                      Gap(30),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: width20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                            GetBuilder<SingleProductController>(
                              builder: (controller) {
                                if (!controller.isLoaded) {
                                  return MediaQuery.removePadding(
                                    context: context,
                                    removeTop: true,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: 3,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: EdgeInsets.only(
                                            top: index == 0 ? 8.0 : height15 - 10,
                                            bottom: height10,
                                          ),
                                          child: SingleProductCard(
                                            product: SingleProductModel(),
                                            controller: controller,
                                            isLoading: true,
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                }

                                final products = controller.singleProductList;
                                if (products.isEmpty) {
                                  return Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(vertical: height30),
                                      child: Column(
                                        children: [
                                          Icon(Icons.search_off, size: 50, color: Colors.grey[400]),
                                          SizedBox(height: height10),
                                          Text(
                                            controller.isFiltering && controller.filteredListEmpty
                                                ? 'No products found in "${controller.selectedCategoryName}" category'
                                                : 'No products available',
                                            style: TextStyle(color: Colors.grey[600], fontSize: 16),
                                            textAlign: TextAlign.center,
                                          ),
                                          if (controller.isFiltering && controller.filteredListEmpty)
                                            TextButton(
                                              onPressed: controller.resetFilter,
                                              child: const Text('Show All Products'),
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
          if (_showCouponPopup)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: GestureDetector(
                  onTap: () => setState(() => _showCouponPopup = false),
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                    child: Center(
                      child: GestureDetector(
                        onTap: () {},
                        child: Stack(
                          children: [
                            _buildTriangleDecoration(
                              alignment: Alignment.topRight,
                              size: 80,
                              opacity: 0.3,
                              color: (AppColors.iSecondaryColor ?? Colors.blue).withOpacity(0.6),
                            ),
                            _buildTriangleDecoration(
                              alignment: Alignment.bottomLeft,
                              size: 60,
                              opacity: 0.2,
                              color: (AppColors.iAccentColor ?? Colors.green).withOpacity(0.5),
                            ),
                            Container(
                              width: 300,
                              decoration: BoxDecoration(
                                color: AppColors.iCardBgColor ?? Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 4),
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
                                            onTap: () => setState(() => _showCouponPopup = false),
                                            child: Container(
                                              width: 36,
                                              height: 36,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: (AppColors.gradient2 ?? Colors.grey).withOpacity(0.8),
                                              ),
                                              child: Icon(
                                                Icons.close,
                                                size: 20,
                                                color: AppColors.white ?? Colors.white,
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
                                                  color: AppColors.iWhiteColor ?? Colors.white,
                                                  height: 1.2,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 16),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Use the coupon get 25% discount',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: AppColors.textColor ?? Colors.black,
                                        height: 1.4,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 24),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: (AppColors.iSecondaryColor ?? Colors.blue).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: (AppColors.iSecondaryColor ?? Colors.blue).withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        CouponManager.couponCode,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.iSecondaryColor ?? Colors.blue,
                                          letterSpacing: 1.5,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: _copyCouponCode,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.iSecondaryColor ?? Colors.blue,
                                          foregroundColor: AppColors.iWhiteColor ?? Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          elevation: 0,
                                          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                                        ),
                                        child: const Text('COPY CODE'),
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