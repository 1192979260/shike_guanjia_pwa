import 'package:flutter_test/flutter_test.dart';
import 'package:shike_guanjia/models/models.dart';
import 'package:shike_guanjia/screens/home/home_lesson_summary.dart';

void main() {
  test(
    'uses concrete lessons instead of active class rules for home timeline',
    () {
      final now = DateTime(2026, 6, 15, 14);
      final cls = _class(
        recurringRule: const RecurringRule(
          type: RecurringRuleType.weekly,
          daysOfWeek: [3, 4],
          timeSlots: [
            LessonTimeSlot(
              dayOfWeek: 3,
              startHour: 16,
              startMinute: 10,
              endHour: 17,
              endMinute: 10,
            ),
            LessonTimeSlot(
              dayOfWeek: 4,
              startHour: 17,
              startMinute: 30,
              endHour: 18,
              endMinute: 30,
            ),
          ],
        ),
      );
      final lessons = [_lesson('future', DateTime(2026, 6, 19, 16, 10))];

      expect(
        buildTodayLessonSummaries(lessons: lessons, classes: [cls], now: now),
        isEmpty,
      );
      expect(
        buildUpcomingLessonSummaries(
          lessons: lessons,
          classes: [cls],
          now: now,
        ),
        isEmpty,
      );
    },
  );

  test(
    'keeps only scheduled lessons for active classes in chronological order',
    () {
      final now = DateTime(2026, 6, 15, 9);
      final active = _class();
      final paused = _class(id: 'paused', status: ClassStatus.paused);
      final lessons = [
        _lesson('later', DateTime(2026, 6, 16, 16), classId: active.id),
        _lesson(
          'completed',
          DateTime(2026, 6, 15, 10),
          classId: active.id,
          status: LessonStatus.completed,
        ),
        _lesson('paused-class', DateTime(2026, 6, 15, 11), classId: paused.id),
        _lesson('earlier', DateTime(2026, 6, 15, 15), classId: active.id),
      ];

      final summaries = buildUpcomingLessonSummaries(
        lessons: lessons,
        classes: [active, paused],
        now: now,
      );

      expect(summaries.map((item) => item.lesson.id), ['earlier', 'later']);
    },
  );

  test('includes lessons through the end of the third future calendar day', () {
    final now = DateTime(2026, 6, 15, 14, 25);
    final active = _class();
    final summaries = buildUpcomingLessonSummaries(
      lessons: [_lesson('third-day-evening', DateTime(2026, 6, 18, 19, 30))],
      classes: [active],
      now: now,
    );

    expect(summaries.map((item) => item.lesson.id), ['third-day-evening']);
  });
}

TrainingClass _class({
  String id = 'class-a',
  ClassStatus status = ClassStatus.active,
  RecurringRule recurringRule = const RecurringRule(
    type: RecurringRuleType.weekly,
    daysOfWeek: [1],
  ),
}) {
  return TrainingClass(
    id: id,
    childId: 'child-a',
    familyId: 'family-a',
    institutionName: '小篮星',
    className: '篮球启蒙班',
    courseName: '篮球启蒙班',
    totalHours: 48,
    usedHours: 7,
    remainingHours: 41,
    totalFee: 4800,
    startTime: DateTime(2026, 6, 1),
    recurringRule: recurringRule,
    status: status,
    createdAt: DateTime(2026, 6, 1),
  );
}

Lesson _lesson(
  String id,
  DateTime scheduledDate, {
  String classId = 'class-a',
  LessonStatus status = LessonStatus.scheduled,
}) {
  return Lesson(
    id: id,
    classId: classId,
    scheduledDate: scheduledDate,
    status: status,
  );
}
