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
        bottomNavigationBar: BottomNavigationBar(

          selectedItemColor: AppColors.white,
          unselectedItemColor: AppColors.iCardBgColor,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 12.0,
          unselectedFontSize: 12.0,
          currentIndex: _selectedIndex,
          onTap: onTapNav,
          items: [
            BottomNavigationBarItem(
              backgroundColor: AppColors.iPrimaryColor,
              icon: const Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              backgroundColor: AppColors.iPrimaryColor,
              icon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(backgroundColor: AppColors.iPrimaryColor,

              icon: Icon(Icons.remove_shopping_cart_sharp),
              label: 'History',
            ),
            BottomNavigationBarItem(
              backgroundColor: AppColors.iPrimaryColor,
              icon: Icon(Icons.favorite_outlined,
              ),
              label: 'wish-list',
            ),
            BottomNavigationBarItem(
              backgroundColor: AppColors.iPrimaryColor,
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        )
    );
  }

}
