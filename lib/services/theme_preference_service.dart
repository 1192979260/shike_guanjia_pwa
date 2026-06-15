import 'package:shike_guanjia/models/models.dart';

abstract class ThemePreferenceService {
  Future<ThemeSkin> getThemePreference();

  Future<ThemeSkin> updateThemePreference(ThemeSkin skin);
}
