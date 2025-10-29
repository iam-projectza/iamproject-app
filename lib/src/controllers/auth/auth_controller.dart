
import 'package:get/get.dart';

import '../../data/repository/auth_repo.dart';
import '../../model/response_model.dart';
import '../../model/sign_up_model.dart';
import '../../model/user_model.dart';


class AuthController extends GetxController implements GetxService {
  final AuthRepo authRepo;

  AuthController({
    required this.authRepo,
  });

  UserModel? _userModel;

  UserModel? get userModel => _userModel;
  bool _isloading = false;

  bool get isloading => _isloading;

  Future<ResponseModel> registration(SignUpBodyModel signUpBodyModel) async {
    _isloading = true;
    update();
    Response response = await authRepo.registration(signUpBodyModel);
    late ResponseModel responseModel;
    if (response.statusCode == 200) {
      authRepo.saveUserToken(response.body['token']);
      responseModel = ResponseModel(true, response.body['token']);
    } else {
      responseModel = ResponseModel(false, response.statusText!);
    }
    _isloading = false;
    update();
    return responseModel;
  }



  Future<ResponseModel> login(String phone, String password) async {
    // print('Getting token');
    // print(jsonEncode(authRepo.getUserToken().toString()));
    _isloading = true;
    update();
    Response response = await authRepo.login(phone, password);
    late ResponseModel responseModel;
    if (response.statusCode == 200) {
      authRepo.saveUserToken(response.body['token']);

      print('My token is ' + response.body['token']);

      responseModel = ResponseModel(true, response.body['token']);
    } else {
      responseModel = ResponseModel(false, response.statusText!);
    }
    _isloading = false;
    update();
    return responseModel;
  }









  void saveUserNumberAndPassword(String number, String password) {
    authRepo.saveUserNumberAndPassword(number, password);
  }

  bool userLoggedIn() {
    return authRepo.userLoggedIn();
  }

  bool clearSharedData() {
    return authRepo.clearSharedData();
  }


}
