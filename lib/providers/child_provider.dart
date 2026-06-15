import 'package:flutter/foundation.dart';
import '../core/service_locator.dart';
import '../models/child.dart';
import '../services/child_service.dart';
import 'auth_provider.dart';

class ChildProvider extends ChangeNotifier {
  final ChildService _childService = getIt<ChildService>();
  final AuthProvider _auth;

  List<Child> _children = [];
  bool _isLoading = false;
  String? _error;

  List<Child> get children => _children;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ChildProvider({required AuthProvider auth}) : _auth = auth;

  Future<void> loadChildren() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_auth.familyId != null) {
        _children = await _childService.getChildren(_auth.familyId!);
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to load children: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Child> addChild(String name, int? age, String? avatarUrl) async {
    Child? child;

    _isLoading = true;
    notifyListeners();

    try {
      child = await _childService.createChild(
        name: name,
        age: age,
        avatarUrl: avatarUrl,
        familyId: _auth.familyId ?? '',
      );
      if (child != null) {
        _children.add(child);
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to add child: $e');
    }

    _isLoading = false;
    notifyListeners();
    return child ??
        Child(
          id: '',
          name: name,
          age: age,
          avatarUrl: avatarUrl,
          familyId: _auth.familyId ?? '',
          createdAt: DateTime.now(),
        );
  }

  Future<void> updateChild(Child child) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updated = await _childService.updateChild(
        child.id,
        name: child.name,
        age: child.age,
        avatarUrl: child.avatarUrl,
      );
      final index = _children.indexWhere((c) => c.id == child.id);
      if (index != -1) {
        _children[index] = updated ?? child;
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to update child: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> removeChild(String childId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _childService.deleteChild(childId);
      _children.removeWhere((c) => c.id == childId);
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to remove child: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
