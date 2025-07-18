import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import '../../../../core/providers/biometric_provider.dart';
import '../../../../core/services/biometric_preferences_service.dart';
import '../../../../core/utils/app_logger.dart';

class BiometricAuthService {
  final LocalAuthentication _localAuth;
  final BiometricPreferencesService _preferencesService;
  final BiometricProvider? _biometricProvider;

  BiometricAuthService({
    LocalAuthentication? localAuth,
    BiometricPreferencesService? preferencesService,
    BiometricProvider? biometricProvider,
  }) : _localAuth = localAuth ?? LocalAuthentication(),
       _preferencesService = preferencesService ?? BiometricPreferencesService(),
       _biometricProvider = biometricProvider;

  Future<bool> isBiometricAvailable() async {
    try {
      // Si tenemos acceso al BiometricProvider, usarlo para verificar la disponibilidad
      if (_biometricProvider != null) {
        return _biometricProvider.isAvailable;
      }
      
      // Verificación tradicional si no tenemos el provider
      final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
      
      if (canAuthenticate) {
        AppLogger.authInfo('Biometric authentication is available');
      } else {
        AppLogger.authWarning('Biometric authentication is not available');
      }
      
      return canAuthenticate;
    } on PlatformException catch (e) {
      AppLogger.authError('Error checking biometric availability: ${e.message}');
      return false;
    }
  }
  
  /// Verifica si la biometría está habilitada en las preferencias del usuario
  Future<bool> isBiometricEnabled() async {
    try {
      // Si tenemos acceso al BiometricProvider, usarlo para verificar si está habilitado
      if (_biometricProvider != null) {
        return _biometricProvider.isEnabled;
      }
      
      // Usar el servicio de preferencias directamente si no tenemos el provider
      return await _preferencesService.isBiometricEnabled();
    } catch (e) {
      AppLogger.authError('Error checking if biometric is enabled: $e');
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      AppLogger.authInfo('Available biometrics: $availableBiometrics');
      return availableBiometrics;
    } on PlatformException catch (e) {
      AppLogger.authError('Error getting available biometrics: ${e.message}');
      return [];
    }
  }

  Future<bool> authenticate() async {
    try {
      // Verificar primero si la biometría está habilitada
      final isEnabled = await isBiometricEnabled();
      if (!isEnabled) {
        AppLogger.authWarning('Biometric authentication is not enabled in user preferences');
        return false;
      }
      
      // Si tenemos acceso al BiometricProvider, usarlo para autenticar
      if (_biometricProvider != null) {
        final authenticated = await _biometricProvider.authenticate(reason: 'Autentícate para acceder a tu cuenta');
        
        if (authenticated) {
          AppLogger.authInfo('Biometric authentication successful via provider');
        } else {
          AppLogger.authWarning('Biometric authentication failed or cancelled via provider');
        }
        
        return authenticated;
      }
      
      // Autenticación tradicional si no tenemos el provider
      final bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Autentícate para acceder a tu cuenta',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      
      if (authenticated) {
        AppLogger.authInfo('Biometric authentication successful');
      } else {
        AppLogger.authWarning('Biometric authentication failed or cancelled');
      }
      
      return authenticated;
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable) {
        AppLogger.authError('Biometric authentication not available');
      } else if (e.code == auth_error.notEnrolled) {
        AppLogger.authError('No biometrics enrolled on this device');
      } else if (e.code == auth_error.lockedOut) {
        AppLogger.authError('Biometric authentication locked out due to too many attempts');
      } else if (e.code == auth_error.permanentlyLockedOut) {
        AppLogger.authError('Biometric authentication permanently locked out');
      } else {
        AppLogger.authError('Biometric authentication error: ${e.message}');
      }
      return false;
    }
  }
}
