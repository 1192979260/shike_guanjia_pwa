/// Class status
enum ClassStatus {
  active, // 进行中
  paused, // 已暂停
  ended, // 已结束
}

/// Recurring rule type
enum RecurringRuleType {
  weekly, // 每周
  monthly, // 每月
  custom, // 自定义间隔
}

/// Weekly lesson time slot
class LessonTimeSlot {
  final int dayOfWeek; // 0=周日, 1=周一 ... 6=周六
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  const LessonTimeSlot({
    required this.dayOfWeek,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
  });

  factory LessonTimeSlot.fromJson(Map<String, dynamic> json) {
    return LessonTimeSlot(
      dayOfWeek: json['dayOfWeek'] as int,
      startHour: json['startHour'] as int,
      startMinute: json['startMinute'] as int,
      endHour: json['endHour'] as int,
      endMinute: json['endMinute'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'startHour': startHour,
      'startMinute': startMinute,
      'endHour': endHour,
      'endMinute': endMinute,
    };
  }

  LessonTimeSlot copyWith({
    int? dayOfWeek,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
  }) {
    return LessonTimeSlot(
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
    );
  }

  int get startMinutes => startHour * 60 + startMinute;
  int get endMinutes => endHour * 60 + endMinute;
}

/// Recurring rule for schedule generation
class RecurringRule {
  final RecurringRuleType type;
  final List<int> daysOfWeek; // 0=周日, 1=周一 ... 6=周六
  final List<LessonTimeSlot> timeSlots;
  final int? weekOfMonth; // 1=第一个, 2=第二个...
  final int? customIntervalDays; // 自定义间隔天数

  const RecurringRule({
    required this.type,
    this.daysOfWeek = const [1],
    this.timeSlots = const [],
    this.weekOfMonth = 1,
    this.customIntervalDays,
  });

  factory RecurringRule.fromJson(Map<String, dynamic> json) {
    final daysOfWeek =
        (json['daysOfWeek'] as List?)?.map((d) => d as int).toList() ?? [1];
    return RecurringRule(
      type: RecurringRuleType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => RecurringRuleType.weekly,
      ),
      daysOfWeek: daysOfWeek,
      timeSlots:
          (json['timeSlots'] as List?)
              ?.map(
                (slot) => LessonTimeSlot.fromJson(slot as Map<String, dynamic>),
              )
              .toList() ??
          [],
      weekOfMonth: json['weekOfMonth'] as int?,
      customIntervalDays: json['customIntervalDays'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'daysOfWeek': daysOfWeek,
      'timeSlots': timeSlots.map((slot) => slot.toJson()).toList(),
      'weekOfMonth': weekOfMonth,
      'customIntervalDays': customIntervalDays,
    };
  }

  RecurringRule copyWith({
    RecurringRuleType? type,
    List<int>? daysOfWeek,
    List<LessonTimeSlot>? timeSlots,
    int? weekOfMonth,
    int? customIntervalDays,
  }) {
    return RecurringRule(
      type: type ?? this.type,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      timeSlots: timeSlots ?? this.timeSlots,
      weekOfMonth: weekOfMonth ?? this.weekOfMonth,
      customIntervalDays: customIntervalDays ?? this.customIntervalDays,
    );
  }
}

/// Class (培训班)
class TrainingClass {
  final String id;
  final String childId;
  final String familyId;
  final String institutionName;
  final String className;
  final String courseName;
  final String? teacherName;
  final String? teacherPhone;
  final int totalHours;
  final int usedHours;
  final int remainingHours;
  final double totalFee;
  double get feePerHour => totalHours > 0 ? totalFee / totalHours : 0;
  final DateTime startTime;
  final DateTime? endTime;
  final RecurringRule recurringRule;
  final ClassStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? notes;

  TrainingClass({
    required this.id,
    required this.childId,
    required this.familyId,
    required this.institutionName,
    required this.className,
    required this.courseName,
    this.teacherName,
    this.teacherPhone,
    required this.totalHours,
    this.usedHours = 0,
    required this.remainingHours,
    required this.totalFee,
    required this.startTime,
    this.endTime,
    required this.recurringRule,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.notes,
  });

  factory TrainingClass.fromJson(Map<String, dynamic> json) {
    final ruleJson = json['recurringRule'] as Map<String, dynamic>? ?? {};
    return TrainingClass(
      id: json['id'] as String,
      childId: json['childId'] as String,
      familyId: json['familyId'] as String,
      institutionName: json['institutionName'] as String,
      className: json['className'] as String,
      courseName: json['courseName'] as String,
      teacherName: json['teacherName'] as String?,
      teacherPhone: json['teacherPhone'] as String?,
      totalHours: json['totalHours'] as int,
      usedHours: json['usedHours'] as int? ?? 0,
      remainingHours: json['remainingHours'] as int,
      totalFee: (json['totalFee'] as num).toDouble(),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      recurringRule: RecurringRule.fromJson(ruleJson),
      status: ClassStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ClassStatus.active,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'familyId': familyId,
      'institutionName': institutionName,
      'className': className,
      'courseName': courseName,
      'teacherName': teacherName,
      'teacherPhone': teacherPhone,
      'totalHours': totalHours,
      'usedHours': usedHours,
      'remainingHours': remainingHours,
      'totalFee': totalFee,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'recurringRule': recurringRule.toJson(),
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'notes': notes,
    };
  }

  TrainingClass copyWith({
    String? id,
    String? childId,
    String? familyId,
    String? institutionName,
    String? className,
    String? courseName,
    String? teacherName,
    String? teacherPhone,
    int? totalHours,
    int? usedHours,
    int? remainingHours,
    double? totalFee,
    DateTime? startTime,
    DateTime? endTime,
    RecurringRule? recurringRule,
    ClassStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
  }) {
    return TrainingClass(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      familyId: familyId ?? this.familyId,
      institutionName: institutionName ?? this.institutionName,
      className: className ?? this.className,
      courseName: courseName ?? this.courseName,
      teacherName: teacherName ?? this.teacherName,
      teacherPhone: teacherPhone ?? this.teacherPhone,
      totalHours: totalHours ?? this.totalHours,
      usedHours: usedHours ?? this.usedHours,
      remainingHours: remainingHours ?? this.remainingHours,
      totalFee: totalFee ?? this.totalFee,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      recurringRule: recurringRule ?? this.recurringRule,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
    );
  }
}
