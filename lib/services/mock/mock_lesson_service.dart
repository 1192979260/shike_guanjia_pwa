import "package:shike_guanjia/models/models.dart";
import 'package:uuid/uuid.dart';

import 'package:shike_guanjia/services/lesson_service.dart';
import 'package:shike_guanjia/services/mock/mock_data_store.dart';
import 'package:shike_guanjia/services/scheduling_engine.dart';

class MockLessonService implements LessonService {
  MockLessonService(this._store);

  final MockDataStore _store;
  final _uuid = const Uuid();
  final _suspensions = <String, List<_SuspensionPeriod>>{};

  @override
  Future<List<Lesson>> generateLessons(TrainingClass trainingClass) async {
    final dates = LessonGenerator.generateLessonDates(
      rule: trainingClass.recurringRule,
      startDate: trainingClass.startTime,
      endDate: trainingClass.endTime,
      totalLessons: trainingClass.totalHours,
    );

    final lessons = dates
        .where((date) => !_isSuspended(trainingClass.id, date))
        .map((date) => _createLesson(trainingClass, date))
        .toList();

    for (final lesson in lessons) {
      _store.lessons[lesson.id] = lesson;
    }
    return lessons;
  }

  Lesson _createLesson(TrainingClass trainingClass, DateTime date) {
    final slot = _slotForDate(trainingClass, date);
    final start = DateTime(
      date.year,
      date.month,
      date.day,
      slot?.startHour ?? trainingClass.startTime.hour,
      slot?.startMinute ?? trainingClass.startTime.minute,
    );
    final end = slot == null
        ? start.add(const Duration(hours: 1))
        : DateTime(
            date.year,
            date.month,
            date.day,
            slot.endHour,
            slot.endMinute,
          );
    return Lesson(
      id: _uuid.v4(),
      classId: trainingClass.id,
      scheduledDate: start,
      scheduledEndDate: end.isAfter(start)
          ? end
          : start.add(const Duration(hours: 1)),
      status: LessonStatus.scheduled,
    );
  }

  LessonTimeSlot? _slotForDate(TrainingClass trainingClass, DateTime date) {
    final dayOfWeek = date.weekday == DateTime.sunday ? 0 : date.weekday;
    for (final slot in trainingClass.recurringRule.timeSlots) {
      if (slot.dayOfWeek == dayOfWeek) return slot;
    }
    return null;
  }

  @override
  Future<Lesson?> getLesson(String lessonId) async => _store.lessons[lessonId];

  @override
  Future<List<Lesson>> getClassLessons(String classId) async {
    return _store.lessons.values
        .where((lesson) => lesson.classId == classId)
        .toList(growable: false);
  }

  @override
  Future<List<Lesson>> getLessonsInRange({
    required String familyId,
    required DateTime start,
    required DateTime end,
    String? childId,
    String? classId,
  }) async {
    return _store.lessons.values
        .where((lesson) {
          final trainingClass = _store.classes[lesson.classId];
          if (trainingClass == null || trainingClass.familyId != familyId) {
            return false;
          }
          if (childId != null && trainingClass.childId != childId) {
            return false;
          }
          if (classId != null && lesson.classId != classId) {
            return false;
          }
          return !lesson.scheduledDate.isBefore(start) &&
              !lesson.scheduledDate.isAfter(end);
        })
        .toList(growable: false);
  }

  @override
  Future<List<Lesson>> getTodayLessons(String familyId) {
    final now = DateTime.now();
    return getLessonsInRange(
      familyId: familyId,
      start: DateTime(now.year, now.month, now.day),
      end: DateTime(now.year, now.month, now.day, 23, 59, 59),
    );
  }

  @override
  Future<List<Lesson>> getUpcomingLessons(String familyId, {int days = 3}) {
    final now = DateTime.now();
    return getLessonsInRange(
      familyId: familyId,
      start: now,
      end: now.add(Duration(days: days)),
    );
  }

  @override
  Future<Lesson?> addManualLesson({
    required String classId,
    required DateTime scheduledDate,
  }) async {
    if (!_store.classes.containsKey(classId)) {
      return null;
    }
    final lesson = Lesson(
      id: _uuid.v4(),
      classId: classId,
      scheduledDate: scheduledDate,
      status: LessonStatus.scheduled,
    );
    _store.lessons[lesson.id] = lesson;
    return lesson;
  }

  @override
  Future<Lesson?> updateLesson(
    String lessonId, {
    DateTime? scheduledDate,
    LessonStatus? status,
    String? notes,
  }) async {
    final existing = _store.lessons[lessonId];
    if (existing == null) {
      return null;
    }
    final updated = existing.copyWith(
      scheduledDate: scheduledDate,
      status: status,
      notes: notes,
      actualDate: status == LessonStatus.completed ? DateTime.now() : null,
      checkinTime: status == LessonStatus.completed ? DateTime.now() : null,
    );
    _store.lessons[lessonId] = updated;
    return updated;
  }

  @override
  Future<bool> deleteLesson(String lessonId) async {
    return _store.lessons.remove(lessonId) != null;
  }

  @override
  Future<List<Lesson>> checkConflicts(Lesson lesson) async {
    final trainingClass = _store.classes[lesson.classId];
    if (trainingClass == null) {
      return const [];
    }

    final existingLessons = _store.lessons.values.where((existing) {
      if (existing.id == lesson.id) {
        return false;
      }
      final existingClass = _store.classes[existing.classId];
      return existingClass?.childId == trainingClass.childId;
    }).toList();

    return ConflictDetector.detectConflicts(
      existingLessons: existingLessons,
      newLesson: lesson,
    ).map((conflict) => conflict.existingLesson).toList(growable: false);
  }

  @override
  Future<bool> setSuspensionPeriod({
    required String classId,
    required DateTime start,
    required DateTime end,
  }) async {
    if (!_store.classes.containsKey(classId) || end.isBefore(start)) {
      return false;
    }
    _suspensions
        .putIfAbsent(classId, () => <_SuspensionPeriod>[])
        .add(_SuspensionPeriod(start, end));
    _store.lessons.removeWhere(
      (_, lesson) =>
          lesson.classId == classId &&
          lesson.status == LessonStatus.scheduled &&
          !lesson.scheduledDate.isBefore(start) &&
          !lesson.scheduledDate.isAfter(end),
    );
    return true;
  }

  @override
  Future<bool> removeSuspensionPeriod(String classId) async {
    return _suspensions.remove(classId) != null;
  }

  bool _isSuspended(String classId, DateTime date) {
    return (_suspensions[classId] ?? const <_SuspensionPeriod>[]).any(
      (period) => !date.isBefore(period.start) && !date.isAfter(period.end),
    );
  }
}

class _SuspensionPeriod {
  const _SuspensionPeriod(this.start, this.end);

  final DateTime start;
  final DateTime end;
}
