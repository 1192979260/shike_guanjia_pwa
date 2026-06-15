/// Monthly cost statistics
class MonthlyCostStatistics {
  final String id;
  final String familyId;
  final String? childId;
  final String? classId;
  final int year;
  final int month;
  final int totalAttendedLessons;
  final int totalLeaveLessons;
  final double totalCost;
  final DateTime calculatedAt;

  MonthlyCostStatistics({
    required this.id,
    required this.familyId,
    this.childId,
    this.classId,
    required this.year,
    required this.month,
    required this.totalAttendedLessons,
    required this.totalLeaveLessons,
    required this.totalCost,
    required this.calculatedAt,
  });

  factory MonthlyCostStatistics.fromJson(Map<String, dynamic> json) {
    return MonthlyCostStatistics(
      id: json['id'] as String,
      familyId: json['familyId'] as String,
      childId: json['childId'] as String?,
      classId: json['classId'] as String?,
      year: json['year'] as int,
      month: json['month'] as int,
      totalAttendedLessons: json['totalAttendedLessons'] as int,
      totalLeaveLessons: json['totalLeaveLessons'] as int,
      totalCost: (json['totalCost'] as num).toDouble(),
      calculatedAt: DateTime.parse(json['calculatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'familyId': familyId,
      'childId': childId,
      'classId': classId,
      'year': year,
      'month': month,
      'totalAttendedLessons': totalAttendedLessons,
      'totalLeaveLessons': totalLeaveLessons,
      'totalCost': totalCost,
      'calculatedAt': calculatedAt.toIso8601String(),
    };
  }

  MonthlyCostStatistics copyWith({
    String? id,
    String? familyId,
    String? childId,
    String? classId,
    int? year,
    int? month,
    int? totalAttendedLessons,
    int? totalLeaveLessons,
    double? totalCost,
    DateTime? calculatedAt,
  }) {
    return MonthlyCostStatistics(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      childId: childId ?? this.childId,
      classId: classId ?? this.classId,
      year: year ?? this.year,
      month: month ?? this.month,
      totalAttendedLessons: totalAttendedLessons ?? this.totalAttendedLessons,
      totalLeaveLessons: totalLeaveLessons ?? this.totalLeaveLessons,
      totalCost: totalCost ?? this.totalCost,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }
}

/// Class cost breakdown
class ClassCostBreakdown {
  final String classId;
  final String className;
  final String childName;
  final int attendedLessons;
  final int leaveLessons;
  final double cost;
  final double percentage;

  ClassCostBreakdown({
    required this.classId,
    required this.className,
    required this.childName,
    required this.attendedLessons,
    required this.leaveLessons,
    required this.cost,
    required this.percentage,
  });

  factory ClassCostBreakdown.fromJson(Map<String, dynamic> json) {
    return ClassCostBreakdown(
      classId: json['classId'] as String,
      className: json['className'] as String,
      childName: json['childName'] as String,
      attendedLessons: json['attendedLessons'] as int,
      leaveLessons: json['leaveLessons'] as int,
      cost: (json['cost'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'classId': classId,
      'className': className,
      'childName': childName,
      'attendedLessons': attendedLessons,
      'leaveLessons': leaveLessons,
      'cost': cost,
      'percentage': percentage,
    };
  }
}

/// Cost trend data point
class CostTrendPoint {
  final int year;
  final int month;
  final double cost;
  final int lessonCount;

  CostTrendPoint({
    required this.year,
    required this.month,
    required this.cost,
    required this.lessonCount,
  });

  factory CostTrendPoint.fromJson(Map<String, dynamic> json) {
    return CostTrendPoint(
      year: json['year'] as int,
      month: json['month'] as int,
      cost: (json['cost'] as num).toDouble(),
      lessonCount: json['lessonCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'month': month,
      'cost': cost,
      'lessonCount': lessonCount,
    };
  }
}
