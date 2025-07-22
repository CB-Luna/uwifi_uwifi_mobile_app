import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';

/// Service to save and retrieve biometric authentication preferences
class BiometricPreferencesService {
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _biometricUserEmailKey = 'biometric_user_email';
  final SharedPreferences _preferences;

  BiometricPreferencesService({required SharedPreferences preferences})
      : _preferences = preferences;

  /// Saves the biometric authentication enabled state
  Future<bool> saveBiometricEnabled(bool enabled) async {
    try {
      final result = await _preferences.setBool(_biometricEnabledKey, enabled);
      AppLogger.navInfo('Biometric preference saved: $enabled');
      return result;
    } catch (e) {
      AppLogger.navError('Error saving biometric preference: $e');
      return false;
    }
  }

  /// Gets the current biometric enabled state
  Future<bool> isBiometricEnabled() async {
    try {
      final enabled = _preferences.getBool(_biometricEnabledKey);
      return enabled ?? false; // By default, biometrics are disabled
    } catch (e) {
      AppLogger.navError('Error getting biometric preference: $e');
      return false;
    }
  }
  
  /// Saves the user email for biometric authentication
  Future<bool> saveBiometricUserEmail(String email) async {
    try {
      final result = await _preferences.setString(_biometricUserEmailKey, email);
      AppLogger.navInfo('Email for biometric authentication saved: $email');
      return result;
    } catch (e) {
      AppLogger.navError('Error saving email for biometrics: $e');
      return false;
    }
  }
  
  /// Retrieves the user email for biometric authentication
  /// Returns null if not previously saved
  Future<String?> getBiometricUserEmail() async {
    try {
      final email = _preferences.getString(_biometricUserEmailKey);
      if (email != null && email.isNotEmpty) {
        AppLogger.authInfo('Email retrieved for biometric authentication: $email');
      } else {
        AppLogger.authWarning('No saved email found for biometric authentication');
      }
      return email;
    } catch (e) {
      AppLogger.navError('Error getting email for biometrics: $e');
      return null;
    }
  }
  
  /// Clears the saved email for biometric authentication
  Future<bool> clearBiometricUserEmail() async {
    try {
      final result = await _preferences.remove(_biometricUserEmailKey);
      AppLogger.authInfo('Email for biometric authentication deleted: $result');
      return result;
    } catch (e) {
      AppLogger.navError('Error deleting email for biometrics: $e');
      return false;
    }
  }
  
  /// Clears all biometric authentication preferences
  Future<void> clearBiometricPreferences() async {
    try {
      await _preferences.remove(_biometricEnabledKey);
      await _preferences.remove(_biometricUserEmailKey);
      AppLogger.navInfo('Biometric preferences deleted');
    } catch (e) {
      AppLogger.navError('Error clearing biometric preferences: $e');
    }
  }
}
