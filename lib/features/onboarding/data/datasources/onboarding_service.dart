import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class OnboardingService {
  static const String _onboardingKey = 'has_completed_onboarding';
  
  // Singleton pattern
  static final OnboardingService _instance = OnboardingService._internal();
  factory OnboardingService() => _instance;
  OnboardingService._internal();

  Future<bool> hasCompletedOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final result = prefs.getBool(_onboardingKey) ?? false;
      debugPrint('🔍 OnboardingService: hasCompletedOnboarding = $result');
      return result;
    } catch (e) {
      debugPrint('❌ OnboardingService: Error checking onboarding status: $e');
      return false;
    }
  }

  Future<void> setOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingKey, true);
      debugPrint('✅ OnboardingService: setOnboardingCompleted = true');
    } catch (e) {
      debugPrint('❌ OnboardingService: Error setting onboarding completed: $e');
    }
  }

  Future<void> resetOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Primero verificamos si la clave existe
      final exists = prefs.containsKey(_onboardingKey);
      debugPrint('🔍 OnboardingService: Onboarding key exists = $exists');
      
      // Luego la eliminamos
      await prefs.remove(_onboardingKey);
      
      // Verificamos que se haya eliminado correctamente
      final afterReset = prefs.containsKey(_onboardingKey);
      debugPrint('🔄 OnboardingService: Onboarding key removed = ${!afterReset}');
      
      // Establecemos explícitamente el valor como false para asegurarnos
      await prefs.setBool(_onboardingKey, false);
      debugPrint('🔄 OnboardingService: Onboarding explicitly set to false');
    } catch (e) {
      debugPrint('❌ OnboardingService: Error resetting onboarding: $e');
    }
  }
  
  // Método para verificar si la clave existe
  Future<bool> hasOnboardingKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final exists = prefs.containsKey(_onboardingKey);
      debugPrint('🔍 OnboardingService: hasOnboardingKey = $exists');
      return exists;
    } catch (e) {
      debugPrint('❌ OnboardingService: Error checking onboarding key: $e');
      return false;
    }
  }
}
