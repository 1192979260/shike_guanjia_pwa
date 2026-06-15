import 'package:flutter/foundation.dart';
import '../core/service_locator.dart';
import '../models/models.dart';
import '../services/attendance_service.dart';
import '../services/lesson_service.dart';
import 'reminder_provider.dart';

class LessonProvider extends ChangeNotifier {
  final LessonService _lessonService = getIt<LessonService>();
  final AttendanceService _attendanceService = getIt<AttendanceService>();
  ReminderProvider? _reminderProvider;

  List<Lesson> _lessons = [];
  List<Lesson> _todayLessons = [];
  bool _isLoading = false;
  String? _error;

  List<Lesson> get lessons => _lessons;
  List<Lesson> get todayLessons => _todayLessons;
  bool get isLoading => _isLoading;
  String? get error => _error;

  LessonProvider({ReminderProvider? reminderProvider})
    : _reminderProvider = reminderProvider;

  void updateReminderProvider(ReminderProvider reminderProvider) {
    _reminderProvider = reminderProvider;
  }

  Future<void> loadLessons({
    String? classId,
    DateTime? startFrom,
    DateTime? endAt,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (classId != null) {
        final classLessons = await _lessonService.getClassLessons(classId);
        _lessons = [
          ..._lessons.where((lesson) => lesson.classId != classId),
          ...classLessons,
        ]..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
      } else if (startFrom != null && endAt != null) {
        _lessons = await _lessonService.getLessonsInRange(
          familyId: '',
          start: startFrom,
          end: endAt,
        );
      } else {
        _lessons = await _lessonService.getUpcomingLessons('', days: 30);
      }
      await _syncReminders();
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to load lessons: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadTodayLessons() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _todayLessons = await _lessonService.getTodayLessons('');
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to load today lessons: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Lesson> createLesson({
    required String classId,
    required DateTime scheduledDate,
  }) async {
    Lesson? lesson;

    _isLoading = true;
    notifyListeners();

    try {
      lesson = await _lessonService.addManualLesson(
        classId: classId,
        scheduledDate: scheduledDate,
      );
      if (lesson != null) {
        _lessons.add(lesson);
        await _syncReminders();
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return lesson ??
        Lesson(
          id: '',
          classId: classId,
          scheduledDate: scheduledDate,
          status: LessonStatus.scheduled,
        );
  }

  Future<bool> checkinLesson(String lessonId) async {
    final lesson = _lessons.firstWhere(
      (l) => l.id == lessonId,
      orElse: () => throw Exception('Lesson not found'),
    );

    if (lesson.status == LessonStatus.scheduled) {
      _isLoading = true;
      notifyListeners();

      try {
        await _attendanceService.checkIn(
          lessonId: lesson.id,
          classId: lesson.classId,
          childId: '',
        );
        final updated = await _lessonService.getLesson(lesson.id);
        final index = _lessons.indexOf(lesson);
        if (updated != null) _lessons[index] = updated;
        final todayIndex = _todayLessons.indexWhere(
          (item) => item.id == lesson.id,
        );
        if (updated != null && todayIndex >= 0) {
          _todayLessons[todayIndex] = updated;
        }
        await _syncReminders();
      } catch (e) {
        _error = e.toString();
        debugPrint('Failed to checkin: $e');
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> cancelCheckIn(String lessonId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _attendanceService.cancelCheckIn(lessonId);
      final updated = await _lessonService.getLesson(lessonId);
      if (updated != null) {
        final index = _lessons.indexWhere((lesson) => lesson.id == lessonId);
        if (index >= 0) _lessons[index] = updated;
        final todayIndex = _todayLessons.indexWhere(
          (lesson) => lesson.id == lessonId,
        );
        if (todayIndex >= 0) _todayLessons[todayIndex] = updated;
        await _syncReminders();
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to cancel check-in: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markLeave(String lessonId, String reason) async {
    final lesson = _lessons.firstWhere(
      (l) => l.id == lessonId,
      orElse: () => throw Exception('Lesson not found'),
    );

    if (lesson.status == LessonStatus.scheduled) {
      final updated = lesson.copyWith(
        status: LessonStatus.leave,
        leaveReason: reason,
      );

      _isLoading = true;
      notifyListeners();

      try {
        await _attendanceService.checkIn(
          lessonId: lesson.id,
          classId: lesson.classId,
          childId: '',
        );
        final index = _lessons.indexOf(lesson);
        _lessons[index] = updated;
        await _syncReminders();
      } catch (e) {
        _error = e.toString();
      }

      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteLesson(String lessonId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _lessonService.deleteLesson(lessonId);
      _lessons.removeWhere((l) => l.id == lessonId);
      _todayLessons.removeWhere((l) => l.id == lessonId);
      await _syncReminders();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Get today's lessons
  List<Lesson> getTodayLessons() {
    final now = DateTime.now();
    return _lessons.where((l) {
      return l.scheduledDate.year == now.year &&
          l.scheduledDate.month == now.month &&
          l.scheduledDate.day == now.day &&
          l.status == LessonStatus.scheduled;
    }).toList();
  }

  /// Get upcoming lessons (next N days)
  List<Lesson> getUpcomingLessons(int days) {
    final now = DateTime.now();
    final endAt = DateTime(now.year, now.month, now.day + days);
    return _lessons.where((l) {
      return !l.scheduledDate.isBefore(now) && !l.scheduledDate.isAfter(endAt);
    }).toList();
  }

  /// Get monthly stats
  Map<String, dynamic> getMonthlyStats(DateTime month) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0);

    final monthLessons = _lessons.where((l) {
      return !l.scheduledDate.isBefore(start) && !l.scheduledDate.isAfter(end);
    }).toList();

    final completed = monthLessons
        .where((l) => l.status == LessonStatus.completed)
        .length;
    final leaves = monthLessons
        .where((l) => l.status == LessonStatus.leave)
        .length;
    final scheduled = monthLessons
        .where((l) => l.status == LessonStatus.scheduled)
        .length;

    return {'completed': completed, 'leaves': leaves, 'scheduled': scheduled};
  }

  Future<void> _syncReminders() async {
    await _reminderProvider?.updateLessons(_lessons);
  }
}
