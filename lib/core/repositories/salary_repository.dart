import '../models/salary_request.dart';

abstract class SalaryRepository {
  Future<List<SalaryRequest>> getAllSalaryRequests();

  Future<SalaryRequest?> getSalaryRequestById(String id);

  Future<List<SalaryRequest>> getSalaryRequestsByEmployee(String employeeId);

  Future<List<SalaryRequest>> getSalaryRequestsByStatus(
      SalaryRequestStatus status);

  Future<List<SalaryRequest>> getSalaryRequestsByType(SalaryRequestType type);

  Future<List<SalaryRequest>> getPendingSalaryRequests();

  Future<void> createSalaryRequest(SalaryRequest request);

  Future<void> approveSalaryRequest(String id, String approvedBy,
      {String? notes});

  Future<void> rejectSalaryRequest(String id, String approvedBy,
      {String? notes});

  Future<void> cancelSalaryRequest(String id);

  Stream<List<SalaryRequest>> watchSalaryRequests(String employeeId);

  Stream<List<SalaryRequest>> watchPendingSalaryRequests();

  Future<DisbursementResult> disburseSalary(String requestId, {String? notes});
}

class DisbursementResult {
  final bool success;
  final String? transactionId;
  final String message;
  final String? error;

  const DisbursementResult({
    required this.success,
    this.transactionId,
    required this.message,
    this.error,
  });

  factory DisbursementResult.fromJson(Map<String, dynamic> json) {
    return DisbursementResult(
      success: json['success'] as bool? ?? false,
      transactionId: json['transactionId'] as String?,
      message: json['message'] as String? ?? '',
      error: json['error'] as String?,
    );
  }
}
