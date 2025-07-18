import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';

class BiometricPreferencesService {
  static const String _biometricEnabledKey = 'biometric_enabled';

  /// Guarda el estado de habilitación de la biometría
  Future<bool> setBiometricEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final result = await prefs.setBool(_biometricEnabledKey, enabled);
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
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool(_biometricEnabledKey);
      return enabled ?? false; // Por defecto, la biometría está deshabilitada
    } catch (e) {
      AppLogger.navError('Error al obtener preferencia de biometría: $e');
      return false;
    }
  }
}
