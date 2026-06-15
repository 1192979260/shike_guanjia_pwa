import 'package:flutter/foundation.dart';
import '../core/service_locator.dart';
import '../models/models.dart';
import '../services/class_service.dart';
import 'auth_provider.dart';
import 'reminder_provider.dart';

class ClassProvider extends ChangeNotifier {
  final ClassService _classService = getIt<ClassService>();
  final AuthProvider _auth;
  ReminderProvider? _reminderProvider;

  List<TrainingClass> _classes = [];
  bool _isLoading = false;
  String? _error;

  List<TrainingClass> get classes => _classes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<TrainingClass> get activeClasses =>
      _classes.where((c) => c.status == ClassStatus.active).toList();

  List<TrainingClass> get endedClasses =>
      _classes.where((c) => c.status == ClassStatus.ended).toList();

  ClassProvider({
    required AuthProvider auth,
    ReminderProvider? reminderProvider,
  }) : _auth = auth,
       _reminderProvider = reminderProvider;

  void updateReminderProvider(ReminderProvider reminderProvider) {
    _reminderProvider = reminderProvider;
  }

  Future<void> loadClasses({String? childId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final familyId = _auth.familyId ?? '';
      _classes = await _classService.getClasses(familyId, childId: childId);
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to load classes: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<TrainingClass> addClass({
    required String childId,
    required String institutionName,
    required String className,
    required String courseName,
    required double totalFee,
    required int totalHours,
    int usedHours = 0,
    required DateTime startTime,
    required RecurringRule recurringRule,
  }) async {
    TrainingClass? cls;

    _isLoading = true;
    notifyListeners();

    try {
      cls = await _classService.createClass(
        childId: childId,
        familyId: _auth.familyId ?? '',
        institutionName: institutionName,
        className: className,
        courseName: courseName,
        totalHours: totalHours,
        usedHours: usedHours,
        totalFee: totalFee,
        startTime: startTime,
        recurringRule: recurringRule,
      );
      if (cls != null) {
        _classes.add(cls);
        await _reminderProvider?.rescheduleLessons();
      } else {
        throw StateError('新增班级失败，请稍后重试');
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to add class: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return cls;
  }

  Future<TrainingClass> updateClass(TrainingClass cls) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updated = await _classService.updateClass(
        cls.id,
        institutionName: cls.institutionName,
        className: cls.className,
        courseName: cls.courseName,
        teacherName: cls.teacherName,
        teacherPhone: cls.teacherPhone,
        totalHours: cls.totalHours,
        usedHours: cls.usedHours,
        totalFee: cls.totalFee,
        startTime: cls.startTime,
        endTime: cls.endTime,
        recurringRule: cls.recurringRule,
        status: cls.status,
        notes: cls.notes,
      );
      final index = _classes.indexWhere((c) => c.id == cls.id);
      final nextClass = updated ?? cls;
      if (index != -1) {
        _classes[index] = nextClass;
      }
      await _reminderProvider?.rescheduleLessons();
      return nextClass;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteClass(String classId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _classService.deleteClass(classId);
      _classes.removeWhere((c) => c.id == classId);
      await _reminderProvider?.rescheduleLessons();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> pauseClass(String classId) async {
    try {
      final cls = _classes.firstWhere((c) => c.id == classId);
      final updated =
          await _classService.pauseClass(classId) ??
          cls.copyWith(status: ClassStatus.paused);
      _classes[_classes.indexOf(cls)] = updated;
      await _reminderProvider?.rescheduleLessons();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> resumeClass(String classId) async {
    try {
      final cls = _classes.firstWhere((c) => c.id == classId);
      final updated =
          await _classService.resumeClass(classId) ??
          cls.copyWith(status: ClassStatus.active);
      _classes[_classes.indexOf(cls)] = updated;
      await _reminderProvider?.rescheduleLessons();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> endClass(String classId) async {
    try {
      final cls = _classes.firstWhere((c) => c.id == classId);
      final updated =
          await _classService.endClass(classId) ??
          cls.copyWith(status: ClassStatus.ended);
      _classes[_classes.indexOf(cls)] = updated;
      await _reminderProvider?.rescheduleLessons();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  /// Auto-update remaining hours when a lesson is marked completed
  Future<void> onLessonCompleted(String classId, int hoursUsed) async {
    final cls = _classes.firstWhere((c) => c.id == classId);
    if (cls.remainingHours > 0) {
      final updated = cls.copyWith(
        usedHours: cls.usedHours + hoursUsed,
        remainingHours: cls.remainingHours - hoursUsed,
      );

      if (updated.remainingHours <= 0) {
        updated.copyWith(status: ClassStatus.ended);
      }

      await updateClass(updated);
    }
  }

  /// Get upcoming lessons (next 7 days) for a class
  List<Map<String, dynamic>> getUpcomingLessons(String classId, int days) {
    return _classes
        .where((c) => c.id == classId && c.status == ClassStatus.active)
        .expand((c) {
          // Generate dates and check which are upcoming
          // This is a simplified version — the real logic is in schedule_generator
          return <Map<String, dynamic>>[];
        })
        .toList();
  }
}
