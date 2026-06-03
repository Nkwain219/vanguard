import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reminder.dart';
import '../repositories/reminder_repository.dart';

class ReminderState {
  final List<ReminderTemplate> templates;
  final bool isLoading;
  final String? error;
  final List<Reminder> sentReminders;

  const ReminderState({
    this.templates = const [],
    this.isLoading = false,
    this.error,
    this.sentReminders = const [],
  });

  ReminderState copyWith({
    List<ReminderTemplate>? templates,
    bool? isLoading,
    String? error,
    List<Reminder>? sentReminders,
  }) {
    return ReminderState(
      templates: templates ?? this.templates,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      sentReminders: sentReminders ?? this.sentReminders,
    );
  }
}

class ReminderViewModel extends StateNotifier<ReminderState> {
  final ReminderRepository _repository;

  ReminderViewModel(this._repository) : super(const ReminderState());

  Future<void> loadTemplates() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final templates = await _repository.getReminderTemplates();
      state = state.copyWith(templates: templates, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> sendReminder({
    required String title,
    required String message,
    required String category,
    required List<String> recipientIds,
    required String senderId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final reminder = Reminder(
        id: '',
        title: title,
        message: message,
        category: category,
        recipientIds: recipientIds,
        senderId: senderId,
        sentAt: DateTime.now(),
      );

      await _repository.sendReminder(reminder);

      final updatedSent = [...state.sentReminders, reminder];

      state = state.copyWith(isLoading: false, sentReminders: updatedSent);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
