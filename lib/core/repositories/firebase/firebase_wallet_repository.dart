import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/wallet_transaction.dart';
import '../../services/firestore_service.dart';
import '../wallet_repository.dart';

class FirebaseWalletRepository implements WalletRepository {
  CollectionReference<Map<String, dynamic>> get _collection =>
      FirestoreService.instance.firestore
          .collection('vanguard_wallet_transactions');

  DocumentReference<Map<String, dynamic>> get _summaryDoc =>
      FirestoreService.instance.firestore
          .collection('vanguard_wallet_summary')
          .doc('current');

  @override
  Future<List<WalletTransaction>> getAllTransactions() async {
    final snapshot = await _collection.orderBy('date', descending: true).get();
    return snapshot.docs
        .map((doc) => WalletTransaction.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<List<WalletTransaction>> getTransactionsByType(
      TransactionType type) async {
    final snapshot = await _collection
        .where('type', isEqualTo: type.name)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => WalletTransaction.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<List<WalletTransaction>> getTransactionsByEmployee(
      String employeeId) async {
    final snapshot = await _collection
        .where('submittedBy', isEqualTo: employeeId)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => WalletTransaction.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<List<WalletTransaction>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final snapshot = await _collection
        .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('date', isLessThanOrEqualTo: end.toIso8601String())
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => WalletTransaction.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<void> createTransaction(WalletTransaction transaction) async {
    await _collection.doc(transaction.id).set(transaction.toJson());
    await _updateSummary(transaction);
  }

  @override
  Future<void> verifyTransaction(String id, String verifiedBy) async {
    await _collection.doc(id).update({
      'isVerified': true,
      'verifiedBy': verifiedBy,
      'verifiedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final doc = await _collection.doc(id).get();
    if (doc.exists) {
      final txn = WalletTransaction.fromJson(doc.data()!);
      await _collection.doc(id).delete();
      await _updateSummaryOnDelete(txn);
    }
  }

  @override
  Future<WalletSummary> getWalletSummary() async {
    final doc = await _summaryDoc.get();
    if (doc.exists && doc.data() != null) {
      return WalletSummary.fromJson(doc.data()!);
    }
    return WalletSummary.empty();
  }

  @override
  Stream<List<WalletTransaction>> watchTransactions() {
    return _collection.orderBy('date', descending: true).snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => WalletTransaction.fromJson(doc.data()))
            .toList());
  }

  Stream<List<WalletTransaction>> watchTransactionsByEmployee(
      String employeeId) {
    return _collection
        .where('submittedBy', isEqualTo: employeeId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WalletTransaction.fromJson(doc.data()))
            .toList());
  }

  @override
  Stream<WalletSummary> watchWalletSummary() {
    return _summaryDoc.snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return WalletSummary.fromJson(doc.data()!);
      }
      return WalletSummary.empty();
    });
  }

  Future<void> _updateSummary(WalletTransaction txn) async {
    final summary = await getWalletSummary();
    final now = DateTime.now();
    final isThisMonth =
        txn.date.year == now.year && txn.date.month == now.month;

    double newBalance = summary.totalBalance;
    double newRevenue = summary.totalRevenue;
    double newExpenses = summary.totalExpenses;
    double newMonthlyRevenue = summary.monthlyRevenue;
    double newMonthlyExpenses = summary.monthlyExpenses;

    if (txn.type == TransactionType.deposit) {
      newBalance += txn.amount;
      newRevenue += txn.amount;
      if (isThisMonth) newMonthlyRevenue += txn.amount;
    } else {
      newBalance -= txn.amount;
      newExpenses += txn.amount;
      if (isThisMonth) newMonthlyExpenses += txn.amount;
    }

    newBalance = newRevenue - newExpenses;

    await _summaryDoc.set({
      'totalBalance': newBalance,
      'totalRevenue': newRevenue,
      'totalExpenses': newExpenses,
      'monthlyRevenue': newMonthlyRevenue,
      'monthlyExpenses': newMonthlyExpenses,
      'lastUpdated': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _updateSummaryOnDelete(WalletTransaction txn) async {
    final summary = await getWalletSummary();

    double newBalance = summary.totalBalance;
    double newRevenue = summary.totalRevenue;
    double newExpenses = summary.totalExpenses;

    if (txn.type == TransactionType.deposit) {
      newBalance -= txn.amount;
      newRevenue -= txn.amount;
    } else {
      newBalance += txn.amount;
      newExpenses -= txn.amount;
    }

    await _summaryDoc.set({
      'totalBalance': newBalance,
      'totalRevenue': newRevenue,
      'totalExpenses': newExpenses,
      'monthlyRevenue': summary.monthlyRevenue,
      'monthlyExpenses': summary.monthlyExpenses,
      'lastUpdated': DateTime.now().toIso8601String(),
    });
  }
}
