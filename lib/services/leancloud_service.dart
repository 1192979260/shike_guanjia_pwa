import "package:shike_guanjia/models/models.dart";
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'storage_service.dart';

/// Mock backend service — simulates BaaS calls with local data.
/// In production, replace with actual LeanCloud SDK calls.
class LeanCloudService {
  static final LeanCloudService _instance = LeanCloudService._internal();
  factory LeanCloudService() => _instance;
  LeanCloudService._internal();

  final StorageService _storage = StorageService();

  // --- Simulated in-memory store ---
  final Map<String, Map<String, dynamic>> _classes = {};
  final Map<String, Map<String, dynamic>> _lessons = {};
  final Map<String, Map<String, dynamic>> _children = {};
  final Map<String, Map<String, dynamic>> _families = {};

  // --- Auth ---
  Future<bool> login(String phone, String code) async {
    // Simulate: any 6-digit code works
    if (phone.length == 11 && code.length == 6) {
      final user = {
        'id': 'user_${phone.hashCode}',
        'phone': phone,
        'nickname': '',
        'createdAt': DateTime.now().toIso8601String(),
      };
      await _storage.saveAuth(phone);

      // Create family if not exists
      if (!_families.containsKey(_storage.familyId)) {
        final familyId = 'family_${phone.hashCode}';
        _families[familyId] = {
          'id': familyId,
          'name': '我的家庭',
          'members': [
            {
              'id': 'member_1',
              'userId': user['id'],
              'relation': 'mother',
              'displayName': '妈妈',
              'createdAt': DateTime.now().toIso8601String(),
            }
          ],
        };
        await _storage.saveFamilyId(familyId);
      }
      return true;
    }
    return false;
  }

  Future<void> sendVerificationCode(String phone) async {
    // Simulate sending code
    debugPrint('验证码已发送到 $phone（模拟：任意6位数即可登录）');
  }

  // --- Children ---
  Future<List<Child>> getChildren(String familyId) async {
    final result = _children.values
        .where((c) => c['familyId'] == familyId)
        .map((c) => Child.fromJson(c))
        .toList();
    result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    await _cacheChildren(result);
    return result;
  }

  Future<Child> createChild(Child child) async {
    final data = child.toJson();
    _children[child.id] = data;
    await _cacheChildrenList();
    return child;
  }

  Future<Child> updateChild(Child child) async {
    _children[child.id] = child.toJson();
    await _cacheChildrenList();
    return child;
  }

  Future<void> deleteChild(String id) async {
    _children.remove(id);
    // Also delete associated classes and lessons
    _classes.removeWhere((k, v) => v['childId'] == id);
    _lessons.removeWhere((k, v) => _classBelongsTo(v['classId'], id));
    await _cacheChildrenList();
  }

  bool _classBelongsTo(String classId, String childId) {
    return _classes[classId]?['childId'] == childId;
  }

  // --- Classes ---
  Future<List<TrainingClass>> getClasses({
    String? familyId,
    String? childId,
    ClassStatus? status,
  }) async {
    var result = _classes.values.toList();

    if (familyId != null) {
      result = result.where((c) => c['familyId'] == familyId).toList();
    }
    if (childId != null) {
      result = result.where((c) => c['childId'] == childId).toList();
    }
    if (status != null) {
      result = result.where((c) => c['status'] == status.name).toList();
    }

    result.sort((a, b) {
      final aStart = DateTime.parse(a['startTime'] as String);
      final bStart = DateTime.parse(b['startTime'] as String);
      return aStart.compareTo(bStart);
    });

    return result.map((c) => TrainingClass.fromJson(c)).toList();
  }

  Future<TrainingClass> createClass(TrainingClass cls) async {
    _classes[cls.id] = cls.toJson();
    await _cacheClassesList([cls]);
    return cls;
  }

  Future<TrainingClass> updateClass(TrainingClass cls) async {
    _classes[cls.id] = cls.toJson();
    await _cacheClassesList([cls]);
    return cls;
  }

  Future<void> deleteClass(String id) async {
    _classes.remove(id);
    _lessons.removeWhere((k, v) => v['classId'] == id);
  }

  Future<TrainingClass> pauseClass(String id) async {
    final existing = _classes[id];
    if (existing != null) {
      existing['status'] = ClassStatus.paused.name;
      _classes[id] = existing;
      await _cacheClassesList([TrainingClass.fromJson(existing)]);
      return TrainingClass.fromJson(existing);
    }
    throw Exception('Class not found: $id');
  }

  Future<TrainingClass> resumeClass(String id) async {
    final existing = _classes[id];
    if (existing != null) {
      existing['status'] = ClassStatus.active.name;
      _classes[id] = existing;
      await _cacheClassesList([TrainingClass.fromJson(existing)]);
      return TrainingClass.fromJson(existing);
    }
    throw Exception('Class not found: $id');
  }

  Future<TrainingClass> endClass(String id) async {
    final existing = _classes[id];
    if (existing != null) {
      existing['status'] = ClassStatus.ended.name;
      _classes[id] = existing;
      await _cacheClassesList([TrainingClass.fromJson(existing)]);
      return TrainingClass.fromJson(existing);
    }
    throw Exception('Class not found: $id');
  }

  // --- Lessons ---
  Future<List<Lesson>> getLessons({
    String? classId,
    DateTime? startFrom,
    DateTime? endAt,
  }) async {
    var result = _lessons.values.toList();

    if (classId != null) {
      result = result.where((l) => l['classId'] == classId).toList();
    }
    if (startFrom != null) {
      result = result.where((l) {
        final sd = DateTime.parse(l['scheduledDate'] as String);
        return !sd.isBefore(startFrom);
      }).toList();
    }
    if (endAt != null) {
      result = result.where((l) {
        final sd = DateTime.parse(l['scheduledDate'] as String);
        return !sd.isAfter(endAt);
      }).toList();
    }

    result.sort((a, b) {
      final da = DateTime.parse(a['scheduledDate']);
      final db = DateTime.parse(b['scheduledDate']);
      return da.compareTo(db);
    });

    return result.map((l) => Lesson.fromJson(l)).toList();
  }

  Future<Lesson> createLesson(Lesson lesson) async {
    _lessons[lesson.id] = lesson.toJson();
    await _cacheLessonsList(_allLessons());
    return lesson;
  }

  Future<Lesson> updateLesson(Lesson lesson) async {
    _lessons[lesson.id] = lesson.toJson();
    await _cacheLessonsList(_allLessons());
    return lesson;
  }

  Future<void> deleteLesson(String id) async {
    _lessons.remove(id);
    await _cacheLessonsList(_allLessons());
  }

  // --- Sync ---
  Future<void> sync() async {
    // In production: pull changes from cloud, push local changes
    await _storage.saveLastSync();
  }

  // --- Caching helpers ---
  Future<void> _cacheChildrenList() async {
    final list = _children.values.map((c) => c).toList();
    await _storage.cacheChildren(jsonEncode(list));
  }

  Future<void> _cacheClassesList(List<TrainingClass> list) async {
    final jsonList = list.map((c) => c.toJson()).toList();
    await _storage.cacheClasses(jsonEncode(jsonList));
  }

  Future<void> _cacheChildren(List<Child> list) async {
    final jsonList = list.map((c) => c.toJson()).toList();
    await _storage.cacheChildren(jsonEncode(jsonList));
  }

  Future<void> _cacheLessonsList(List<Lesson> list) async {
    final jsonList = list.map((l) => l.toJson()).toList();
    await _storage.cacheLessons(jsonEncode(jsonList));
  }

  List<Lesson> _allLessons() {
    return _lessons.values.map((lesson) => Lesson.fromJson(lesson)).toList();
  }
}
