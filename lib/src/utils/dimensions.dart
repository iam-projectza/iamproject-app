import 'package:get/get.dart';

class Dimensions {
  static double get screenheight => Get.height;
  static double get screenWidth => Get.width;

  static double get pageView => screenheight / 2.64;
  static double get pageViewContainer => screenheight / 3.84;
  static double get pageViewTextContainer => screenheight / 7.03;

  //dynamic height padding and margin
  static double get height10 => screenheight / 84.4;
  static double get height20 => screenheight / 42.2;
  static double get height15 => screenheight / 66.27;
  static double get height30 => screenheight / 28.13;
  static double get height45 => screenheight / 18.76;

  //fonts
  static double get font20 => screenheight / 46.2;
  static double get font26 => screenheight / 32.46;
  static double get font16 => screenheight / 52.75;

  static double get radius20 => screenheight / 46.2;
  static double get radius30 => screenheight / 28.13;
  static double get radius15 => screenheight / 56.27;

  // New radius values
  static double get radius40 => screenheight / 21.1;
  static double get radius35 => screenheight / 24.0;

  //dynamic width padding and margin
  static double get width10 => screenheight / 84.4;
  static double get width20 => screenheight / 42.2;
  static double get width15 => screenheight / 66.27;
  static double get width30 => screenheight / 28.13;

  //icon size
  static double get iconSize24 => screenheight / 35.17;
  static double get iconSize16 => screenheight / 52.75;

  //list view size
  static double get listViewImgSize => screenWidth / 3.80;
  static double get listViewTextSize => screenWidth / 5.2;

  //popular food
  static double get popularFoodImgSize => screenheight / 2.41;

  //bottom height
  static double get bottomHeightBar => screenheight / 7.03;

  //splash screen images
  static double get splashImage => screenheight / 3.38;
}