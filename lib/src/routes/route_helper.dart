import 'package:get/get.dart';
import 'package:iam/src/controllers/cart_controller.dart';
import 'package:iam/src/controllers/order_controller.dart'; // Add this import
import 'package:iam/src/data/repository/cart_repo.dart';
import 'package:iam/src/data/repository/orders_repo.dart'; // Add this import
import 'package:iam/src/pages/cart/cart_page.dart';
import 'package:iam/src/pages/food_details/single_product_details.dart';
import 'package:iam/src/pages/user/user_home_page.dart';

import '../controllers/auth/auth_middleware.dart';
import '../data/api/api_client.dart';
import '../pages/cart/wish_list_page.dart';
import '../pages/food_details/category_food_details.dart';
import '../pages/home/home_page.dart';
import '../pages/orders/checkout_page.dart';
import '../pages/orders/orders_page.dart';
import '../pages/user/login_page.dart';
import '../pages/user/sign_up_page.dart';
import '../pages/wishlist/wishlist_page.dart';
import '../utils/app_constants.dart';

class RouteHelper {
 static const String initialPage ='/';
 static const String categoryFood= '/categoryFood';
 static const String singleProduct='/singleProduct';
 static const String wishList = '/wish-list';
 static const String cartPage ='/cart';
 static const String ordersPage = '/orders';
 static const String checkoutPage = '/checkout';
 static const String orderSuccess = '/order-success';

 //auth
 static const String signUpPage = '/sign-up';
 static const String loginPage = '/login';
 static const String userHomePage = '/user-profile';
 static const String wishlistPage = '/wishlist';


 static String getInitialPage()=>initialPage;
 static String getCategoryFood(int pageId, String page)=>'$categoryFood?pageId=$pageId&page=$page';
 static String getSingleProduct(int pageId, String page)=>'$singleProduct?pageId=$pageId&page=$page';
 static String getWishListPage()=>wishList;
 static String getCartPage()=>cartPage;
 static String getOrdersPage() => ordersPage;
 static String getCheckoutPage() => checkoutPage;
 static String getOrderSuccessPage() => orderSuccess;

 //auth
 static String getSignUpPage()=>signUpPage;
 static String getLoginPage() => loginPage;
 static String getUserProfilePage()=>userHomePage;

 static String getWishlistPage() => wishlistPage;
 static List<GetPage> routes =[
  GetPage(
   name: initialPage,
   page: () => HomePage(),
   middlewares: [AuthMiddleware()],
  ),
  GetPage(
   name: wishlistPage,
   page: () => WishlistPage(),
  ),
  GetPage(name: categoryFood, page: (){
   var pageId = Get.parameters['pageId'];
   var page =Get.parameters['page'];
   return CategoryFoodDetails(pageId: int.parse(pageId!), page:page!);
  }),
  GetPage(name: singleProduct, page: (){
   var pageId = Get.parameters['pageId'];
   var page =Get.parameters['page'];
   return SingleProductDetails(pageId: int.parse(pageId!), page:page!);
  }),
  GetPage(name: wishList, page: (){
   return WishListPage();
  }),
  GetPage(
   name: cartPage,
   page: () => CartPage(),
   binding: BindingsBuilder(() {
    if (!Get.isRegistered<CartController>()) {
     Get.lazyPut(() => CartRepo(apiClient: Get.find(), sharedPreferences: Get.find()));
     Get.lazyPut(() => CartController(cartRepo: Get.find()));
    }
   }),
  ),
  // In route_helper.dart - update the ordersPage route
  GetPage(
   name: ordersPage,
   page: () => OrdersPage(),
   binding: BindingsBuilder(() {
    print('🔧 Initializing dependencies for OrdersPage...');

    // Ensure all dependencies are available
    if (!Get.isRegistered<ApiClient>()) {
     Get.lazyPut(() => ApiClient(appBaseUrl: AppConstants.BASE_URL, sharedPreferences: Get.find()));
    }

    if (!Get.isRegistered<OrderRepo>()) {
     Get.lazyPut(() => OrderRepo(apiClient: Get.find()));
    }

    if (!Get.isRegistered<OrderController>()) {
     Get.lazyPut(() => OrderController(orderRepo: Get.find()));
    }

    print('✅ OrdersPage dependencies initialized');
   }),
  ),
  GetPage(name: checkoutPage, page: () => CheckoutPage()),
  GetPage(name: orderSuccess, page: () => OrderSuccessPage()),
  GetPage(name: signUpPage, page: ()=>SignUpPage()),
  GetPage(
   name: userHomePage,
   page: () => UserHomePage(),
   middlewares: [AuthMiddleware()],
  ),
  GetPage(name: loginPage, page: () => LoginPage()),
 ];
}