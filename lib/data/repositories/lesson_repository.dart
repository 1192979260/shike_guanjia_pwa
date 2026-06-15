import 'package:shike_guanjia/data/repositories/base_repository.dart';
import 'package:shike_guanjia/models/models.dart';
import 'package:shike_guanjia/services/lesson_service.dart';


class LessonRepository extends BaseRepository {
  LessonRepository(this._service);

  final LessonService _service;

  Future<RepositoryResult<List<Lesson>>> generateLessons(
    TrainingClass trainingClass,
  ) {
    return guard(() => _service.generateLessons(trainingClass));
  }

  Future<RepositoryResult<Lesson>> getLesson(String lessonId) {
    return guardNullable(
      () => _service.getLesson(lessonId),
      notFoundError: 'Lesson not found',
    );
  }

  Future<RepositoryResult<List<Lesson>>> getClassLessons(String classId) {
    return guard(() => _service.getClassLessons(classId));
  }

  Future<RepositoryResult<List<Lesson>>> getLessonsInRange({
    required String familyId,
    required DateTime start,
    required DateTime end,
    String? childId,
    String? classId,
  }) {
    return guard(
      () => _service.getLessonsInRange(
        familyId: familyId,
        start: start,
        end: end,
        childId: childId,
        classId: classId,
      ),
    );
  }

  Future<RepositoryResult<List<Lesson>>> getTodayLessons(String familyId) {
    return guard(() => _service.getTodayLessons(familyId));
  }

  Future<RepositoryResult<List<Lesson>>> getUpcomingLessons(
    String familyId, {
    int days = 3,
  }) {
    return guard(() => _service.getUpcomingLessons(familyId, days: days));
  }

  Future<RepositoryResult<Lesson>> addManualLesson({
    required String classId,
    required DateTime scheduledDate,
  }) {
    return guardNullable(
      () => _service.addManualLesson(
        classId: classId,
        scheduledDate: scheduledDate,
      ),
      notFoundError: 'Class not found',
    );
  }

  Future<RepositoryResult<Lesson>> updateLesson(
    String lessonId, {
    DateTime? scheduledDate,
    LessonStatus? status,
    String? notes,
  }) {
    return guardNullable(
      () => _service.updateLesson(
        lessonId,
        scheduledDate: scheduledDate,
        status: status,
        notes: notes,
      ),
      notFoundError: 'Lesson not found',
    );
  }

  Future<RepositoryResult<bool>> deleteLesson(String lessonId) {
    return guard(() => _service.deleteLesson(lessonId));
  }

  Future<RepositoryResult<List<Lesson>>> checkConflicts(Lesson lesson) {
    return guard(() => _service.checkConflicts(lesson));
  }

  Future<RepositoryResult<bool>> setSuspensionPeriod({
    required String classId,
    required DateTime start,
    required DateTime end,
  }) {
    return guard(
      () => _service.setSuspensionPeriod(
        classId: classId,
        start: start,
        end: end,
      ),
    );
  }

  Future<RepositoryResult<bool>> removeSuspensionPeriod(String classId) {
    return guard(() => _service.removeSuspensionPeriod(classId));
  }
}
