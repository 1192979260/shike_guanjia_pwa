/// Lesson status
enum LessonStatus {
  scheduled, // 待上课
  completed, // 已上课
  leave, // 已请假
  cancelled, // 已取消
}

/// Lesson model (课次)
class Lesson {
  final String id;
  final String classId;
  final DateTime scheduledDate;
  final DateTime? scheduledEndDate;
  final LessonStatus status;
  final DateTime? actualDate;
  final DateTime? checkinTime;
  final bool isMakeup; // 是否补录
  final String? notes; // 课后笔记/评价
  final String? leaveReason; // 请假原因

  Lesson({
    required this.id,
    required this.classId,
    required this.scheduledDate,
    this.scheduledEndDate,
    required this.status,
    this.actualDate,
    this.checkinTime,
    this.isMakeup = false,
    this.notes,
    this.leaveReason,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      classId: json['classId'] as String,
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      scheduledEndDate: json['scheduledEndDate'] != null
          ? DateTime.parse(json['scheduledEndDate'] as String)
          : null,
      status: LessonStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => LessonStatus.scheduled,
      ),
      actualDate: json['actualDate'] != null
          ? DateTime.parse(json['actualDate'] as String)
          : null,
      checkinTime: json['checkinTime'] != null
          ? DateTime.parse(json['checkinTime'] as String)
          : null,
      isMakeup: json['isMakeup'] as bool? ?? false,
      notes: json['notes'] as String?,
      leaveReason: json['leaveReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'classId': classId,
      'scheduledDate': scheduledDate.toIso8601String(),
      'scheduledEndDate': scheduledEndDate?.toIso8601String(),
      'status': status.name,
      'actualDate': actualDate?.toIso8601String(),
      'checkinTime': checkinTime?.toIso8601String(),
      'isMakeup': isMakeup,
      'notes': notes,
      'leaveReason': leaveReason,
    };
  }

  Lesson copyWith({
    String? id,
    String? classId,
    DateTime? scheduledDate,
    DateTime? scheduledEndDate,
    LessonStatus? status,
    DateTime? actualDate,
    DateTime? checkinTime,
    bool? isMakeup,
    String? notes,
    String? leaveReason,
  }) {
    return Lesson(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledEndDate: scheduledEndDate ?? this.scheduledEndDate,
      status: status ?? this.status,
      actualDate: actualDate ?? this.actualDate,
      checkinTime: checkinTime ?? this.checkinTime,
      isMakeup: isMakeup ?? this.isMakeup,
      notes: notes ?? this.notes,
      leaveReason: leaveReason ?? this.leaveReason,
    );
  }
}
