import 'package:shike_guanjia/models/models.dart';
import 'package:shike_guanjia/services/http/api_client.dart';
import 'package:shike_guanjia/services/theme_preference_service.dart';

class HttpThemePreferenceService implements ThemePreferenceService {
  HttpThemePreferenceService(this._client);

  final ApiClient _client;

  @override
  Future<ThemeSkin> getThemePreference() async {
    final data = await _client.getData<Map<String, dynamic>>(
      '/api/preferences/theme',
    );
    return ThemeSkin.fromJson(data['skin'] ?? data['themeSkin']);
  }

  @override
  Future<ThemeSkin> updateThemePreference(ThemeSkin skin) async {
    final data = await _client.patchData<Map<String, dynamic>>(
      '/api/preferences/theme',
      data: {'skin': skin.toJson()},
    );
    return ThemeSkin.fromJson(data['skin'] ?? data['themeSkin']);
  }
}
