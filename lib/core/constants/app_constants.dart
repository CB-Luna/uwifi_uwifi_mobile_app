class AppConstants {
  // Supabase Configuration - Actualiza estos valores con tu configuración real
  static const String supabaseUrl =
      'https://u-supabase.virtalus.cbluna-dev.com';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.ewogICJyb2xlIjogImFub24iLAogICJpc3MiOiAic3VwYWJhc2UiLAogICJpYXQiOiAxNzE1MjM4MDAwLAogICJleHAiOiAxODczMDA0NDAwCn0.qKqYn2vjtHqKqyt1FAghuIjvNsyr9b1ElpVfvJg6zJ4';

  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userIdKey = 'user_id';

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String logoutEndpoint = '/auth/logout';

  // App Configuration
  static const String appName = 'UWifi App';
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
}
