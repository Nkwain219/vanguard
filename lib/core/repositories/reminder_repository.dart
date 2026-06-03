import '../models/reminder.dart';

abstract class ReminderRepository {
  Future<List<ReminderTemplate>> getReminderTemplates();
  Future<void> sendReminder(Reminder reminder);
  Future<List<Reminder>> getRemindersForUser(String userId);
}
