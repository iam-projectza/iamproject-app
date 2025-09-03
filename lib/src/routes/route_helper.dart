
import 'package:get/get.dart';
import 'package:iam/src/pages/food_details/single_product_details.dart';

import '../pages/cart/wish_list_page.dart';
import '../pages/food_details/category_food_details.dart';
import '../pages/home/home_page.dart';

class RouteHelper {

 static const String initialPage ='/';
 static const String categoryFood= '/categoryFood';
 static const String singleProduct='/singleProduct';
 static const String wishList = '/wish-list';

 static String getInitialPage()=>initialPage;
 static String getCategoryFood(int pageId, String page)=>'$categoryFood?pageId=$pageId&page=$page';
 static String getSingleProduct(int pageId, String page)=>'$singleProduct?pageId=$pageId&page=$page';
 static String getWishListPage()=>'$wishList';

 static List<GetPage> routes =[
   GetPage(name: initialPage, page: ()=>HomePage()),
  GetPage(name: categoryFood, page: (){
   var pageId = Get.parameters['pageId'];
   var page =Get.parameters['page'];

   return CategoryFoodDetails(pageId: int.parse(pageId!), page:page!);
  },),

  GetPage(name: singleProduct, page: (){
   var pageId = Get.parameters['pageId'];
   var page =Get.parameters['page'];

   return SingleProductDetails(pageId: int.parse(pageId!), page:page!);
  },

  ),
  GetPage(name: wishList, page: (){
   return WishListPage();
  },
   //  transition: Transition.fadeIn,
  ),

 ];


}