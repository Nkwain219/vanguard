enum TaskStatus { pending, inProgress, completed, cancelled }

enum TaskPriority { low, medium, high, urgent }

class Task {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final List<String> assigneeIds;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? dueDate;
  final List<String> attachments;
  final List<TaskComment> comments;
  final double progress;
  final String? projectId;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.assigneeIds,
    required this.createdBy,
    required this.createdAt,
    this.dueDate,
    this.attachments = const [],
    this.comments = const [],
    this.progress = 0.0,
    this.projectId,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    List<String>? assigneeIds,
    String? createdBy,
    DateTime? createdAt,
    DateTime? dueDate,
    List<String>? attachments,
    List<TaskComment>? comments,
    double? progress,
    String? projectId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assigneeIds: assigneeIds ?? this.assigneeIds,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      attachments: attachments ?? this.attachments,
      comments: comments ?? this.comments,
      progress: progress ?? this.progress,
      projectId: projectId ?? this.projectId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.name,
      'priority': priority.name,
      'assigneeIds': assigneeIds,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'attachments': attachments,
      'comments': comments.map((c) => c.toJson()).toList(),
      'progress': progress,
      'projectId': projectId,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      status: TaskStatus.values.firstWhere((s) => s.name == json['status']),
      priority:
          TaskPriority.values.firstWhere((p) => p.name == json['priority']),
      assigneeIds: List<String>.from(json['assigneeIds'] as List),
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      attachments: List<String>.from(json['attachments'] as List? ?? []),
      comments: (json['comments'] as List?)
              ?.map((c) => TaskComment.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      projectId: json['projectId'] as String?,
    );
  }
}

class TaskComment {
  final String id;
  final String taskId;
  final String userId;
  final String userFullName;
  final String content;
  final DateTime createdAt;

  const TaskComment({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.userFullName,
    required this.content,
    required this.createdAt,
  });

  TaskComment copyWith({
    String? id,
    String? taskId,
    String? userId,
    String? userFullName,
    String? content,
    DateTime? createdAt,
  }) {
    return TaskComment(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      userId: userId ?? this.userId,
      userFullName: userFullName ?? this.userFullName,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'userId': userId,
      'userFullName': userFullName,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TaskComment.fromJson(Map<String, dynamic> json) {
    return TaskComment(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      userId: json['userId'] as String,
      userFullName: json['userFullName'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
