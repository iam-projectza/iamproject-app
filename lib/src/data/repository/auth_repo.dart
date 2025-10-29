// auth_repo.dart
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/sign_up_model.dart';
import '../../utils/app_constants.dart';
import '../api/api_client.dart';

class AuthRepo extends GetxController {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  AuthRepo({
    required this.apiClient,
    required this.sharedPreferences,
  });

  // Reactive properties
  var isLoggedIn = false.obs;
  var userToken = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Check initial login status
    checkLoginStatus();
  }

  // Check if user is logged in
  void checkLoginStatus() {
    final loggedIn = userLoggedIn();
    isLoggedIn.value = loggedIn;

    if (loggedIn) {
      getUserToken().then((token) {
        userToken.value = token;
        apiClient.token = token;
        apiClient.updateHeader(token);
      });
    }
  }

  Future<Response> registration(SignUpBodyModel signUpBodyModel) async {
    return await apiClient.postData(
        AppConstants.REGISTRATION_URI, signUpBodyModel.toJson());
  }

  bool userLoggedIn() {
    return sharedPreferences.containsKey(AppConstants.TOKEN);
  }

  Future<String> getUserToken() async {
    return sharedPreferences.getString(AppConstants.TOKEN) ?? 'None';
  }

  Future<Response> login(String phone, String password) async {
    final response = await apiClient.postData(
        AppConstants.LOGIN_URI, {'phone': phone, 'password': password});

    if (response.statusCode == 200) {
      // Assuming your API returns a token in the response
      final token = response.body['token']; // Adjust based on your API response
      if (token != null) {
        await saveUserToken(token);
        isLoggedIn.value = true;
        userToken.value = token;
      }
    }

    return response;
  }

  Future<bool> saveUserToken(String token) async {
    apiClient.token = token;
    apiClient.updateHeader(token);
    return await sharedPreferences.setString(AppConstants.TOKEN, token);
  }

  Future<void> saveUserNumberAndPassword(String number, String password) async {
    try {
      await sharedPreferences.setString(AppConstants.PHONE, number);
      await sharedPreferences.setString(AppConstants.PASSWORD, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> logout() async {
    final success = clearSharedData();
    if (success) {
      isLoggedIn.value = false;
      userToken.value = '';
    }
    return success;
  }

  bool clearSharedData() {
    sharedPreferences.remove(AppConstants.TOKEN);
    sharedPreferences.remove(AppConstants.PASSWORD);
    sharedPreferences.remove(AppConstants.PHONE);
    apiClient.token = '';
    apiClient.updateHeader('');
    return true;
  }

  Future<Response> getUserInfo() async {
    // Make an API request to fetch user information
    return await apiClient.getData(AppConstants.USER_INFO_URI); // Adjust URI as needed
  }
}