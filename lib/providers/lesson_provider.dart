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
        final now = DateTime.now();
        final start = DateTime(now.year, now.month, now.day);
        final endDay = DateTime(now.year, now.month, now.day + 30);
        _lessons = await _lessonService.getLessonsInRange(
          familyId: '',
          start: start,
          end: DateTime(endDay.year, endDay.month, endDay.day, 23, 59, 59, 999),
        );
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

  Future<void> repairMissingInitialLessons(List<TrainingClass> classes) async {
    final todayStart = DateTime.now();
    final repairableStart = DateTime(
      todayStart.year,
      todayStart.month,
      todayStart.day,
    );
    final targets = classes.where((trainingClass) {
      if (trainingClass.status != ClassStatus.active) return false;
      if (trainingClass.startTime.isBefore(repairableStart)) return false;
      return !_lessons.any(
        (lesson) =>
            lesson.classId == trainingClass.id &&
            lesson.scheduledDate.isAtSameMomentAs(trainingClass.startTime),
      );
    }).toList();
    if (targets.isEmpty) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final repaired = <Lesson>[];
      for (final trainingClass in targets) {
        repaired.addAll(await _lessonService.generateLessons(trainingClass));
      }
      final byId = {for (final lesson in _lessons) lesson.id: lesson};
      for (final lesson in repaired) {
        byId[lesson.id] = lesson;
      }
      _lessons = byId.values.toList()
        ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
      await _syncReminders();
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to repair missing initial lessons: $e');
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

  Future<bool> changeLesson({
    required String lessonId,
    required LessonChangeType type,
    required LessonChangeSource source,
    required DateTime newScheduledDate,
    String? reason,
  }) async {
    final lesson = _lessons.firstWhere(
      (l) => l.id == lessonId,
      orElse: () => throw Exception('Lesson not found'),
    );

    if (lesson.status != LessonStatus.scheduled) return false;
    if (newScheduledDate.isBefore(DateTime.now())) {
      _error = '新上课时间不能早于当前时间';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final change = await _lessonService.createLessonChange(
        lessonId: lesson.id,
        type: type,
        source: source,
        newScheduledDate: newScheduledDate,
        reason: reason,
      );
      if (change == null) {
        _error = '课次变更失败';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      final original = await _lessonService.getLesson(change.lessonId);
      final replacement = await _lessonService.getLesson(change.newLessonId);
      if (original != null) _upsertLesson(original);
      if (replacement != null) _upsertLesson(replacement);
      _lessons.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
      await _syncReminders();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to change lesson: $e');
      _isLoading = false;
      notifyListeners();
      return false;
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
      return l.status == LessonStatus.scheduled &&
          !l.scheduledDate.isBefore(now) &&
          !l.scheduledDate.isAfter(endAt);
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

  void _upsertLesson(Lesson lesson) {
    final index = _lessons.indexWhere((item) => item.id == lesson.id);
    if (index >= 0) {
      _lessons[index] = lesson;
    } else {
      _lessons.add(lesson);
    }
    final todayIndex = _todayLessons.indexWhere((item) => item.id == lesson.id);
    if (todayIndex >= 0) _todayLessons[todayIndex] = lesson;
  }
}
