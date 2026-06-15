import 'package:flutter/foundation.dart';
import 'package:shike_guanjia/core/service_locator.dart';
import 'package:shike_guanjia/models/models.dart';
import 'package:shike_guanjia/services/auth_service.dart';
import 'package:shike_guanjia/services/http/api_client.dart';
import 'auth_provider.dart';

class FamilyProvider extends ChangeNotifier {
  FamilyProvider({required AuthProvider auth, AuthService? authService})
    : _auth = auth,
      _authService = authService ?? getIt<AuthService>();

  static const maxMembers = 2;

  AuthProvider _auth;
  final AuthService _authService;

  Family? _family;
  List<FamilyMember> _members = [];
  bool _isLoading = false;
  bool _isMutating = false;
  bool _sessionInvalidated = false;
  String? _error;

  Family? get family => _family;
  List<FamilyMember> get members => _members;
  bool get isLoading => _isLoading;
  bool get isMutating => _isMutating;
  bool get sessionInvalidated => _sessionInvalidated;
  String? get error => _error;
  bool get canAddMember => _members.length < maxMembers;
  String? get currentUserId => _authService.getCurrentUser()?.id;

  void updateAuth(AuthProvider auth) {
    final wasLoggedIn = _auth.isLoggedIn;
    _auth = auth;
    if (!auth.isLoggedIn) {
      clear();
      return;
    }
    if (auth.isLoggedIn && !wasLoggedIn) {
      loadFamily();
    }
  }

  Future<void> loadFamily() async {
    if (!_auth.isLoggedIn) {
      clear();
      return;
    }
    _isLoading = true;
    _error = null;
    _sessionInvalidated = false;
    notifyListeners();

    try {
      final family = await _authService.getFamily();
      if (family == null) {
        _family = null;
        _members = [];
        _sessionInvalidated = true;
        _error = '家庭不存在或已失效，请重新登录';
      } else {
        _family = family;
        _members = await _authService.getFamilyMembers();
      }
    } catch (e) {
      _error = _messageForError(e);
      _sessionInvalidated = e is ApiException && e.code == 'FAMILY_NOT_FOUND';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addMember(
    String phone,
    FamilyRelation relation, {
    bool refresh = true,
  }) async {
    if (_isMutating) return false;
    final normalizedPhone = phone.trim();
    if (!_isValidPhone(normalizedPhone)) {
      _error = '请输入有效手机号';
      notifyListeners();
      return false;
    }
    if (!canAddMember) {
      _error = _messageForCode('FAMILY_MEMBER_LIMIT_REACHED');
      notifyListeners();
      return false;
    }

    _isMutating = true;
    _error = null;
    notifyListeners();
    try {
      final member = await _authService.addFamilyMember(
        normalizedPhone,
        relation,
      );
      if (member == null) {
        _error = '添加成员失败，请稍后重试';
        return false;
      }
      if (refresh) {
        await _refreshFamilySnapshot();
      }
      return true;
    } catch (e) {
      _error = _messageForError(e);
      return false;
    } finally {
      _isMutating = false;
      notifyListeners();
    }
  }

  Future<bool> removeMember(String memberId) async {
    if (_isMutating) return false;
    if (_members.length <= 1) {
      _error = _messageForCode('CANNOT_REMOVE_LAST_MEMBER');
      notifyListeners();
      return false;
    }

    final removedMember = _members
        .where((member) => member.id == memberId)
        .cast<FamilyMember?>()
        .firstWhere((member) => member != null, orElse: () => null);
    final removesCurrentUser = removedMember?.userId == currentUserId;

    _isMutating = true;
    _error = null;
    notifyListeners();
    try {
      final removed = await _authService.removeFamilyMember(memberId);
      if (!removed) {
        _error = '移除成员失败，请稍后重试';
        return false;
      }
      if (removesCurrentUser) {
        await _auth.clearLocalSession();
        clear();
        return true;
      }
      await _refreshFamilySnapshot();
      return true;
    } catch (e) {
      _error = _messageForError(e);
      return false;
    } finally {
      _isMutating = false;
      notifyListeners();
    }
  }

  void clear() {
    _family = null;
    _members = [];
    _isLoading = false;
    _isMutating = false;
    _sessionInvalidated = false;
    _error = null;
    notifyListeners();
  }

  Future<void> _refreshFamilySnapshot() async {
    final family = await _authService.getFamily();
    if (family == null) {
      _family = null;
      _members = [];
      _sessionInvalidated = true;
      _error = '家庭不存在或已失效，请重新登录';
      return;
    }
    _family = family;
    _members = await _authService.getFamilyMembers();
  }

  String _messageForError(Object error) {
    if (error is ApiException) {
      return _messageForCode(error.code, fallback: error.message);
    }
    return error.toString();
  }

  String _messageForCode(String code, {String? fallback}) {
    switch (code) {
      case 'FAMILY_MEMBER_LIMIT_REACHED':
        return '当前家庭最多支持 2 位成员';
      case 'USER_ALREADY_IN_FAMILY':
        return '该手机号已在当前家庭中';
      case 'CANNOT_REMOVE_LAST_MEMBER':
        return '至少需要保留一位家庭成员';
      case 'FAMILY_INVITE_EXPIRED':
        return '邀请已过期，请重新发送';
      case 'FAMILY_INVITE_NOT_FOUND':
        return '邀请不存在或已失效';
      case 'FAMILY_NOT_FOUND':
        return '家庭不存在或已失效，请重新登录';
      default:
        return fallback ?? '操作失败，请稍后重试';
    }
  }

  bool _isValidPhone(String phone) => RegExp(r'^\+?\d{10,15}$').hasMatch(phone);
}
