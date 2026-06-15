import 'package:flutter/material.dart';
import 'package:shike_guanjia/core/service_locator.dart';
import 'package:shike_guanjia/models/models.dart';
import 'package:shike_guanjia/services/storage_service.dart';
import 'package:shike_guanjia/services/theme_preference_service.dart';
import 'package:shike_guanjia/themes/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider({ThemePreferenceService? themeService, StorageService? storage})
    : _themeService = themeService ?? getIt<ThemePreferenceService>(),
      _storage = storage ?? getIt<StorageService>();

  final ThemePreferenceService _themeService;
  final StorageService _storage;

  ThemeSkin _skin = ThemeSkin.warm;
  bool _initialized = false;
  bool _isSaving = false;
  bool _lastLoggedIn = false;
  String? _error;

  ThemeSkin get skin => _skin;
  ThemeData get themeData => AppTheme.themeFor(_skin);
  bool get initialized => _initialized;
  bool get isSaving => _isSaving;
  String? get error => _error;

  Future<void> init({bool loggedIn = false}) async {
    if (_initialized) return;
    _skin = _storage.cachedThemeSkin ?? ThemeSkin.warm;
    _initialized = true;
    _lastLoggedIn = loggedIn;
    notifyListeners();

    if (loggedIn) {
      await syncFromServer();
    }
  }

  void onAuthChanged(bool loggedIn) {
    if (!_initialized) {
      init(loggedIn: loggedIn);
      return;
    }
    if (loggedIn && !_lastLoggedIn) {
      syncFromServer();
    }
    _lastLoggedIn = loggedIn;
  }

  Future<void> syncFromServer() async {
    try {
      final serverSkin = await _themeService.getThemePreference();
      _skin = serverSkin;
      await _storage.cacheThemeSkin(serverSkin);
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to sync theme preference: $e');
    }
    notifyListeners();
  }

  Future<void> setSkin(ThemeSkin skin) async {
    if (_skin == skin && _error == null) return;
    _skin = skin;
    _isSaving = true;
    _error = null;
    await _storage.cacheThemeSkin(skin);
    notifyListeners();

    try {
      final saved = await _themeService.updateThemePreference(skin);
      _skin = saved;
      await _storage.cacheThemeSkin(saved);
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to save theme preference: $e');
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void clearSessionState() {
    _lastLoggedIn = false;
  }
}
