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
  String? _selectedChildId;
  String? _selectedCourse;

  List<TrainingClass> get classes => _classes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedChildId => _selectedChildId;
  String? get selectedCourse => _selectedCourse;

  List<TrainingClass> get activeClasses =>
      _classes.where((c) => c.status == ClassStatus.active).toList();

  List<TrainingClass> get endedClasses =>
      _classes.where((c) => c.status == ClassStatus.ended).toList();

  /// Get filtered classes based on selected child and course.
  List<TrainingClass> get filteredClasses {
    return _classes.where((c) {
      if (_selectedChildId != null && c.childId != _selectedChildId) {
        return false;
      }
      if (_selectedCourse != null && c.courseName != _selectedCourse) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Get unique course names from the currently selected child scope.
  List<String> get uniqueCourses {
    final courses = _classes
        .where((c) => _selectedChildId == null || c.childId == _selectedChildId)
        .map((c) => c.courseName.trim())
        .where((course) => course.isNotEmpty)
        .toSet()
        .toList();
    courses.sort();
    return courses;
  }

  ClassProvider({
    required AuthProvider auth,
    ReminderProvider? reminderProvider,
  }) : _auth = auth,
       _reminderProvider = reminderProvider;

  /// Set child filter. Changing child clears course because course options are
  /// derived from that child's real classes.
  void setChildFilter(String? childId) {
    if (_selectedChildId == childId) return;
    _selectedChildId = childId;
    _selectedCourse = null;
    notifyListeners();
  }

  /// Set course filter.
  void setCourseFilter(String? course) {
    if (_selectedCourse == course) return;
    _selectedCourse = course;
    notifyListeners();
  }

  /// Clear course filter
  void clearCourseFilter() {
    if (_selectedCourse == null) return;
    _selectedCourse = null;
    notifyListeners();
  }

  void _ensureCourseFilterIsAvailable() {
    final selectedCourse = _selectedCourse;
    if (selectedCourse != null && !uniqueCourses.contains(selectedCourse)) {
      _selectedCourse = null;
    }
  }

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
      _ensureCourseFilterIsAvailable();
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
        _ensureCourseFilterIsAvailable();
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
      _ensureCourseFilterIsAvailable();
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
      _ensureCourseFilterIsAvailable();
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
