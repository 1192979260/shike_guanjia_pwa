import "package:shike_guanjia/models/models.dart";

/// Training class service interface
abstract class ClassService {
  /// Create training class
  Future<TrainingClass?> createClass({
    required String childId,
    required String familyId,
    required String institutionName,
    required String className,
    required String courseName,
    String? teacherName,
    String? teacherPhone,
    required int totalHours,
    int usedHours = 0,
    required double totalFee,
    required DateTime startTime,
    DateTime? endTime,
    required RecurringRule recurringRule,
  });

  /// Update training class
  Future<TrainingClass?> updateClass(
    String classId, {
    String? institutionName,
    String? className,
    String? courseName,
    String? teacherName,
    String? teacherPhone,
    int? totalHours,
    int? usedHours,
    double? totalFee,
    DateTime? startTime,
    DateTime? endTime,
    RecurringRule? recurringRule,
    ClassStatus? status,
    String? notes,
  });

  /// Delete training class
  Future<bool> deleteClass(String classId);

  /// Get class by ID
  Future<TrainingClass?> getClass(String classId);

  /// Get all classes for family
  Future<List<TrainingClass>> getClasses(
    String familyId, {
    String? childId,
    ClassStatus? status,
  });

  /// Get classes for child
  Future<List<TrainingClass>> getChildClasses(String childId);

  /// Get active classes
  Future<List<TrainingClass>> getActiveClasses(String familyId);

  /// Get completed classes
  Future<List<TrainingClass>> getCompletedClasses(String familyId);

  /// Pause class
  Future<TrainingClass?> pauseClass(String classId);

  /// Resume class
  Future<TrainingClass?> resumeClass(String classId);

  /// End class
  Future<TrainingClass?> endClass(String classId);

  /// Renew class
  Future<TrainingClass?> renewClass(
    String classId, {
    required int newTotalHours,
    required double newTotalFee,
  });

  /// Check for scheduling conflicts
  Future<List<TrainingClass>> checkConflicts(TrainingClass newClass);
}
