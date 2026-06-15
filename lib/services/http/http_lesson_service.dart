import 'package:shike_guanjia/models/models.dart';
import 'package:shike_guanjia/services/http/http_backend_service.dart';
import 'package:shike_guanjia/services/lesson_service.dart';

class HttpLessonService implements LessonService {
  HttpLessonService(this._backend);

  final HttpBackendService _backend;

  @override
  Future<List<Lesson>> generateLessons(TrainingClass trainingClass) =>
      _backend.generateLessons(trainingClass);

  @override
  Future<Lesson?> getLesson(String lessonId) => _backend.getLesson(lessonId);

  @override
  Future<List<Lesson>> getClassLessons(String classId) =>
      _backend.getClassLessons(classId);

  @override
  Future<List<Lesson>> getLessonsInRange({
    required String familyId,
    required DateTime start,
    required DateTime end,
    String? childId,
    String? classId,
  }) => _backend.getLessonsInRange(
    familyId: familyId,
    start: start,
    end: end,
    childId: childId,
    classId: classId,
  );

  @override
  Future<List<Lesson>> getTodayLessons(String familyId) =>
      _backend.getTodayLessons(familyId);

  @override
  Future<List<Lesson>> getUpcomingLessons(String familyId, {int days = 3}) =>
      _backend.getUpcomingLessons(familyId, days: days);

  @override
  Future<Lesson?> addManualLesson({
    required String classId,
    required DateTime scheduledDate,
  }) =>
      _backend.addManualLesson(classId: classId, scheduledDate: scheduledDate);

  @override
  Future<LessonChangeRecord?> createLessonChange({
    required String lessonId,
    required LessonChangeType type,
    required LessonChangeSource source,
    required DateTime newScheduledDate,
    String? reason,
  }) => _backend.createLessonChange(
    lessonId: lessonId,
    type: type,
    source: source,
    newScheduledDate: newScheduledDate,
    reason: reason,
  );

  @override
  Future<bool> cancelLessonChange(String changeId) =>
      _backend.cancelLessonChange(changeId);

  @override
  Future<List<LessonChangeRecord>> getLessonChangeHistory({
    String? childId,
    DateTime? startDate,
    DateTime? endDate,
  }) => _backend.getLessonChangeHistory(
    childId: childId,
    startDate: startDate,
    endDate: endDate,
  );

  @override
  Future<Lesson?> updateLesson(
    String lessonId, {
    DateTime? scheduledDate,
    LessonStatus? status,
    String? notes,
  }) => _backend.updateLesson(
    lessonId,
    scheduledDate: scheduledDate,
    status: status,
    notes: notes,
  );

  @override
  Future<bool> deleteLesson(String lessonId) => _backend.deleteLesson(lessonId);

  @override
  Future<List<Lesson>> checkConflicts(Lesson lesson) =>
      _backend.checkLessonConflicts(lesson);

  @override
  Future<bool> setSuspensionPeriod({
    required String classId,
    required DateTime start,
    required DateTime end,
  }) => _backend.setSuspensionPeriod(classId: classId, start: start, end: end);

  @override
  Future<bool> removeSuspensionPeriod(String classId) =>
      _backend.removeSuspensionPeriod(classId);
}
