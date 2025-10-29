import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../model/sign_up_model.dart';
import '../../../routes/route_helper.dart';
import 'authenication_repository.dart';

class SignUpController extends GetxController {
  static SignUpController get to => Get.find();

  // Inject repository and Firestore
  final AuthenticationRepository _authRepo = AuthenticationRepository.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reactive state
  final RxBool _isLoading = false.obs;
  final RxString _message = ''.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  String get message => _message.value;

  @override
  void onReady() {
    // Auto-navigate if user is already signed in
    ever(_authRepo.isSignedIn as RxInterface<Object?>, (isLoggedIn) {
      if (isLoggedIn != null) {
        Get.offAllNamed(RouteHelper.getInitialPage());
      }
    });
    super.onReady();
  }

  // Sign Up with Email & Password + Save Extra Data to Firestore
  Future<bool> signUp(SignUpBodyModel model) async {
    _isLoading.value = true;
    update();

    try {
      // Prepare user data for Firestore
      final userData = {
        'email': model.email,
        'name': model.name,
        'phone': model.phone,
        'address': model.address,
        'role': model.role,
      };

      // 1. Register via Authentication Repository with user data
      String? error = await _authRepo.registerWithEmailAndPassword(
        model.email,
        model.password,
        userData, // Add this parameter
      );

      if (error != null) {
        _message.value = error;
        _isLoading.value = false;
        update();
        return false;
      }

      _message.value = 'Registration successful!';
      _isLoading.value = false;
      update();

      // 2. Navigate based on role
      if (model.role == 1) {
        Get.offAllNamed(RouteHelper.getInitialPage()); // Receiver
      } else if (model.role == 2) {
        Get.offAllNamed(RouteHelper.getInitialPage()); // Giver
      }

      return true;
    } catch (e) {
      _isLoading.value = false;
      update();
      _message.value = 'An unexpected error occurred: $e';
      return false;
    }
  }

  // Optional: Sign out (for testing or logout button)
  Future<void> signOut() async {
    await _authRepo.logout();
  }
}