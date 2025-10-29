import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam/src/pages/wishlist/wishlist_page.dart';
import '../../constants/colors.dart';
import '../../controllers/order_controller.dart';
import '../cart/cart_page.dart';
import '../main_page/main_food_page.dart';
import '../user/user_home_page.dart';
import '../orders/orders_page.dart'; // Import orders page
import '../../controllers/wishlist_controller.dart';
import '../../controllers/cart_controller.dart'; // Import cart controller for badge

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const MainFoodPage();
      case 1:
        return const WishlistPage();
      case 2:
        return const OrdersPage(); // Changed from Cart to Orders
      case 3:
        return const CartPage(); // Moved Cart to position 3
      case 4:
        return const UserHomePage(); // Moved Profile to position 4
      default:
        return const Center(child: Text('Page not found'));
    }
  }

  void onTapNav(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.only(bottom: 86),
        child: _buildPage(_selectedIndex),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: AppColors.iPrimaryColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 15,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMinimalNavItem(0, Icons.home_outlined, Icons.home_filled, 'Home'),
              _buildWishlistNavItem(1),
              _buildOrdersNavItem(2), // New Orders nav item
              _buildCartNavItem(3), // Cart with badge
              _buildMinimalNavItem(4, Icons.account_circle_outlined, Icons.account_circle, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalNavItem(int index, IconData outlineIcon, IconData filledIcon, String label) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => onTapNav(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppColors.iSecondaryColor.withOpacity(0.2) : Colors.transparent,
            ),
            child: Icon(
              isSelected ? filledIcon : outlineIcon,
              size: 22,
              color: isSelected ? AppColors.iSecondaryColor : AppColors.textColor.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.iSecondaryColor : AppColors.textColor.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistNavItem(int index) {
    bool isSelected = _selectedIndex == index;

    return GetBuilder<WishlistController>(
      builder: (wishlistController) {
        final wishlistCount = wishlistController.wishlistCount;

        return GestureDetector(
          onTap: () => onTapNav(index),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? AppColors.iSecondaryColor.withOpacity(0.2) : Colors.transparent,
                    ),
                    child: Icon(
                      isSelected ? Icons.favorite : Icons.favorite_outline,
                      size: 22,
                      color: isSelected ? AppColors.iSecondaryColor : AppColors.textColor.withOpacity(0.6),
                    ),
                  ),
                  if (wishlistCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          wishlistCount > 9 ? '9+' : wishlistCount.toString(),
                          style: TextStyle(
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
              const SizedBox(height: 4),
              Text(
                'Wishlist',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.iSecondaryColor : AppColors.textColor.withOpacity(0.6),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrdersNavItem(int index) {
    bool isSelected = _selectedIndex == index;

    return GetBuilder<OrderController>(
      builder: (orderController) {
        // You can add order count badge logic here if needed
        final orderCount = orderController.orders.length; // Or pending orders count

        return GestureDetector(
          onTap: () => onTapNav(index),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? AppColors.iSecondaryColor.withOpacity(0.2) : Colors.transparent,
                    ),
                    child: Icon(
                      isSelected ? Icons.receipt_long : Icons.receipt_long_outlined,
                      size: 22,
                      color: isSelected ? AppColors.iSecondaryColor : AppColors.textColor.withOpacity(0.6),
                    ),
                  ),
                  // Optional: Add badge for pending orders
                  if (orderController.ongoingOrders.isNotEmpty)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          orderController.ongoingOrders.length > 9 ? '9+' : orderController.ongoingOrders.length.toString(),
                          style: TextStyle(
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
              const SizedBox(height: 4),
              Text(
                'Orders',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.iSecondaryColor : AppColors.textColor.withOpacity(0.6),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCartNavItem(int index) {
    bool isSelected = _selectedIndex == index;

    return GetBuilder<CartController>(
      builder: (cartController) {
        final cartCount = cartController.totalItems;

        return GestureDetector(
          onTap: () => onTapNav(index),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? AppColors.iSecondaryColor.withOpacity(0.2) : Colors.transparent,
                    ),
                    child: Icon(
                      isSelected ? Icons.shopping_cart : Icons.shopping_cart_outlined,
                      size: 22,
                      color: isSelected ? AppColors.iSecondaryColor : AppColors.textColor.withOpacity(0.6),
                    ),
                  ),
                  if (cartCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          cartCount > 9 ? '9+' : cartCount.toString(),
                          style: TextStyle(
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
              const SizedBox(height: 4),
              Text(
                'Cart',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.iSecondaryColor : AppColors.textColor.withOpacity(0.6),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}