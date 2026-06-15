import "package:shike_guanjia/models/models.dart";

/// Cost calculator with memoization
class CostCalculator {
  final Map<String, double> _cache = {};

  /// Calculate per-session cost for class
  double calculatePerSessionCost(TrainingClass trainingClass) {
    final cacheKey = 'per_session_${trainingClass.id}';
    
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final cost = trainingClass.totalHours > 0
        ? trainingClass.totalFee / trainingClass.totalHours
        : 0.0;

    _cache[cacheKey] = cost;
    return cost;
  }

  /// Calculate remaining cost for class
  double calculateRemainingCost(TrainingClass trainingClass) {
    final perSessionCost = calculatePerSessionCost(trainingClass);
    return perSessionCost * trainingClass.remainingHours;
  }

  /// Calculate monthly cost for family
  double calculateMonthlyCost({
    required List<TrainingClass> classes,
    required List<Lesson> attendedLessons,
    required int year,
    required int month,
  }) {
    double totalCost = 0.0;

    for (final lesson in attendedLessons) {
      // Check if lesson is in target month
      if (lesson.checkinTime != null &&
          lesson.checkinTime!.year == year &&
          lesson.checkinTime!.month == month) {
        
        // Find class for this lesson
        final trainingClass = classes.firstWhere(
          (c) => c.id == lesson.classId,
          orElse: () => throw Exception('Class not found'),
        );

        totalCost += calculatePerSessionCost(trainingClass);
      }
    }

    return totalCost;
  }

  /// Calculate cost breakdown by class
  List<ClassCostBreakdown> calculateCostBreakdown({
    required List<TrainingClass> classes,
    required List<Lesson> attendedLessons,
    required List<Child> children,
    required int year,
    required int month,
  }) {
    final breakdowns = <ClassCostBreakdown>[];
    double totalMonthlyCost = 0.0;

    // Calculate cost per class
    for (final trainingClass in classes) {
      final classLessons = attendedLessons
          .where((l) => 
              l.classId == trainingClass.id &&
              l.checkinTime != null &&
              l.checkinTime!.year == year &&
              l.checkinTime!.month == month)
          .toList();

      final child = children.firstWhere(
        (c) => c.id == trainingClass.childId,
        orElse: () => Child(
          id: 'unknown',
          name: 'Unknown',
          familyId: '',
          createdAt: DateTime.now(),
        ),
      );

      final cost = classLessons.length * calculatePerSessionCost(trainingClass);
      totalMonthlyCost += cost;

      breakdowns.add(ClassCostBreakdown(
        classId: trainingClass.id,
        className: trainingClass.className,
        childName: child.name,
        attendedLessons: classLessons.length,
        leaveLessons: 0, // Would need leave records
        cost: cost,
        percentage: 0.0, // Will calculate after total is known
      ));
    }

    // Calculate percentages
    for (final breakdown in breakdowns) {
      breakdowns[breakdowns.indexOf(breakdown)] = ClassCostBreakdown(
        classId: breakdown.classId,
        className: breakdown.className,
        childName: breakdown.childName,
        attendedLessons: breakdown.attendedLessons,
        leaveLessons: breakdown.leaveLessons,
        cost: breakdown.cost,
        percentage: totalMonthlyCost > 0
            ? (breakdown.cost / totalMonthlyCost) * 100
            : 0.0,
      );
    }

    return breakdowns;
  }

  /// Calculate cost trend
  List<CostTrendPoint> calculateCostTrend({
    required List<TrainingClass> classes,
    required List<Lesson> attendedLessons,
    required int months,
  }) {
    final trend = <CostTrendPoint>[];
    final now = DateTime.now();

    for (int i = 0; i < months; i++) {
      final monthDate = DateTime(
        now.year,
        now.month - i,
        1,
      );

      final year = monthDate.year;
      final month = monthDate.month;

      final cost = calculateMonthlyCost(
        classes: classes,
        attendedLessons: attendedLessons,
        year: year,
        month: month,
      );

      final lessonCount = attendedLessons
          .where((l) =>
              l.checkinTime != null &&
              l.checkinTime!.year == year &&
              l.checkinTime!.month == month)
          .length;

      trend.add(CostTrendPoint(
        year: year,
        month: month,
        cost: cost,
        lessonCount: lessonCount,
      ));
    }

    return trend.reversed.toList();
  }

  /// Clear cache
  void clearCache() {
    _cache.clear();
  }

  /// Clear cache for specific class
  void clearClassCache(String classId) {
    _cache.removeWhere((key, _) => key.contains(classId));
  }
}
