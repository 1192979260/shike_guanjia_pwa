import 'package:flutter_test/flutter_test.dart';
import 'package:shike_guanjia/models/models.dart';
import 'package:shike_guanjia/services/scheduling_engine.dart';

void main() {
  group('LessonGenerator', () {
    test('generates weekly lessons on selected weekdays', () {
      final dates = LessonGenerator.generateLessonDates(
        rule: const RecurringRule(
          type: RecurringRuleType.weekly,
          daysOfWeek: [1, 3],
        ),
        startDate: DateTime(2026, 6, 8),
        endDate: DateTime(2026, 6, 21),
        totalLessons: 4,
      );

      expect(
        dates,
        [
          DateTime(2026, 6, 8),
          DateTime(2026, 6, 10),
          DateTime(2026, 6, 15),
          DateTime(2026, 6, 17),
        ],
      );
    });

    test('generates monthly lessons on nth weekday', () {
      final dates = LessonGenerator.generateLessonDates(
        rule: const RecurringRule(
          type: RecurringRuleType.monthly,
          daysOfWeek: [6],
          weekOfMonth: 1,
        ),
        startDate: DateTime(2026, 6, 1),
        totalLessons: 3,
      );

      expect(
        dates,
        [
          DateTime(2026, 6, 6),
          DateTime(2026, 7, 4),
          DateTime(2026, 8, 1),
        ],
      );
    });

    test('stops custom interval generation at end date', () {
      final dates = LessonGenerator.generateLessonDates(
        rule: const RecurringRule(
          type: RecurringRuleType.custom,
          customIntervalDays: 14,
        ),
        startDate: DateTime(2026, 6, 1),
        endDate: DateTime(2026, 6, 20),
        totalLessons: 4,
      );

      expect(dates, [DateTime(2026, 6, 1), DateTime(2026, 6, 15)]);
    });
  });

  group('ConflictDetector', () {
    test('detects overlapping one-hour lesson windows', () {
      final existing = Lesson(
        id: 'lesson-a',
        classId: 'class-a',
        scheduledDate: DateTime(2026, 6, 11, 10),
        status: LessonStatus.scheduled,
      );
      final incoming = Lesson(
        id: 'lesson-b',
        classId: 'class-b',
        scheduledDate: DateTime(2026, 6, 11, 10, 30),
        status: LessonStatus.scheduled,
      );

      final conflicts = ConflictDetector.detectConflicts(
        existingLessons: [existing],
        newLesson: incoming,
      );

      expect(conflicts, hasLength(1));
      expect(conflicts.single.overlapType, OverlapType.partial);
    });

    test('does not flag adjacent lessons as conflicts', () {
      final existing = Lesson(
        id: 'lesson-a',
        classId: 'class-a',
        scheduledDate: DateTime(2026, 6, 11, 10),
        status: LessonStatus.scheduled,
      );
      final incoming = Lesson(
        id: 'lesson-b',
        classId: 'class-b',
        scheduledDate: DateTime(2026, 6, 11, 11),
        status: LessonStatus.scheduled,
      );

      final conflicts = ConflictDetector.detectConflicts(
        existingLessons: [existing],
        newLesson: incoming,
      );

      expect(conflicts, isEmpty);
    });
  });
}
