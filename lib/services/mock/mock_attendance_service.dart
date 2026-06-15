import "package:shike_guanjia/models/models.dart";
import 'package:uuid/uuid.dart';

import 'package:shike_guanjia/services/attendance_service.dart';
import 'package:shike_guanjia/services/mock/mock_data_store.dart';

class MockAttendanceService implements AttendanceService {
  MockAttendanceService(this._store);

  final MockDataStore _store;
  final _uuid = const Uuid();

  @override
  Future<Attendance?> checkIn({
    required String lessonId,
    required String classId,
    required String childId,
    AttendanceType type = AttendanceType.checkin,
    String? notes,
  }) async {
    final lesson = _store.lessons[lessonId];
    final trainingClass = _store.classes[classId];
    if (lesson == null ||
        trainingClass == null ||
        lesson.status == LessonStatus.completed ||
        lesson.status == LessonStatus.leave ||
        lesson.status == LessonStatus.rescheduled ||
        lesson.status == LessonStatus.cancelled) {
      return null;
    }

    final now = DateTime.now();
    final attendance = Attendance(
      id: _uuid.v4(),
      lessonId: lessonId,
      classId: classId,
      childId: childId,
      checkinTime: now,
      type: type,
      notes: notes,
      createdAt: now,
    );

    _store.attendances[attendance.id] = attendance;
    _store.lessons[lessonId] = lesson.copyWith(
      status: LessonStatus.completed,
      actualDate: now,
      checkinTime: now,
      notes: notes,
    );
    _store.classes[classId] = trainingClass.copyWith(
      usedHours: trainingClass.usedHours + 1,
      remainingHours: (trainingClass.remainingHours - 1).clamp(
        0,
        trainingClass.totalHours,
      ),
      status: trainingClass.remainingHours <= 1
          ? ClassStatus.ended
          : trainingClass.status,
      updatedAt: now,
    );
    return attendance;
  }

  @override
  Future<Attendance?> getAttendance(String attendanceId) async {
    return _store.attendances[attendanceId];
  }

  @override
  Future<bool> cancelCheckIn(String lessonId) async {
    final lesson = _store.lessons[lessonId];
    if (lesson == null) return false;
    Attendance? attendance;
    for (final item in _store.attendances.values) {
      if (item.lessonId == lessonId) {
        attendance = item;
        break;
      }
    }
    if (attendance == null) return false;
    final trainingClass = _store.classes[attendance.classId];
    _store.attendances.remove(attendance.id);
    _store.lessons[lessonId] = Lesson(
      id: lesson.id,
      classId: lesson.classId,
      scheduledDate: lesson.scheduledDate,
      scheduledEndDate: lesson.scheduledEndDate,
      status: LessonStatus.scheduled,
      isMakeup: lesson.isMakeup,
      notes: lesson.notes,
      leaveReason: lesson.leaveReason,
    );
    if (trainingClass != null) {
      final usedHours = (trainingClass.usedHours - 1).clamp(
        0,
        trainingClass.totalHours,
      );
      _store.classes[trainingClass.id] = trainingClass.copyWith(
        usedHours: usedHours,
        remainingHours: (trainingClass.totalHours - usedHours).clamp(
          0,
          trainingClass.totalHours,
        ),
        status:
            trainingClass.status == ClassStatus.ended &&
                usedHours < trainingClass.totalHours
            ? ClassStatus.active
            : trainingClass.status,
        updatedAt: DateTime.now(),
      );
    }
    return true;
  }

  @override
  Future<List<Attendance>> getLessonAttendance(String lessonId) async {
    return _store.attendances.values
        .where((item) => item.lessonId == lessonId)
        .toList(growable: false);
  }

  @override
  Future<List<Attendance>> getAttendanceInRange({
    required String familyId,
    required DateTime start,
    required DateTime end,
    String? childId,
    String? classId,
  }) async {
    return _store.attendances.values
        .where((attendance) {
          final trainingClass = _store.classes[attendance.classId];
          if (trainingClass == null || trainingClass.familyId != familyId) {
            return false;
          }
          if (childId != null && attendance.childId != childId) {
            return false;
          }
          if (classId != null && attendance.classId != classId) {
            return false;
          }
          return !attendance.checkinTime.isBefore(start) &&
              !attendance.checkinTime.isAfter(end);
        })
        .toList(growable: false);
  }

  @override
  Future<List<Attendance>> getBackdatedAttendance(String familyId) async {
    return _store.attendances.values
        .where((attendance) {
          final trainingClass = _store.classes[attendance.classId];
          return trainingClass?.familyId == familyId &&
              attendance.type == AttendanceType.backdated;
        })
        .toList(growable: false);
  }

  @override
  Future<LeaveRecord?> requestLeave({
    required String lessonId,
    required String classId,
    required String childId,
    String? reason,
  }) async {
    final lesson = _store.lessons[lessonId];
    if (lesson == null ||
        lesson.scheduledDate.isBefore(DateTime.now()) ||
        lesson.status != LessonStatus.scheduled) {
      return null;
    }

    final now = DateTime.now();
    final makeupLesson = lesson.copyWith(
      id: _uuid.v4(),
      scheduledDate: lesson.scheduledDate.add(const Duration(days: 7)),
      isMakeup: true,
    );
    final leave = LeaveRecord(
      id: _uuid.v4(),
      lessonId: lessonId,
      classId: classId,
      childId: childId,
      requestTime: now,
      status: LeaveStatus.approved,
      reason: reason,
      makeupLessonId: makeupLesson.id,
      createdAt: now,
    );

    _store.lessons[lessonId] = lesson.copyWith(
      status: LessonStatus.leave,
      leaveReason: reason,
    );
    _store.lessons[makeupLesson.id] = makeupLesson;
    _store.leaves[leave.id] = leave;
    return leave;
  }

  @override
  Future<bool> cancelLeave(String leaveId) async {
    final leave = _store.leaves[leaveId];
    if (leave == null || leave.status == LeaveStatus.cancelled) {
      return false;
    }

    _store.leaves[leaveId] = leave.copyWith(status: LeaveStatus.cancelled);
    final lesson = _store.lessons[leave.lessonId];
    if (lesson != null) {
      _store.lessons[lesson.id] = lesson.copyWith(
        status: LessonStatus.scheduled,
        leaveReason: '',
      );
    }
    if (leave.makeupLessonId != null) {
      _store.lessons.remove(leave.makeupLessonId);
    }
    return true;
  }

  @override
  Future<LeaveRecord?> getLeave(String leaveId) async => _store.leaves[leaveId];

  @override
  Future<List<LeaveRecord>> getLeaveHistory({
    required String familyId,
    String? childId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return _store.leaves.values
        .where((leave) {
          final trainingClass = _store.classes[leave.classId];
          if (trainingClass == null || trainingClass.familyId != familyId) {
            return false;
          }
          if (childId != null && leave.childId != childId) {
            return false;
          }
          if (startDate != null && leave.requestTime.isBefore(startDate)) {
            return false;
          }
          if (endDate != null && leave.requestTime.isAfter(endDate)) {
            return false;
          }
          return true;
        })
        .toList(growable: false);
  }

  @override
  Future<List<Lesson>> getMakeupLessons(String familyId) async {
    return _store.lessons.values
        .where((lesson) {
          final trainingClass = _store.classes[lesson.classId];
          return lesson.isMakeup && trainingClass?.familyId == familyId;
        })
        .toList(growable: false);
  }

  @override
  Future<Map<String, dynamic>> getAttendanceStats({
    required String familyId,
    required int year,
    required int month,
    String? childId,
  }) async {
    final lessons = _store.lessons.values.where((lesson) {
      final trainingClass = _store.classes[lesson.classId];
      return trainingClass?.familyId == familyId &&
          (childId == null || trainingClass?.childId == childId) &&
          lesson.scheduledDate.year == year &&
          lesson.scheduledDate.month == month;
    }).toList();
    final total = lessons
        .where(
          (item) =>
              item.status != LessonStatus.cancelled &&
              item.status != LessonStatus.rescheduled,
        )
        .length;
    final attended = lessons
        .where((item) => item.status == LessonStatus.completed)
        .length;
    final leaves = lessons
        .where((item) => item.status == LessonStatus.leave)
        .length;
    return {
      'total': total,
      'attended': attended,
      'leave': leaves,
      'missed': total - attended - leaves,
      'attendanceRate': total == 0 ? 0.0 : attended / total,
      'leaveRate': total == 0 ? 0.0 : leaves / total,
    };
  }
}
