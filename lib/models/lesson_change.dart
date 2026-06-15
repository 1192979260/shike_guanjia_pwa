enum LessonChangeType { leave, reschedule }

enum LessonChangeSource { student, teacher, institution, holiday, other }

enum LessonChangeStatus { active, cancelled }

class LessonChangeRecord {
  final String id;
  final String lessonId;
  final String classId;
  final String childId;
  final LessonChangeType type;
  final LessonChangeSource source;
  final String? reason;
  final DateTime originalStartAt;
  final DateTime? originalEndAt;
  final String newLessonId;
  final LessonChangeStatus status;
  final DateTime createdAt;

  LessonChangeRecord({
    required this.id,
    required this.lessonId,
    required this.classId,
    required this.childId,
    required this.type,
    required this.source,
    this.reason,
    required this.originalStartAt,
    this.originalEndAt,
    required this.newLessonId,
    required this.status,
    required this.createdAt,
  });

  factory LessonChangeRecord.fromJson(Map<String, dynamic> json) {
    return LessonChangeRecord(
      id: json['id'] as String,
      lessonId: json['lessonId'] as String,
      classId: json['classId'] as String,
      childId: json['childId'] as String,
      type: LessonChangeType.values.firstWhere(
        (item) => item.name == json['type'],
        orElse: () => LessonChangeType.leave,
      ),
      source: LessonChangeSource.values.firstWhere(
        (item) => item.name == json['source'],
        orElse: () => LessonChangeSource.other,
      ),
      reason: json['reason'] as String?,
      originalStartAt: DateTime.parse(json['originalStartAt'] as String),
      originalEndAt: json['originalEndAt'] == null
          ? null
          : DateTime.parse(json['originalEndAt'] as String),
      newLessonId: json['newLessonId'] as String,
      status: LessonChangeStatus.values.firstWhere(
        (item) => item.name == json['status'],
        orElse: () => LessonChangeStatus.active,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lessonId': lessonId,
      'classId': classId,
      'childId': childId,
      'type': type.name,
      'source': source.name,
      'reason': reason,
      'originalStartAt': originalStartAt.toIso8601String(),
      'originalEndAt': originalEndAt?.toIso8601String(),
      'newLessonId': newLessonId,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
