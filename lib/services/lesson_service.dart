import "package:shike_guanjia/models/models.dart";

/// Lesson service interface
abstract class LessonService {
  /// Generate lessons from class schedule
  Future<List<Lesson>> generateLessons(TrainingClass trainingClass);

  /// Get lesson by ID
  Future<Lesson?> getLesson(String lessonId);

  /// Get lessons for class
  Future<List<Lesson>> getClassLessons(String classId);

  /// Get lessons for date range
  Future<List<Lesson>> getLessonsInRange({
    required String familyId,
    required DateTime start,
    required DateTime end,
    String? childId,
    String? classId,
  });

  /// Get today's lessons
  Future<List<Lesson>> getTodayLessons(String familyId);

  /// Get upcoming lessons (next N days)
  Future<List<Lesson>> getUpcomingLessons(String familyId, {int days = 3});

  /// Add manual lesson
  Future<Lesson?> addManualLesson({
    required String classId,
    required DateTime scheduledDate,
  });

  /// Update lesson
  Future<Lesson?> updateLesson(
    String lessonId, {
    DateTime? scheduledDate,
    LessonStatus? status,
    String? notes,
  });

  /// Delete lesson
  Future<bool> deleteLesson(String lessonId);

  /// Check for time conflicts
  Future<List<Lesson>> checkConflicts(Lesson lesson);

  /// Set suspension period for class
  Future<bool> setSuspensionPeriod({
    required String classId,
    required DateTime start,
    required DateTime end,
  });

  /// Remove suspension period
  Future<bool> removeSuspensionPeriod(String classId);
}

