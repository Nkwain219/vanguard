import '../models/notification.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> getAllNotifications();

  Future<List<AppNotification>> getUnreadNotifications();

  Future<AppNotification?> getNotificationById(String id);

  Future<List<AppNotification>> getNotificationsForUser(
      String userId, String userRole);

  Future<void> createNotification(AppNotification notification);

  Future<void> markAsRead(String id);

  Future<void> markAllAsRead();

  Future<void> deleteNotification(String id);

  Future<void> clearAllNotifications();

  Future<int> getUnreadCount();

  Stream<List<AppNotification>> watchNotifications();

  Stream<List<AppNotification>> watchNotificationsForUser(
      String userId, String userRole);

  Stream<int> watchUnreadCount();
}
