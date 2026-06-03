enum AttendanceEventType {
  clockIn,
  clockOut,
}

enum ClockOutReason {
  manual,
  leftPerimeter,
  endOfDay,
}

class AttendanceEvent {
  final String id;
  final AttendanceEventType type;
  final DateTime timestamp;
  final String? selfieUrl;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final ClockOutReason? clockOutReason;
  final String? deviceId;
  final bool isSynced;

  const AttendanceEvent({
    required this.id,
    required this.type,
    required this.timestamp,
    this.selfieUrl,
    this.latitude,
    this.longitude,
    this.locationName,
    this.clockOutReason,
    this.deviceId,
    this.isSynced = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'selfieUrl': selfieUrl,
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'clockOutReason': clockOutReason?.name,
      'deviceId': deviceId,
      'isSynced': isSynced,
    };
  }

  factory AttendanceEvent.fromJson(Map<String, dynamic> json) {
    return AttendanceEvent(
      id: json['id'] as String,
      type:
          AttendanceEventType.values.firstWhere((e) => e.name == json['type']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      selfieUrl: json['selfieUrl'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      locationName: json['locationName'] as String?,
      clockOutReason: json['clockOutReason'] != null
          ? ClockOutReason.values
              .firstWhere((e) => e.name == json['clockOutReason'])
          : null,
      deviceId: json['deviceId'] as String?,
      isSynced: json['isSynced'] as bool? ?? false,
    );
  }

  AttendanceEvent copyWith({
    String? id,
    AttendanceEventType? type,
    DateTime? timestamp,
    String? selfieUrl,
    double? latitude,
    double? longitude,
    String? locationName,
    ClockOutReason? clockOutReason,
    String? deviceId,
    bool? isSynced,
  }) {
    return AttendanceEvent(
      id: id ?? this.id,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      selfieUrl: selfieUrl ?? this.selfieUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      clockOutReason: clockOutReason ?? this.clockOutReason,
      deviceId: deviceId ?? this.deviceId,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
