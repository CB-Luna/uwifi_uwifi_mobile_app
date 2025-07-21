import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/biometric_preferences_service.dart';
import '../utils/app_logger.dart';

class BiometricProvider extends ChangeNotifier {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final BiometricPreferencesService _preferencesService;

  bool _isAvailable = false;
  bool _isEnabled = false;
  bool _isLoading = true;
  String _biometricType = 'Biometric Authentication';

  // Getters
  bool get isAvailable => _isAvailable;
  bool get isEnabled => _isEnabled;
  bool get isLoading => _isLoading;
  String get biometricType => _biometricType;

  // Constructor
  BiometricProvider({required SharedPreferences preferences}) : 
      _preferencesService = BiometricPreferencesService(preferences: preferences) {
    _initBiometrics();
  }

  // Inicializar el estado de la biometría
  Future<void> _initBiometrics() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Verificar disponibilidad de biometría
      await _checkBiometricAvailability();

      // Si está disponible, verificar si está habilitada
      if (_isAvailable) {
        _isEnabled = await _preferencesService.isBiometricEnabled();
      }
    } catch (e) {
      AppLogger.navError('Error al inicializar biometría: $e');
      _isAvailable = false;
      _isEnabled = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Verificar disponibilidad de biometría
  Future<void> _checkBiometricAvailability() async {
    try {
      // Verificar si el dispositivo soporta biometría
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      if (canCheckBiometrics && isDeviceSupported) {
        // Obtener tipos de biometría disponibles
        final availableBiometrics = await _localAuth.getAvailableBiometrics();

        // Determinar el tipo de biometría
        if (availableBiometrics.contains(BiometricType.face)) {
          _biometricType = 'Face ID';
        } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
          _biometricType = 'Fingerprint';
        } else if (availableBiometrics.isNotEmpty) {
          _biometricType = 'Biometric Authentication';
        }

        _isAvailable = availableBiometrics.isNotEmpty;
      } else {
        _isAvailable = false;
      }
    } catch (e) {
      AppLogger.navError('Error al verificar disponibilidad biométrica: $e');
      _isAvailable = false;
    }
  }

  // Ya no necesitamos establecer el contexto, ya que no lo usamos

  // Habilitar o deshabilitar biometría
  Future<bool> toggleBiometric(bool enable, {String? userEmail}) async {
    try {
      AppLogger.authInfo('toggleBiometric llamado con enable=$enable, userEmail=$userEmail');
      
      if (enable) {
        // Si estamos habilitando, verificar autenticación primero
        AppLogger.authInfo('Solicitando autenticación biométrica para habilitar');
        final authenticated = await authenticate();
        
        if (!authenticated) {
          AppLogger.authWarning('Autenticación biométrica fallida al habilitar');
          return false;
        }
        
        AppLogger.authInfo('Autenticación biométrica exitosa al habilitar');
        
        // Si se proporciona un email, guardarlo para autenticación biométrica
        if (userEmail != null) {
          AppLogger.authInfo('Guardando email para autenticación biométrica: $userEmail');
          final emailSaved = await _preferencesService.saveBiometricUserEmail(userEmail);
          AppLogger.authInfo('Email guardado con éxito: $emailSaved');
        } else {
          AppLogger.authWarning('No se proporcionó email para guardar en preferencias biométricas');
        }
      } else {
        // Si estamos deshabilitando, limpiar el email guardado
        AppLogger.authInfo('Deshabilitando biometría, limpiando email guardado');
        await _preferencesService.clearBiometricUserEmail();
      }

      // Guardar preferencia
      AppLogger.authInfo('Guardando preferencia biométrica: $enable');
      final success = await _preferencesService.saveBiometricEnabled(enable);
      
      if (success) {
        _isEnabled = enable;
        notifyListeners();
        AppLogger.authInfo('Preferencia biométrica actualizada con éxito: $enable');
      } else {
        AppLogger.authWarning('Error al guardar preferencia biométrica');
      }
      
      return success;
    } catch (e) {
      AppLogger.navError('Error al cambiar estado de biometría: $e');
      return false;
    }
  }

  // Autenticar usando biometría
  Future<bool> authenticate({
    String reason = 'Authenticate to continue',
  }) async {
    try {
      if (!_isAvailable) return false;

      final authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      return authenticated;
    } catch (e) {
      AppLogger.navError('Error during biometric authentication: $e');
      return false;
    }
  }
}
