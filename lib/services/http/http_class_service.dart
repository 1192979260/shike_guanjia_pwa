import 'package:shike_guanjia/models/models.dart';
import 'package:shike_guanjia/services/class_service.dart';
import 'package:shike_guanjia/services/http/http_backend_service.dart';

class HttpClassService implements ClassService {
  HttpClassService(this._backend);

  final HttpBackendService _backend;

  @override
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
  }) => _backend.createClass(
    childId: childId,
    familyId: familyId,
    institutionName: institutionName,
    className: className,
    courseName: courseName,
    teacherName: teacherName,
    teacherPhone: teacherPhone,
    totalHours: totalHours,
    usedHours: usedHours,
    totalFee: totalFee,
    startTime: startTime,
    endTime: endTime,
    recurringRule: recurringRule,
  );

  @override
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
  }) => _backend.updateClass(
    classId,
    institutionName: institutionName,
    className: className,
    courseName: courseName,
    teacherName: teacherName,
    teacherPhone: teacherPhone,
    totalHours: totalHours,
    usedHours: usedHours,
    totalFee: totalFee,
    startTime: startTime,
    endTime: endTime,
    recurringRule: recurringRule,
    status: status,
    notes: notes,
  );

  @override
  Future<bool> deleteClass(String classId) => _backend.deleteClass(classId);

  @override
  Future<TrainingClass?> getClass(String classId) => _backend.getClass(classId);

  @override
  Future<List<TrainingClass>> getClasses(
    String familyId, {
    String? childId,
    ClassStatus? status,
  }) => _backend.getClasses(familyId, childId: childId, status: status);

  @override
  Future<List<TrainingClass>> getChildClasses(String childId) =>
      _backend.getChildClasses(childId);

  @override
  Future<List<TrainingClass>> getActiveClasses(String familyId) =>
      _backend.getActiveClasses(familyId);

  @override
  Future<List<TrainingClass>> getCompletedClasses(String familyId) =>
      _backend.getCompletedClasses(familyId);

  @override
  Future<TrainingClass?> pauseClass(String classId) =>
      _backend.pauseClass(classId);

  @override
  Future<TrainingClass?> resumeClass(String classId) =>
      _backend.resumeClass(classId);

  @override
  Future<TrainingClass?> endClass(String classId) => _backend.endClass(classId);

  @override
  Future<TrainingClass?> renewClass(
    String classId, {
    required int newTotalHours,
    required double newTotalFee,
  }) => _backend.renewClass(
    classId,
    newTotalHours: newTotalHours,
    newTotalFee: newTotalFee,
  );

  @override
  Future<List<TrainingClass>> checkConflicts(TrainingClass newClass) =>
      _backend.checkClassConflicts(newClass);
}
