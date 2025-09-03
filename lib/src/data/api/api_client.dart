import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/app_constants.dart';

class ApiClient extends GetConnect implements GetxService{
  late String token;
  final String appBaseUrl;
  late SharedPreferences sharedPreferences;

  late Map<String, String> _mainHeaders;

  ApiClient({required this.appBaseUrl, required this.sharedPreferences}){
    baseUrl =appBaseUrl;
    timeout = Duration(seconds: 30);
    //token =AppConstants.TOKEN;
    //   token = sharedPreferences.getString(AppConstants.TOKEN)!;
    token = sharedPreferences.getString(AppConstants.TOKEN)??'';
    _mainHeaders ={
      'Content-type' :'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  void updateHeader(String token){
    _mainHeaders ={
      'Content-type' :'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }
  //get method

  Future<Response> getData(String uri, {Map<String, String>? headers}) async {
    print("🔹 ApiClient.getData() - Requesting URL: $baseUrl$uri");

    try {
      Response response = await get(uri, headers: headers ?? _mainHeaders);
      print("🔹 ApiClient.getData() - Response Status: ${response.statusCode}");
      print("🔹 ApiClient.getData() - Response: ${response.body}");

      if (response.statusCode == 200) {
        print("🔹 API call successful!");
      } else {
        print("❌ API call failed with status code: ${response.statusCode}");
      }
      return response;
    } catch (e) {
      print("❌ ApiClient.getData() - Error: $e");
      return Response(statusCode: 500, statusText: "Error: $e");
    }
  }

}
