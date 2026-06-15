import "package:shike_guanjia/models/models.dart";
import 'package:uuid/uuid.dart';

import 'package:shike_guanjia/services/auth_service.dart';
import 'package:shike_guanjia/services/mock/mock_data_store.dart';

class MockAuthService implements AuthService {
  MockAuthService(this._store);

  final MockDataStore _store;
  final _uuid = const Uuid();
  final _codes = <String, _VerificationCode>{};
  final _requestTimes = <String, List<DateTime>>{};

  @override
  Future<bool> sendVerificationCode(String phone) async {
    if (!_isValidPhone(phone) || _isRateLimited(phone)) {
      return false;
    }

    final now = DateTime.now();
    _requestTimes.putIfAbsent(phone, () => <DateTime>[]).add(now);
    _codes[phone] = _VerificationCode(
      code: '123456',
      expiresAt: now.add(const Duration(minutes: 5)),
    );
    return true;
  }

  @override
  Future<User?> login(String phone, String code) async {
    if (!_isValidPhone(phone)) {
      return null;
    }

    final verification = _codes[phone];
    final isValidCode = code == '123456' ||
        (verification != null &&
            verification.code == code &&
            verification.expiresAt.isAfter(DateTime.now()));
    if (!isValidCode) {
      return null;
    }

    final existing = _store.users.values
        .where((user) => user.phone == phone)
        .cast<User?>()
        .firstWhere((user) => user != null, orElse: () => null);

    final user = existing ??
        User(
          id: _uuid.v4(),
          phone: phone,
          createdAt: DateTime.now(),
        );
    _store.users[user.id] = user;

    final family = _findFamilyForUser(user.id) ??
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

  bool _isRateLimited(String phone) {
    final oneMinuteAgo = DateTime.now().subtract(const Duration(minutes: 1));
    final recent = (_requestTimes[phone] ?? <DateTime>[])
        .where((time) => time.isAfter(oneMinuteAgo))
        .toList();
    _requestTimes[phone] = recent;
    return recent.length >= 3;
  }

  bool _isValidPhone(String phone) => RegExp(r'^\+?\d{10,15}$').hasMatch(phone);
}

class _VerificationCode {
  const _VerificationCode({
    required this.code,
    required this.expiresAt,
  });

  final String code;
  final DateTime expiresAt;
}
