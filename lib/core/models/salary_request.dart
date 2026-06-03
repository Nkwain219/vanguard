enum SalaryRequestStatus { pending, approved, rejected }

enum SalaryRequestType { salary, bonus, overtime, deduction, advance }

class SalaryRequest {
  final String id;
  final String employeeId;
  final String employeeFullName;
  final SalaryRequestType type;
  final double amount;
  final String reason;
  final SalaryRequestStatus status;
  final DateTime requestDate;
  final DateTime? approvalDate;
  final String? approvedBy;
  final String? notes;

  const SalaryRequest({
    required this.id,
    required this.employeeId,
    required this.employeeFullName,
    required this.type,
    required this.amount,
    required this.reason,
    required this.status,
    required this.requestDate,
    this.approvalDate,
    this.approvedBy,
    this.notes,
  });

  SalaryRequest copyWith({
    String? id,
    String? employeeId,
    String? employeeFullName,
    SalaryRequestType? type,
    double? amount,
    String? reason,
    SalaryRequestStatus? status,
    DateTime? requestDate,
    DateTime? approvalDate,
    String? approvedBy,
    String? notes,
  }) {
    return SalaryRequest(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeFullName: employeeFullName ?? this.employeeFullName,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      requestDate: requestDate ?? this.requestDate,
      approvalDate: approvalDate ?? this.approvalDate,
      approvedBy: approvedBy ?? this.approvedBy,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'employeeFullName': employeeFullName,
      'type': type.name,
      'amount': amount,
      'reason': reason,
      'status': status.name,
      'requestDate': requestDate.toIso8601String(),
      'approvalDate': approvalDate?.toIso8601String(),
      'approvedBy': approvedBy,
      'notes': notes,
    };
  }

  factory SalaryRequest.fromJson(Map<String, dynamic> json) {
    return SalaryRequest(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      employeeFullName: json['employeeFullName'] as String,
      type: SalaryRequestType.values.firstWhere((t) => t.name == json['type']),
      amount: (json['amount'] as num).toDouble(),
      reason: json['reason'] as String,
      status: SalaryRequestStatus.values
          .firstWhere((s) => s.name == json['status']),
      requestDate: DateTime.parse(json['requestDate'] as String),
      approvalDate: json['approvalDate'] != null
          ? DateTime.parse(json['approvalDate'] as String)
          : null,
      approvedBy: json['approvedBy'] as String?,
      notes: json['notes'] as String?,
    );
  }
}
