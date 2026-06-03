import '../models/wallet_transaction.dart';

abstract class WalletRepository {
  Future<List<WalletTransaction>> getAllTransactions();

  Future<List<WalletTransaction>> getTransactionsByType(TransactionType type);

  Future<List<WalletTransaction>> getTransactionsByEmployee(String employeeId);

  Future<List<WalletTransaction>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  );

  Future<void> createTransaction(WalletTransaction transaction);

  Future<void> verifyTransaction(String id, String verifiedBy);

  Future<void> deleteTransaction(String id);

  Future<WalletSummary> getWalletSummary();

  Stream<List<WalletTransaction>> watchTransactions();

  Stream<WalletSummary> watchWalletSummary();
}
