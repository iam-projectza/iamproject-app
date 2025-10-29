import 'package:get/get.dart';
import 'package:iam/src/helper/services/category_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/auth/auth_controller.dart';
import '../controllers/auth/firebase/authenication_repository.dart';
import '../controllers/auth/firebase/sign_up_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/category_product_controller.dart';
import '../controllers/order_controller.dart';
import '../controllers/single_product_controller.dart';
import '../controllers/wishlist_controller.dart';
import '../data/api/api_client.dart';
import '../data/repository/auth_repo.dart';
import '../data/repository/cart_repo.dart';
import '../data/repository/category_product_repo.dart';
import '../data/repository/orders_repo.dart';
import '../data/repository/single_product_repo.dart';
import '../utils/app_constants.dart';

Future<void> initLightweight() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  Get.put(sharedPreferences); // Use Get.put for immediate availability

  Get.put(ApiClient(appBaseUrl: AppConstants.BASE_URL, sharedPreferences: sharedPreferences));

  // Repos
  Get.put(CategoryProductRepo(apiClient: Get.find()));
  Get.put(SingleProductRepo(apiClient: Get.find()));
  Get.put(CartRepo(sharedPreferences: sharedPreferences, apiClient: Get.find()));
  Get.put(OrderRepo(apiClient: Get.find()));
  Get.put(AuthRepo(apiClient: Get.find(), sharedPreferences: sharedPreferences));

  // Services & Controllers
  Get.put(CategoryService());
  Get.put(SignUpController());
  Get.put(AuthenticationRepository());

  Get.put(CategoryProductController(categoryProductRepo: Get.find()));
  Get.put(SingleProductController(singleProductRepo: Get.find()));
  Get.put(CartController(cartRepo: Get.find()));
  Get.put(OrderController(orderRepo: Get.find()));
  Get.put(AuthController(authRepo: Get.find()));
  Get.put(WishlistController()); // ✅ Ensure this is PUT, not lazyPut if used early
}
Future<void> initHeavy() async {
  try {
    // Fetch data from API
    final categoryProductController = Get.find<CategoryProductController>();
    await categoryProductController.getCategoryProductList();

    // Load categories into the service
    final categoryService = Get.find<CategoryService>();
    categoryService.loadCategories(categoryProductController.categoryProductList);

    final singleProductController = Get.find<SingleProductController>();
    await singleProductController.getSingleProductList();

    print('Heavy initialization complete');
  } catch (e) {
    print('Error during heavy initialization: $e');
  }
}

Future<void> init() async {
  await initLightweight();
  await initHeavy();
}