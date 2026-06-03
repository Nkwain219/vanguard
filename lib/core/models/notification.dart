enum NotificationType { info, warning, success, error, reminder }

enum NotificationPriority { normal, high, urgent }

enum TargetAudience { all, employees, volunteers, admins, secretaries, custom }

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationPriority priority;
  final DateTime createdAt;
  final bool isRead;
  final String? actionUrl;

  final String? senderId;
  final String? senderName;
  final TargetAudience targetAudience;
  final List<String> recipientIds;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.priority = NotificationPriority.normal,
    required this.createdAt,
    this.isRead = false,
    this.actionUrl,
    this.senderId,
    this.senderName,
    this.targetAudience = TargetAudience.all,
    this.recipientIds = const [],
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    NotificationPriority? priority,
    DateTime? createdAt,
    bool? isRead,
    String? actionUrl,
    String? senderId,
    String? senderName,
    TargetAudience? targetAudience,
    List<String>? recipientIds,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      actionUrl: actionUrl ?? this.actionUrl,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      targetAudience: targetAudience ?? this.targetAudience,
      recipientIds: recipientIds ?? this.recipientIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.name,
      'priority': priority.name,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'actionUrl': actionUrl,
      'senderId': senderId,
      'senderName': senderName,
      'targetAudience': targetAudience.name,
      'recipientIds': recipientIds,
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: NotificationType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => NotificationType.info,
      ),
      priority: NotificationPriority.values.firstWhere(
        (p) => p.name == json['priority'],
        orElse: () => NotificationPriority.normal,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      actionUrl: json['actionUrl'] as String?,
      senderId: json['senderId'] as String?,
      senderName: json['senderName'] as String?,
      targetAudience: TargetAudience.values.firstWhere(
        (a) => a.name == json['targetAudience'],
        orElse: () => TargetAudience.all,
      ),
      recipientIds: (json['recipientIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}
