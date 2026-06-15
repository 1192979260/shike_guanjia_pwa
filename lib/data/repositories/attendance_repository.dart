import 'package:shike_guanjia/data/repositories/base_repository.dart';
import 'package:shike_guanjia/models/models.dart';
import 'package:shike_guanjia/services/attendance_service.dart';


class AttendanceRepository extends BaseRepository {
  AttendanceRepository(this._service);

  final AttendanceService _service;

  Future<RepositoryResult<Attendance>> checkIn({
    required String lessonId,
    required String classId,
    required String childId,
    AttendanceType type = AttendanceType.checkin,
    String? notes,
  }) {
    return guardNullable(
      () => _service.checkIn(
        lessonId: lessonId,
        classId: classId,
        childId: childId,
        type: type,
        notes: notes,
      ),
      notFoundError: 'Lesson cannot be checked in',
    );
  }

  Future<RepositoryResult<Attendance>> getAttendance(String attendanceId) {
    return guardNullable(
      () => _service.getAttendance(attendanceId),
      notFoundError: 'Attendance not found',
    );
  }

  Future<RepositoryResult<List<Attendance>>> getLessonAttendance(String lessonId) {
    return guard(() => _service.getLessonAttendance(lessonId));
  }

  Future<RepositoryResult<List<Attendance>>> getAttendanceInRange({
    required String familyId,
    required DateTime start,
    required DateTime end,
    String? childId,
    String? classId,
  }) {
    return guard(
      () => _service.getAttendanceInRange(
        familyId: familyId,
        start: start,
        end: end,
        childId: childId,
        classId: classId,
      ),
    );
  }

  Future<RepositoryResult<List<Attendance>>> getBackdatedAttendance(
    String familyId,
  ) {
    return guard(() => _service.getBackdatedAttendance(familyId));
  }

  Future<RepositoryResult<LeaveRecord>> requestLeave({
    required String lessonId,
    required String classId,
    required String childId,
    String? reason,
  }) {
    return guardNullable(
      () => _service.requestLeave(
        lessonId: lessonId,
        classId: classId,
        childId: childId,
        reason: reason,
      ),
      notFoundError: 'Leave request is not allowed',
    );
  }

  Future<RepositoryResult<bool>> cancelLeave(String leaveId) {
    return guard(() => _service.cancelLeave(leaveId));
  }

  Future<RepositoryResult<LeaveRecord>> getLeave(String leaveId) {
    return guardNullable(
      () => _service.getLeave(leaveId),
      notFoundError: 'Leave record not found',
    );
  }

  Future<RepositoryResult<List<LeaveRecord>>> getLeaveHistory({
    required String familyId,
    String? childId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return guard(
      () => _service.getLeaveHistory(
        familyId: familyId,
        childId: childId,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  Future<RepositoryResult<List<Lesson>>> getMakeupLessons(String familyId) {
    return guard(() => _service.getMakeupLessons(familyId));
  }

  Future<RepositoryResult<Map<String, dynamic>>> getAttendanceStats({
    required String familyId,
    required int year,
    required int month,
    String? childId,
  }) {
    return guard(
      () => _service.getAttendanceStats(
        familyId: familyId,
        year: year,
        month: month,
        childId: childId,
      ),
    );
  }
}
