import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';

/// Servicio para guardar y recuperar las preferencias de autenticación biométrica
class BiometricPreferencesService {
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _biometricUserEmailKey = 'biometric_user_email';
  final SharedPreferences _preferences;

  BiometricPreferencesService({required SharedPreferences preferences})
      : _preferences = preferences;

  /// Guarda el estado de habilitación de la autenticación biométrica
  Future<bool> saveBiometricEnabled(bool enabled) async {
    try {
      final result = await _preferences.setBool(_biometricEnabledKey, enabled);
      AppLogger.navInfo('Preferencia de biometría guardada: $enabled');
      return result;
    } catch (e) {
      AppLogger.navError('Error al guardar preferencia de biometría: $e');
      return false;
    }
  }

  /// Obtiene el estado actual de habilitación de la biometría
  Future<bool> isBiometricEnabled() async {
    try {
      final enabled = _preferences.getBool(_biometricEnabledKey);
      return enabled ?? false; // Por defecto, la biometría está deshabilitada
    } catch (e) {
      AppLogger.navError('Error al obtener preferencia de biometría: $e');
      return false;
    }
  }
  
  /// Guarda el email del usuario para la autenticación biométrica
  Future<bool> saveBiometricUserEmail(String email) async {
    try {
      final result = await _preferences.setString(_biometricUserEmailKey, email);
      AppLogger.navInfo('Email para autenticación biométrica guardado: $email');
      return result;
    } catch (e) {
      AppLogger.navError('Error al guardar email para biometría: $e');
      return false;
    }
  }
  
  /// Recupera el email del usuario para la autenticación biométrica
  /// Retorna null si no se ha guardado previamente
  Future<String?> getBiometricUserEmail() async {
    try {
      final email = _preferences.getString(_biometricUserEmailKey);
      if (email != null && email.isNotEmpty) {
        AppLogger.authInfo('Email recuperado para autenticación biométrica: $email');
      } else {
        AppLogger.authWarning('No se encontró email guardado para autenticación biométrica');
      }
      return email;
    } catch (e) {
      AppLogger.navError('Error al obtener email para biometría: $e');
      return null;
    }
  }
  
  /// Limpia el email guardado para autenticación biométrica
  Future<bool> clearBiometricUserEmail() async {
    try {
      final result = await _preferences.remove(_biometricUserEmailKey);
      AppLogger.authInfo('Email para autenticación biométrica eliminado: $result');
      return result;
    } catch (e) {
      AppLogger.navError('Error al eliminar email para biometría: $e');
      return false;
    }
  }
  
  /// Limpia todas las preferencias de autenticación biométrica
  Future<void> clearBiometricPreferences() async {
    try {
      await _preferences.remove(_biometricEnabledKey);
      await _preferences.remove(_biometricUserEmailKey);
      AppLogger.navInfo('Preferencias de biometría eliminadas');
    } catch (e) {
      AppLogger.navError('Error al limpiar preferencias de biometría: $e');
    }
  }
}
