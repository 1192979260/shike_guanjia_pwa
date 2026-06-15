import 'package:provider/provider.dart';

import 'auth_provider.dart';
import 'child_provider.dart';
import 'class_provider.dart';
import 'family_provider.dart';
import 'lesson_provider.dart';
import 'reminder_provider.dart';
import 'theme_provider.dart';

export 'auth_provider.dart';
export 'child_provider.dart';
export 'class_provider.dart';
export 'family_provider.dart';
export 'lesson_provider.dart';
export 'reminder_provider.dart';
export 'theme_provider.dart';

final globalProviders = [
  ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()..init()),
  ChangeNotifierProxyProvider<AuthProvider, ThemeProvider>(
    create: (context) =>
        ThemeProvider()
          ..init(loggedIn: context.read<AuthProvider>().isLoggedIn),
    update: (_, auth, previous) {
      final provider = previous ?? ThemeProvider();
      provider.onAuthChanged(auth.isLoggedIn);
      return provider;
    },
  ),
  ChangeNotifierProxyProvider<AuthProvider, ReminderProvider>(
    create: (context) =>
        ReminderProvider()
          ..init(loggedIn: context.read<AuthProvider>().isLoggedIn),
    update: (_, auth, previous) {
      final provider = previous ?? ReminderProvider();
      provider.onAuthChanged(auth.isLoggedIn);
      return provider;
    },
  ),
  ChangeNotifierProxyProvider<AuthProvider, FamilyProvider>(
    create: (context) => FamilyProvider(auth: context.read<AuthProvider>()),
    update: (_, auth, previous) {
      final provider = previous ?? FamilyProvider(auth: auth);
      provider.updateAuth(auth);
      return provider;
    },
  ),
  ChangeNotifierProxyProvider<AuthProvider, ChildProvider>(
    create: (context) => ChildProvider(auth: context.read<AuthProvider>()),
    update: (_, auth, previous) => previous ?? ChildProvider(auth: auth),
  ),
  ChangeNotifierProxyProvider2<AuthProvider, ReminderProvider, ClassProvider>(
    create: (context) => ClassProvider(
      auth: context.read<AuthProvider>(),
      reminderProvider: context.read<ReminderProvider>(),
    ),
    update: (_, auth, reminder, previous) {
      final provider =
          previous ?? ClassProvider(auth: auth, reminderProvider: reminder);
      provider.updateReminderProvider(reminder);
      return provider;
    },
  ),
  ChangeNotifierProxyProvider<ReminderProvider, LessonProvider>(
    create: (context) =>
        LessonProvider(reminderProvider: context.read<ReminderProvider>()),
    update: (_, reminder, previous) {
      final provider = previous ?? LessonProvider(reminderProvider: reminder);
      provider.updateReminderProvider(reminder);
      return provider;
    },
  ),
];
