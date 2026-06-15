import "package:shike_guanjia/models/models.dart";

/// Attendance service interface
abstract class AttendanceService {
  /// Check-in for lesson
  Future<Attendance?> checkIn({
    required String lessonId,
    required String classId,
    required String childId,
    AttendanceType type = AttendanceType.checkin,
    String? notes,
  });

  /// Get attendance record
  Future<Attendance?> getAttendance(String attendanceId);

  /// Cancel a mistaken check-in for a lesson.
  Future<bool> cancelCheckIn(String lessonId);

  /// Get attendance for lesson
  Future<List<Attendance>> getLessonAttendance(String lessonId);

  /// Get attendance for date range
  Future<List<Attendance>> getAttendanceInRange({
    required String familyId,
    required DateTime start,
    required DateTime end,
    String? childId,
    String? classId,
  });

  /// Get backdated attendance (within 24 hours)
  Future<List<Attendance>> getBackdatedAttendance(String familyId);

  /// Request leave
  Future<LeaveRecord?> requestLeave({
    required String lessonId,
    required String classId,
    required String childId,
    String? reason,
  });

  /// Cancel leave request
  Future<bool> cancelLeave(String leaveId);

  /// Get leave record
  Future<LeaveRecord?> getLeave(String leaveId);

  /// Get leave history
  Future<List<LeaveRecord>> getLeaveHistory({
    required String familyId,
    String? childId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get make-up lessons
  Future<List<Lesson>> getMakeupLessons(String familyId);

  /// Get attendance statistics
  Future<Map<String, dynamic>> getAttendanceStats({
    required String familyId,
    required int year,
    required int month,
    String? childId,
  });
}
