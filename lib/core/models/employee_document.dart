enum DocumentType {
  contract,
  idCard,
  resume,
  certificate,
  bankDetails,
  other,
}

class EmployeeDocument {
  final String id;
  final String employeeId;
  final String name;
  final DocumentType type;
  final String fileUrl;
  final String fileName;
  final int fileSize;
  final String mimeType;
  final String uploadedBy;
  final DateTime uploadedAt;
  final String? notes;

  const EmployeeDocument({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.type,
    required this.fileUrl,
    required this.fileName,
    required this.fileSize,
    required this.mimeType,
    required this.uploadedBy,
    required this.uploadedAt,
    this.notes,
  });

  EmployeeDocument copyWith({
    String? id,
    String? employeeId,
    String? name,
    DocumentType? type,
    String? fileUrl,
    String? fileName,
    int? fileSize,
    String? mimeType,
    String? uploadedBy,
    DateTime? uploadedAt,
    String? notes,
  }) {
    return EmployeeDocument(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      name: name ?? this.name,
      type: type ?? this.type,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'name': name,
      'type': type.name,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'uploadedBy': uploadedBy,
      'uploadedAt': uploadedAt.toIso8601String(),
      'notes': notes,
    };
  }

  factory EmployeeDocument.fromJson(Map<String, dynamic> json) {
    return EmployeeDocument(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      name: json['name'] as String,
      type: DocumentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DocumentType.other,
      ),
      fileUrl: json['fileUrl'] as String,
      fileName: json['fileName'] as String,
      fileSize: (json['fileSize'] as num).toInt(),
      mimeType: json['mimeType'] as String,
      uploadedBy: json['uploadedBy'] as String,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      notes: json['notes'] as String?,
    );
  }

  String get formattedSize {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}
