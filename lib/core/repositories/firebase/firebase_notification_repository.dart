import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/notification.dart';
import '../../services/firestore_service.dart';
import '../notification_repository.dart';

class FirebaseNotificationRepository implements NotificationRepository {
  CollectionReference<Map<String, dynamic>> get _collection =>
      FirestoreService.instance.notificationsCollection;

  @override
  Future<List<AppNotification>> getAllNotifications() async {
    final snapshot =
        await _collection.orderBy('createdAt', descending: true).get();
    return snapshot.docs
        .map((doc) => AppNotification.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<List<AppNotification>> getUnreadNotifications() async {
    final snapshot = await _collection
        .where('isRead', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => AppNotification.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<AppNotification?> getNotificationById(String id) async {
    final doc = await _collection.doc(id).get();
    if (doc.exists && doc.data() != null) {
      return AppNotification.fromJson(doc.data()!);
    }
    return null;
  }

  @override
  Future<List<AppNotification>> getNotificationsForUser(
      String userId, String userRole) async {
    final snapshot =
        await _collection.orderBy('createdAt', descending: true).get();
    final allNotifications = snapshot.docs
        .map((doc) => AppNotification.fromJson(doc.data()))
        .toList();

    return allNotifications.where((n) {
      if (n.targetAudience == TargetAudience.all) return true;

      final roleAudience = '${userRole}s';
      if (n.targetAudience == TargetAudience.employees &&
          roleAudience == 'employees') return true;
      if (n.targetAudience == TargetAudience.volunteers &&
          roleAudience == 'volunteers') return true;
      if (n.targetAudience == TargetAudience.admins && roleAudience == 'admins')
        return true;
      if (n.targetAudience == TargetAudience.secretaries &&
          roleAudience == 'secretarys') return true;

      if (n.recipientIds.contains(userId)) return true;

      if (n.senderId == userId) return true;

      return false;
    }).toList();
  }

  @override
  Future<void> createNotification(AppNotification notification) async {
    await _collection.doc(notification.id).set(notification.toJson());
  }

  @override
  Future<void> markAsRead(String id) async {
    await _collection.doc(id).update({'isRead': true});
  }

  @override
  Future<void> markAllAsRead() async {
    final unread = await _collection.where('isRead', isEqualTo: false).get();
    final batch = FirestoreService.instance.firestore.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  @override
  Future<void> deleteNotification(String id) async {
    await _collection.doc(id).delete();
  }

  @override
  Future<void> clearAllNotifications() async {
    final allDocs = await _collection.get();
    final batch = FirestoreService.instance.firestore.batch();
    for (final doc in allDocs.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  @override
  Future<int> getUnreadCount() async {
    final snapshot = await _collection.where('isRead', isEqualTo: false).get();
    return snapshot.docs.length;
  }

  @override
  Stream<List<AppNotification>> watchNotifications() {
    return _collection.orderBy('createdAt', descending: true).snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => AppNotification.fromJson(doc.data()))
            .toList());
  }

  @override
  Stream<List<AppNotification>> watchNotificationsForUser(
      String userId, String userRole) {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final allNotifications = snapshot.docs
          .map((doc) => AppNotification.fromJson(doc.data()))
          .toList();

      return allNotifications.where((n) {
        if (n.targetAudience == TargetAudience.all) return true;

        final roleAudience = '${userRole}s';
        if (n.targetAudience == TargetAudience.employees &&
            roleAudience == 'employees') return true;
        if (n.targetAudience == TargetAudience.volunteers &&
            roleAudience == 'volunteers') return true;
        if (n.targetAudience == TargetAudience.admins &&
            roleAudience == 'admins') return true;
        if (n.targetAudience == TargetAudience.secretaries &&
            roleAudience == 'secretarys') return true;

        if (n.recipientIds.contains(userId)) return true;

        if (n.senderId == userId) return true;

        return false;
      }).toList();
    });
  }

  @override
  Stream<int> watchUnreadCount() {
    return _collection
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
