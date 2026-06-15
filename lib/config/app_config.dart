class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://shike-backend-269793-9-1252534988.sh.run.tcloudbase.com/',
  );
}
