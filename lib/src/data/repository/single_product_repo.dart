
import 'package:get/get.dart';

import '../../utils/app_constants.dart';
import '../api/api_client.dart';

class SingleProductRepo extends GetxService {
  final ApiClient apiClient;
  SingleProductRepo({required this.apiClient});
  Future<Response> getSingleProductList() async{
    print("SingleProductRepo.getSingleProductList() called!");

    return await apiClient.getData(AppConstants.SINGLE_PRODUCT_URI);
  }
}