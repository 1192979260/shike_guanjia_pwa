import 'package:shike_guanjia/data/repositories/base_repository.dart';
import 'package:shike_guanjia/models/models.dart';
import 'package:shike_guanjia/services/class_service.dart';


class ClassRepository extends BaseRepository {
  ClassRepository(this._service);

  final ClassService _service;

  Future<RepositoryResult<TrainingClass>> createClass({
    required String childId,
    required String familyId,
    required String institutionName,
    required String className,
    required String courseName,
    String? teacherName,
    String? teacherPhone,
    required int totalHours,
    required double totalFee,
    required DateTime startTime,
    DateTime? endTime,
    required RecurringRule recurringRule,
  }) {
    return guardNullable(
      () => _service.createClass(
        childId: childId,
        familyId: familyId,
        institutionName: institutionName,
        className: className,
        courseName: courseName,
        teacherName: teacherName,
        teacherPhone: teacherPhone,
        totalHours: totalHours,
        totalFee: totalFee,
        startTime: startTime,
        endTime: endTime,
        recurringRule: recurringRule,
      ),
      notFoundError: 'Invalid class data',
    );
  }

  Future<RepositoryResult<TrainingClass>> updateClass(
    String classId, {
    String? institutionName,
    String? className,
    String? courseName,
    String? teacherName,
    String? teacherPhone,
    int? totalHours,
    double? totalFee,
    DateTime? startTime,
    DateTime? endTime,
    RecurringRule? recurringRule,
    ClassStatus? status,
    String? notes,
  }) {
    return guardNullable(
      () => _service.updateClass(
        classId,
        institutionName: institutionName,
        className: className,
        courseName: courseName,
        teacherName: teacherName,
        teacherPhone: teacherPhone,
        totalHours: totalHours,
        totalFee: totalFee,
        startTime: startTime,
        endTime: endTime,
        recurringRule: recurringRule,
        status: status,
        notes: notes,
      ),
      notFoundError: 'Class not found',
    );
  }

  Future<RepositoryResult<bool>> deleteClass(String classId) {
    return guard(() => _service.deleteClass(classId));
  }

  Future<RepositoryResult<TrainingClass>> getClass(String classId) {
    return guardNullable(
      () => _service.getClass(classId),
      notFoundError: 'Class not found',
    );
  }

  Future<RepositoryResult<List<TrainingClass>>> getClasses(String familyId) {
    return guard(() => _service.getClasses(familyId));
  }

  Future<RepositoryResult<List<TrainingClass>>> getChildClasses(String childId) {
    return guard(() => _service.getChildClasses(childId));
  }

  Future<RepositoryResult<List<TrainingClass>>> getActiveClasses(String familyId) {
    return guard(() => _service.getActiveClasses(familyId));
  }

  Future<RepositoryResult<List<TrainingClass>>> getCompletedClasses(String familyId) {
    return guard(() => _service.getCompletedClasses(familyId));
  }

  Future<RepositoryResult<TrainingClass>> pauseClass(String classId) {
    return guardNullable(
      () => _service.pauseClass(classId),
      notFoundError: 'Class not found',
    );
  }

  Future<RepositoryResult<TrainingClass>> resumeClass(String classId) {
    return guardNullable(
      () => _service.resumeClass(classId),
      notFoundError: 'Class not found',
    );
  }

  Future<RepositoryResult<TrainingClass>> endClass(String classId) {
    return guardNullable(
      () => _service.endClass(classId),
      notFoundError: 'Class not found',
    );
  }

  Future<RepositoryResult<TrainingClass>> renewClass(
    String classId, {
    required int newTotalHours,
    required double newTotalFee,
  }) {
    return guardNullable(
      () => _service.renewClass(
        classId,
        newTotalHours: newTotalHours,
        newTotalFee: newTotalFee,
      ),
      notFoundError: 'Class not found',
    );
  }

  Future<RepositoryResult<List<TrainingClass>>> checkConflicts(
    TrainingClass trainingClass,
  ) {
    return guard(() => _service.checkConflicts(trainingClass));
  }
}
