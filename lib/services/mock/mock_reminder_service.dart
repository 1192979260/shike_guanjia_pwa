import 'package:shike_guanjia/models/models.dart';
import 'package:shike_guanjia/services/reminder_service.dart';

class MockReminderService implements ReminderService {
  ReminderSettings _settings;
  NotificationPermissionStatus _permissionStatus;
  List<Lesson> scheduledLessons = [];
  var cancelCount = 0;

  MockReminderService({
    ReminderSettings? initialSettings,
    NotificationPermissionStatus permissionStatus =
        NotificationPermissionStatus.granted,
  }) : _settings = initialSettings ?? ReminderSettings.defaults(),
       _permissionStatus = permissionStatus;

  @override
  Future<ReminderSettings> getReminderSettings() async => _settings;

  @override
  Future<ReminderSettings> updateReminderSettings(
    ReminderSettings settings,
  ) async {
    _settings = settings;
    return _settings;
  }

  @override
  Future<NotificationPermissionStatus> getNotificationPermissionStatus() async {
    return _permissionStatus;
  }

  @override
  Future<bool> requestNotificationPermission() async {
    _permissionStatus = NotificationPermissionStatus.granted;
    return true;
  }

  @override
  Future<void> scheduleLessonReminders(
    List<Lesson> lessons,
    ReminderSettings settings,
  ) async {
    scheduledLessons = settings.enabled
        ? lessons.where((lesson) => _isEligible(lesson, settings)).toList()
        : <Lesson>[];
  }

  @override
  Future<void> cancelLessonReminders() async {
    cancelCount += 1;
    scheduledLessons = [];
  }

  bool _isEligible(Lesson lesson, ReminderSettings settings) {
    if (lesson.status != LessonStatus.scheduled) return false;
    if (!settings.includeMakeupLessons && lesson.isMakeup) return false;
    if (!settings.includeTodayLessons && _isToday(lesson.scheduledDate)) {
      return false;
    }
    return true;
  }

  bool _isToday(DateTime value) {
    final now = DateTime.now();
    return value.year == now.year &&
        value.month == now.month &&
        value.day == now.day;
  }
}
