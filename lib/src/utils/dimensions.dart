import 'package:get/get.dart';

class Dimensions {
  static double screenheight = Get.context!.height;
  static double screenWidth = Get.context!.width;

  static double pageView = screenheight/2.64;
  static double pageViewContainer = screenheight/3.84; //i can use any scale factor
  static double pageViewTextContainer = screenheight/7.03;

  //dynamic height padding and margin
  static double height10 = screenheight/84.4;
  static double height20 = screenheight/42.2;
  static double height15 = screenheight/66.27;
  static double height30 = screenheight/28.13; // already exists, used in PopularFoodDetails
  static double height45 = screenheight/18.76;

  //fonts
  static double font20 = screenheight/46.2; // already exists, used in PopularFoodDetails
  static double font26 = screenheight/32.46;
  static double font16 = screenheight/52.75;

  static double radius20 = screenheight/46.2;
  static double radius30 = screenheight/28.13;
  static double radius15 = screenheight/56.27;

  // New radius values
  static double radius40 = screenheight/21.1; // Added for circular avatar outer radius
  static double radius35 = screenheight/24.0; // Added for circular avatar inner radius

  //dynamic width padding and margin
  static double width10 = screenheight/84.4;
  static double width20 = screenheight/42.2; // already exists, used in PopularFoodDetails
  static double width15 = screenheight/66.27;
  static double width30 = screenheight/28.13;

  //icon size
  static double iconSize24 = screenheight/35.17;
  static double iconSize16 = screenheight/52.75; // already exists, used in PopularFoodDetails

  //list view size
  static double listViewImgSize = screenWidth/3.80;
  static double listViewTextSize = screenWidth/5.2;

  //popular food
  static double popularFoodImgSize = screenheight/2.41;

  //bottom height
  static double bottomHeightBar = screenheight/7.03;

  //splash screen images
  static double splashImage = screenheight/3.38;
}
