import 'package:shike_guanjia/models/models.dart';
import 'package:shike_guanjia/services/theme_preference_service.dart';

class MockThemePreferenceService implements ThemePreferenceService {
  ThemeSkin _skin;

  MockThemePreferenceService({ThemeSkin initialSkin = ThemeSkin.warm})
    : _skin = initialSkin;

  @override
  Future<ThemeSkin> getThemePreference() async => _skin;

  @override
  Future<ThemeSkin> updateThemePreference(ThemeSkin skin) async {
    _skin = skin;
    return _skin;
  }
}
