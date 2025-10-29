import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam/src/controllers/auth/firebase/authenication_repository.dart';
import 'package:iam/src/widgets/big_text.dart';
import 'package:iam/src/widgets/small_text.dart';
import '../../constants/colors.dart';
import '../../utils/dimensions.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthenticationRepository authRepo = Get.find<AuthenticationRepository>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _isLoading = false.obs;
  final _isGoogleLoading = false.obs;
  final _isFacebookLoading = false.obs;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      _isLoading.value = true;

      final error = await authRepo.loginWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (error != null) {
        Get.snackbar(
          'Login Failed',
          error,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      _isLoading.value = false;
    }
  }

  void _loginWithGoogle() async {
    _isGoogleLoading.value = true;
    try {
      final user = await authRepo.signInWithGoogle();
      if (user != null) {
        Get.offAllNamed('/');
      }
    } catch (e) {
      Get.snackbar(
        'Google Sign-In Failed',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isGoogleLoading.value = false;
    }
  }

  void _loginWithFacebook() async {
    _isFacebookLoading.value = true;
    try {
      // Add your Facebook login implementation here
      // For now, we'll simulate a delay and show a message
      await Future.delayed(const Duration(seconds: 2));
      Get.snackbar(
        'Coming Soon',
        'Facebook login will be available soon',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Facebook Sign-In Failed',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isFacebookLoading.value = false;
    }
  }

  void _forgotPassword() {
    if (_emailController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your email first',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.defaultDialog(
      title: 'Reset Password',
      content: Text('Send password reset link to ${_emailController.text}?'),
      confirm: ElevatedButton(
        onPressed: () async {
          final error = await authRepo.sendPasswordResetEmail(_emailController.text.trim());
          if (error != null) {
            Get.snackbar(
              'Error',
              error,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          } else {
            Get.back();
            Get.snackbar(
              'Success',
              'Password reset email sent',
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          }
        },
        child: const Text('Send'),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Cancel'),
      ),
    );
  }

  void _navigateToSignUp() {
    Get.toNamed('/sign-up');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [
              AppColors.gradient2,
              AppColors.darkColor,
              AppColors.iSecondaryColor
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(Dimensions.height20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo
                SizedBox(
                  width: 120,
                  height: 120,

                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/logo/ic_launcher.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.iSecondaryColor,
                          child: const Icon(
                            Icons.restaurant,
                            size: 60,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                SizedBox(height: Dimensions.height30),

                BigText(
                  text: 'Welcome Back',
                  size: 28,
                  color: AppColors.white,
                ),

                SizedBox(height: Dimensions.height10),

                SmallText(
                  text: 'Sign in to continue',
                  color: AppColors.white.withOpacity(0.8),
                  size: 16,
                ),

                SizedBox(height: Dimensions.height30),

                Container(
                  padding: EdgeInsets.all(Dimensions.height20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: AppColors.white),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(color: AppColors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.iSecondaryColor),
                            ),
                            prefixIcon: Icon(Icons.email, color: AppColors.white),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: Dimensions.height20),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          style: TextStyle(color: AppColors.white),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(color: AppColors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.iSecondaryColor),
                            ),
                            prefixIcon: Icon(Icons.lock, color: AppColors.white),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: Dimensions.height10),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _forgotPassword,
                            child: SmallText(
                              text: 'Forgot Password?',
                              color: AppColors.white,
                            ),
                          ),
                        ),

                        SizedBox(height: Dimensions.height20),

                        // Login Button
                        Obx(() => SizedBox(
                          width: double.infinity,
                          child: _isLoading.value
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.iSecondaryColor,
                              padding: EdgeInsets.symmetric(
                                vertical: Dimensions.height15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 3,
                              shadowColor: Colors.black.withOpacity(0.3),
                            ),
                            child: SmallText(
                              text: 'Login',
                              size: 18,
                              color: AppColors.white,
                            ),
                          ),
                        )),

                        SizedBox(height: Dimensions.height20),

                        // Divider with "or" text
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: AppColors.white.withOpacity(0.3),
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: Dimensions.width10),
                              child: SmallText(
                                text: 'or continue with',
                                color: AppColors.white.withOpacity(0.7),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: AppColors.white.withOpacity(0.3),
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: Dimensions.height20),

                        // Google Login Button
                        Obx(() => SizedBox(
                          width: double.infinity,
                          child: _isGoogleLoading.value
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                            onPressed: _loginWithGoogle,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: Dimensions.height15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 2,
                              shadowColor: Colors.black.withOpacity(0.2),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/icons/google.png',
                                  width: 24,
                                  height: 24,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.g_mobiledata,
                                      size: 24,
                                      color: Colors.red,
                                    );
                                  },
                                ),
                                SizedBox(width: Dimensions.width10),
                                SmallText(
                                  text: 'Sign in with Google',
                                  size: 16,
                                  color: Colors.black87,
                                ),
                              ],
                            ),
                          ),
                        )),

                        SizedBox(height: Dimensions.height15),

                        // Facebook Login Button
                        Obx(() => SizedBox(
                          width: double.infinity,
                          child: _isFacebookLoading.value
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                            onPressed: _loginWithFacebook,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1877F2),
                              padding: EdgeInsets.symmetric(
                                vertical: Dimensions.height15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 2,
                              shadowColor: Colors.black.withOpacity(0.2),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/icons/facebook.png',
                                  width: 24,
                                  height: 24,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.facebook,
                                      size: 24,
                                      color: Colors.white,
                                    );
                                  },
                                ),
                                SizedBox(width: Dimensions.width10),
                                SmallText(
                                  text: 'Sign in with Facebook',
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        )),

                        SizedBox(height: Dimensions.height20),

                        // Sign up link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SmallText(
                              text: "Don't have an account?",
                              color: AppColors.white,
                            ),
                            TextButton(
                              onPressed: _navigateToSignUp,
                              child: SmallText(
                                text: 'Sign Up',
                                color: AppColors.iSecondaryColor,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}