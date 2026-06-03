import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderTemplate {
  final String id;
  final String title;
  final String message;
  final String category;

  const ReminderTemplate({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'category': category,
    };
  }

  factory ReminderTemplate.fromMap(Map<String, dynamic> map) {
    return ReminderTemplate(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      category: map['category'] ?? '',
    );
  }
}

class Reminder {
  final String id;
  final String title;
  final String message;
  final String category;
  final List<String> recipientIds;
  final String senderId;
  final DateTime sentAt;
  final bool isRead;

  const Reminder({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    required this.recipientIds,
    required this.senderId,
    required this.sentAt,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'category': category,
      'recipientIds': recipientIds,
      'senderId': senderId,
      'sentAt': Timestamp.fromDate(sentAt),
      'isRead': isRead,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map, String id) {
    return Reminder(
      id: id,
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      category: map['category'] ?? '',
      recipientIds: List<String>.from(map['recipientIds'] ?? []),
      senderId: map['senderId'] ?? '',
      sentAt: (map['sentAt'] as Timestamp).toDate(),
      isRead: map['isRead'] ?? false,
    );
  }
}
