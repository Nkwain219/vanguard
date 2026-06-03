enum DepositStatus { pending, approved, rejected }

enum DepositType { travel, meal, equipment, office, other }

class Deposit {
  final String id;
  final String employeeId;
  final String employeeFullName;
  final DepositType type;
  final double amount;
  final String reason;
  final DepositStatus status;
  final DateTime requestDate;
  final DateTime? approvalDate;
  final String? approvedBy;
  final List<String> attachments;
  final String? notes;

  const Deposit({
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
    this.attachments = const [],
    this.notes,
  });

  Deposit copyWith({
    String? id,
    String? employeeId,
    String? employeeFullName,
    DepositType? type,
    double? amount,
    String? reason,
    DepositStatus? status,
    DateTime? requestDate,
    DateTime? approvalDate,
    String? approvedBy,
    List<String>? attachments,
    String? notes,
  }) {
    return Deposit(
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
      attachments: attachments ?? this.attachments,
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
      'attachments': attachments,
      'notes': notes,
    };
  }

  factory Deposit.fromJson(Map<String, dynamic> json) {
    return Deposit(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      employeeFullName: json['employeeFullName'] as String,
      type: DepositType.values.firstWhere((t) => t.name == json['type']),
      amount: (json['amount'] as num).toDouble(),
      reason: json['reason'] as String,
      status: DepositStatus.values.firstWhere((s) => s.name == json['status']),
      requestDate: DateTime.parse(json['requestDate'] as String),
      approvalDate: json['approvalDate'] != null
          ? DateTime.parse(json['approvalDate'] as String)
          : null,
      approvedBy: json['approvedBy'] as String?,
      attachments: List<String>.from(json['attachments'] as List? ?? []),
      notes: json['notes'] as String?,
    );
  }
}
