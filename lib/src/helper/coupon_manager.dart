// coupon_manager.dart
import 'package:shared_preferences/shared_preferences.dart';

class CouponManager {
  static const String _couponCopiedKey = 'coupon_copied';
  static const String _couponCodeKey = 'SUMMER25';

  static Future<bool> hasCopiedCoupon() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_couponCopiedKey) ?? false;
  }

  static Future<void> setCouponCopied() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_couponCopiedKey, true);
  }

  static Future<void> resetCoupon() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_couponCopiedKey, false);
  }

  static String get couponCode => _couponCodeKey;
}