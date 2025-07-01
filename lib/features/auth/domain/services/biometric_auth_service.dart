import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import '../../../../core/utils/app_logger.dart';

class BiometricAuthService {
  final LocalAuthentication _localAuth;

  BiometricAuthService({LocalAuthentication? localAuth})
      : _localAuth = localAuth ?? LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    try {
      // Check if biometric authentication is available on the device
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
