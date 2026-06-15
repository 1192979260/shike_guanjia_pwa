import 'package:flutter/foundation.dart';
import 'package:shike_guanjia/core/service_locator.dart';
import 'package:shike_guanjia/models/models.dart';
import 'package:shike_guanjia/services/reminder_service.dart';
import 'package:shike_guanjia/services/storage_service.dart';

class ReminderProvider extends ChangeNotifier {
  ReminderProvider({ReminderService? reminderService, StorageService? storage})
    : _reminderService = reminderService ?? getIt<ReminderService>(),
      _storage = storage ?? getIt<StorageService>();

  final ReminderService _reminderService;
  final StorageService _storage;

  ReminderSettings _settings = ReminderSettings.defaults();
  NotificationPermissionStatus _permissionStatus =
      NotificationPermissionStatus.unknown;
  List<Lesson> _lastLessons = [];
  bool _isLoading = false;
  bool _isSaving = false;
  bool _initialized = false;
  bool _lastLoggedIn = false;
  String? _error;

  ReminderSettings get settings => _settings;
  NotificationPermissionStatus get permissionStatus => _permissionStatus;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get initialized => _initialized;
  String? get error => _error;

  Future<void> init({bool loggedIn = false}) async {
    if (_initialized) return;
    _isLoading = true;
    _settings = _storage.cachedReminderSettings ?? ReminderSettings.defaults();
    notifyListeners();

    await refreshPermissionStatus();
    if (loggedIn) {
      await syncFromServer();
    }

    _lastLoggedIn = loggedIn;
    _initialized = true;
    _isLoading = false;
    notifyListeners();
  }

  void onAuthChanged(bool loggedIn) {
    if (!_initialized) {
      init(loggedIn: loggedIn);
      return;
    }
    if (!loggedIn && _lastLoggedIn) {
      clearForLogout();
    }
    if (loggedIn && !_lastLoggedIn) {
      syncFromServer();
    }
    _lastLoggedIn = loggedIn;
  }

  Future<void> syncFromServer() async {
    try {
      final serverSettings = await _reminderService.getReminderSettings();
      _settings = serverSettings;
      await _storage.cacheReminderSettings(serverSettings);
      _error = null;
      await rescheduleLessons();
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to sync reminder settings: $e');
    }
    notifyListeners();
  }

  Future<void> updateSettings(ReminderSettings settings) async {
    final localSettings = settings.copyWith(updatedAt: DateTime.now());
    _settings = localSettings;
    _isSaving = true;
    _error = null;
    await _storage.cacheReminderSettings(localSettings);
    notifyListeners();

    await rescheduleLessons();
    try {
      final saved = await _reminderService.updateReminderSettings(
        localSettings,
      );
      _settings = saved;
      await _storage.cacheReminderSettings(saved);
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to save reminder settings: $e');
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> refreshPermissionStatus() async {
    _permissionStatus = await _reminderService
        .getNotificationPermissionStatus();
    notifyListeners();
  }

  Future<void> requestPermission() async {
    final granted = await _reminderService.requestNotificationPermission();
    _permissionStatus = granted
        ? NotificationPermissionStatus.granted
        : NotificationPermissionStatus.denied;
    notifyListeners();
  }

  Future<void> updateLessons(List<Lesson> lessons) async {
    _lastLessons = List.unmodifiable(lessons);
    await rescheduleLessons();
  }

  Future<void> rescheduleLessons() async {
    if (!_settings.enabled) {
      await _reminderService.cancelLessonReminders();
      return;
    }
    await _reminderService.scheduleLessonReminders(_lastLessons, _settings);
  }

  Future<void> clearForLogout() async {
    _lastLoggedIn = false;
    _lastLessons = [];
    await _reminderService.cancelLessonReminders();
    notifyListeners();
  }
}
