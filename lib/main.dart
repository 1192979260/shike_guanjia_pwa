import "package:shike_guanjia/models/models.dart";
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shike_guanjia/core/service_locator.dart';
import 'package:shike_guanjia/providers/providers.dart';
import 'package:shike_guanjia/screens/login/login_screen.dart';
import 'package:shike_guanjia/screens/home/home_screen.dart';
import 'package:shike_guanjia/screens/onboarding/onboarding_screen.dart';
import 'package:shike_guanjia/screens/class_detail/class_detail_screen.dart';
import 'package:shike_guanjia/screens/class_form/add_class_screen.dart';
import 'package:shike_guanjia/screens/settings/family_sharing_screen.dart';
import 'package:shike_guanjia/screens/settings/reminder_settings_screen.dart';
import 'package:shike_guanjia/screens/settings/theme_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  runApp(const ShikeGuanjiaApp());
}

class ShikeGuanjiaApp extends StatelessWidget {
  const ShikeGuanjiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: globalProviders,
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: '课时管家',
            theme: themeProvider.themeData,
            themeMode: ThemeMode.light,
            home: const _StartupGate(),
            routes: {
              '/login': (_) => const LoginScreen(),
              '/home': (_) => const HomeScreen(),
              '/family_sharing': (_) => const FamilySharingScreen(),
              '/reminder_settings': (_) => const ReminderSettingsScreen(),
              '/theme_selection': (_) => const ThemeSelectionScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/class_detail') {
                return MaterialPageRoute(
                  builder: (_) => ClassDetailScreen(
                    cls: settings.arguments as TrainingClass,
                  ),
                );
              }
              if (settings.name == '/add_class') {
                final args = settings.arguments;
                TrainingClass? editClass;
                var renew = false;
                if (args is Map) {
                  editClass = args['editClass'] as TrainingClass?;
                  renew = args['renew'] == true;
                }
                return MaterialPageRoute(
                  builder: (_) =>
                      AddClassScreen(editClass: editClass, renew: renew),
                );
              }
              return null;
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class _StartupGate extends StatelessWidget {
  const _StartupGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!auth.isLoggedIn) {
      return const LoginScreen();
    }
    if (!auth.onboardingDone) {
      return const OnboardingScreen();
    }
    return const HomeScreen();
  }
}
