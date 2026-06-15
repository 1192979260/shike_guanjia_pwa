import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:shike_guanjia/models/models.dart';

/// Local storage service for offline support
class StorageService {
  static const _keyAuth = 'auth_phone';
  static const _keyAuthToken = 'auth_token';
  static const _keyLoggedIn = 'auth_logged_in';
  static const _keyFamilyId = 'family_id';
  static const _keyLastSync = 'last_sync_time';
  static const _keyOnboardingDone = 'onboarding_done';
  static const _keyLocalClasses = 'local_classes';
  static const _keyLocalLessons = 'local_lessons';
  static const _keyLocalChildren = 'local_children';
  static const _keyReminderSettings = 'reminder_settings';
  static const _keyThemeSkin = 'theme_skin';

  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Auth
  Future<void> saveAuth(String phone) async {
    await _prefs?.setString(_keyAuth, phone);
    await _prefs?.setBool(_keyLoggedIn, true);
  }

  Future<void> saveAuthToken(String token) async {
    await _prefs?.setString(_keyAuthToken, token);
    await _prefs?.setBool(_keyLoggedIn, true);
  }

  String? get phone => _prefs?.getString(_keyAuth);
  String? get authToken => _prefs?.getString(_keyAuthToken);
  bool get isLoggedIn => _prefs?.getBool(_keyLoggedIn) ?? false;
  Future<void> logout() async {
    await _prefs?.setString(_keyAuth, '');
    await _prefs?.remove(_keyAuthToken);
    await _prefs?.setBool(_keyLoggedIn, false);
  }

  // Family
  Future<void> saveFamilyId(String id) async {
    await _prefs?.setString(_keyFamilyId, id);
  }

  String? get familyId => _prefs?.getString(_keyFamilyId);

  // Sync
  Future<void> saveLastSync() async {
    await _prefs?.setString(_keyLastSync, DateTime.now().toIso8601String());
  }

  DateTime? get lastSyncTime {
    final s = _prefs?.getString(_keyLastSync);
    return s != null ? DateTime.parse(s) : null;
  }

  // Onboarding
  Future<void> setOnboardingDone() async {
    await _prefs?.setBool(_keyOnboardingDone, true);
  }

  bool get onboardingDone => _prefs?.getBool(_keyOnboardingDone) ?? false;

  // Local data cache
  Future<void> cacheClasses(String jsonStr) async {
    await _prefs?.setString(_keyLocalClasses, jsonStr);
  }

  List<Map<String, dynamic>>? get cachedClasses {
    final s = _prefs?.getString(_keyLocalClasses);
    if (s == null) return null;
    try {
      return List<Map<String, dynamic>>.from(jsonDecode(s) as List);
    } catch (e) {
      debugPrint('Failed to parse cached classes: $e');
      return null;
    }
  }

  Future<void> cacheLessons(String jsonStr) async {
    await _prefs?.setString(_keyLocalLessons, jsonStr);
  }

  List<Map<String, dynamic>>? get cachedLessons {
    final s = _prefs?.getString(_keyLocalLessons);
    if (s == null) return null;
    try {
      return List<Map<String, dynamic>>.from(jsonDecode(s) as List);
    } catch (e) {
      debugPrint('Failed to parse cached lessons: $e');
      return null;
    }
  }

  Future<void> cacheChildren(String jsonStr) async {
    await _prefs?.setString(_keyLocalChildren, jsonStr);
  }

  List<Map<String, dynamic>>? get cachedChildren {
    final s = _prefs?.getString(_keyLocalChildren);
    if (s == null) return null;
    try {
      return List<Map<String, dynamic>>.from(jsonDecode(s) as List);
    } catch (e) {
      debugPrint('Failed to parse cached children: $e');
      return null;
    }
  }

  // Preferences
  Future<void> cacheReminderSettings(ReminderSettings settings) async {
    await _prefs?.setString(
      _keyReminderSettings,
      jsonEncode(settings.toJson()),
    );
  }

  ReminderSettings? get cachedReminderSettings {
    final s = _prefs?.getString(_keyReminderSettings);
    if (s == null) return null;
    try {
      return ReminderSettings.fromJson(jsonDecode(s) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Failed to parse cached reminder settings: $e');
      return null;
    }
  }

  Future<void> cacheThemeSkin(ThemeSkin skin) async {
    await _prefs?.setString(_keyThemeSkin, skin.toJson());
  }

  ThemeSkin? get cachedThemeSkin {
    final value = _prefs?.getString(_keyThemeSkin);
    return value == null ? null : ThemeSkin.fromJson(value);
  }
}
