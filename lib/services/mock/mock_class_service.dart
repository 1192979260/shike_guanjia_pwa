import "package:shike_guanjia/models/models.dart";
import 'package:uuid/uuid.dart';

import 'package:shike_guanjia/services/class_service.dart';
import 'package:shike_guanjia/services/mock/mock_data_store.dart';
import 'package:shike_guanjia/services/scheduling_engine.dart';

class MockClassService implements ClassService {
  MockClassService(this._store);

  final MockDataStore _store;
  final _uuid = const Uuid();

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
  }) async {
    if (childId.isEmpty ||
        familyId.isEmpty ||
        className.trim().isEmpty ||
        totalHours < 0 ||
        usedHours < 0 ||
        usedHours > totalHours ||
        totalFee < 0) {
      return null;
    }

    final trainingClass = TrainingClass(
      id: _uuid.v4(),
      childId: childId,
      familyId: familyId,
      institutionName: institutionName.trim(),
      className: className.trim(),
      courseName: courseName.trim(),
      teacherName: teacherName,
      teacherPhone: teacherPhone,
      totalHours: totalHours,
      usedHours: usedHours,
      remainingHours: totalHours - usedHours,
      totalFee: totalFee,
      startTime: startTime,
      endTime: endTime,
      recurringRule: recurringRule,
      status: ClassStatus.active,
      createdAt: DateTime.now(),
    );
    _store.classes[trainingClass.id] = trainingClass;

    // 自动生成课程
    await generateLessons(trainingClass);
    return trainingClass;
  }

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
  }) async {
    final existing = _store.classes[classId];
    if (existing == null) {
      return null;
    }

    final nextTotalHours = totalHours ?? existing.totalHours;
    final nextUsedHours = usedHours ?? existing.usedHours;
    if (nextUsedHours < 0 || nextUsedHours > nextTotalHours) {
      return null;
    }

    final updated = existing.copyWith(
      institutionName: institutionName,
      className: className,
      courseName: courseName,
      teacherName: teacherName,
      teacherPhone: teacherPhone,
      totalHours: totalHours,
      usedHours: nextUsedHours,
      remainingHours: nextTotalHours - nextUsedHours,
      totalFee: totalFee,
      startTime: startTime,
      endTime: endTime,
      recurringRule: recurringRule,
      status: status,
      updatedAt: DateTime.now(),
      notes: notes,
    );

    _store.classes[classId] = updated;

    // 如果排课规则变更，重新生成未来的课程
    if (recurringRule != null || startTime != null || endTime != null) {
      // 删除所有尚未开始的排课
      _store.lessons.removeWhere(
        (_, lesson) =>
            lesson.classId == classId &&
            lesson.status == LessonStatus.scheduled &&
            lesson.scheduledDate.isAfter(DateTime.now()),
      );
      await generateLessons(updated);
    }
    return updated;
  }

  @override
  Future<bool> deleteClass(String classId) async {
    if (_store.classes.remove(classId) == null) {
      return false;
    }

    // 级联删除相关课程、考勤、请假记录
    _store.lessons.removeWhere((_, item) => item.classId == classId);
    _store.attendances.removeWhere((_, item) => item.classId == classId);
    _store.leaves.removeWhere((_, item) => item.classId == classId);
    return true;
  }

  @override
  Future<TrainingClass?> getClass(String classId) async =>
      _store.classes[classId];

  @override
  Future<List<TrainingClass>> getClasses(
    String familyId, {
    String? childId,
    ClassStatus? status,
  }) async {
    return _store.classes.values
        .where(
          (item) =>
              item.familyId == familyId &&
              (childId == null || item.childId == childId) &&
              (status == null || item.status == status),
        )
        .toList(growable: false);
  }

  @override
  Future<List<TrainingClass>> getChildClasses(String childId) async {
    return _store.classes.values
        .where((item) => item.childId == childId)
        .toList(growable: false);
  }

  @override
  Future<List<TrainingClass>> getActiveClasses(String familyId) async {
    return getClasses(familyId, status: ClassStatus.active);
  }

  @override
  Future<List<TrainingClass>> getCompletedClasses(String familyId) async {
    return getClasses(familyId, status: ClassStatus.ended);
  }

  @override
  Future<TrainingClass?> pauseClass(String classId) {
    return updateClass(classId, status: ClassStatus.paused);
  }

  @override
  Future<TrainingClass?> resumeClass(String classId) {
    return updateClass(classId, status: ClassStatus.active);
  }

  @override
  Future<TrainingClass?> endClass(String classId) {
    return updateClass(classId, status: ClassStatus.ended);
  }

  @override
  Future<TrainingClass?> renewClass(
    String classId, {
    required int newTotalHours,
    required double newTotalFee,
  }) async {
    final existing = _store.classes[classId];
    if (existing == null) {
      return null;
    }
    return createClass(
      childId: existing.childId,
      familyId: existing.familyId,
      institutionName: existing.institutionName,
      className: existing.className,
      courseName: existing.courseName,
      teacherName: existing.teacherName,
      teacherPhone: existing.teacherPhone,
      totalHours: newTotalHours,
      totalFee: newTotalFee,
      startTime: DateTime.now(),
      recurringRule: existing.recurringRule,
    );
  }

  @override
  Future<List<TrainingClass>> checkConflicts(TrainingClass newClass) async {
    final newLessons =
        LessonGenerator.generateLessonDates(
              rule: newClass.recurringRule,
              startDate: newClass.startTime,
              endDate: newClass.endTime,
              totalLessons: newClass.totalHours,
            )
            .map(
              (date) => Lesson(
                id: _uuid.v4(),
                classId: newClass.id,
                scheduledDate: DateTime(
                  date.year,
                  date.month,
                  date.day,
                  newClass.startTime.hour,
                  newClass.startTime.minute,
                ),
                status: LessonStatus.scheduled,
              ),
            )
            .toList();

    final existingLessons = _store.lessons.values.where((lesson) {
      final existingClass = _store.classes[lesson.classId];
      return existingClass?.childId == newClass.childId &&
          existingClass?.id != newClass.id;
    }).toList();

    final conflictingClassIds = <String>{};
    for (final newLesson in newLessons) {
      final conflicts = ConflictDetector.detectConflicts(
        existingLessons: existingLessons,
        newLesson: newLesson,
      );
      for (final conflict in conflicts) {
        conflictingClassIds.add(conflict.existingLesson.classId);
      }
    }

    return _store.classes.values
        .where((cls) => conflictingClassIds.contains(cls.id))
        .toList(growable: false);
  }

  Future<List<Lesson>> generateLessons(TrainingClass trainingClass) async {
    final existingLessons = _store.lessons.values
        .where((l) => l.classId == trainingClass.id)
        .map((l) => l.scheduledDate.toIso8601String())
        .toSet();

    final consumedHours = _store.lessons.values
        .where(
          (lesson) =>
              lesson.classId == trainingClass.id &&
              (lesson.status == LessonStatus.completed ||
                  lesson.status == LessonStatus.leave),
        )
        .length;
    final dates = LessonGenerator.generateLessonDates(
      rule: trainingClass.recurringRule,
      startDate: trainingClass.startTime,
      endDate: trainingClass.endTime,
      totalLessons: (trainingClass.totalHours - consumedHours).clamp(0, trainingClass.totalHours),
    );

    final lessons = <Lesson>[];
    for (final date in dates) {
      final lessonDate = DateTime(
        date.year,
        date.month,
        date.day,
        trainingClass.startTime.hour,
        trainingClass.startTime.minute,
      );

      // 防止重复生成相同日期的课程
      if (!existingLessons.contains(lessonDate.toIso8601String())) {
        final lesson = Lesson(
          id: _uuid.v4(),
          classId: trainingClass.id,
          scheduledDate: lessonDate,
          status: LessonStatus.scheduled,
        );
        _store.lessons[lesson.id] = lesson;
        lessons.add(lesson);
      }
    }

    return lessons;
  }
}
