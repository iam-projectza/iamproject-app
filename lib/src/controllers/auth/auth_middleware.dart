import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:iam/src/controllers/auth/firebase/authenication_repository.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final AuthenticationRepository authRepo = Get.find<AuthenticationRepository>();

    // Check if user is authenticated
    if (!authRepo.isSignedIn.value && route != '/login' && route != '/sign-up') {
      // Redirect to login page if not authenticated
      return const RouteSettings(name: '/login');
    }

    // If user is authenticated and trying to access login/signup, redirect to home
    if (authRepo.isSignedIn.value && (route == '/login' || route == '/sign-up')) {
      return const RouteSettings(name: '/');
    }

    // Allow navigation if authenticated
    return null;
  }
}