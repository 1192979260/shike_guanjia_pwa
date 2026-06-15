import 'package:flutter_test/flutter_test.dart';
import 'package:shike_guanjia/models/models.dart';
import 'package:shike_guanjia/services/cost_calculator.dart';

void main() {
  group('CostCalculator', () {
    late CostCalculator calculator;

    setUp(() {
      calculator = CostCalculator();
    });

    test('calculates per-session and remaining cost', () {
      final trainingClass = _class(
        totalHours: 20,
        remainingHours: 8,
        totalFee: 2400,
      );

      expect(calculator.calculatePerSessionCost(trainingClass), 120);
      expect(calculator.calculateRemainingCost(trainingClass), 960);
    });

    test('returns zero per-session cost for zero total hours', () {
      final trainingClass = _class(totalHours: 0, remainingHours: 0);

      expect(calculator.calculatePerSessionCost(trainingClass), 0);
      expect(calculator.calculateRemainingCost(trainingClass), 0);
    });

    test('aggregates attended monthly cost', () {
      final classes = [
        _class(id: 'class-a', totalHours: 10, totalFee: 1000),
        _class(id: 'class-b', totalHours: 5, totalFee: 1000),
      ];
      final lessons = [
        _lesson('lesson-a', 'class-a', DateTime(2026, 6, 3)),
        _lesson('lesson-b', 'class-b', DateTime(2026, 6, 9)),
        _lesson('lesson-c', 'class-a', DateTime(2026, 7, 1)),
      ];

      final total = calculator.calculateMonthlyCost(
        classes: classes,
        attendedLessons: lessons,
        year: 2026,
        month: 6,
      );

      expect(total, 300);
    });

    test('ignores historical used hours without attended lessons', () {
      final classes = [
        _class(
          id: 'class-a',
          totalHours: 20,
          remainingHours: 14,
          usedHours: 6,
          totalFee: 2000,
        ),
      ];

      final total = calculator.calculateMonthlyCost(
        classes: classes,
        attendedLessons: const [],
        year: 2026,
        month: 6,
      );

      expect(total, 0);
    });

    test('assigns backfilled attendance to actual lesson month', () {
      final classes = [_class(id: 'class-a', totalHours: 20, totalFee: 2000)];
      final lessons = [_lesson('lesson-a', 'class-a', DateTime(2026, 5, 28))];

      final mayTotal = calculator.calculateMonthlyCost(
        classes: classes,
        attendedLessons: lessons,
        year: 2026,
        month: 5,
      );
      final juneTotal = calculator.calculateMonthlyCost(
        classes: classes,
        attendedLessons: lessons,
        year: 2026,
        month: 6,
      );

      expect(mayTotal, 100);
      expect(juneTotal, 0);
    });

    test('calculates class cost breakdown percentages', () {
      final classes = [
        _class(id: 'class-a', childId: 'child-a', className: 'Piano'),
        _class(
          id: 'class-b',
          childId: 'child-b',
          className: 'Dance',
          totalFee: 2000,
        ),
      ];
      final children = [
        Child(
          id: 'child-a',
          name: 'A',
          familyId: 'family-a',
          createdAt: DateTime(2026),
        ),
        Child(
          id: 'child-b',
          name: 'B',
          familyId: 'family-a',
          createdAt: DateTime(2026),
        ),
      ];
      final lessons = [
        _lesson('lesson-a', 'class-a', DateTime(2026, 6, 3)),
        _lesson('lesson-b', 'class-b', DateTime(2026, 6, 9)),
      ];

      final breakdown = calculator.calculateCostBreakdown(
        classes: classes,
        attendedLessons: lessons,
        children: children,
        year: 2026,
        month: 6,
      );

      expect(breakdown, hasLength(2));
      expect(breakdown.first.cost, 100);
      expect(breakdown.last.cost, 200);
      expect(breakdown.first.percentage.toStringAsFixed(2), '33.33');
      expect(breakdown.last.percentage.toStringAsFixed(2), '66.67');
    });
  });
}

TrainingClass _class({
  String id = 'class-a',
  String childId = 'child-a',
  String className = 'Piano',
  int totalHours = 10,
  int usedHours = 0,
  int remainingHours = 10,
  double totalFee = 1000,
}) {
  return TrainingClass(
    id: id,
    childId: childId,
    familyId: 'family-a',
    institutionName: 'Studio',
    className: className,
    courseName: 'Course',
    totalHours: totalHours,
    usedHours: usedHours,
    remainingHours: remainingHours,
    totalFee: totalFee,
    startTime: DateTime(2026, 6, 1),
    recurringRule: const RecurringRule(type: RecurringRuleType.weekly),
    status: ClassStatus.active,
    createdAt: DateTime(2026, 6, 1),
  );
}

Lesson _lesson(String id, String classId, DateTime checkinTime) {
  return Lesson(
    id: id,
    classId: classId,
    scheduledDate: checkinTime,
    status: LessonStatus.completed,
    checkinTime: checkinTime,
  );
}
