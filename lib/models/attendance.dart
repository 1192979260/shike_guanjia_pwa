/// Attendance record type
enum AttendanceType {
  checkin, // 正常签到
  earlyAttempt, // 提前尝试
  backdated, // 补录
}

/// Attendance record (上课记录)
class Attendance {
  final String id;
  final String lessonId;
  final String classId;
  final String childId;
  final DateTime checkinTime;
  final AttendanceType type;
  final String? notes;
  final DateTime createdAt;

  Attendance({
    required this.id,
    required this.lessonId,
    required this.classId,
    required this.childId,
    required this.checkinTime,
    required this.type,
    this.notes,
    required this.createdAt,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] as String,
      lessonId: json['lessonId'] as String,
      classId: json['classId'] as String,
      childId: json['childId'] as String,
      checkinTime: DateTime.parse(json['checkinTime'] as String),
      type: _attendanceTypeFromJson(json['type'] as String?),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lessonId': lessonId,
      'classId': classId,
      'childId': childId,
      'checkinTime': checkinTime.toIso8601String(),
      'type': _attendanceTypeToJson(type),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Attendance copyWith({
    String? id,
    String? lessonId,
    String? classId,
    String? childId,
    DateTime? checkinTime,
    AttendanceType? type,
    String? notes,
    DateTime? createdAt,
  }) {
    return Attendance(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      classId: classId ?? this.classId,
      childId: childId ?? this.childId,
      checkinTime: checkinTime ?? this.checkinTime,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

AttendanceType _attendanceTypeFromJson(String? value) {
  if (value == 'early_attempt') return AttendanceType.earlyAttempt;
  return AttendanceType.values.firstWhere(
    (item) => item.name == value,
    orElse: () => AttendanceType.checkin,
  );
}

String _attendanceTypeToJson(AttendanceType type) {
  if (type == AttendanceType.earlyAttempt) return 'early_attempt';
  return type.name;
}

/// Leave status
enum LeaveStatus {
  approved, // 已批准
  cancelled, // 已取消
}

/// Leave record (请假记录)
class LeaveRecord {
  final String id;
  final String lessonId;
  final String classId;
  final String childId;
  final DateTime requestTime;
  final LeaveStatus status;
  final String? reason;
  final String? makeupLessonId; // 补课记录ID
  final DateTime createdAt;

  LeaveRecord({
    required this.id,
    required this.lessonId,
    required this.classId,
    required this.childId,
    required this.requestTime,
    required this.status,
    this.reason,
    this.makeupLessonId,
    required this.createdAt,
  });

  factory LeaveRecord.fromJson(Map<String, dynamic> json) {
    return LeaveRecord(
      id: json['id'] as String,
      lessonId: json['lessonId'] as String,
      classId: json['classId'] as String,
      childId: json['childId'] as String,
      requestTime: DateTime.parse(json['requestTime'] as String),
      status: LeaveStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => LeaveStatus.approved,
      ),
      reason: json['reason'] as String?,
      makeupLessonId: json['makeupLessonId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lessonId': lessonId,
      'classId': classId,
      'childId': childId,
      'requestTime': requestTime.toIso8601String(),
      'status': status.name,
      'reason': reason,
      'makeupLessonId': makeupLessonId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  LeaveRecord copyWith({
    String? id,
    String? lessonId,
    String? classId,
    String? childId,
    DateTime? requestTime,
    LeaveStatus? status,
    String? reason,
    String? makeupLessonId,
    DateTime? createdAt,
  }) {
    return LeaveRecord(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      classId: classId ?? this.classId,
      childId: childId ?? this.childId,
      requestTime: requestTime ?? this.requestTime,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      makeupLessonId: makeupLessonId ?? this.makeupLessonId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
