import 'package:iam/src/widgets/small_text.dart';
import 'package:scaffold_gradient_background/scaffold_gradient_background.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam/src/controllers/auth/firebase/authenication_repository.dart';
import 'package:iam/src/widgets/big_text.dart';
import '../../constants/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/build_settings_card_widget.dart';
import 'edit_user_profile.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> with SingleTickerProviderStateMixin {
  final AuthenticationRepository authRepo = Get.find<AuthenticationRepository>();

  Map<String, dynamic> userData = {
    'name': 'Loading...',
    'email': 'Loading...',
    'phone': 'Loading...',
    'address': 'Loading...',
    'photoUrl': '',
  };

  bool _isLoading = true;

  // Animation controller for the expandable logout button
  late AnimationController _logoutAnimationController;
  late Animation<double> _logoutWidthAnimation;
  bool _isLogoutExpanded = false;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();

    // Initialize with real Firebase data
    _initializeUserData();

    // Initialize logout button animation
    _logoutAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _logoutWidthAnimation = Tween<double>(
      begin: 60.0, // Collapsed width (just icon)
      end: 150.0,  // Expanded width (icon + text)
    ).animate(CurvedAnimation(
      parent: _logoutAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _initializeUserData() async {
    final user = authRepo.firebaseUser.value;
    if (user != null) {
      await _loadUserDataFromFirestore(user.uid);
    } else {
      // Listen for user changes if user is not immediately available
      authRepo.firebaseUser.listen((user) async {
        if (user != null) {
          await _loadUserDataFromFirestore(user.uid);
        }
      });
    }
  }

  Future<void> _loadUserDataFromFirestore(String userId) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get user data from Firestore
      final userDataFromFirestore = await authRepo.getUserData(userId);

      if (userDataFromFirestore != null) {
        setState(() {
          userData = {
            'name': userDataFromFirestore['name'] ?? 'User',
            'email': userDataFromFirestore['email'] ?? 'No email provided',
            'phone': userDataFromFirestore['phone'] ?? 'No phone number',
            'address': userDataFromFirestore['address'] ?? 'Update your address',
            'photoUrl': userDataFromFirestore['photoUrl'] ?? '',
          };
        });
      } else {
        // If no Firestore data, use basic auth data
        _updateUserDataFromFirebase();
      }
    } catch (e) {
      print('Error loading user data from Firestore: $e');
      _updateUserDataFromFirebase();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateUserDataFromFirebase() {
    final user = authRepo.firebaseUser.value;
    if (user != null) {
      setState(() {
        userData = {
          'name': user.displayName ?? 'User',
          'email': user.email ?? 'No email provided',
          'phone': 'No phone number', // Default since this comes from Firestore
          'address': 'Update your address', // Default since this comes from Firestore
          'photoUrl': user.photoURL ?? '',
        };
      });
    }
  }

  // Get user photo URL with fallback
  String get _userPhotoUrl {
    if (userData['photoUrl'] != null && userData['photoUrl'].isNotEmpty) {
      return userData['photoUrl'];
    }
    final user = authRepo.firebaseUser.value;
    if (user?.photoURL != null && user!.photoURL!.isNotEmpty) {
      return user.photoURL!;
    }
    return "https://ui-avatars.com/api/?name=${userData['name']}&background=0D8ABC&color=fff";
  }

  // Get user display name
  String get _userDisplayName {
    if (userData['name'] != null && userData['name'] != 'Loading...') {
      return userData['name'];
    }

    final user = authRepo.firebaseUser.value;
    final displayName = user?.displayName;
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    final email = user?.email;
    if (email != null && email.isNotEmpty) {
      return email.split('@').first;
    }

    return 'User';
  }

  // Get user email
  String get _userEmail {
    if (userData['email'] != null && userData['email'] != 'Loading...') {
      return userData['email'];
    }

    final user = authRepo.firebaseUser.value;
    return user?.email ?? 'No email provided';
  }

  // Get user phone
  String get _userPhone {
    return userData['phone'] ?? 'No phone number';
  }

  // Get user address
  String get _userAddress {
    return userData['address'] ?? 'Update your address';
  }

  @override
  void dispose() {
    _logoutAnimationController.dispose();
    super.dispose();
  }

  void _showEditProfileDialog() {
    // Prepare current user data for editing
    final currentUserData = {
      'name': _userDisplayName,
      'email': _userEmail,
      'phone': _userPhone,
      'address': _userAddress,
    };

    print('Opening edit profile with data: $currentUserData');

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return EditUserProfile(
          userData: currentUserData,
          onClose: () {
            Navigator.of(context).pop();
            _refreshUserData(); // Refresh data after editing
          },
          onSave: (updatedData) {
            _saveUserDataToFirebase(updatedData);
          },
        );
      },
    );
  }

  Future<void> _saveUserDataToFirebase(Map<String, dynamic> updatedData) async {
    try {
      final user = authRepo.firebaseUser.value;
      if (user != null) {
        // Update in Firestore
        await authRepo.updateUserData(user.uid, updatedData);

        // Update local state
        setState(() {
          userData = {...userData, ...updatedData};
        });

        // Update Firebase Auth display name if name changed
        if (updatedData['name'] != null) {
          await user.updateDisplayName(updatedData['name']);
        }

        Get.snackbar(
          'Success',
          'Profile updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _refreshUserData() async {
    final user = authRepo.firebaseUser.value;
    if (user != null) {
      await _loadUserDataFromFirestore(user.uid);
    }
  }

  void _toggleLogoutButton() {
    setState(() {
      _isLogoutExpanded = !_isLogoutExpanded;
      if (_isLogoutExpanded) {
        _logoutAnimationController.forward();
      } else {
        _logoutAnimationController.reverse();
      }
    });
  }

  void _showLogoutDialog() {
    _confirmLogout();
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.gradient2,
          title: BigText(
            text: 'Logout',
            size: 20,
            color: AppColors.white,
          ),
          content: SmallText(
            text: 'Are you sure you want to logout?',
            color: AppColors.white,
          ),
          actions: [
            TextButton(
              onPressed: _isLoggingOut ? null : () => Navigator.of(context).pop(),
              child: SmallText(
                text: 'Cancel',
                color: AppColors.white,
              ),
            ),
            TextButton(
              onPressed: _isLoggingOut ? null : () => _performLogout(context),
              child: _isLoggingOut
                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  : SmallText(
                text: 'Logout',
                color: Colors.red,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout(BuildContext context) async {
    setState(() {
      _isLoggingOut = true;
    });

    try {
      Navigator.of(context).pop();
      await authRepo.logout();

      Get.snackbar(
        'Success',
        'Logged out successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Logout Failed',
        'Error during logout: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() {
        _isLoggingOut = false;
      });
    }
  }

  void _directLogout() async {
    setState(() {
      _isLoggingOut = true;
    });

    try {
      await authRepo.logout();

      Get.snackbar(
        'Success',
        'Logged out successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Logout Failed',
        'Error during logout: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() {
        _isLoggingOut = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return ScaffoldGradientBackground(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            AppColors.iPrimaryColor,
            AppColors.gradient2,
            AppColors.textColor
          ],
        ),
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.white,
          ),
        ),
      );
    }

    return ScaffoldGradientBackground(
      gradient: LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [
          AppColors.iPrimaryColor,
          AppColors.gradient2,
          AppColors.textColor
        ],
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          color: Colors.transparent,
          child: Padding(
            padding: EdgeInsets.only(
              top: Dimensions.height45,
              left: Dimensions.width20,
              right: Dimensions.width20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: AppColors.iSecondaryColor,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(
                    'assets/icons/menus.png',
                    fit: BoxFit.contain,
                    color: AppColors.white,
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.textColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          IconButton(
                            icon: Image.asset(
                              'assets/icons/notification-02.png',
                              width: 22,
                              height: 22,
                              color: AppColors.white,
                            ),
                            onPressed: () {},
                            padding: EdgeInsets.zero,
                          ),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.yellow,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1),
                              ),
                              child: const Icon(
                                Icons.star,
                                size: 9,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(width: Dimensions.width10),

                      CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage(_userPhotoUrl),
                        backgroundColor: Colors.grey[200],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                SizedBox(height: Dimensions.height30),

                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(_userPhotoUrl),
                            backgroundColor: Colors.grey[200],
                          ),
                          Positioned(
                            bottom: 0,
                            right: 4,
                            child: GestureDetector(
                              onTap: _showEditProfileDialog,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.iSecondaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Dimensions.height10),
                      BigText(text: _userDisplayName, size: 24, color: AppColors.white),
                      SizedBox(height: Dimensions.height15),
                      SmallText(text: _userEmail, color: AppColors.white),
                    ],
                  ),
                ),
                SizedBox(height: Dimensions.height30),

                Container(
                  margin: EdgeInsets.symmetric(horizontal: Dimensions.width20),
                  padding: EdgeInsets.all(Dimensions.height15),
                  decoration: BoxDecoration(
                    color: AppColors.gradient2,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _showEditProfileDialog,
                        child: BuildSettingsCardWidget(
                          icon: Icons.account_circle_outlined,
                          iconColor: Colors.orange,
                          title: SmallText(text: 'Personal Information', size: 18, color: AppColors.white),
                        ),
                      ),
                      BuildSettingsCardWidget(
                        icon: Icons.wrong_location_sharp,
                        iconColor: Colors.pink,
                        title: SmallText(text: 'Address', size: 18, color: AppColors.white),
                        subtitle: SmallText(
                          text: _userAddress,
                          size: 12,
                          color: AppColors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: Dimensions.height30),

                Container(
                  margin: EdgeInsets.symmetric(horizontal: Dimensions.width20),
                  padding: EdgeInsets.all(Dimensions.height15),
                  decoration: BoxDecoration(
                    color: AppColors.gradient2,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      BuildSettingsCardWidget(
                        icon: Icons.shopping_cart_outlined,
                        iconColor: Colors.orange,
                        title: SmallText(text: 'Cart', size: 18, color: AppColors.white),
                      ),
                      BuildSettingsCardWidget(
                        icon: Icons.favorite_border,
                        iconColor: Colors.pink,
                        title: SmallText(text: 'Favorites', size: 18, color: AppColors.white),
                      ),
                      BuildSettingsCardWidget(
                        icon: Icons.payment_outlined,
                        iconColor: Colors.blue,
                        title: SmallText(text: 'Payment Method', size: 18, color: AppColors.white),
                      ),
                      BuildSettingsCardWidget(
                        icon: Icons.notifications_outlined,
                        iconColor: Colors.green,
                        title: SmallText(text: 'Notifications', size: 18, color: AppColors.white),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: Dimensions.height20),

                Container(
                  margin: EdgeInsets.symmetric(horizontal: Dimensions.width20),
                  padding: EdgeInsets.all(Dimensions.height15),
                  decoration: BoxDecoration(
                    color: AppColors.gradient2,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      BuildSettingsCardWidget(
                        icon: Icons.help_outline,
                        iconColor: Colors.deepPurple,
                        title: SmallText(text: 'FAQs', size: 18, color: AppColors.white),
                      ),
                      BuildSettingsCardWidget(
                        icon: Icons.reviews_outlined,
                        iconColor: Colors.teal,
                        title: SmallText(text: 'User Reviews', size: 18, color: AppColors.white),
                      ),
                      BuildSettingsCardWidget(
                        icon: Icons.settings_outlined,
                        iconColor: Colors.indigo,
                        title: SmallText(text: 'Settings', size: 18, color: AppColors.white),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 100),
              ],
            ),
          ),

          Positioned(
            right: Dimensions.width20,
            bottom: Dimensions.height10,
            child: AnimatedBuilder(
              animation: _logoutAnimationController,
              builder: (context, child) {
                return SizedBox(
                  width: _isLogoutExpanded ? 210 : 60,
                  height: 60,
                  child: Stack(
                    children: [
                      Positioned(
                        right: _isLogoutExpanded ? 150 : 0,
                        child: GestureDetector(
                          onTap: _toggleLogoutButton,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.iSecondaryColor,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Icon(
                              _isLogoutExpanded ? Icons.close : Icons.logout,
                              color: AppColors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),

                      if (_isLogoutExpanded)
                        Positioned(
                          right: 0,
                          child: GestureDetector(
                            onTap: _showLogoutDialog,
                            onLongPress: _directLogout,
                            child: Container(
                              width: 150,
                              height: 60,
                              padding: EdgeInsets.symmetric(
                                horizontal: Dimensions.width10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.iSecondaryColor,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _isLoggingOut
                                      ? const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  )
                                      : Icon(
                                    Icons.logout,
                                    color: AppColors.white,
                                    size: 24,
                                  ),
                                  SizedBox(width: Dimensions.width10),
                                  Expanded(
                                    child: SmallText(
                                      text: 'Logout',
                                      size: 16,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}