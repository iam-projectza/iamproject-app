import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/app_constants.dart';

class ApiClient extends GetConnect implements GetxService {
  late String token;
  final String appBaseUrl;
  late SharedPreferences sharedPreferences;

  late Map<String, String> _mainHeaders;

  // Add public getter for headers
  Map<String, String> get mainHeaders => _mainHeaders;

  ApiClient({required this.appBaseUrl, required this.sharedPreferences}) {
    baseUrl = appBaseUrl;
    timeout = Duration(seconds: 30);
    token = sharedPreferences.getString(AppConstants.TOKEN) ?? '';
    _mainHeaders = {
      'Content-type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  void updateHeader(String token) {
    _mainHeaders = {
      'Content-type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  // GET method
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

  // POST method - ADD MORE DETAILED DEBUGGING
  Future<Response> postData(String uri, dynamic body, {Map<String, String>? headers}) async {
    print("🚀 ========== API CLIENT POST REQUEST ==========");
    print("🔹 ApiClient.postData() - Requesting URL: $baseUrl$uri");
    print("🔹 ApiClient.postData() - Headers: ${headers ?? _mainHeaders}");
    print("🔹 ApiClient.postData() - Request Body: $body");
    print("📤 Sending POST request...");

    try {
      Response response = await post(uri, body, headers: headers ?? _mainHeaders);

      print("📥 ========== API CLIENT POST RESPONSE ==========");
      print("🔹 ApiClient.postData() - Response Status: ${response.statusCode}");

      // Check for redirect
      if (response.statusCode == 302 || response.statusCode == 301) {
        print("🔄 API POST call was redirected!");
        String? redirectUrl = response.headers?['location'];
        print("🔹 Redirect URL: $redirectUrl");

        // If redirected to main domain, it means the API endpoint doesn't exist
        if (redirectUrl != null && redirectUrl.contains('iamproject.co.za') && !redirectUrl.contains('/api/')) {
          print("❌ API endpoint not found - redirected to main website");
          return Response(
              statusCode: 404,
              statusText: 'API endpoint not found. Check the URL.',
              body: {'error': 'API endpoint not found - redirected to main site'}
          );
        }
      }

      print("🔹 ApiClient.postData() - Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ API POST call successful!");
      } else {
        print("❌ API POST call failed with status code: ${response.statusCode}");
      }

      return response;
    } catch (e, stackTrace) {
      print("💥 ========== API CLIENT POST ERROR ==========");
      print("❌ ApiClient.postData() - Error: $e");
      print("❌ ApiClient.postData() - Stack Trace: $stackTrace");
      return Response(statusCode: 500, statusText: "Error: $e");
    }
  }
  // PUT method
  Future<Response> putData(String uri, dynamic body, {Map<String, String>? headers}) async {
    print("🔹 ApiClient.putData() - Requesting URL: $baseUrl$uri");
    print("🔹 ApiClient.putData() - Request Body: $body");

    try {
      Response response = await put(uri, body, headers: headers ?? _mainHeaders);
      print("🔹 ApiClient.putData() - Response Status: ${response.statusCode}");
      print("🔹 ApiClient.putData() - Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("🔹 API PUT call successful!");
      } else {
        print("❌ API PUT call failed with status code: ${response.statusCode}");
      }
      return response;
    } catch (e) {
      print("❌ ApiClient.putData() - Error: $e");
      return Response(statusCode: 500, statusText: "Error: $e");
    }
  }

  // DELETE method
  Future<Response> deleteData(String uri, {Map<String, String>? headers}) async {
    print("🔹 ApiClient.deleteData() - Requesting URL: $baseUrl$uri");

    try {
      Response response = await delete(uri, headers: headers ?? _mainHeaders);
      print("🔹 ApiClient.deleteData() - Response Status: ${response.statusCode}");
      print("🔹 ApiClient.deleteData() - Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        print("🔹 API DELETE call successful!");
      } else {
        print("❌ API DELETE call failed with status code: ${response.statusCode}");
      }
      return response;
    } catch (e) {
      print("❌ ApiClient.deleteData() - Error: $e");
      return Response(statusCode: 500, statusText: "Error: $e");
    }
  }
}