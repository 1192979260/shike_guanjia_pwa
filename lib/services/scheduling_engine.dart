import "package:shike_guanjia/models/models.dart";

// Convert DateTime.weekday (1=Monday, 7=Sunday) to 0=Sunday, 1=Monday, etc.
int _toWeekday(int dateTimeWeekday) {
  return dateTimeWeekday == 7 ? 0 : dateTimeWeekday;
}

/// Abstract scheduling rule strategy
abstract class SchedulingRuleStrategy {
  /// Generate lesson dates for given range
  List<DateTime> generateDates({
    required DateTime startDate,
    DateTime? endDate,
    required int maxLessons,
  });

  /// Get rule type
  RecurringRuleType get type;
}

/// Weekly schedule rule strategy
class WeeklyScheduleRule implements SchedulingRuleStrategy {
  final List<int> daysOfWeek; // 0=Sunday, 1=Monday, etc.

  WeeklyScheduleRule({this.daysOfWeek = const [1]});

  @override
  RecurringRuleType get type => RecurringRuleType.weekly;

  @override
  List<DateTime> generateDates({
    required DateTime startDate,
    DateTime? endDate,
    required int maxLessons,
  }) {
    final dates = <DateTime>[];
    var currentDate = startDate;
    int count = 0;

    while (count < maxLessons) {
      final weekday = _toWeekday(currentDate.weekday);
      if (daysOfWeek.contains(weekday)) {
        dates.add(
          DateTime(currentDate.year, currentDate.month, currentDate.day),
        );
        count++;
      }

      if (endDate != null && currentDate.isAfter(endDate)) {
        break;
      }

      currentDate = currentDate.add(const Duration(days: 1));
    }

    return dates;
  }
}

/// Monthly schedule rule strategy
class MonthlyScheduleRule implements SchedulingRuleStrategy {
  final int weekOfMonth; // 1=first, 2=first, etc.
  final int dayOfWeek; // 0=Sunday, 1=Monday, etc.

  MonthlyScheduleRule({this.weekOfMonth = 1, this.dayOfWeek = 1});

  @override
  RecurringRuleType get type => RecurringRuleType.monthly;

  @override
  List<DateTime> generateDates({
    required DateTime startDate,
    DateTime? endDate,
    required int maxLessons,
  }) {
    final dates = <DateTime>[];
    var currentMonth = DateTime(startDate.year, startDate.month, 1);
    int count = 0;

    while (count < maxLessons) {
      // Find the Nth occurrence of the target day in this month
      var dayCount = 0;
      var currentDate = DateTime(currentMonth.year, currentMonth.month, 1);

      while (currentDate.month == currentMonth.month) {
        final weekday = _toWeekday(currentDate.weekday);
        if (weekday == dayOfWeek) {
          dayCount++;
          if (dayCount == weekOfMonth) {
            if (!currentDate.isBefore(startDate)) {
              dates.add(currentDate);
              count++;
            }
            break;
          }
        }
        currentDate = currentDate.add(const Duration(days: 1));
      }

      if (endDate != null && currentDate.isAfter(endDate)) {
        break;
      }

      // Move to next month
      if (currentMonth.month == 12) {
        currentMonth = DateTime(currentMonth.year + 1, 1, 1);
      } else {
        currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
      }
    }

    return dates;
  }
}

/// Custom interval schedule rule strategy
class CustomIntervalScheduleRule implements SchedulingRuleStrategy {
  final int intervalDays;

  CustomIntervalScheduleRule({this.intervalDays = 7});

  @override
  RecurringRuleType get type => RecurringRuleType.custom;

  @override
  List<DateTime> generateDates({
    required DateTime startDate,
    DateTime? endDate,
    required int maxLessons,
  }) {
    final dates = <DateTime>[];
    var currentDate = startDate;

    for (int i = 0; i < maxLessons; i++) {
      if (endDate != null && currentDate.isAfter(endDate)) {
        break;
      }

      dates.add(DateTime(currentDate.year, currentDate.month, currentDate.day));

      currentDate = currentDate.add(Duration(days: intervalDays));
    }

    return dates;
  }
}

/// Lesson generator
class LessonGenerator {
  /// Generate strategy from recurring rule
  static SchedulingRuleStrategy createStrategy(RecurringRule rule) {
    switch (rule.type) {
      case RecurringRuleType.weekly:
        return WeeklyScheduleRule(daysOfWeek: rule.daysOfWeek);
      case RecurringRuleType.monthly:
        return MonthlyScheduleRule(
          weekOfMonth: rule.weekOfMonth ?? 1,
          dayOfWeek: rule.daysOfWeek.isNotEmpty ? rule.daysOfWeek[0] : 1,
        );
      case RecurringRuleType.custom:
        return CustomIntervalScheduleRule(
          intervalDays: rule.customIntervalDays ?? 7,
        );
    }
  }

  /// Generate lesson dates
  static List<DateTime> generateLessonDates({
    required RecurringRule rule,
    required DateTime startDate,
    DateTime? endDate,
    required int totalLessons,
  }) {
    final strategy = createStrategy(rule);
    return strategy.generateDates(
      startDate: startDate,
      endDate: endDate,
      maxLessons: totalLessons,
    );
  }
}

/// Conflict detector
class ConflictDetector {
  /// Detect time overlaps between lessons
  static List<LessonConflict> detectConflicts({
    required List<Lesson> existingLessons,
    required Lesson newLesson,
    Duration tolerance = const Duration(minutes: 0),
  }) {
    final conflicts = <LessonConflict>[];

    for (final lesson in existingLessons) {
      if (_hasOverlap(lesson, newLesson, tolerance)) {
        conflicts.add(
          LessonConflict(
            existingLesson: lesson,
            newLesson: newLesson,
            overlapType: _determineOverlapType(lesson, newLesson),
          ),
        );
      }
    }

    return conflicts;
  }

  /// Check if two lessons overlap
  static bool _hasOverlap(Lesson a, Lesson b, Duration tolerance) {
    final aStart = a.scheduledDate;
    final aEnd = a.scheduledEndDate ?? aStart.add(const Duration(hours: 1));
    final bStart = b.scheduledDate;
    final bEnd = b.scheduledEndDate ?? bStart.add(const Duration(hours: 1));

    return aStart.isBefore(bEnd.add(tolerance)) &&
        aEnd.add(tolerance).isAfter(bStart);
  }

  /// Determine overlap type
  static OverlapType _determineOverlapType(Lesson a, Lesson b) {
    if (a.scheduledDate.isAtSameMomentAs(b.scheduledDate)) {
      return OverlapType.exact;
    } else if (a.scheduledDate.isBefore(b.scheduledDate)) {
      return OverlapType.partial;
    } else {
      return OverlapType.partial;
    }
  }
}

/// Lesson conflict
class LessonConflict {
  final Lesson existingLesson;
  final Lesson newLesson;
  final OverlapType overlapType;

  LessonConflict({
    required this.existingLesson,
    required this.newLesson,
    required this.overlapType,
  });
}

/// Overlap type
enum OverlapType {
  exact, // Exact same time
  partial, // Partial overlap
}
