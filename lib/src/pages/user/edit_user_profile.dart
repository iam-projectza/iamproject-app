import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iam/src/controllers/auth/firebase/authenication_repository.dart';
import 'package:iam/src/widgets/big_text.dart';
import 'package:iam/src/widgets/small_text.dart';
import '../../constants/colors.dart';
import '../../utils/dimensions.dart';

class EditUserProfile extends StatefulWidget {
  final Map<String, dynamic> userData;
  final VoidCallback onClose;
  final Function(Map<String, dynamic>)? onSave;

  const EditUserProfile({
    super.key,
    required this.userData,
    required this.onClose,
    this.onSave,
  });

  @override
  State<EditUserProfile> createState() => _EditUserProfileState();
}

class _EditUserProfileState extends State<EditUserProfile>
    with SingleTickerProviderStateMixin {
  final AuthenticationRepository authRepo = Get.find<AuthenticationRepository>();

  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    // DEBUG: Print the received user data to check what's coming in
    print('Received userData in EditUserProfile: ${widget.userData}');

    // Initialize form controllers with real user data
    // Use empty string as fallback if data is null
    _nameController = TextEditingController(text: widget.userData['name']?.toString() ?? '');
    _emailController = TextEditingController(text: widget.userData['email']?.toString() ?? '');
    _phoneController = TextEditingController(text: widget.userData['phone']?.toString() ?? '');
    _addressController = TextEditingController(text: widget.userData['address']?.toString() ?? '');

    // DEBUG: Print the controller values
    print('Name controller: ${_nameController.text}');
    print('Email controller: ${_emailController.text}');
    print('Phone controller: ${_phoneController.text}');
    print('Address controller: ${_addressController.text}');

    // Set up animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    // Start the animation when the form is created
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _closeForm() {
    _animationController.reverse().then((value) {
      widget.onClose();
    });
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      try {
        final updatedData = {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
        };

        // DEBUG: Print the data being saved
        print('Saving updated data: $updatedData');

        // Call the onSave callback if provided
        if (widget.onSave != null) {
          await widget.onSave!(updatedData);
        }

        // Update Firebase user profile
        await _updateFirebaseProfile(updatedData);

        Get.snackbar(
          'Success',
          'Profile updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        // Then close the form with animation
        _closeForm();
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to update profile: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _updateFirebaseProfile(Map<String, dynamic> updatedData) async {
    final user = authRepo.firebaseUser.value;
    if (user != null) {
      try {
        // Update display name in Firebase Auth
        await user.updateDisplayName(updatedData['name']);
        print('Successfully updated display name in Firebase');

        // You can also update additional user data in Firestore here
        // Example:
        // await FirebaseFirestore.instance
        //     .collection('users')
        //     .doc(user.uid)
        //     .update({
        //   'name': updatedData['name'],
        //   'phone': updatedData['phone'],
        //   'address': updatedData['address'],
        //   'updatedAt': FieldValue.serverTimestamp(),
        // });
      } catch (e) {
        print('Error updating Firebase profile: $e');
        rethrow;
      }
    }
  }

  // Get user photo URL with fallback
  String get _userPhotoUrl {
    final user = authRepo.firebaseUser.value;
    if (user?.photoURL != null && user!.photoURL!.isNotEmpty) {
      return user.photoURL!;
    }
    // Use the name from controller or fallback
    final name = _nameController.text.isNotEmpty ? _nameController.text : 'User';
    return "https://ui-avatars.com/api/?name=$name&background=0D8ABC&color=fff";
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: _closeForm,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              color: Colors.black.withOpacity(0.4),
              child: Center(
                child: GestureDetector(
                  onTap: () {}, // Prevent closing when tapping on the form
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.8,
                      padding: EdgeInsets.all(Dimensions.height20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.iPrimaryColor.withOpacity(0.85),
                            AppColors.gradient2.withOpacity(0.9),
                            AppColors.textColor.withOpacity(0.85),
                          ],
                          stops: const [0.1, 0.5, 0.9],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 25,
                            spreadRadius: 2,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              BigText(
                                text: 'Edit Profile',
                                size: 24,
                                color: AppColors.white,
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: AppColors.white),
                                onPressed: _closeForm,
                              ),
                            ],
                          ),
                          SizedBox(height: Dimensions.height20),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    // Profile Picture
                                    Center(
                                      child: Stack(
                                        children: [
                                          CircleAvatar(
                                            radius: 50,
                                            backgroundImage: NetworkImage(_userPhotoUrl),
                                            backgroundColor: Colors.grey[200],
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            right: 4,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: AppColors.iSecondaryColor.withOpacity(0.8),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.camera_alt,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: Dimensions.height30),

                                    // Name Field
                                    TextFormField(
                                      controller: _nameController,
                                      style: TextStyle(color: AppColors.white),
                                      decoration: InputDecoration(
                                        labelText: 'Full Name',
                                        labelStyle: TextStyle(color: AppColors.white.withOpacity(0.9)),
                                        hintText: 'Enter your full name',
                                        hintStyle: TextStyle(color: AppColors.white.withOpacity(0.5)),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.white.withOpacity(0.4)),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: AppColors.iSecondaryColor),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.15),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: Dimensions.width15,
                                          vertical: Dimensions.height15,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your name';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: Dimensions.height20),

                                    // Email Field (read-only for Firebase email)
                                    TextFormField(
                                      controller: _emailController,
                                      style: TextStyle(color: AppColors.white.withOpacity(0.7)),
                                      readOnly: true, // Email is managed by Firebase Auth
                                      decoration: InputDecoration(
                                        labelText: 'Email',
                                        labelStyle: TextStyle(color: AppColors.white.withOpacity(0.9)),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.white.withOpacity(0.4)),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: AppColors.iSecondaryColor),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.1),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: Dimensions.width15,
                                          vertical: Dimensions.height15,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: Dimensions.height20),

                                    // Phone Field
                                    TextFormField(
                                      controller: _phoneController,
                                      style: TextStyle(color: AppColors.white),
                                      decoration: InputDecoration(
                                        labelText: 'Phone Number',
                                        labelStyle: TextStyle(color: AppColors.white.withOpacity(0.9)),
                                        hintText: 'Enter your phone number',
                                        hintStyle: TextStyle(color: AppColors.white.withOpacity(0.5)),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.white.withOpacity(0.4)),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: AppColors.iSecondaryColor),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.15),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: Dimensions.width15,
                                          vertical: Dimensions.height15,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your phone number';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: Dimensions.height20),

                                    // Address Field
                                    TextFormField(
                                      controller: _addressController,
                                      style: TextStyle(color: AppColors.white),
                                      maxLines: 3,
                                      decoration: InputDecoration(
                                        labelText: 'Address',
                                        labelStyle: TextStyle(color: AppColors.white.withOpacity(0.9)),
                                        hintText: 'Enter your address',
                                        hintStyle: TextStyle(color: AppColors.white.withOpacity(0.5)),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.white.withOpacity(0.4)),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: AppColors.iSecondaryColor),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.15),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: Dimensions.width15,
                                          vertical: Dimensions.height15,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your address';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: Dimensions.height30),

                                    // Save Button
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: _isSaving ? null : _saveForm,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.iSecondaryColor.withOpacity(0.9),
                                          padding: EdgeInsets.symmetric(
                                            vertical: Dimensions.height20,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          elevation: 5,
                                          shadowColor: Colors.black.withOpacity(0.3),
                                        ),
                                        child: _isSaving
                                            ? const CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        )
                                            : SmallText(
                                          text: 'Save Changes',
                                          size: 18,
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}