import 'package:get_it/get_it.dart';
import 'package:shike_guanjia/services/attendance_service.dart';
import 'package:shike_guanjia/services/auth_service.dart';
import 'package:shike_guanjia/services/child_service.dart';
import 'package:shike_guanjia/services/class_service.dart';
import 'package:shike_guanjia/services/cost_service.dart';
import 'package:shike_guanjia/services/http/api_client.dart';
import 'package:shike_guanjia/services/http/http_backend_service.dart';
import 'package:shike_guanjia/services/http/http_class_service.dart';
import 'package:shike_guanjia/services/http/http_lesson_service.dart';
import 'package:shike_guanjia/services/http/http_reminder_service.dart';
import 'package:shike_guanjia/services/http/http_theme_preference_service.dart';
import 'package:shike_guanjia/services/lesson_service.dart';
import 'package:shike_guanjia/services/mock/mock_services.dart';
import 'package:shike_guanjia/services/reminder_service.dart';
import 'package:shike_guanjia/services/storage_service.dart';
import 'package:shike_guanjia/services/sync_service.dart';
import 'package:shike_guanjia/services/theme_preference_service.dart';

/// Global service locator
final getIt = GetIt.instance;

/// Initialize all services
Future<void> setupServiceLocator() async {
  if (getIt.isRegistered<ApiClient>()) {
    return;
  }

  final storage = StorageService();
  await storage.init();

  getIt.registerSingleton<StorageService>(storage);
  getIt.registerLazySingleton<ApiClient>(ApiClient.new);
  getIt.registerLazySingleton<HttpBackendService>(
    () => HttpBackendService(getIt<ApiClient>(), getIt<StorageService>()),
  );
  getIt.registerLazySingleton<AuthService>(() => getIt<HttpBackendService>());
  getIt.registerLazySingleton<ChildService>(() => getIt<HttpBackendService>());
  getIt.registerLazySingleton<ClassService>(
    () => HttpClassService(getIt<HttpBackendService>()),
  );
  getIt.registerLazySingleton<LessonService>(
    () => HttpLessonService(getIt<HttpBackendService>()),
  );
  getIt.registerLazySingleton<AttendanceService>(
    () => getIt<HttpBackendService>(),
  );
  getIt.registerLazySingleton<CostService>(() => getIt<HttpBackendService>());
  getIt.registerLazySingleton<ReminderService>(
    () => HttpReminderService(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<ThemePreferenceService>(
    () => HttpThemePreferenceService(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<MockDataStore>(MockDataStore.new);
  getIt.registerLazySingleton<SyncService>(
    () => MockSyncService(getIt<MockDataStore>()),
  );
}
