import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../model/single_product_model.dart';
import '../../cart_controller.dart';
import '../../wishlist_controller.dart';



class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  // Firebase instances
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Reactive variables
  late Rx<User?> firebaseUser;
  late RxBool isSignedIn;

  @override
  void onInit() {
    super.onInit();
    // Initialize reactive user stream
    firebaseUser = Rx<User?>(_auth.currentUser);
    isSignedIn = RxBool(_auth.currentUser != null);

    // Listen to auth state changes
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, (User? user) {
      isSignedIn.value = user != null;

      // Store user data locally when user changes
      if (user != null) {
        _storeUserDataLocally(user);
      }

      // Redirect based on auth status
      if (user == null) {
        // User signed out, redirect to login
        Get.offAllNamed('/login');
      } else {
        // User signed in, ensure we're on a valid route
        if (Get.currentRoute == '/login') {
          Get.offAllNamed('/');
        }
      }
    });
  }

  // ─── STORE USER DATA LOCALLY ────────────────────────────────────────

  Future<void> _storeUserDataLocally(User user) async {
    try {
      final sharedPreferences = await SharedPreferences.getInstance();

      // Get additional user data from Firestore
      final userData = await getUserData(user.uid);

      String userName = userData?['name'] ?? user.displayName ?? 'Customer';
      String userEmail = user.email ?? 'customer@example.com';

      await sharedPreferences.setString('user_name', userName);
      await sharedPreferences.setString('user_email', userEmail);

      print('✅ User data stored locally:');
      print('   - Name: $userName');
      print('   - Email: $userEmail');
    } catch (e) {
      print('❌ Error storing user data locally: $e');
    }
  }

  Future<void> storeUserData(String name, String email) async {
    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences.setString('user_name', name);
      await sharedPreferences.setString('user_email', email);
      print('✅ User data stored locally: $name, $email');
    } catch (e) {
      print('❌ Error storing user data: $e');
    }
  }

  Future<Map<String, String?>> getStoredUserData() async {
    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      String? name = sharedPreferences.getString('user_name');
      String? email = sharedPreferences.getString('user_email');

      print('📋 Retrieved stored user data:');
      print('   - Name: $name');
      print('   - Email: $email');

      return {
        'name': name,
        'email': email,
      };
    } catch (e) {
      print('❌ Error retrieving stored user data: $e');
      return {'name': null, 'email': null};
    }
  }

  // ─── SIGN UP ────────────────────────────────────────────────────────

  Future<String?> registerWithEmailAndPassword(String email, String password, Map<String, dynamic> userData) async {
    try {
      // Clear any existing data
      await clearPreviousUserData();

      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;

      if (user != null) {
        await user.updateDisplayName(userData['name']);
        await _saveUserDataToFirestore(user.uid, userData);
        await setCurrentUserId(user.uid); // Set current user ID
        await storeUserData(userData['name'], email);

        // Clear and reload controllers for new user
        await _reloadUserSpecificData();

        return null; // Success
      } else {
        return "User creation failed";
      }
    } on FirebaseAuthException catch (e) {
      return _mapErrorMessage(e);
    } catch (e) {
      return "An unexpected error occurred: $e";
    }
  }

  // ─── SAVE USER DATA TO FIRESTORE ────────────────────────────────────

  Future<void> _saveUserDataToFirestore(String userId, Map<String, dynamic> userData) async {
    try {
      await _firestore.collection('USERS').doc(userId).set({
        'uid': userId,
        'email': userData['email'],
        'name': userData['name'],
        'phone': userData['phone'],
        'address': userData['address'],
        'role': userData['role'],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error saving user data to Firestore: $e");
      throw "Failed to save user data: $e";
    }
  }

  // ─── SIGN IN ────────────────────────────────────────────────────────

  Future<String?> loginWithEmailAndPassword(String email, String password) async {
    try {
      // Clear previous user's cart data
      await clearPreviousUserData();

      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store user data locally after login
      final User? user = userCredential.user;
      if (user != null) {
        await setCurrentUserId(user.uid); // Set current user ID
        await _storeUserDataLocally(user);

        // Clear and reload controllers for new user
        await _reloadUserSpecificData();
      }

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return _mapErrorMessage(e);
    } catch (e) {
      return "An unexpected error occurred: $e";
    }
  }

  // ─── SIGN OUT ───────────────────────────────────────────────────────

  Future<void> logout() async {
    try {
      // Clear local storage
      final sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences.remove('user_name');
      await sharedPreferences.remove('user_email');
      await sharedPreferences.remove('current_user_id');

      // Clear cart and wishlist data
      await clearPreviousUserData();

      await _auth.signOut();
      Get.offAllNamed('/login');
    } catch (e) {
      throw "Logout failed: $e";
    }
  }

  // ─── PASSWORD RESET ────────────────────────────────────────────────

  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return _mapErrorMessage(e);
    } catch (e) {
      return "An unexpected error occurred: $e";
    }
  }

  // ─── USER INFO ─────────────────────────────────────────────────────

  String? get userId => _auth.currentUser?.uid;
  String? get userEmail => _auth.currentUser?.email;
  String? get userDisplayName => _auth.currentUser?.displayName;
  String? get userPhotoUrl => _auth.currentUser?.photoURL;
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // ─── GET USER DATA FROM FIRESTORE ──────────────────────────────────

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('USERS').doc(userId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("Error getting user data: $e");
      return null;
    }
  }

  // ─── GET USER ADDRESS ──────────────────────────────────────────────

  Future<String?> getUserAddress() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final DocumentSnapshot doc = await _firestore.collection('USERS').doc(user.uid).get();
        if (doc.exists) {
          final userData = doc.data() as Map<String, dynamic>;
          return userData['address'] as String?;
        }
      }
      return null;
    } catch (e) {
      print('Error getting user address: $e');
      return null;
    }
  }

  // ─── GET COMPLETE USER PROFILE ─────────────────────────────────────

  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final DocumentSnapshot doc = await _firestore.collection('USERS').doc(user.uid).get();
        if (doc.exists) {
          return doc.data() as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // ─── UPDATE USER DATA ──────────────────────────────────────────────

  Future<void> updateUserData(String userId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('USERS').doc(userId).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local storage if name or email changed
      if (updates.containsKey('name') || updates.containsKey('email')) {
        final sharedPreferences = await SharedPreferences.getInstance();
        if (updates.containsKey('name')) {
          await sharedPreferences.setString('user_name', updates['name']);
        }
        if (updates.containsKey('email')) {
          await sharedPreferences.setString('user_email', updates['email']);
        }
      }
    } catch (e) {
      print("Error updating user data: $e");
      throw "Failed to update user data: $e";
    }
  }

  // ─── UPDATE USER PROFILE ───────────────────────────────────────────

  Future<void> updateUserProfile(String displayName, String? photoURL) async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        if (photoURL != null) {
          await user.updatePhotoURL(photoURL);
        }

        // Update local storage
        await storeUserData(displayName, user.email ?? '');

        // Update Firestore
        await updateUserData(user.uid, {
          'name': displayName,
          ...(photoURL != null ? {'photoURL': photoURL} : {}),
        });
      }
    } catch (e) {
      print("Error updating user profile: $e");
      throw "Failed to update profile: $e";
    }
  }

  // ─── WISHLIST METHODS ──────────────────────────────────────────────

  // Add product to wishlist - with debug prints
  Future<void> addToWishlist(SingleProductModel product) async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        print('🔥 Adding to Firebase wishlist: ${product.name}');
        print('🔥 User ID: ${user.uid}');
        print('🔥 Product ID: ${product.id}');

        final wishlistItem = {
          'product_id': product.id,
          'name': product.name,
          'price': product.price,
          'image': product.image,
          'description': product.description,
          'category_id': product.category_id,
          'category_name': product.category_name,
          'added_at': FieldValue.serverTimestamp(),
        };

        print('🔥 Wishlist data: $wishlistItem');

        await _firestore
            .collection('USERS')
            .doc(user.uid)
            .collection('WISHLIST')
            .doc(product.id.toString())
            .set(wishlistItem);

        print('✅ SUCCESS: Product added to Firebase wishlist: ${product.name}');
      } else {
        print('❌ No user logged in');
        throw 'Please login to add items to wishlist';
      }
    } catch (e) {
      print('❌ ERROR adding to Firebase wishlist: $e');
      throw 'Failed to add to wishlist: $e';
    }
  }

  // Remove product from wishlist - with debug prints
  Future<void> removeFromWishlist(int productId) async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        print('🗑️ Removing from Firebase wishlist: $productId');
        print('🗑️ User ID: ${user.uid}');

        await _firestore
            .collection('USERS')
            .doc(user.uid)
            .collection('WISHLIST')
            .doc(productId.toString())
            .delete();

        print('✅ SUCCESS: Product removed from Firebase wishlist: $productId');
      } else {
        print('❌ No user logged in');
        throw 'Please login to manage wishlist';
      }
    } catch (e) {
      print('❌ ERROR removing from Firebase wishlist: $e');
      throw 'Failed to remove from wishlist: $e';
    }
  }

  // Check if product is in wishlist
  Future<bool> isInWishlist(int productId) async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore
            .collection('USERS')
            .doc(user.uid)
            .collection('WISHLIST')
            .doc(productId.toString())
            .get();

        return doc.exists;
      }
      return false;
    } catch (e) {
      print('❌ Error checking wishlist: $e');
      return false;
    }
  }

  // Get user's wishlist
  Future<List<SingleProductModel>> getWishlist() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final querySnapshot = await _firestore
            .collection('USERS')
            .doc(user.uid)
            .collection('WISHLIST')
            .orderBy('added_at', descending: true)
            .get();

        final wishlistItems = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return SingleProductModel(
            id: data['product_id'] as int?,
            name: data['name'] as String?,
            price: (data['price'] as num?)?.toDouble(),
            image: data['image'] as String?,
            description: data['description'] as String?,
            category_id: data['category_id'] as int?,
            category_name: data['category_name'] as String?,
          );
        }).toList();

        print('📋 Loaded ${wishlistItems.length} items from wishlist');
        return wishlistItems;
      }
      return [];
    } catch (e) {
      print('❌ Error getting wishlist: $e');
      return [];
    }
  }

  // Stream for real-time wishlist updates
  Stream<List<SingleProductModel>> getWishlistStream() {
    final User? user = _auth.currentUser;
    if (user != null) {
      return _firestore
          .collection('USERS')
          .doc(user.uid)
          .collection('WISHLIST')
          .orderBy('added_at', descending: true)
          .snapshots()
          .map((querySnapshot) {
        return querySnapshot.docs.map((doc) {
          final data = doc.data();
          return SingleProductModel(
            id: data['product_id'] as int?,
            name: data['name'] as String?,
            price: (data['price'] as num?)?.toDouble(),
            image: data['image'] as String?,
            description: data['description'] as String?,
            category_id: data['category_id'] as int?,
            category_name: data['category_name'] as String?,
          );
        }).toList();
      });
    }
    return Stream.value([]);
  }

  // ─── HELPER ─────────────────────────────────────────────────────────

  String _mapErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'email-already-in-use':
        return 'Email is already registered.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }

  signInWithGoogle() {
    // Implement Google Sign In here
  }

  // In AuthenticationRepository, add these methods:

// Clear previous user's data when logging in
  Future<void> clearPreviousUserData() async {
    try {
      final sharedPreferences = await SharedPreferences.getInstance();

      // Clear cart and wishlist data (they'll be reloaded for new user)
      final keys = sharedPreferences.getKeys();
      for (String key in keys) {
        if (key.startsWith('cart_') || key.startsWith('cart_history_')) {
          await sharedPreferences.remove(key);
          print('🗑️ Cleared previous user data: $key');
        }
      }
    } catch (e) {
      print('❌ Error clearing previous user data: $e');
    }
  }

// Set current user ID
  Future<void> setCurrentUserId(String userId) async {
    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences.setString('current_user_id', userId);
      print('👤 Current user set: $userId');
    } catch (e) {
      print('❌ Error setting current user: $e');
    }
  }

// Get current user ID
  String? getCurrentUserId() {
    try {
      final sharedPreferences = Get.find<SharedPreferences>();
      return sharedPreferences.getString('current_user_id');
    } catch (e) {
      print('❌ Error getting current user: $e');
      return null;
    }
  }

// Update the login method to handle user switching

// Update the registration method

// Reload user-specific data
  Future<void> _reloadUserSpecificData() async {
    try {
      // Reload cart controller
      if (Get.isRegistered<CartController>()) {
        final cartController = Get.find<CartController>();
        cartController.clear(); // Clear current cart
        cartController.setCart = cartController.getCartData(); // Reload user's cart
      }

      // Reload wishlist controller
      if (Get.isRegistered<WishlistController>()) {
        final wishlistController = Get.find<WishlistController>();
        await wishlistController.loadWishlist(); // Reload user's wishlist
      }

      print('🔄 User-specific data reloaded');
    } catch (e) {
      print('❌ Error reloading user-specific data: $e');
    }
  }

// Update logout to clear data

}