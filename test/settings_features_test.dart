import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shike_guanjia/core/service_locator.dart';
import 'package:shike_guanjia/models/models.dart';
import 'package:shike_guanjia/providers/providers.dart';
import 'package:shike_guanjia/screens/settings/family_sharing_screen.dart';
import 'package:shike_guanjia/screens/settings/reminder_settings_screen.dart';
import 'package:shike_guanjia/screens/settings/theme_selection_screen.dart';
import 'package:shike_guanjia/services/auth_service.dart';
import 'package:shike_guanjia/services/mock/mock_reminder_service.dart';
import 'package:shike_guanjia/services/reminder_service.dart';
import 'package:shike_guanjia/services/storage_service.dart';
import 'package:shike_guanjia/services/theme_preference_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storage;

  setUp(() async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues({});
    storage = StorageService();
    await storage.init();
    getIt.registerSingleton<StorageService>(storage);
    getIt.registerSingleton<AuthService>(_FamilyService());
  });

  group('models and storage', () {
    test('serializes reminder settings and theme skin safely', () {
      final settings = ReminderSettings(
        enabled: false,
        advanceMinutes: 30,
        includeTodayLessons: false,
        includeMakeupLessons: true,
        updatedAt: DateTime(2026, 6, 12, 9),
      );

      final decoded = ReminderSettings.fromJson(settings.toJson());

      expect(decoded.enabled, isFalse);
      expect(decoded.advanceMinutes, 30);
      expect(decoded.updatedAt, DateTime(2026, 6, 12, 9));
      expect(ThemeSkin.fromJson('fresh'), ThemeSkin.fresh);
      expect(ThemeSkin.fromJson('unexpected'), ThemeSkin.warm);
    });

    test('persists preferences and keeps them after logout', () async {
      final settings = ReminderSettings.defaults().copyWith(
        advanceMinutes: 120,
      );

      await storage.cacheReminderSettings(settings);
      await storage.cacheThemeSkin(ThemeSkin.classic);
      await storage.saveAuth('13800138000');
      await storage.logout();

      expect(storage.cachedReminderSettings?.advanceMinutes, 120);
      expect(storage.cachedThemeSkin, ThemeSkin.classic);
      expect(storage.isLoggedIn, isFalse);
    });
  });

  group('ReminderProvider', () {
    test(
      'loads cached settings first and keeps local settings on save failure',
      () async {
        await storage.cacheReminderSettings(
          ReminderSettings.defaults().copyWith(advanceMinutes: 30),
        );
        final service = _FailingUpdateReminderService(
          initial: ReminderSettings.defaults().copyWith(advanceMinutes: 60),
        );
        final provider = ReminderProvider(
          reminderService: service,
          storage: storage,
        );

        await provider.init(loggedIn: false);
        expect(provider.settings.advanceMinutes, 30);

        await provider.updateSettings(
          provider.settings.copyWith(advanceMinutes: 15),
        );

        expect(provider.settings.advanceMinutes, 15);
        expect(provider.error, isNotNull);
      },
    );

    test('schedules only eligible lessons through mock service', () async {
      final service = MockReminderService();
      final provider = ReminderProvider(
        reminderService: service,
        storage: storage,
      );
      await provider.init();
      await provider.updateSettings(
        provider.settings.copyWith(includeMakeupLessons: false),
      );

      await provider.updateLessons([
        _lesson('scheduled', DateTime.now().add(const Duration(days: 1))),
        _lesson(
          'completed',
          DateTime.now().add(const Duration(days: 1)),
          status: LessonStatus.completed,
        ),
        _lesson(
          'makeup',
          DateTime.now().add(const Duration(days: 1)),
          isMakeup: true,
        ),
      ]);

      expect(service.scheduledLessons.map((item) => item.id), ['scheduled']);
    });
  });

  group('ThemeProvider', () {
    test(
      'uses cached skin then server preference and keeps local on failure',
      () async {
        await storage.cacheThemeSkin(ThemeSkin.fresh);
        final service = _ThemeService(ThemeSkin.classic)..failUpdate = true;
        final provider = ThemeProvider(themeService: service, storage: storage);

        await provider.init(loggedIn: false);
        expect(provider.skin, ThemeSkin.fresh);

        await provider.syncFromServer();
        expect(provider.skin, ThemeSkin.classic);

        await provider.setSkin(ThemeSkin.warm);
        expect(provider.skin, ThemeSkin.warm);
        expect(provider.error, isNotNull);
      },
    );
  });

  group('FamilyProvider', () {
    test(
      'loads members, validates phone, maps errors, and removes members',
      () async {
        final auth = _LoggedInAuthProvider();
        final service = _FamilyService();
        final provider = FamilyProvider(auth: auth, authService: service);

        await provider.loadFamily();
        expect(provider.members, hasLength(1));

        final invalid = await provider.addMember(
          'bad-phone',
          FamilyRelation.father,
        );
        expect(invalid, isFalse);
        expect(provider.error, '请输入有效手机号');

        final added = await provider.addMember(
          '13800138001',
          FamilyRelation.father,
        );
        expect(added, isTrue);
        expect(provider.members, hasLength(2));

        final overLimit = await provider.addMember(
          '13800138002',
          FamilyRelation.father,
        );
        expect(overLimit, isFalse);
        expect(provider.error, '当前家庭最多支持 2 位成员');

        final removed = await provider.removeMember(provider.members.last.id);
        expect(removed, isTrue);
        expect(provider.members, hasLength(1));
      },
    );
  });

  group('settings screens', () {
    testWidgets('reminder screen renders permission and options', (
      tester,
    ) async {
      final provider = ReminderProvider(
        reminderService: MockReminderService(
          permissionStatus: NotificationPermissionStatus.denied,
        ),
        storage: storage,
      );
      await provider.init();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: provider,
            child: const ReminderSettingsScreen(),
          ),
        ),
      );

      expect(find.text('上课提醒'), findsWidgets);
      expect(find.text('通知权限未开启'), findsOneWidget);
      expect(find.text('1 小时'), findsOneWidget);
    });

    testWidgets('theme screen renders all skins', (tester) async {
      final provider = ThemeProvider(
        themeService: _ThemeService(ThemeSkin.warm),
        storage: storage,
      );
      await provider.init();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: provider,
            child: const ThemeSelectionScreen(),
          ),
        ),
      );

      expect(find.text('暖色贴纸'), findsOneWidget);
      expect(find.text('清新浅色'), findsOneWidget);
      expect(find.text('经典稳重'), findsOneWidget);
    });

    testWidgets('family screen renders current family', (tester) async {
      final auth = _LoggedInAuthProvider();
      final familyProvider = FamilyProvider(
        auth: auth,
        authService: _FamilyService(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(value: auth),
              ChangeNotifierProvider<FamilyProvider>.value(
                value: familyProvider,
              ),
            ],
            child: const FamilySharingScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('家庭共享'), findsWidgets);
      expect(find.text('测试家庭'), findsOneWidget);
      expect(find.text('宝妈'), findsOneWidget);
    });
  });
}

Lesson _lesson(
  String id,
  DateTime scheduledDate, {
  LessonStatus status = LessonStatus.scheduled,
  bool isMakeup = false,
}) {
  return Lesson(
    id: id,
    classId: 'class-a',
    scheduledDate: scheduledDate,
    status: status,
    isMakeup: isMakeup,
  );
}

class _FailingUpdateReminderService extends MockReminderService {
  _FailingUpdateReminderService({required ReminderSettings initial})
    : super(initialSettings: initial);

  @override
  Future<ReminderSettings> updateReminderSettings(
    ReminderSettings settings,
  ) async {
    throw StateError('save failed');
  }
}

class _ThemeService implements ThemePreferenceService {
  _ThemeService(this.skin);

  ThemeSkin skin;
  bool failUpdate = false;

  @override
  Future<ThemeSkin> getThemePreference() async => skin;

  @override
  Future<ThemeSkin> updateThemePreference(ThemeSkin skin) async {
    this.skin = skin;
    if (failUpdate) throw StateError('save failed');
    return skin;
  }
}

class _FamilyService implements AuthService {
  Family _family = Family(
    id: 'family-a',
    name: '测试家庭',
    members: [
      FamilyMember(
        id: 'member-a',
        userId: 'user-a',
        relation: FamilyRelation.mother,
        displayName: '妈妈',
        createdAt: DateTime(2026),
      ),
    ],
  );

  @override
  Future<FamilyMember?> addFamilyMember(
    String phone,
    FamilyRelation relation,
  ) async {
    if (_family.members.length >= 2) return null;
    final member = FamilyMember(
      id: 'member-${_family.members.length + 1}',
      userId: phone,
      relation: relation,
      displayName: phone,
      createdAt: DateTime(2026),
    );
    _family = _family.copyWith(members: [..._family.members, member]);
    return member;
  }

  @override
  Future<Family?> getFamily() async => _family;

  @override
  Future<List<FamilyMember>> getFamilyMembers() async => _family.members;

  @override
  User? getCurrentUser() =>
      User(id: 'user-a', phone: '13800138000', createdAt: DateTime(2026));

  @override
  bool isLoggedIn() => true;

  @override
  Future<User?> login(String phone, String code) async => getCurrentUser();

  @override
  Future<void> logout() async {}

  @override
  Future<bool> removeFamilyMember(String memberId) async {
    final next = _family.members
        .where((member) => member.id != memberId)
        .toList(growable: false);
    if (next.length == _family.members.length || next.isEmpty) return false;
    _family = _family.copyWith(members: next);
    return true;
  }

  @override
  Future<bool> sendVerificationCode(String phone) async => true;
}

class _LoggedInAuthProvider extends AuthProvider {
  @override
  bool get isLoggedIn => true;

  @override
  String? get familyId => 'family-a';
}
