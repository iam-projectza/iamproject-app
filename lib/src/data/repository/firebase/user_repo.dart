
import 'package:get/get.dart';

import '../../../utils/app_constants.dart';
import '../../api/api_client.dart';
class UserRepo {
  final ApiClient apiClient;
  UserRepo({required this.apiClient});
  Future<Response> getUserinfo() async {
    return await apiClient.getData(AppConstants.USERINFO_URI);
  }
}