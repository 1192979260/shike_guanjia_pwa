import 'package:flutter/foundation.dart';
import '../core/service_locator.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/http/http_backend_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = getIt<AuthService>();
  final StorageService _storage = getIt<StorageService>();

  bool _isLoggedIn = false;
  String? _phone;
  String? _familyId;
  bool _isLoading = false;
  bool _isInitialized = false;

  bool get isLoggedIn => _isLoggedIn;
  String? get phone => _phone;
  String? get familyId => _familyId;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    final backend = _authService is HttpBackendService ? _authService : null;
    final restored = await backend?.restoreSession() ?? false;
    _isLoggedIn = restored;
    _phone = _storage.phone;
    _familyId = _storage.familyId;
    _isInitialized = true;
    notifyListeners();
  }

  Future<bool> register(String phone, String password) {
    return _authenticate(() => _authService.register(phone, password));
  }

  Future<bool> login(String phone, String password) {
    return _authenticate(() => _authService.login(phone, password));
  }

  Future<bool> _authenticate(Future<User?> Function() action) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await action();
      if (user != null) {
        _isLoggedIn = true;
        _phone = user.phone;
        final backend = _authService is HttpBackendService
            ? _authService
            : null;
        _familyId =
            (await backend?.getCurrentFamily())?.id ?? _storage.familyId;
      }
      return user != null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _isLoggedIn = false;
    _phone = null;
    _familyId = null;
    notifyListeners();
  }

  Future<void> setOnboardingDone() async {
    await _storage.setOnboardingDone();
  }

  bool get onboardingDone => _storage.onboardingDone;
}
