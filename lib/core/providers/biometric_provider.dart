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

  // Initialize biometric state
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
      AppLogger.navError('Error initializing biometrics: $e');
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
      // Check if the device supports biometrics
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      if (canCheckBiometrics && isDeviceSupported) {
        // Get available biometric types
        final availableBiometrics = await _localAuth.getAvailableBiometrics();

        // Determine the biometric type
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
      AppLogger.navError('Error verifying biometric availability: $e');
      _isAvailable = false;
    }
  }

  // We no longer need to set the context, since we don't use it

  // Enable or disable biometrics
  Future<bool> toggleBiometric(bool enable, {String? userEmail}) async {
    try {
      AppLogger.authInfo('toggleBiometric called with enable=$enable, userEmail=$userEmail');
      
      if (enable) {
        // If we're enabling, verify authentication first
        AppLogger.authInfo('Requesting biometric authentication to enable');
        final authenticated = await authenticate();
        
        if (!authenticated) {
          AppLogger.authWarning('Biometric authentication failed when enabling');
          return false;
        }
        
        AppLogger.authInfo('Biometric authentication successful when enabling');
        
        // If an email is provided, save it for biometric authentication
        if (userEmail != null) {
          AppLogger.authInfo('Saving email for biometric authentication: $userEmail');
          final emailSaved = await _preferencesService.saveBiometricUserEmail(userEmail);
          AppLogger.authInfo('Email saved successfully: $emailSaved');
        } else {
          AppLogger.authWarning('No email provided to save in biometric preferences');
        }
      } else {
        // If we're disabling, clear the saved email
        AppLogger.authInfo('Disabling biometrics, clearing saved email');
        await _preferencesService.clearBiometricUserEmail();
      }

      // Save preference
      AppLogger.authInfo('Saving biometric preference: $enable');
      final success = await _preferencesService.saveBiometricEnabled(enable);
      
      if (success) {
        _isEnabled = enable;
        notifyListeners();
        AppLogger.authInfo('Biometric preference successfully updated: $enable');
      } else {
        AppLogger.authWarning('Error saving biometric preference');
      }
      
      return success;
    } catch (e) {
      AppLogger.navError('Error changing biometric state: $e');
      return false;
    }
  }

  // Authenticate using biometrics
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
