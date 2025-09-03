
import 'package:get/get.dart';

import '../../utils/app_constants.dart';
import '../api/api_client.dart';

class CategoryProductRepo extends GetxService {
  final ApiClient apiClient;
  CategoryProductRepo({required this.apiClient});
  Future<Response> getCategoryProductList() async{
    print("PopularProductRepo.getPopularProductList() called!");

    return await apiClient.getData(AppConstants.CATEGORY_URI);
  }
}