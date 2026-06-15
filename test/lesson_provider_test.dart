import 'package:flutter_test/flutter_test.dart';
import 'package:shike_guanjia/core/service_locator.dart';
import 'package:shike_guanjia/models/models.dart';
import 'package:shike_guanjia/providers/lesson_provider.dart';
import 'package:shike_guanjia/services/attendance_service.dart';
import 'package:shike_guanjia/services/lesson_service.dart';

void main() {
  setUp(() async {
    await getIt.reset();
  });

  test('default lesson load starts at today midnight', () async {
    final lessonService = _RecordingLessonService();
    getIt.registerSingleton<LessonService>(lessonService);
    getIt.registerSingleton<AttendanceService>(_UnusedAttendanceService());

    final provider = LessonProvider();
    await provider.loadLessons();

    final start = lessonService.lastRangeStart;
    final end = lessonService.lastRangeEnd;
    expect(start, isNotNull);
    expect(end, isNotNull);
    expect(start!.hour, 0);
    expect(start.minute, 0);
    expect(start.second, 0);
    expect(start.millisecond, 0);
    expect(end!.hour, 23);
    expect(end.minute, 59);
    expect(end.second, 59);
  });

  test('repairs missing initial lesson for active classes', () async {
    final now = DateTime.now();
    final startTime = DateTime(now.year, now.month, now.day, 16, 30);
    final trainingClass = _class(startTime: startTime);
    final lessonService = _RecordingLessonService(
      rangeLessons: [
        Lesson(
          id: 'future',
          classId: trainingClass.id,
          scheduledDate: startTime.add(const Duration(days: 2)),
          status: LessonStatus.scheduled,
        ),
      ],
    );
    getIt.registerSingleton<LessonService>(lessonService);
    getIt.registerSingleton<AttendanceService>(_UnusedAttendanceService());

    final provider = LessonProvider();
    await provider.loadLessons();
    await provider.repairMissingInitialLessons([trainingClass]);

    expect(lessonService.generatedClassIds, [trainingClass.id]);
    expect(
      provider.lessons.any(
        (lesson) =>
            lesson.classId == trainingClass.id &&
            lesson.scheduledDate.isAtSameMomentAs(startTime),
      ),
      isTrue,
    );
  });

  test('loads and cancels lesson change history', () async {
    final original = Lesson(
      id: 'lesson-original',
      classId: 'class-a',
      scheduledDate: DateTime(2026, 6, 16, 16),
      status: LessonStatus.rescheduled,
    );
    final replacement = Lesson(
      id: 'lesson-replacement',
      classId: 'class-a',
      scheduledDate: DateTime(2026, 6, 23, 16),
      status: LessonStatus.scheduled,
      isMakeup: true,
    );
    final change = LessonChangeRecord(
      id: 'change-a',
      lessonId: original.id,
      classId: original.classId,
      childId: 'child-a',
      type: LessonChangeType.reschedule,
      source: LessonChangeSource.teacher,
      reason: '老师请假',
      originalStartAt: original.scheduledDate,
      originalEndAt: original.scheduledDate.add(const Duration(hours: 1)),
      newLessonId: replacement.id,
      status: LessonChangeStatus.active,
      createdAt: DateTime(2026, 6, 15),
    );
    final lessonService = _RecordingLessonService(
      classLessons: [original, replacement],
      changeRecords: [change],
      lessonsById: {
        original.id: original.copyWith(status: LessonStatus.scheduled),
      },
    );
    getIt.registerSingleton<LessonService>(lessonService);
    getIt.registerSingleton<AttendanceService>(_UnusedAttendanceService());

    final provider = LessonProvider();
    await provider.loadLessons(classId: original.classId);
    await provider.loadLessonChangeHistory();

    expect(provider.getLessonChangeRecordsForClass(original.classId), [change]);

    final success = await provider.cancelLessonChange(change.id);

    expect(success, isTrue);
    expect(lessonService.cancelledChangeIds, [change.id]);
    expect(provider.lessons.map((lesson) => lesson.id), [original.id]);
    expect(provider.lessons.single.status, LessonStatus.scheduled);
    expect(
      provider.lessonChangeRecords.single.status,
      LessonChangeStatus.cancelled,
    );
  });
}

class _RecordingLessonService implements LessonService {
  _RecordingLessonService({
    List<Lesson> rangeLessons = const [],
    List<Lesson> classLessons = const [],
    List<LessonChangeRecord> changeRecords = const [],
    Map<String, Lesson> lessonsById = const {},
  }) : rangeLessons = List.of(rangeLessons),
       classLessons = List.of(classLessons),
       changeRecords = List.of(changeRecords),
       lessonsById = Map.of(lessonsById);

  final List<Lesson> rangeLessons;
  final List<Lesson> classLessons;
  final List<LessonChangeRecord> changeRecords;
  final Map<String, Lesson> lessonsById;
  final generatedClassIds = <String>[];
  final cancelledChangeIds = <String>[];
  DateTime? lastRangeStart;
  DateTime? lastRangeEnd;

  @override
  Future<List<Lesson>> getLessonsInRange({
    required String familyId,
    required DateTime start,
    required DateTime end,
    String? childId,
    String? classId,
  }) async {
    lastRangeStart = start;
    lastRangeEnd = end;
    return rangeLessons;
  }

  @override
  Future<Lesson?> addManualLesson({
    required String classId,
    required DateTime scheduledDate,
  }) async => null;

  @override
  Future<LessonChangeRecord?> createLessonChange({
    required String lessonId,
    required LessonChangeType type,
    required LessonChangeSource source,
    required DateTime newScheduledDate,
    DateTime? newScheduledEndDate,
    String? reason,
  }) async => null;

  @override
  Future<bool> cancelLessonChange(String changeId) async {
    cancelledChangeIds.add(changeId);
    return true;
  }

  @override
  Future<List<LessonChangeRecord>> getLessonChangeHistory({
    String? childId,
    DateTime? startDate,
    DateTime? endDate,
  }) async => changeRecords;

  @override
  Future<List<Lesson>> checkConflicts(Lesson lesson) async => [];

  @override
  Future<bool> deleteLesson(String lessonId) async => true;

  @override
  Future<List<Lesson>> generateLessons(TrainingClass trainingClass) async {
    generatedClassIds.add(trainingClass.id);
    return [
      Lesson(
        id: 'generated-${trainingClass.id}',
        classId: trainingClass.id,
        scheduledDate: trainingClass.startTime,
        status: LessonStatus.scheduled,
      ),
    ];
  }

  @override
  Future<List<Lesson>> getClassLessons(String classId) async => classLessons;

  @override
  Future<Lesson?> getLesson(String lessonId) async => lessonsById[lessonId];

  @override
  Future<List<Lesson>> getTodayLessons(String familyId) async => [];

  @override
  Future<List<Lesson>> getUpcomingLessons(
    String familyId, {
    int days = 3,
  }) async {
    throw StateError('default load should use date range');
  }

  @override
  Future<bool> removeSuspensionPeriod(String classId) async => true;

  @override
  Future<bool> setSuspensionPeriod({
    required String classId,
    required DateTime start,
    required DateTime end,
  }) async => true;

  @override
  Future<Lesson?> updateLesson(
    String lessonId, {
    DateTime? scheduledDate,
    LessonStatus? status,
    String? notes,
  }) async => null;
}

TrainingClass _class({required DateTime startTime}) {
  return TrainingClass(
    id: 'class-a',
    childId: 'child-a',
    familyId: 'family-a',
    institutionName: '小篮星',
    className: '篮球启蒙班',
    courseName: '篮球启蒙班',
    totalHours: 48,
    usedHours: 0,
    remainingHours: 48,
    totalFee: 4800,
    startTime: startTime,
    recurringRule: const RecurringRule(
      type: RecurringRuleType.weekly,
      daysOfWeek: [1],
      timeSlots: [
        LessonTimeSlot(
          dayOfWeek: 1,
          startHour: 16,
          startMinute: 30,
          endHour: 17,
          endMinute: 0,
        ),
      ],
    ),
    status: ClassStatus.active,
    createdAt: startTime,
  );
}

class _UnusedAttendanceService implements AttendanceService {
  @override
  Future<bool> cancelCheckIn(String lessonId) async => true;

  @override
  Future<Attendance?> checkIn({
    required String lessonId,
    required String classId,
    required String childId,
    AttendanceType type = AttendanceType.checkin,
    String? notes,
  }) async => null;

  @override
  Future<Map<String, dynamic>> getAttendanceStats({
    required String familyId,
    required int year,
    required int month,
    String? childId,
  }) async => {};

  @override
  Future<List<Attendance>> getAttendanceInRange({
    required String familyId,
    required DateTime start,
    required DateTime end,
    String? childId,
    String? classId,
  }) async => [];

  @override
  Future<Attendance?> getAttendance(String attendanceId) async => null;

  @override
  Future<List<Attendance>> getBackdatedAttendance(String familyId) async => [];

  @override
  Future<LeaveRecord?> getLeave(String leaveId) async => null;

  @override
  Future<List<LeaveRecord>> getLeaveHistory({
    required String familyId,
    String? childId,
    DateTime? startDate,
    DateTime? endDate,
  }) async => [];

  @override
  Future<List<Attendance>> getLessonAttendance(String lessonId) async => [];

  @override
  Future<List<Lesson>> getMakeupLessons(String familyId) async => [];

  @override
  Future<bool> cancelLeave(String leaveId) async => true;

  @override
  Future<LeaveRecord?> requestLeave({
    required String lessonId,
    required String classId,
    required String childId,
    String? reason,
  }) async => null;
}
