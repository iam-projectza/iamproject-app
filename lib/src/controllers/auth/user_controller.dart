import 'package:get/get.dart';

import '../../data/repository/firebase/user_repo.dart';
import '../../model/response_model.dart';
import '../../model/user_model.dart';


class UserController extends GetxController implements GetxService {
  final UserRepo userRepo;

  UserController({
    required this.userRepo,
  });

  bool _isloading = false;
  UserModel? _userModel;
  bool get isloading => _isloading;
  UserModel? get userModel => _userModel;

  Future<ResponseModel> getUserInfo() async {


    Response response = await userRepo.getUserinfo();
    late ResponseModel responseModel;
    if (response.statusCode == 200) {
      print('Before user model creation');
      _userModel = UserModel.fromJson(response.body);
      print('User model created: $_userModel');
      update();
      _isloading =true;
      responseModel = ResponseModel(true, 'Successful');
    } else {
      responseModel = ResponseModel(false, response.statusText!);
    }
    update();
    return responseModel;
  }

}