import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';

class WalletBalanceState {
  final double? balance;
  final double? totalCredit;
  final double? totalDebit;
  final bool isLoading;
  final String? error;

  const WalletBalanceState({
    this.balance,
    this.totalCredit,
    this.totalDebit,
    this.isLoading = false,
    this.error,
  });

  WalletBalanceState copyWith({
    double? balance,
    double? totalCredit,
    double? totalDebit,
    bool? isLoading,
    String? error,
  }) {
    return WalletBalanceState(
      balance: balance ?? this.balance,
      totalCredit: totalCredit ?? this.totalCredit,
      totalDebit: totalDebit ?? this.totalDebit,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class WalletBalanceNotifier extends StateNotifier<WalletBalanceState> {
  WalletBalanceNotifier() : super(const WalletBalanceState());

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Future<void> fetchBalance() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      debugPrint('🔄 Fetching MeSomb balance and statistics...');
      final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
      final callable = functions.httpsCallable('checkBalance');

      final result = await callable.call();
      debugPrint('✅ Cloud Function response: ${result.data}');
      final data = result.data as Map<String, dynamic>;

      if (data['success'] == true) {
        final parsedBalance = _parseDouble(data['balance']);
        final parsedCredit = _parseDouble(data['totalCredit']);
        final parsedDebit = _parseDouble(data['totalDebit']);

        debugPrint('✅ MeSomb Balance: $parsedBalance XAF');
        debugPrint('✅ Total Credit (Revenue): $parsedCredit XAF');
        debugPrint('✅ Total Debit (Expenses): $parsedDebit XAF');

        state = state.copyWith(
          balance: parsedBalance,
          totalCredit: parsedCredit,
          totalDebit: parsedDebit,
          isLoading: false,
        );
      } else {
        final errorMsg =
            data['message']?.toString() ?? 'Failed to fetch balance';
        debugPrint('❌ Balance fetch failed: $errorMsg');
        state = state.copyWith(
          isLoading: false,
          error: errorMsg,
        );
      }
    } on FirebaseFunctionsException catch (e) {
      debugPrint(
          '❌ FirebaseFunctionsException: code=${e.code}, message=${e.message}, details=${e.details}');
      state = state.copyWith(
        isLoading: false,
        error: e.message ?? 'Failed to fetch balance',
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Unexpected error fetching balance: $e');
      debugPrint('Stack trace: $stackTrace');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() => fetchBalance();
}

final walletBalanceProvider =
    StateNotifierProvider<WalletBalanceNotifier, WalletBalanceState>((ref) {
  return WalletBalanceNotifier();
});

final mesombBalanceProvider = Provider<double?>((ref) {
  return ref.watch(walletBalanceProvider).balance;
});

final mesombTotalCreditProvider = Provider<double?>((ref) {
  return ref.watch(walletBalanceProvider).totalCredit;
});

final mesombTotalDebitProvider = Provider<double?>((ref) {
  return ref.watch(walletBalanceProvider).totalDebit;
});

final walletBalanceLoadingProvider = Provider<bool>((ref) {
  return ref.watch(walletBalanceProvider).isLoading;
});
