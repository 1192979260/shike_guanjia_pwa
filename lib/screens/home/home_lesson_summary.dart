import '../../models/models.dart';
import '../../utils/date_utils.dart';

class HomeLessonSummary {
  const HomeLessonSummary({required this.lesson, required this.trainingClass});

  final Lesson lesson;
  final TrainingClass trainingClass;
}

List<HomeLessonSummary> buildTodayLessonSummaries({
  required List<Lesson> lessons,
  required List<TrainingClass> classes,
  required DateTime now,
}) {
  final start = DateTime(now.year, now.month, now.day);
  final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
  return _buildLessonSummaries(
    lessons: lessons,
    classes: classes,
    start: start,
    end: end,
  );
}

List<HomeLessonSummary> buildUpcomingLessonSummaries({
  required List<Lesson> lessons,
  required List<TrainingClass> classes,
  required DateTime now,
  int days = 3,
}) {
  final endDay = DateTime(now.year, now.month, now.day + days);
  return _buildLessonSummaries(
    lessons: lessons,
    classes: classes,
    start: now,
    end: DateTime(endDay.year, endDay.month, endDay.day, 23, 59, 59, 999),
  );
}

String lessonTimeRange(Lesson lesson) {
  final end =
      lesson.scheduledEndDate ??
      lesson.scheduledDate.add(const Duration(hours: 1));
  return '${formatTime(lesson.scheduledDate)}-${formatTime(end)}';
}

List<HomeLessonSummary> _buildLessonSummaries({
  required List<Lesson> lessons,
  required List<TrainingClass> classes,
  required DateTime start,
  required DateTime end,
}) {
  final classById = {
    for (final cls in classes)
      if (cls.status == ClassStatus.active) cls.id: cls,
  };
  final summaries =
      lessons
          .where((lesson) {
            if (lesson.status != LessonStatus.scheduled) return false;
            if (lesson.scheduledDate.isBefore(start)) return false;
            if (lesson.scheduledDate.isAfter(end)) return false;
            return classById.containsKey(lesson.classId);
          })
          .map(
            (lesson) => HomeLessonSummary(
              lesson: lesson,
              trainingClass: classById[lesson.classId]!,
            ),
          )
          .toList()
        ..sort(
          (a, b) => a.lesson.scheduledDate.compareTo(b.lesson.scheduledDate),
        );
  return summaries;
}
