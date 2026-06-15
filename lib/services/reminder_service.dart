import 'package:shike_guanjia/models/models.dart';

enum NotificationPermissionStatus { granted, denied, unknown }

abstract class ReminderService {
  Future<ReminderSettings> getReminderSettings();

  Future<ReminderSettings> updateReminderSettings(ReminderSettings settings);

  Future<NotificationPermissionStatus> getNotificationPermissionStatus();

  Future<bool> requestNotificationPermission();

  Future<void> scheduleLessonReminders(
    List<Lesson> lessons,
    ReminderSettings settings,
  );

  Future<void> cancelLessonReminders();
}
