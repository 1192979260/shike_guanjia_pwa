import 'package:shike_guanjia/models/models.dart';
import 'package:shike_guanjia/services/attendance_service.dart';
import 'package:shike_guanjia/services/auth_service.dart';
import 'package:shike_guanjia/services/child_service.dart';
import 'package:shike_guanjia/services/cost_service.dart';
import 'package:shike_guanjia/services/http/api_client.dart';
import 'package:shike_guanjia/services/storage_service.dart';

class HttpBackendService
    implements AuthService, ChildService, AttendanceService, CostService {
  HttpBackendService(this._client, this._storage);

  final ApiClient _client;
  final StorageService _storage;
  User? _currentUser;
  Family? _currentFamily;

  Future<bool> restoreSession() async {
    final token = _storage.authToken;
    if (token == null || token.isEmpty) {
      return false;
    }
    _client.setToken(token);
    try {
      final data = await _client.getData<Map<String, dynamic>>('/api/auth/me');
      _currentUser = User.fromJson(data['user'] as Map<String, dynamic>);
      _currentFamily = Family.fromJson(data['family'] as Map<String, dynamic>);
      await _storage.saveAuth(_currentUser!.phone);
      await _storage.saveFamilyId(_currentFamily!.id);
      return true;
    } catch (_) {
      _client.setToken(null);
      await _storage.logout();
      return false;
    }
  }

  @override
  Future<bool> sendVerificationCode(String phone) async {
    await _client.postData<Map<String, dynamic>>(
      '/api/auth/send-code',
      data: {'phone': phone},
    );
    return true;
  }

  @override
  Future<User?> login(String phone, String code) async {
    final data = await _client.postData<Map<String, dynamic>>(
      '/api/auth/login',
      data: {'phone': phone, 'code': code},
    );
    final token = data['token'] as String;
    _client.setToken(token);
    _currentUser = User.fromJson(data['user'] as Map<String, dynamic>);
    _currentFamily = Family.fromJson(data['family'] as Map<String, dynamic>);
    await _storage.saveAuth(_currentUser!.phone);
    await _storage.saveAuthToken(token);
    await _storage.saveFamilyId(_currentFamily!.id);
    return _currentUser;
  }

  @override
  Future<void> logout() async {
    try {
      await _client.postData<Map<String, dynamic>>('/api/auth/logout');
    } finally {
      _client.setToken(null);
      _currentUser = null;
      _currentFamily = null;
      await _storage.logout();
    }
  }

  @override
  User? getCurrentUser() => _currentUser;

  @override
  bool isLoggedIn() => _client.token != null || _storage.isLoggedIn;

  @override
  Future<FamilyMember?> addFamilyMember(
    String phone,
    FamilyRelation relation,
  ) async {
    final data = await _client.postData<Map<String, dynamic>>(
      '/api/family/members',
      data: {'phone': phone, 'relation': relation.name},
    );
    return FamilyMember.fromJson(data);
  }

  @override
  Future<bool> removeFamilyMember(String memberId) async {
    await _client.deleteData<Map<String, dynamic>>(
      '/api/family/members/$memberId',
    );
    return true;
  }

  @override
  Future<List<FamilyMember>> getFamilyMembers() async {
    final data = await _client.getData<List<dynamic>>('/api/family/members');
    return data
        .map((item) => FamilyMember.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Family?> getFamily() async {
    final data = await _client.getData<Map<String, dynamic>>('/api/family');
    _currentFamily = Family.fromJson(data);
    return _currentFamily;
  }

  Future<Family?> getCurrentFamily() async => _currentFamily ?? getFamily();

  @override
  Future<Child?> createChild({
    required String name,
    int? age,
    String? avatarUrl,
    required String familyId,
  }) async {
    final data = await _client.postData<Map<String, dynamic>>(
      '/api/children',
      data: {'name': name, 'age': age, 'avatarUrl': avatarUrl},
    );
    return Child.fromJson(data);
  }

  @override
  Future<Child?> updateChild(
    String childId, {
    String? name,
    int? age,
    String? avatarUrl,
  }) async {
    final data = await _client.patchData<Map<String, dynamic>>(
      '/api/children/$childId',
      data: {'name': name, 'age': age, 'avatarUrl': avatarUrl},
    );
    return Child.fromJson(data);
  }

  @override
  Future<bool> deleteChild(String childId) async {
    await _client.deleteData<Map<String, dynamic>>('/api/children/$childId');
    return true;
  }

  @override
  Future<Child?> getChild(String childId) async {
    final data = await _client.getData<Map<String, dynamic>>(
      '/api/children/$childId',
    );
    return Child.fromJson(data);
  }

  @override
  Future<List<Child>> getChildren(String familyId) async {
    final data = await _client.getData<List<dynamic>>('/api/children');
    return data
        .map((item) => Child.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  List<ChildValidationError> validateChild({required String name, int? age}) =>
      Child.validate(name: name, age: age);

  Future<TrainingClass?> createClass({
    required String childId,
    required String familyId,
    required String institutionName,
    required String className,
    required String courseName,
    String? teacherName,
    String? teacherPhone,
    required int totalHours,
    int usedHours = 0,
    required double totalFee,
    required DateTime startTime,
    DateTime? endTime,
    required RecurringRule recurringRule,
  }) async {
    final data = await _client.postData<Map<String, dynamic>>(
      '/api/classes',
      data: {
        'childId': childId,
        'institutionName': institutionName,
        'className': className,
        'courseName': courseName,
        'teacherName': teacherName,
        'teacherPhone': teacherPhone,
        'totalHours': totalHours,
        'usedHours': usedHours,
        'totalFee': totalFee,
        'startTime': _localIso(startTime),
        'endTime': endTime == null ? null : _localIso(endTime),
        'recurringRule': recurringRule.toJson(),
      },
    );
    return TrainingClass.fromJson(data);
  }

  Future<TrainingClass?> updateClass(
    String classId, {
    String? institutionName,
    String? className,
    String? courseName,
    String? teacherName,
    String? teacherPhone,
    int? totalHours,
    int? usedHours,
    double? totalFee,
    DateTime? startTime,
    DateTime? endTime,
    RecurringRule? recurringRule,
    ClassStatus? status,
    String? notes,
  }) async {
    final data = await _client.patchData<Map<String, dynamic>>(
      '/api/classes/$classId',
      data: {
        'institutionName': institutionName,
        'className': className,
        'courseName': courseName,
        'teacherName': teacherName,
        'teacherPhone': teacherPhone,
        'totalHours': totalHours,
        'usedHours': usedHours,
        'totalFee': totalFee,
        'startTime': startTime == null ? null : _localIso(startTime),
        'endTime': endTime == null ? null : _localIso(endTime),
        'recurringRule': recurringRule?.toJson(),
        'status': status?.name,
        'notes': notes,
      },
    );
    return TrainingClass.fromJson(data);
  }

  Future<bool> deleteClass(String classId) async {
    await _client.deleteData<Map<String, dynamic>>('/api/classes/$classId');
    return true;
  }

  Future<TrainingClass?> getClass(String classId) async {
    final data = await _client.getData<Map<String, dynamic>>(
      '/api/classes/$classId',
    );
    return TrainingClass.fromJson(data);
  }

  Future<List<TrainingClass>> getClasses(
    String familyId, {
    String? childId,
    ClassStatus? status,
  }) async {
    final data = await _client.getData<List<dynamic>>(
      '/api/classes',
      queryParameters: {'childId': childId, 'status': status?.name},
    );
    return data
        .map((item) => TrainingClass.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<TrainingClass>> getChildClasses(String childId) async {
    final data = await _client.getData<List<dynamic>>(
      '/api/children/$childId/classes',
    );
    return data
        .map((item) => TrainingClass.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<TrainingClass>> getActiveClasses(String familyId) =>
      getClasses(familyId, status: ClassStatus.active);

  Future<List<TrainingClass>> getCompletedClasses(String familyId) =>
      getClasses(familyId, status: ClassStatus.ended);

  Future<TrainingClass?> pauseClass(String classId) async {
    final data = await _client.postData<Map<String, dynamic>>(
      '/api/classes/$classId/pause',
    );
    return TrainingClass.fromJson(data);
  }

  Future<TrainingClass?> resumeClass(String classId) async {
    final data = await _client.postData<Map<String, dynamic>>(
      '/api/classes/$classId/resume',
    );
    return TrainingClass.fromJson(data);
  }

  Future<TrainingClass?> endClass(String classId) async {
    final data = await _client.postData<Map<String, dynamic>>(
      '/api/classes/$classId/end',
    );
    return TrainingClass.fromJson(data);
  }

  Future<TrainingClass?> renewClass(
    String classId, {
    required int newTotalHours,
    required double newTotalFee,
  }) async {
    final data = await _client.postData<Map<String, dynamic>>(
      '/api/classes/$classId/renew',
      data: {'newTotalHours': newTotalHours, 'newTotalFee': newTotalFee},
    );
    return TrainingClass.fromJson(data);
  }

  Future<List<TrainingClass>> checkClassConflicts(
    TrainingClass newClass,
  ) async {
    final data = await _client.getData<List<dynamic>>(
      '/api/classes/${newClass.id}/conflicts',
    );
    return data
        .map((item) => TrainingClass.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<Lesson>> generateLessons(TrainingClass trainingClass) async {
    final data = await _client.postData<List<dynamic>>(
      '/api/classes/${trainingClass.id}/generate-lessons',
    );
    return data
        .map((item) => Lesson.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Lesson?> getLesson(String lessonId) async {
    final data = await _client.getData<Map<String, dynamic>>(
      '/api/lessons/$lessonId',
    );
    return Lesson.fromJson(data);
  }

  Future<List<Lesson>> getClassLessons(String classId) async {
    final data = await _client.getData<List<dynamic>>(
      '/api/classes/$classId/lessons',
    );
    return data
        .map((item) => Lesson.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<Lesson>> getLessonsInRange({
    required String familyId,
    required DateTime start,
    required DateTime end,
    String? childId,
    String? classId,
  }) async {
    final data = await _client.getData<List<dynamic>>(
      '/api/lessons/range',
      queryParameters: {
        'start': _localIso(start),
        'end': _localIso(end),
        'childId': childId,
        'classId': classId,
      },
    );
    return data
        .map((item) => Lesson.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<Lesson>> getTodayLessons(String familyId) async {
    final data = await _client.getData<List<dynamic>>('/api/lessons/today');
    return data
        .map((item) => Lesson.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<Lesson>> getUpcomingLessons(
    String familyId, {
    int days = 3,
  }) async {
    final data = await _client.getData<List<dynamic>>(
      '/api/lessons/upcoming',
      queryParameters: {'days': days},
    );
    return data
        .map((item) => Lesson.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Lesson?> addManualLesson({
    required String classId,
    required DateTime scheduledDate,
  }) async {
    final data = await _client.postData<Map<String, dynamic>>(
      '/api/lessons/manual',
      data: {'classId': classId, 'scheduledDate': _localIso(scheduledDate)},
    );
    return Lesson.fromJson(data);
  }

  Future<Lesson?> updateLesson(
    String lessonId, {
    DateTime? scheduledDate,
    LessonStatus? status,
    String? notes,
  }) async {
    final data = await _client.patchData<Map<String, dynamic>>(
      '/api/lessons/$lessonId',
      data: {
        'scheduledDate': scheduledDate == null
            ? null
            : _localIso(scheduledDate),
        'status': status?.name,
        'notes': notes,
      },
    );
    return Lesson.fromJson(data);
  }

  Future<bool> deleteLesson(String lessonId) async {
    await _client.deleteData<Map<String, dynamic>>('/api/lessons/$lessonId');
    return true;
  }

  Future<List<Lesson>> checkLessonConflicts(Lesson lesson) async {
    final data = await _client.getData<List<dynamic>>(
      '/api/lessons/${lesson.id}/conflicts',
    );
    return data
        .map((item) => Lesson.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<bool> setSuspensionPeriod({
    required String classId,
    required DateTime start,
    required DateTime end,
  }) async {
    await _client.postData<Map<String, dynamic>>(
      '/api/suspensions',
      data: {
        'classId': classId,
        'start': _localIso(start),
        'end': _localIso(end),
      },
    );
    return true;
  }

  Future<bool> removeSuspensionPeriod(String classId) async {
    await _client.deleteData<Map<String, dynamic>>(
      '/api/classes/$classId/suspensions',
    );
    return true;
  }

  @override
  Future<Attendance?> checkIn({
    required String lessonId,
    required String classId,
    required String childId,
    AttendanceType type = AttendanceType.checkin,
    String? notes,
  }) async {
    final data = await _client.postData<Map<String, dynamic>>(
      '/api/attendance/check-in',
      data: {
        'lessonId': lessonId,
        'classId': classId,
        'childId': childId,
        'type': type.name,
        'notes': notes,
      },
    );
    return Attendance.fromJson(data);
  }

  @override
  Future<Attendance?> getAttendance(String attendanceId) async {
    final data = await _client.getData<Map<String, dynamic>>(
      '/api/attendance/$attendanceId',
    );
    return Attendance.fromJson(data);
  }

  @override
  Future<bool> cancelCheckIn(String lessonId) async {
    await _client.postData<Map<String, dynamic>>(
      '/api/attendance/lessons/$lessonId/cancel',
    );
    return true;
  }

  @override
  Future<List<Attendance>> getLessonAttendance(String lessonId) async {
    final data = await _client.getData<List<dynamic>>(
      '/api/attendance',
      queryParameters: {'lessonId': lessonId},
    );
    return data
        .map((item) => Attendance.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Attendance>> getAttendanceInRange({
    required String familyId,
    required DateTime start,
    required DateTime end,
    String? childId,
    String? classId,
  }) async {
    final data = await _client.getData<List<dynamic>>(
      '/api/attendance',
      queryParameters: {
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
        'childId': childId,
        'classId': classId,
      },
    );
    return data
        .map((item) => Attendance.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Attendance>> getBackdatedAttendance(String familyId) async {
    final lessons = await _client.getData<List<dynamic>>(
      '/api/attendance/backdated',
    );
    return lessons.map((item) {
      final lesson = Lesson.fromJson(item as Map<String, dynamic>);
      return Attendance(
        id: lesson.id,
        lessonId: lesson.id,
        classId: lesson.classId,
        childId: '',
        checkinTime: lesson.scheduledDate,
        type: AttendanceType.backdated,
        createdAt: lesson.scheduledDate,
      );
    }).toList();
  }

  @override
  Future<LeaveRecord?> requestLeave({
    required String lessonId,
    required String classId,
    required String childId,
    String? reason,
  }) async {
    final data = await _client.postData<Map<String, dynamic>>(
      '/api/leaves',
      data: {'lessonId': lessonId, 'reason': reason},
    );
    return LeaveRecord.fromJson(data);
  }

  @override
  Future<bool> cancelLeave(String leaveId) async {
    await _client.postData<Map<String, dynamic>>('/api/leaves/$leaveId/cancel');
    return true;
  }

  @override
  Future<LeaveRecord?> getLeave(String leaveId) async {
    final data = await _client.getData<Map<String, dynamic>>(
      '/api/leaves/$leaveId',
    );
    return LeaveRecord.fromJson(data);
  }

  @override
  Future<List<LeaveRecord>> getLeaveHistory({
    required String familyId,
    String? childId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final data = await _client.getData<List<dynamic>>(
      '/api/leaves/history',
      queryParameters: {
        'childId': childId,
        'startDate': startDate == null ? null : _localIso(startDate),
        'endDate': endDate == null ? null : _localIso(endDate),
      },
    );
    return data
        .map((item) => LeaveRecord.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Lesson>> getMakeupLessons(String familyId) async {
    final data = await _client.getData<List<dynamic>>(
      '/api/leaves/makeup-lessons',
    );
    return data
        .map((item) => Lesson.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Map<String, dynamic>> getAttendanceStats({
    required String familyId,
    required int year,
    required int month,
    String? childId,
  }) async {
    return _client.getData<Map<String, dynamic>>(
      '/api/attendance/stats',
      queryParameters: {'year': year, 'month': month, 'childId': childId},
    );
  }

  @override
  double calculatePerSessionCost(TrainingClass trainingClass) =>
      trainingClass.totalHours > 0
      ? trainingClass.totalFee / trainingClass.totalHours
      : 0;

  @override
  Future<double> calculateMonthlyCost({
    required String familyId,
    required int year,
    required int month,
    String? childId,
    String? classId,
  }) async {
    final stats = await getMonthlyStatistics(
      familyId: familyId,
      year: year,
      month: month,
      childId: childId,
      classId: classId,
    );
    return stats?.totalCost ?? 0;
  }

  @override
  double calculateRemainingCost(TrainingClass trainingClass) =>
      trainingClass.remainingHours * calculatePerSessionCost(trainingClass);

  @override
  Future<MonthlyCostStatistics?> getMonthlyStatistics({
    required String familyId,
    required int year,
    required int month,
    String? childId,
    String? classId,
  }) async {
    final data = await _client.getData<Map<String, dynamic>>(
      '/api/cost/statistics',
      queryParameters: {
        'year': year,
        'month': month,
        'childId': childId,
        'classId': classId,
      },
    );
    return MonthlyCostStatistics.fromJson(data);
  }

  @override
  Future<List<ClassCostBreakdown>> getCostBreakdown({
    required String familyId,
    required int year,
    required int month,
    String? childId,
  }) async {
    final data = await _client.getData<List<dynamic>>(
      '/api/cost/breakdown',
      queryParameters: {'year': year, 'month': month, 'childId': childId},
    );
    return data
        .map(
          (item) => ClassCostBreakdown.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<List<CostTrendPoint>> getCostTrend({
    required String familyId,
    int months = 6,
    String? childId,
  }) async {
    final data = await _client.getData<List<dynamic>>(
      '/api/cost/trend',
      queryParameters: {'months': months, 'childId': childId},
    );
    return data
        .map((item) => CostTrendPoint.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<double> getTotalRemainingValue(String familyId) async {
    final data = await _client.getData<num>('/api/cost/remaining-value');
    return data.toDouble();
  }

  @override
  Future<String> exportCostAsCsv({
    required String familyId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _client.getText(
      '/api/cost/export.csv',
      queryParameters: {
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
      },
    );
  }

  @override
  void clearCache() {}
}

String _localIso(DateTime value) {
  final local = value.toLocal();
  String two(int input) => input.toString().padLeft(2, '0');
  String three(int input) => input.toString().padLeft(3, '0');
  return '${local.year.toString().padLeft(4, '0')}-'
      '${two(local.month)}-'
      '${two(local.day)}T'
      '${two(local.hour)}:'
      '${two(local.minute)}:'
      '${two(local.second)}.'
      '${three(local.millisecond)}';
}
