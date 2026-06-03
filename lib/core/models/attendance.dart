enum AttendanceStatus { present, absent, late, halfDay }

class Attendance {
  final String id;
  final String employeeId;
  final DateTime date;
  final DateTime? clockIn;
  final DateTime? clockOut;
  final AttendanceStatus status;
  final String? notes;
  final double hoursWorked;
  final String? checkInPhotoUrl;
  final String? checkInLocation;
  final String? deviceId;
  final bool isVerified;

  const Attendance({
    required this.id,
    required this.employeeId,
    required this.date,
    this.clockIn,
    this.clockOut,
    required this.status,
    this.notes,
    this.hoursWorked = 0.0,
    this.checkInPhotoUrl,
    this.checkInLocation,
    this.deviceId,
    this.isVerified = false,
  });

  Attendance copyWith({
    String? id,
    String? employeeId,
    DateTime? date,
    DateTime? clockIn,
    DateTime? clockOut,
    AttendanceStatus? status,
    String? notes,
    double? hoursWorked,
    String? checkInPhotoUrl,
    String? checkInLocation,
    String? deviceId,
    bool? isVerified,
  }) {
    return Attendance(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      date: date ?? this.date,
      clockIn: clockIn ?? this.clockIn,
      clockOut: clockOut ?? this.clockOut,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      hoursWorked: hoursWorked ?? this.hoursWorked,
      checkInPhotoUrl: checkInPhotoUrl ?? this.checkInPhotoUrl,
      checkInLocation: checkInLocation ?? this.checkInLocation,
      deviceId: deviceId ?? this.deviceId,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'date': date.toIso8601String(),
      'clockIn': clockIn?.toIso8601String(),
      'clockOut': clockOut?.toIso8601String(),
      'status': status.name,
      'notes': notes,
      'hoursWorked': hoursWorked,
      'checkInPhotoUrl': checkInPhotoUrl,
      'checkInLocation': checkInLocation,
      'deviceId': deviceId,
      'isVerified': isVerified,
    };
  }

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      date: DateTime.parse(json['date'] as String),
      clockIn: json['clockIn'] != null
          ? DateTime.parse(json['clockIn'] as String)
          : null,
      clockOut: json['clockOut'] != null
          ? DateTime.parse(json['clockOut'] as String)
          : null,
      status:
          AttendanceStatus.values.firstWhere((s) => s.name == json['status']),
      notes: json['notes'] as String?,
      hoursWorked: (json['hoursWorked'] as num?)?.toDouble() ?? 0.0,
      checkInPhotoUrl: json['checkInPhotoUrl'] as String?,
      checkInLocation: json['checkInLocation'] as String?,
      deviceId: json['deviceId'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }
}
