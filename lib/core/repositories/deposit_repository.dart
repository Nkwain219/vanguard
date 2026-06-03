import '../models/deposit.dart';

abstract class DepositRepository {
  Future<List<Deposit>> getAllDeposits();

  Future<Deposit?> getDepositById(String id);

  Future<List<Deposit>> getDepositsByEmployee(String employeeId);

  Future<List<Deposit>> getDepositsByStatus(DepositStatus status);

  Future<List<Deposit>> getDepositsByType(DepositType type);

  Future<List<Deposit>> getPendingDeposits();

  Future<void> createDeposit(Deposit deposit);

  Future<void> approveDeposit(String id, String approvedBy, {String? notes});

  Future<void> rejectDeposit(String id, String approvedBy, {String? notes});

  Future<void> cancelDeposit(String id);

  Stream<List<Deposit>> watchDeposits(String employeeId);

  Stream<List<Deposit>> watchPendingDeposits();
}
