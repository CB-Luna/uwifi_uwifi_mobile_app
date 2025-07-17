import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/app_logger.dart';

class AuthService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserEmail = 'user_email';
  static const String _keyHasCompletedOnboarding = 'has_completed_onboarding';
  static const String _keyLastLoginTimestamp = 'last_login_timestamp';

  /// Marcar usuario como autenticado
  Future<void> setUserLoggedIn({
    required String email,
    required bool isFirstTime,
  }) async {
    AppLogger.authInfo(
      'Setting user as logged in - Email: $email, First time: $isFirstTime',
    );

    final prefs = await SharedPreferences.getInstance();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    // Verificar si el usuario ya ha completado el onboarding anteriormente
    final hasCompletedOnboarding = prefs.getBool(_keyHasCompletedOnboarding) ?? false;
    
    await Future.wait([
      prefs.setBool(_keyIsLoggedIn, true),
      prefs.setString(_keyUserEmail, email),
      prefs.setInt(_keyLastLoginTimestamp, timestamp),
      // Solo resetear el onboarding si es la primera vez Y no lo ha completado antes
      if (isFirstTime && !hasCompletedOnboarding) prefs.setBool(_keyHasCompletedOnboarding, false),
    ]);

    AppLogger.authInfo('User login state saved successfully');
  }

  /// Verificar si el usuario está autenticado
  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    AppLogger.authInfo('User logged in status: $isLoggedIn');
    return isLoggedIn;
  }

  /// Obtener email del usuario actual
  Future<String?> getCurrentUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_keyUserEmail);
    AppLogger.authInfo('Current user email: $email');
    return email;
  }

  /// Verificar si ha completado onboarding
  Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool(_keyHasCompletedOnboarding) ?? false;
    AppLogger.onboardingInfo('Onboarding completed status: $completed');
    return completed;
  }

  /// Marcar onboarding como completado
  Future<void> setOnboardingCompleted() async {
    AppLogger.onboardingInfo('Setting onboarding as completed');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasCompletedOnboarding, true);
    AppLogger.onboardingInfo('Onboarding completion saved successfully');
  }

  /// Hacer logout y limpiar estado
  Future<void> logout() async {
    AppLogger.authInfo('Performing logout - clearing all user data');

    final prefs = await SharedPreferences.getInstance();

    await Future.wait([
      prefs.remove(_keyIsLoggedIn),
      prefs.remove(_keyUserEmail),
      prefs.remove(_keyLastLoginTimestamp),
      // NO remover onboarding status para mantener que ya lo completó
    ]);

    AppLogger.authInfo('Logout completed - user data cleared');
  }

  /// Resetear onboarding (solo para nuevos usuarios)
  Future<void> resetOnboardingForNewUser() async {
    AppLogger.onboardingInfo('Checking if onboarding reset is needed for new user');
    final prefs = await SharedPreferences.getInstance();
    
    // Verificar si el usuario ya ha completado el onboarding anteriormente
    final hasCompletedOnboarding = prefs.getBool(_keyHasCompletedOnboarding) ?? false;
    
    // Solo resetear si no lo ha completado antes
    if (!hasCompletedOnboarding) {
      AppLogger.onboardingInfo('Resetting onboarding for new user');
      await prefs.setBool(_keyHasCompletedOnboarding, false);
      AppLogger.onboardingInfo('Onboarding reset completed');
    } else {
      AppLogger.onboardingInfo('Onboarding reset skipped - user already completed it before');
    }
  }

  /// Obtener información completa del estado de autenticación
  Future<Map<String, dynamic>> getAuthState() async {
    final prefs = await SharedPreferences.getInstance();

    final state = {
      'isLoggedIn': prefs.getBool(_keyIsLoggedIn) ?? false,
      'userEmail': prefs.getString(_keyUserEmail),
      'hasCompletedOnboarding':
          prefs.getBool(_keyHasCompletedOnboarding) ?? false,
      'lastLoginTimestamp': prefs.getInt(_keyLastLoginTimestamp),
    };

    AppLogger.authInfo('Current auth state: $state');
    return state;
  }
}
