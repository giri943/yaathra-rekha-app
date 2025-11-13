class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://yaathra-rekha-app.onrender.com/api',
  );
  
  static const String googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue: '1039473962656-arg00t89p580abtlokab16muh20u7mmd.apps.googleusercontent.com',
  );
}