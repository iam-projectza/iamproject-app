import 'package:get/get.dart';
import 'package:iam/src/helper/services/category_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/category_product_controller.dart';
import '../controllers/single_product_controller.dart';
import '../data/api/api_client.dart';
import '../data/repository/category_product_repo.dart';
import '../data/repository/single_product_repo.dart';

import '../utils/app_constants.dart';

// Lightweight Initialization
Future<void> initLightweight() async {
  // Shared Preferences
  final sharedPreferences = await SharedPreferences.getInstance();
  Get.lazyPut(() => sharedPreferences);

  // API Client
  Get.lazyPut(() => ApiClient(appBaseUrl: AppConstants.BASE_URL, sharedPreferences: Get.find()));

  // Repositories
  Get.lazyPut(() => CategoryProductRepo(apiClient: Get.find()));
  Get.lazyPut(() => SingleProductRepo(apiClient: Get.find()));

  // Services - ADD THIS
  Get.lazyPut(() => CategoryService());

  // Controllers
  Get.lazyPut(() => CategoryProductController(categoryProductRepo: Get.find()));
  Get.lazyPut(() => SingleProductController(singleProductRepo: Get.find()));
}

// Heavy Initialization
Future<void> initHeavy() async {
  try {
    // Fetch data from API
    final categoryProductController = Get.find<CategoryProductController>();
    await categoryProductController.getCategoryProductList();

    // Load categories into the service - ADD THIS
    final categoryService = Get.find<CategoryService>();
    categoryService.loadCategories(categoryProductController.categoryProductList);

    final singleProductController = Get.find<SingleProductController>();
    await singleProductController.getSingleProductList();

    print('Heavy initialization complete');
  } catch (e) {
    print('Error during heavy initialization: $e');
  }
}

// Default Initialization (Combines Both)
Future<void> init() async {
  await initLightweight();
  await initHeavy();
}