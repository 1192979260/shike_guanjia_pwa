import "package:shike_guanjia/models/models.dart";

/// Cost service interface
abstract class CostService {
  /// Calculate per-session cost for class
  double calculatePerSessionCost(TrainingClass trainingClass);

  /// Calculate monthly cost
  Future<double> calculateMonthlyCost({
    required String familyId,
    required int year,
    required int month,
    String? childId,
    String? classId,
  });

  /// Calculate remaining cost for class
  double calculateRemainingCost(TrainingClass trainingClass);

  /// Get monthly cost statistics
  Future<MonthlyCostStatistics?> getMonthlyStatistics({
    required String familyId,
    required int year,
    required int month,
    String? childId,
    String? classId,
  });

  /// Get cost breakdown by class
  Future<List<ClassCostBreakdown>> getCostBreakdown({
    required String familyId,
    required int year,
    required int month,
    String? childId,
  });

  /// Get cost trend (last N months)
  Future<List<CostTrendPoint>> getCostTrend({
    required String familyId,
    int months = 6,
    String? childId,
  });

  /// Get total remaining value
  Future<double> getTotalRemainingValue(String familyId);

  /// Export cost data as CSV
  Future<String> exportCostAsCsv({
    required String familyId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Clear cost cache
  void clearCache();
}
