import "package:shike_guanjia/models/models.dart";
import 'package:shike_guanjia/services/cost_calculator.dart';
import 'package:shike_guanjia/services/cost_service.dart';
import 'package:shike_guanjia/services/mock/mock_data_store.dart';

class MockCostService implements CostService {
  MockCostService(this._store);

  final MockDataStore _store;
  final CostCalculator _calculator = CostCalculator();

  @override
  double calculatePerSessionCost(TrainingClass trainingClass) {
    return _roundCurrency(_calculator.calculatePerSessionCost(trainingClass));
  }

  @override
  Future<double> calculateMonthlyCost({
    required String familyId,
    required int year,
    required int month,
    String? childId,
    String? classId,
  }) async {
    final classes = _filteredClasses(
      familyId: familyId,
      childId: childId,
      classId: classId,
    );
    final classIds = classes.map((item) => item.id).toSet();
    final lessons = _store.lessons.values
        .where((lesson) =>
            classIds.contains(lesson.classId) &&
            lesson.status == LessonStatus.completed)
        .toList();
    return _roundCurrency(
      _calculator.calculateMonthlyCost(
        classes: classes,
        attendedLessons: lessons,
        year: year,
        month: month,
      ),
    );
  }

  @override
  double calculateRemainingCost(TrainingClass trainingClass) {
    return _roundCurrency(_calculator.calculateRemainingCost(trainingClass));
  }

  @override
  Future<MonthlyCostStatistics?> getMonthlyStatistics({
    required String familyId,
    required int year,
    required int month,
    String? childId,
    String? classId,
  }) async {
    final classes = _filteredClasses(
      familyId: familyId,
      childId: childId,
      classId: classId,
    );
    if (classes.isEmpty) {
      return null;
    }

    final classIds = classes.map((item) => item.id).toSet();
    final monthLessons = _store.lessons.values.where((lesson) {
      return classIds.contains(lesson.classId) &&
          lesson.scheduledDate.year == year &&
          lesson.scheduledDate.month == month;
    }).toList();

    return MonthlyCostStatistics(
      id: '$familyId-$year-$month-${childId ?? 'all'}-${classId ?? 'all'}',
      familyId: familyId,
      childId: childId,
      classId: classId,
      year: year,
      month: month,
      totalAttendedLessons:
          monthLessons.where((item) => item.status == LessonStatus.completed).length,
      totalLeaveLessons:
          monthLessons.where((item) => item.status == LessonStatus.leave).length,
      totalCost: await calculateMonthlyCost(
        familyId: familyId,
        year: year,
        month: month,
        childId: childId,
        classId: classId,
      ),
      calculatedAt: DateTime.now(),
    );
  }

  @override
  Future<List<ClassCostBreakdown>> getCostBreakdown({
    required String familyId,
    required int year,
    required int month,
    String? childId,
  }) async {
    final classes = _filteredClasses(familyId: familyId, childId: childId);
    final classIds = classes.map((item) => item.id).toSet();
    return _calculator.calculateCostBreakdown(
      classes: classes,
      attendedLessons: _store.lessons.values
          .where((lesson) =>
              classIds.contains(lesson.classId) &&
              lesson.status == LessonStatus.completed)
          .toList(),
      children: _store.children.values.toList(),
      year: year,
      month: month,
    );
  }

  @override
  Future<List<CostTrendPoint>> getCostTrend({
    required String familyId,
    int months = 6,
    String? childId,
  }) async {
    final classes = _filteredClasses(familyId: familyId, childId: childId);
    final classIds = classes.map((item) => item.id).toSet();
    return _calculator.calculateCostTrend(
      classes: classes,
      attendedLessons: _store.lessons.values
          .where((lesson) =>
              classIds.contains(lesson.classId) &&
              lesson.status == LessonStatus.completed)
          .toList(),
      months: months,
    );
  }

  @override
  Future<double> getTotalRemainingValue(String familyId) async {
    return _roundCurrency(
      _filteredClasses(familyId: familyId)
          .where((item) => item.status == ClassStatus.active)
          .fold<double>(
            0,
            (sum, item) => sum + calculateRemainingCost(item),
          ),
    );
  }

  @override
  Future<String> exportCostAsCsv({
    required String familyId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final rows = <String>['date,class,child,session_count,cost'];
    for (final trainingClass in _filteredClasses(familyId: familyId)) {
      final child = _store.children[trainingClass.childId];
      final lessons = _store.lessons.values.where((lesson) {
        return lesson.classId == trainingClass.id &&
            lesson.status == LessonStatus.completed &&
            (startDate == null || !lesson.scheduledDate.isBefore(startDate)) &&
            (endDate == null || !lesson.scheduledDate.isAfter(endDate));
      });
      for (final lesson in lessons) {
        rows.add(
          '${lesson.scheduledDate.toIso8601String()},'
          '${trainingClass.className},'
          '${child?.name ?? ''},'
          '1,'
          '${calculatePerSessionCost(trainingClass).toStringAsFixed(2)}',
        );
      }
    }
    return rows.join('\n');
  }

  @override
  void clearCache() {
    _calculator.clearCache();
  }

  List<TrainingClass> _filteredClasses({
    required String familyId,
    String? childId,
    String? classId,
  }) {
    return _store.classes.values.where((item) {
      return item.familyId == familyId &&
          (childId == null || item.childId == childId) &&
          (classId == null || item.id == classId);
    }).toList(growable: false);
  }

  double _roundCurrency(double value) => double.parse(value.toStringAsFixed(2));
}
