import "package:shike_guanjia/models/models.dart";
import 'package:uuid/uuid.dart';

import 'package:shike_guanjia/services/child_service.dart';
import 'package:shike_guanjia/services/mock/mock_data_store.dart';

class MockChildService implements ChildService {
  MockChildService(this._store);

  final MockDataStore _store;
  final _uuid = const Uuid();

  @override
  Future<Child?> createChild({
    required String name,
    int? age,
    String? avatarUrl,
    required String familyId,
  }) async {
    if (validateChild(name: name, age: age).isNotEmpty) {
      return null;
    }

    final child = Child(
      id: _uuid.v4(),
      name: name.trim(),
      age: age,
      avatarUrl: avatarUrl ?? _defaultAvatarFor(name),
      familyId: familyId,
      createdAt: DateTime.now(),
    );
    _store.children[child.id] = child;
    return child;
  }

  @override
  Future<Child?> updateChild(
    String childId, {
    String? name,
    int? age,
    String? avatarUrl,
  }) async {
    final existing = _store.children[childId];
    if (existing == null) {
      return null;
    }

    final nextName = name ?? existing.name;
    final nextAge = age ?? existing.age;
    if (validateChild(name: nextName, age: nextAge).isNotEmpty) {
      return null;
    }

    final updated = existing.copyWith(
      name: nextName.trim(),
      age: nextAge,
      avatarUrl: avatarUrl ?? existing.avatarUrl,
    );
    _store.children[childId] = updated;
    return updated;
  }

  @override
  Future<bool> deleteChild(String childId) async {
    if (_store.children.remove(childId) == null) {
      return false;
    }

    final classIds = _store.classes.values
        .where((item) => item.childId == childId)
        .map((item) => item.id)
        .toSet();
    _store.classes.removeWhere((_, item) => classIds.contains(item.id));
    _store.lessons.removeWhere((_, item) => classIds.contains(item.classId));
    _store.attendances.removeWhere((_, item) => item.childId == childId);
    _store.leaves.removeWhere((_, item) => item.childId == childId);
    return true;
  }

  @override
  Future<Child?> getChild(String childId) async => _store.children[childId];

  @override
  Future<List<Child>> getChildren(String familyId) async {
    return _store.children.values
        .where((child) => child.familyId == familyId)
        .toList(growable: false);
  }

  @override
  List<ChildValidationError> validateChild({
    required String name,
    int? age,
  }) {
    return Child.validate(name: name, age: age);
  }

  String _defaultAvatarFor(String name) {
    final text = Uri.encodeComponent(name.trim().isEmpty ? 'child' : name);
    return 'mock://avatar/$text';
  }
}
