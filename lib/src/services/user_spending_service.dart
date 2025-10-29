// lib/src/services/user_spending_service.dart
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSpendingService extends GetxService {
  static UserSpendingService get instance => Get.find();

  final double _monthlySpendingLimit = 150.00; // R150 monthly limit
  final int _resetPeriodDays = 30; // Reset every 30 days

  final RxDouble _currentSpending = 0.0.obs;
  final RxString _resetDate = ''.obs;
  final RxBool _isInitialized = false.obs;

  double get monthlySpendingLimit => _monthlySpendingLimit;
  double get currentSpending => _currentSpending.value;
  double get remainingBalance => _monthlySpendingLimit - _currentSpending.value;
  String get resetDate => _resetDate.value;
  bool get isOverLimit => _currentSpending.value >= _monthlySpendingLimit;

  @override
  void onInit() {
    super.onInit();
    _initializeSpendingData();
  }

  Future<void> _initializeSpendingData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if we need to reset (first time or period expired)
      final lastReset = prefs.getString('spending_reset_date');
      final now = DateTime.now();

      if (lastReset == null) {
        // First time - set initial reset date
        await _resetSpendingCycle(now);
      } else {
        final lastResetDate = DateTime.parse(lastReset);
        final daysSinceReset = now.difference(lastResetDate).inDays;

        if (daysSinceReset >= _resetPeriodDays) {
          // Reset period expired - start new cycle
          await _resetSpendingCycle(now);
        } else {
          // Load existing spending data
          _currentSpending.value = prefs.getDouble('current_spending') ?? 0.0;
          _resetDate.value = lastReset;
        }
      }

      _isInitialized.value = true;
      print('💰 Spending service initialized:');
      print('   - Current spending: R${_currentSpending.value}');
      print('   - Remaining balance: R$remainingBalance');
      print('   - Reset date: $_resetDate');
      print('   - Is over limit: $isOverLimit');

    } catch (e) {
      print('❌ Error initializing spending service: $e');
      // Set defaults on error
      _currentSpending.value = 0.0;
      _resetDate.value = DateTime.now().toIso8601String();
      _isInitialized.value = true;
    }
  }

  Future<void> _resetSpendingCycle(DateTime resetDate) async {
    final prefs = await SharedPreferences.getInstance();

    _currentSpending.value = 0.0;
    _resetDate.value = resetDate.toIso8601String();

    await prefs.setDouble('current_spending', 0.0);
    await prefs.setString('spending_reset_date', resetDate.toIso8601String());

    print('🔄 Spending cycle reset: R0.00 available until next reset');
  }

  Future<bool> canSpendAmount(double amount) async {
    if (!_isInitialized.value) {
      await _initializeSpendingData();
    }

    final newTotal = _currentSpending.value + amount;
    return newTotal <= _monthlySpendingLimit;
  }

  Future<bool> addSpending(double amount) async {
    if (!_isInitialized.value) {
      await _initializeSpendingData();
    }

    final newTotal = _currentSpending.value + amount;

    if (newTotal > _monthlySpendingLimit) {
      print('❌ Cannot add spending: Would exceed monthly limit');
      return false;
    }

    _currentSpending.value = newTotal;

    // Save to persistent storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('current_spending', newTotal);

    print('💸 Spending added: R$amount');
    print('   - New total: R${_currentSpending.value}');
    print('   - Remaining: R$remainingBalance');

    return true;
  }

  Future<void> refundSpending(double amount) async {
    if (!_isInitialized.value) {
      await _initializeSpendingData();
    }

    _currentSpending.value = (_currentSpending.value - amount).clamp(0.0, double.infinity);

    // Save to persistent storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('current_spending', _currentSpending.value);

    print('💳 Spending refunded: R$amount');
    print('   - New total: R${_currentSpending.value}');
    print('   - Remaining: R$remainingBalance');
  }

  Future<void> forceResetSpending() async {
    await _resetSpendingCycle(DateTime.now());
    print('🔄 Spending manually reset to R0.00');
  }

  // Check if order can be placed with current cart total
  Future<SpendingCheckResult> checkOrderEligibility(double orderTotal) async {
    if (!_isInitialized.value) {
      await _initializeSpendingData();
    }

    final canSpend = await canSpendAmount(orderTotal);
    final daysUntilReset = _getDaysUntilReset();

    return SpendingCheckResult(
      canProceed: canSpend,
      currentSpending: _currentSpending.value,
      remainingBalance: remainingBalance,
      orderTotal: orderTotal,
      monthlyLimit: _monthlySpendingLimit,
      daysUntilReset: daysUntilReset,
      exceedsLimit: orderTotal > remainingBalance,
    );
  }

  int _getDaysUntilReset() {
    try {
      final resetDate = DateTime.parse(_resetDate.value);
      final now = DateTime.now();
      final nextReset = resetDate.add(Duration(days: _resetPeriodDays));
      return nextReset.difference(now).inDays;
    } catch (e) {
      return _resetPeriodDays;
    }
  }

  Map<String, dynamic> getSpendingSummary() {
    return {
      'currentSpending': _currentSpending.value,
      'remainingBalance': remainingBalance,
      'monthlyLimit': _monthlySpendingLimit,
      'resetDate': _resetDate.value,
      'daysUntilReset': _getDaysUntilReset(),
      'isOverLimit': isOverLimit,
    };
  }

  void debugSpendingStatus() {
    print('\n=== SPENDING STATUS DEBUG ===');
    print('💰 Monthly Limit: R$_monthlySpendingLimit');
    print('💸 Current Spending: R${_currentSpending.value}');
    print('💳 Remaining Balance: R$remainingBalance');
    print('📅 Reset Date: $_resetDate');
    print('⏰ Days Until Reset: ${_getDaysUntilReset()}');
    print('🚫 Is Over Limit: $isOverLimit');
    print('=== END SPENDING DEBUG ===\n');
  }
}

class SpendingCheckResult {
  final bool canProceed;
  final double currentSpending;
  final double remainingBalance;
  final double orderTotal;
  final double monthlyLimit;
  final int daysUntilReset;
  final bool exceedsLimit;

  SpendingCheckResult({
    required this.canProceed,
    required this.currentSpending,
    required this.remainingBalance,
    required this.orderTotal,
    required this.monthlyLimit,
    required this.daysUntilReset,
    required this.exceedsLimit,
  });

  double get amountOverLimit {
    return exceedsLimit ? orderTotal - remainingBalance : 0.0;
  }
}