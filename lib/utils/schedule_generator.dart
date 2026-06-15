import "package:shike_guanjia/models/models.dart";

/// Convert DateTime.weekday (Mon=1..Sun=7) to 0=Sun,1=Mon..6=Sat
int toIndex(int wd) => wd == 7 ? 0 : wd;

/// Convert 0=Sun,1=Mon..6=Sat back to DateTime.weekday (Mon=1..Sun=7)
int toWeekday(int idx) => idx == 0 ? 7 : idx;

/// Trim DateTime to date-only (midnight)
DateTime dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

/// Check if date is within exclude range
bool isInExclude(DateTime date, DateTime? excludeStart, DateTime? excludeEnd) {
  if (excludeStart != null && excludeEnd != null) {
    final ds = dateOnly(excludeStart);
    final de = dateOnly(excludeEnd);
    return !date.isBefore(ds) && !date.isAfter(de);
  }
  return false;
}

/// Generate lesson dates from a recurring rule within [startFrom, endAt).
List<DateTime> generateLessonDates({
  required RecurringRule rule,
  required DateTime startFrom,
  required DateTime endAt,
  DateTime? excludeStart,
  DateTime? excludeEnd,
}) {
  final dates = <DateTime>[];

  switch (rule.type) {
    case RecurringRuleType.weekly:
      _genWeekly(rule, startFrom, endAt, excludeStart, excludeEnd, dates);
      break;
    case RecurringRuleType.monthly:
      _genMonthly(rule, startFrom, endAt, excludeStart, excludeEnd, dates);
      break;
    case RecurringRuleType.custom:
      _genCustom(rule, startFrom, endAt, excludeStart, excludeEnd, dates);
      break;
  }

  dates.sort();
  return dates;
}

void _genWeekly(
  RecurringRule rule,
  DateTime startFrom,
  DateTime endAt,
  DateTime? excludeStart,
  DateTime? excludeEnd,
  List<DateTime> out,
) {
  final targets = rule.daysOfWeek.toSet();
  var d = dateOnly(startFrom);
  final end = dateOnly(endAt);

  while (!d.isAfter(end)) {
    final wd = toIndex(d.weekday);
    if (targets.contains(wd)) {
      if (!isInExclude(d, excludeStart, excludeEnd)) {
        out.add(d);
      }
    }
    d = d.add(const Duration(days: 1));
  }
}

void _genMonthly(
  RecurringRule rule,
  DateTime startFrom,
  DateTime endAt,
  DateTime? excludeStart,
  DateTime? excludeEnd,
  List<DateTime> out,
) {
  final targetWeek = rule.weekOfMonth ?? 1;
  final targetDays = rule.daysOfWeek.toSet();

  var year = startFrom.year;
  var month = startFrom.month;

  while (year < endAt.year || (year == endAt.year && month <= endAt.month)) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    int matchCount = 0;

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final wd = toIndex(date.weekday);

      if (targetDays.contains(wd)) {
        matchCount++;
        if (matchCount == targetWeek) {
          if (!isInExclude(date, excludeStart, excludeEnd)) {
            out.add(date);
          }
          break;
        }
      }
    }

    month++;
    if (month > 12) {
      month = 1;
      year++;
    }
  }
}

void _genCustom(
  RecurringRule rule,
  DateTime startFrom,
  DateTime endAt,
  DateTime? excludeStart,
  DateTime? excludeEnd,
  List<DateTime> out,
) {
  final interval = rule.customIntervalDays ?? 14;
  var d = dateOnly(startFrom);
  final end = dateOnly(endAt);
  int daysSinceStart = 0;

  while (!d.isAfter(end)) {
    if (daysSinceStart > 0 && daysSinceStart % interval == 0) {
      if (!isInExclude(d, excludeStart, excludeEnd)) {
        out.add(d);
      }
    }
    d = d.add(const Duration(days: 1));
    daysSinceStart++;
  }
}
