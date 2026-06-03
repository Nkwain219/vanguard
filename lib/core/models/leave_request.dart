enum LeaveStatus { pending, approved, rejected }

enum LeaveType { annual, sick, maternity, paternity, emergency, unpaid }

class LeaveRequest {
  final String id;
  final String employeeId;
  final String employeeFullName;
  final LeaveType type;
  final DateTime startDate;
  final DateTime endDate;
  final int days;
  final String reason;
  final LeaveStatus status;
  final DateTime requestDate;
  final DateTime? approvalDate;
  final String? approvedBy;
  final String? notes;

  const LeaveRequest({
    required this.id,
    required this.employeeId,
    required this.employeeFullName,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.reason,
    required this.status,
    required this.requestDate,
    this.approvalDate,
    this.approvedBy,
    this.notes,
  });

  LeaveRequest copyWith({
    String? id,
    String? employeeId,
    String? employeeFullName,
    LeaveType? type,
    DateTime? startDate,
    DateTime? endDate,
    int? days,
    String? reason,
    LeaveStatus? status,
    DateTime? requestDate,
    DateTime? approvalDate,
    String? approvedBy,
    String? notes,
  }) {
    return LeaveRequest(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeFullName: employeeFullName ?? this.employeeFullName,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      days: days ?? this.days,
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
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'days': days,
      'reason': reason,
      'status': status.name,
      'requestDate': requestDate.toIso8601String(),
      'approvalDate': approvalDate?.toIso8601String(),
      'approvedBy': approvedBy,
      'notes': notes,
    };
  }

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      employeeFullName: json['employeeFullName'] as String,
      type: LeaveType.values.firstWhere((t) => t.name == json['type']),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      days: json['days'] as int,
      reason: json['reason'] as String,
      status: LeaveStatus.values.firstWhere((s) => s.name == json['status']),
      requestDate: DateTime.parse(json['requestDate'] as String),
      approvalDate: json['approvalDate'] != null
          ? DateTime.parse(json['approvalDate'] as String)
          : null,
      approvedBy: json['approvedBy'] as String?,
      notes: json['notes'] as String?,
    );
  }
}
