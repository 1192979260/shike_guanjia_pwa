import 'package:intl/intl.dart';

/// Chinese weekday string
String weekdayChinese(DateTime dt) {
  const days = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  return days[dt.weekday - 1];
}

/// Format date as yyyy-MM-dd
String formatDate(DateTime dt) {
  return DateFormat('yyyy-MM-dd').format(dt);
}

/// Format date as M月d日 (周X)
String formatDateChinese(DateTime dt) {
  return '${dt.month}月${dt.day}日 (${weekdayChinese(dt)})';
}

/// Format date as M月d日
String formatDateShort(DateTime dt) {
  return '${dt.month}月${dt.day}日';
}

/// Format time as HH:mm
String formatTime(DateTime dt) {
  return DateFormat('HH:mm').format(dt);
}

/// Check if two dates are the same day
bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Get start of week (Monday)
DateTime startOfWeek(DateTime dt) {
  final daysFromMonday = dt.weekday - 1;
  return DateTime(dt.year, dt.month, dt.day - daysFromMonday);
}

/// Get end of week (Sunday)
DateTime endOfWeek(DateTime dt) {
  final daysToSunday = 7 - dt.weekday;
  return DateTime(dt.year, dt.month, dt.day + daysToSunday);
}

/// Get days in a month
int daysInMonth(int year, int month) {
  return DateTime(year, month + 1, 0).day;
}

/// Get first day of month
DateTime firstDayOfMonth(int year, int month) {
  return DateTime(year, month, 1);
}

/// Format currency
String formatCurrency(double amount) {
  return '¥${amount.toStringAsFixed(0)}';
}

/// Format duration (hours)
String formatDuration(int hours) {
  return '$hours课时';
}
