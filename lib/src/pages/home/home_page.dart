import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../main_page/main_food_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex =0;

  List pages = [
    MainFoodPage(),
    // CartPage(),
    // CartHistory(),
    // WishListPage(),
    // AccountPage(),

    //Text('cart'),
    Text('history'),
    Text('wishlist'),
    Text('account'),


  ];

  void onTapNav(int index){
    setState(() {
      _selectedIndex =index;
    });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Container(
          height: 65,
          decoration: BoxDecoration(
            color: AppColors.iPrimaryColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 15,
                spreadRadius: 1,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMinimalNavItem(0, Icons.home_outlined, Icons.home_filled, 'Home'),
              _buildMinimalNavItem(1, Icons.shopping_cart_outlined, Icons.shopping_cart, 'Cart'),
              _buildMinimalNavItem(2, Icons.history_outlined, Icons.history, 'History'),
              _buildMinimalNavItem(3, Icons.favorite_outlined, Icons.favorite, 'Wishlist'),
              _buildMinimalNavItem(4, Icons.person_outlined, Icons.person, 'Profile'),
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
          SizedBox(height: 4),
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
}
