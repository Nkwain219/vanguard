enum ProjectStatus {
  planning,
  active,
  onHold,
  completed,
  cancelled,
}

class Project {
  final String id;
  final String name;
  final String description;
  final ProjectStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final String managerId;
  final List<String> memberIds;
  final List<String> taskIds;
  final double progress;
  final DateTime createdAt;

  const Project({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.startDate,
    this.endDate,
    required this.managerId,
    this.memberIds = const [],
    this.taskIds = const [],
    this.progress = 0.0,
    required this.createdAt,
  });

  String get statusLabel {
    switch (status) {
      case ProjectStatus.planning:
        return 'Planning';
      case ProjectStatus.active:
        return 'Active';
      case ProjectStatus.onHold:
        return 'On Hold';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.cancelled:
        return 'Cancelled';
    }
  }

  int? get daysRemaining {
    if (endDate == null) return null;
    final now = DateTime.now();
    if (now.isAfter(endDate!)) return 0;
    return endDate!.difference(now).inDays;
  }

  bool get isOverdue {
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate!) &&
        status != ProjectStatus.completed;
  }

  Project copyWith({
    String? id,
    String? name,
    String? description,
    ProjectStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    String? managerId,
    List<String>? memberIds,
    List<String>? taskIds,
    double? progress,
    DateTime? createdAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      managerId: managerId ?? this.managerId,
      memberIds: memberIds ?? this.memberIds,
      taskIds: taskIds ?? this.taskIds,
      progress: progress ?? this.progress,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'managerId': managerId,
      'memberIds': memberIds,
      'taskIds': taskIds,
      'progress': progress,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      status: ProjectStatus.values.firstWhere((s) => s.name == json['status']),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      managerId: json['managerId'] as String,
      memberIds: List<String>.from(json['memberIds'] as List? ?? []),
      taskIds: List<String>.from(json['taskIds'] as List? ?? []),
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
