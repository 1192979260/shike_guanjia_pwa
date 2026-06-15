import "package:shike_guanjia/models/models.dart";
import 'package:uuid/uuid.dart';

import 'package:shike_guanjia/services/auth_service.dart';
import 'package:shike_guanjia/services/mock/mock_data_store.dart';

class MockAuthService implements AuthService {
  MockAuthService(this._store);

  final MockDataStore _store;
  final _uuid = const Uuid();
  final _passwords = <String, String>{};

  @override
  Future<User?> register(String phone, String password) async {
    if (!_isValidPhone(phone) || !_isValidPassword(password)) {
      return null;
    }
    if (_passwords.containsKey(phone)) {
      return null;
    }
    _passwords[phone] = password;
    return _createSession(phone);
  }

  @override
  Future<User?> login(String phone, String password) async {
    if (!_isValidPhone(phone) || _passwords[phone] != password) {
      return null;
    }
    return _createSession(phone);
  }

  Future<User?> _createSession(String phone) async {
    final existing = _store.users.values
        .where((user) => user.phone == phone)
        .cast<User?>()
        .firstWhere((user) => user != null, orElse: () => null);

    final user =
        existing ??
        User(id: _uuid.v4(), phone: phone, createdAt: DateTime.now());
    _store.users[user.id] = user;

    final family =
        _findFamilyForUser(user.id) ??
        Family(
          id: _uuid.v4(),
          name: '${phone.substring(phone.length - 4)}的家庭',
          members: [
            FamilyMember(
              id: _uuid.v4(),
              userId: user.id,
              relation: FamilyRelation.mother,
              displayName: user.nickname,
              createdAt: DateTime.now(),
            ),
          ],
        );

    _store.families[family.id] = family;
    _store.currentUser = user;
    _store.currentFamily = family;
    return user;
  }

  @override
  Future<void> logout() async {
    _store.clearSession();
  }

  @override
  User? getCurrentUser() => _store.currentUser;

  @override
  bool isLoggedIn() => _store.currentUser != null;

  @override
  Future<FamilyMember?> addFamilyMember(
    String phone,
    FamilyRelation relation,
  ) async {
    final family = _store.currentFamily;
    if (family == null || family.members.length >= 2 || !_isValidPhone(phone)) {
      return null;
    }

    var user = _store.users.values
        .where((item) => item.phone == phone)
        .cast<User?>()
        .firstWhere((item) => item != null, orElse: () => null);
    user ??= User(id: _uuid.v4(), phone: phone, createdAt: DateTime.now());
    _store.users[user.id] = user;

    final member = FamilyMember(
      id: _uuid.v4(),
      userId: user.id,
      relation: relation,
      createdAt: DateTime.now(),
    );
    final updated = family.copyWith(members: [...family.members, member]);
    _store.families[updated.id] = updated;
    _store.currentFamily = updated;
    return member;
  }

  @override
  Future<bool> removeFamilyMember(String memberId) async {
    final family = _store.currentFamily;
    if (family == null || family.members.length <= 1) {
      return false;
    }

    final updated = family.copyWith(
      members: family.members.where((member) => member.id != memberId).toList(),
    );
    if (updated.members.length == family.members.length) {
      return false;
    }
    _store.families[updated.id] = updated;
    _store.currentFamily = updated;
    return true;
  }

  @override
  Future<List<FamilyMember>> getFamilyMembers() async {
    return List.unmodifiable(_store.currentFamily?.members ?? const []);
  }

  @override
  Future<Family?> getFamily() async => _store.currentFamily;

  Family? _findFamilyForUser(String userId) {
    for (final family in _store.families.values) {
      if (family.members.any((member) => member.userId == userId)) {
        return family;
      }
    }
    return null;
  }

  bool _isValidPhone(String phone) => RegExp(r'^\+?\d{10,15}$').hasMatch(phone);

  bool _isValidPassword(String password) =>
      password.length >= 6 && password.length <= 72;
}
