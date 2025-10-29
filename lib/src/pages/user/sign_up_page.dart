import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam/src/pages/user/login_page.dart';
import '../../constants/colors.dart';
import '../../controllers/auth/firebase/sign_up_controller.dart';
import '../../model/sign_up_model.dart';
import '../../utils/dimensions.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/big_text.dart';
import '../../widgets/custom_loader.dart';
import '../../widgets/show_Custom_snackbar.dart';
import '../../widgets/small_text.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  int selectedRole = 1; // Default role (receiver)

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void updateRole(int role) {
    if (mounted) {
      setState(() {
        selectedRole = role;
      });
    }
  }

  void _registration() {
    // Grab the strings
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final address = addressController.text.trim();

    // Validation
    if (name.isEmpty) {
      showCustomSnackBar('Type in your name', title: 'Name');
    } else if (phone.isEmpty) {
      showCustomSnackBar('Type in your phone number', title: 'Phone');
    } else if (email.isEmpty) {
      showCustomSnackBar('Type in your email', title: 'Email');
    } else if (!GetUtils.isEmail(email)) {
      showCustomSnackBar('Type in your valid email', title: 'Valid Email Address');
    } else if (password.isEmpty) {
      showCustomSnackBar('Type in your password', title: 'Password');
    } else if (address.isEmpty) {
      showCustomSnackBar('Type in your address', title: 'Address');
    } else if (password.length < 6) {
      showCustomSnackBar('Password cannot be less than 6 characters', title: 'Password');
    } else {
      // Create model
      final signUpBodyModel = SignUpBodyModel(
        name: name,
        phone: phone,
        email: email,
        address: address,
        role: selectedRole,
        password: password,
      );

      // Use SignUpController
      final signUpController = Get.find<SignUpController>();
      signUpController.signUp(signUpBodyModel).then((success) {
        if (!mounted) return;

        if (success) {
          showCustomSnackBar('Registration successful!', title: 'Success');
        } else {
          showCustomSnackBar(signUpController.message);
        }
      });
    }
  }

  Widget _buildSocialIcon(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        margin: EdgeInsets.symmetric(horizontal: Dimensions.width10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GetBuilder<SignUpController>(
        builder: (controller) {
          return !controller.isLoading
              ? Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [
                  AppColors.iPrimaryColor,
                  AppColors.gradient2,
                  AppColors.textColor
                ],
              ),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.all(Dimensions.height20),
                child: Column(
                  children: [
                    SizedBox(height: Dimensions.screenheight * 0.05),

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
                      text: 'Create Account',
                      size: 28,
                      color: AppColors.white,
                    ),

                    SizedBox(height: Dimensions.height10),

                    SmallText(
                      text: 'Join us today and get started',
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
                      child: Column(
                        children: [
                          AppTextField(
                            textController: nameController,
                            hintText: 'Full Name',
                            icon: Icons.person,
                          ),

                          SizedBox(height: Dimensions.height20),

                          AppTextField(
                            textController: emailController,
                            hintText: 'Email Address',
                            icon: Icons.email,
                          ),

                          SizedBox(height: Dimensions.height20),

                          AppTextField(
                            textController: phoneController,
                            hintText: 'Phone Number',
                            icon: Icons.phone,
                          ),

                          SizedBox(height: Dimensions.height20),

                          AppTextField(
                            textController: addressController,
                            hintText: 'Address',
                            icon: Icons.home,
                          ),

                          SizedBox(height: Dimensions.height20),

                          // Role Selection
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.white.withOpacity(0.5)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(Dimensions.height10),
                                  child: Text(
                                    'Select Role',
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: RadioListTile<int>(
                                        title: Text(
                                          'Receiver',
                                          style: TextStyle(color: AppColors.white),
                                        ),
                                        value: 1,
                                        groupValue: selectedRole,
                                        onChanged: (value) => updateRole(value!),
                                        activeColor: AppColors.iSecondaryColor,
                                      ),
                                    ),
                                    Expanded(
                                      child: RadioListTile<int>(
                                        title: Text(
                                          'Giver',
                                          style: TextStyle(color: AppColors.white),
                                        ),
                                        value: 2,
                                        groupValue: selectedRole,
                                        onChanged: (value) => updateRole(value!),
                                        activeColor: AppColors.iSecondaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: Dimensions.height20),

                          AppTextField(
                            textController: passwordController,
                            hintText: 'Password',
                            icon: Icons.lock,
                            isObscure: true,
                          ),

                          SizedBox(height: Dimensions.height30),

                          // Sign Up Button
                          GestureDetector(
                            onTap: controller.isLoading ? null : _registration,
                            child: Container(
                              width: double.infinity,
                              height: Dimensions.screenheight / 13,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: AppColors.iSecondaryColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: BigText(
                                  text: 'Sign Up',
                                  size: Dimensions.font20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: Dimensions.height20),

                          // Already have account
                          RichText(
                            text: TextSpan(
                              recognizer: TapGestureRecognizer()..onTap = () {
                                if (mounted) {
                                  Get.to(() => const LoginPage());
                                }
                              },
                              text: 'Already have an account? ',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: Dimensions.font16,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Sign In',
                                  style: TextStyle(
                                    color: AppColors.iSecondaryColor,
                                    fontSize: Dimensions.font16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

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
                                  text: 'or sign up with',
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

                          // Social Media Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildSocialIcon(Icons.chat, Colors.blue, () {
                                Get.snackbar(
                                  'Coming Soon',
                                  'Twitter sign up will be available soon',
                                  backgroundColor: Colors.blue,
                                  colorText: Colors.white,
                                );
                              }),
                              _buildSocialIcon(Icons.facebook, Colors.blue[800]!, () {
                                Get.snackbar(
                                  'Coming Soon',
                                  'Facebook sign up will be available soon',
                                  backgroundColor: Colors.blue,
                                  colorText: Colors.white,
                                );
                              }),
                              _buildSocialIcon(Icons.g_mobiledata, Colors.red, () {
                                Get.snackbar(
                                  'Coming Soon',
                                  'Google sign up will be available soon',
                                  backgroundColor: Colors.blue,
                                  colorText: Colors.white,
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: Dimensions.screenheight * 0.05),
                  ],
                ),
              ),
            ),
          )
              : const CustomLoader();
        },
      ),
    );
  }
}