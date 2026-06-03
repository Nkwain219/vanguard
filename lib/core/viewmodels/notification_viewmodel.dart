import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification.dart';
import '../repositories/notification_repository.dart';

class NotificationState {
  final List<AppNotification> notifications;
  final int unreadCount;
  final bool isLoading;
  final String? error;

  const NotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.error,
  });

  NotificationState copyWith({
    List<AppNotification>? notifications,
    int? unreadCount,
    bool? isLoading,
    String? error,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class NotificationViewModel extends StateNotifier<NotificationState> {
  final NotificationRepository _repository;
  final String? _userId;
  final String? _userRole;
  StreamSubscription<List<AppNotification>>? _subscription;

  NotificationViewModel(this._repository, {String? userId, String? userRole})
      : _userId = userId,
        _userRole = userRole,
        super(const NotificationState()) {
    watchNotifications();
  }

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      List<AppNotification> notifications;
      if (_userId != null && _userRole != null) {
        notifications =
            await _repository.getNotificationsForUser(_userId!, _userRole!);
      } else {
        notifications = await _repository.getAllNotifications();
      }
      final unreadCount = notifications.where((n) => !n.isRead).length;
      state = state.copyWith(
        notifications: notifications,
        unreadCount: unreadCount,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void watchNotifications() {
    _subscription?.cancel();
    Stream<List<AppNotification>> stream;
    if (_userId != null && _userRole != null) {
      stream = _repository.watchNotificationsForUser(_userId!, _userRole!);
    } else {
      stream = _repository.watchNotifications();
    }
    _subscription = stream.listen(
      (notifications) {
        final unreadCount = notifications.where((n) => !n.isRead).length;
        state = state.copyWith(
          notifications: notifications,
          unreadCount: unreadCount,
          isLoading: false,
        );
      },
      onError: (e) {
        state = state.copyWith(error: e.toString(), isLoading: false);
      },
    );
  }

  Future<void> sendNotification({
    required String title,
    required String message,
    required NotificationType type,
    NotificationPriority priority = NotificationPriority.normal,
    TargetAudience targetAudience = TargetAudience.all,
    List<String> recipientIds = const [],
    String? senderId,
    String? senderName,
    String? actionUrl,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final notification = AppNotification(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}_${senderId ?? 'system'}',
        title: title,
        message: message,
        type: type,
        priority: priority,
        createdAt: DateTime.now(),
        senderId: senderId,
        senderName: senderName,
        targetAudience: targetAudience,
        recipientIds: recipientIds,
        actionUrl: actionUrl,
      );
      await _repository.createNotification(notification);

      await loadNotifications();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _repository.markAsRead(id);
      final updated = state.notifications.map((n) {
        if (n.id == id) return n.copyWith(isRead: true);
        return n;
      }).toList();
      state = state.copyWith(
        notifications: updated,
        unreadCount: updated.where((n) => !n.isRead).length,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      final updated =
          state.notifications.map((n) => n.copyWith(isRead: true)).toList();
      state = state.copyWith(notifications: updated, unreadCount: 0);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _repository.deleteNotification(id);
      final updated = state.notifications.where((n) => n.id != id).toList();
      state = state.copyWith(
        notifications: updated,
        unreadCount: updated.where((n) => !n.isRead).length,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
