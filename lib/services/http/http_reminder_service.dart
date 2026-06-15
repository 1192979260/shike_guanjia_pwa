import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shike_guanjia/models/models.dart';
import 'package:shike_guanjia/services/http/api_client.dart';
import 'package:shike_guanjia/services/reminder_service.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class HttpReminderService implements ReminderService {
  HttpReminderService(this._client, {FlutterLocalNotificationsPlugin? plugin})
    : _notifications = plugin ?? FlutterLocalNotificationsPlugin();

  static const _notificationIdBase = 730000;
  static const _channelId = 'lesson_reminders';
  static const _channelName = '上课提醒';

  final ApiClient _client;
  final FlutterLocalNotificationsPlugin _notifications;
  bool _initialized = false;

  @override
  Future<ReminderSettings> getReminderSettings() async {
    final data = await _client.getData<Map<String, dynamic>>(
      '/api/reminder-settings',
    );
    return ReminderSettings.fromJson(data);
  }

  @override
  Future<ReminderSettings> updateReminderSettings(
    ReminderSettings settings,
  ) async {
    final data = await _client.patchData<Map<String, dynamic>>(
      '/api/reminder-settings',
      data: settings.toJson(),
    );
    return ReminderSettings.fromJson(data);
  }

  @override
  Future<NotificationPermissionStatus> getNotificationPermissionStatus() async {
    await _ensureInitialized();
    try {
      final android = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android != null) {
        final enabled = await android.areNotificationsEnabled();
        return enabled == true
            ? NotificationPermissionStatus.granted
            : NotificationPermissionStatus.denied;
      }

      // iOS/macOS do not expose a cheap read-only status in this plugin API.
      // Keep the UI non-blocking and let explicit permission request resolve it.
      return NotificationPermissionStatus.unknown;
    } catch (e) {
      debugPrint('Failed to read notification permission status: $e');
      return NotificationPermissionStatus.unknown;
    }
  }

  @override
  Future<bool> requestNotificationPermission() async {
    await _ensureInitialized();
    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }

    final ios = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      return await ios.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }

    final macos = _notifications
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();
    if (macos != null) {
      return await macos.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }

    return false;
  }

  @override
  Future<void> scheduleLessonReminders(
    List<Lesson> lessons,
    ReminderSettings settings,
  ) async {
    await _ensureInitialized();
    await cancelLessonReminders();
    if (!settings.enabled) {
      return;
    }

    final now = DateTime.now();
    for (final lesson in lessons.where((lesson) {
      if (!_isEligible(lesson, settings)) return false;
      final reminderAt = lesson.scheduledDate.subtract(
        Duration(minutes: settings.advanceMinutes),
      );
      return reminderAt.isAfter(now);
    })) {
      final reminderAt = lesson.scheduledDate.subtract(
        Duration(minutes: settings.advanceMinutes),
      );
      await _notifications.zonedSchedule(
        _notificationIdForLesson(lesson),
        '上课提醒',
        '还有 ${_formatAdvance(settings.advanceMinutes)} 开始上课',
        tz.TZDateTime.from(reminderAt, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: '课时管家上课前本地提醒',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
          macOS: DarwinNotificationDetails(),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: lesson.id,
      );
    }
  }

  @override
  Future<void> cancelLessonReminders() async {
    await _ensureInitialized();
    final pending = await _notifications.pendingNotificationRequests();
    for (final request in pending) {
      if (request.id >= _notificationIdBase) {
        await _notifications.cancel(request.id);
      }
    }
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      macOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _notifications.initialize(initializationSettings);
    _initialized = true;
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

  int _notificationIdForLesson(Lesson lesson) {
    return _notificationIdBase + lesson.id.hashCode.abs() % 2000000000;
  }

  String _formatAdvance(int minutes) {
    if (minutes >= 1440 && minutes % 1440 == 0) {
      return '${minutes ~/ 1440} 天';
    }
    if (minutes >= 60 && minutes % 60 == 0) {
      return '${minutes ~/ 60} 小时';
    }
    return '$minutes 分钟';
  }
}
