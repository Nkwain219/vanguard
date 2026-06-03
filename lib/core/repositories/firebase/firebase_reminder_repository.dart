import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/reminder.dart';
import '../reminder_repository.dart';

class FirebaseReminderRepository implements ReminderRepository {
  final FirebaseFirestore _firestore;

  FirebaseReminderRepository(this._firestore);

  @override
  Future<List<ReminderTemplate>> getReminderTemplates() async {
    return [
      const ReminderTemplate(
        id: 'attendance_check',
        title: 'Attendance Check',
        category: 'Attendance',
        message:
            'Please remember to clock in/out correctly today. Check your attendance history for any missing logs.',
      ),
      const ReminderTemplate(
        id: 'expense_submit',
        title: 'Submit Expenses',
        category: 'Finance',
        message:
            'This is a reminder to submit all pending expense reports by end of day Friday for reimbursement.',
      ),
      const ReminderTemplate(
        id: 'meeting_all_hands',
        title: 'All Hands Meeting',
        category: 'Meetings',
        message:
            'Join us for the monthly All Hands meeting tomorrow at 10:00 AM in the main conference room.',
      ),
      const ReminderTemplate(
        id: 'policy_update',
        title: 'Policy Update',
        category: 'HR',
        message:
            'A new company policy has been published. Please review the updated handbook in the Documents section.',
      ),
      const ReminderTemplate(
        id: 'holiday_notice',
        title: 'Upcoming Holiday',
        category: 'HR',
        message:
            'The office will be closed next Monday for the public holiday. Enjoy your long weekend!',
      ),
      const ReminderTemplate(
        id: 'timesheet_due',
        title: 'Timesheets Due',
        category: 'Payroll',
        message:
            'Friendly reminder to submit your timesheets for this pay period by 5:00 PM today.',
      ),
    ];
  }

  @override
  Future<void> sendReminder(Reminder reminder) async {
    await _firestore.collection('vanguard_reminders').add(reminder.toMap());
  }

  @override
  Future<List<Reminder>> getRemindersForUser(String userId) async {
    final snapshot = await _firestore
        .collection('vanguard_reminders')
        .where('recipientIds', arrayContains: userId)
        .orderBy('sentAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Reminder.fromMap(doc.data(), doc.id))
        .toList();
  }
}
