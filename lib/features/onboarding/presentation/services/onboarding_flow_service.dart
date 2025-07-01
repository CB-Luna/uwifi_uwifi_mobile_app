import 'package:flutter/material.dart';
import '../../data/datasources/onboarding_service.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../../core/router/app_router.dart';

class OnboardingFlowService {
  final OnboardingService _onboardingService = OnboardingService();
  
  // Singleton pattern para garantizar una única instancia
  static final OnboardingFlowService _instance = OnboardingFlowService._internal();
  factory OnboardingFlowService() => _instance;
  OnboardingFlowService._internal() {
    debugPrint('🌟 OnboardingFlowService: Singleton instance created');
  }

  // Variable para forzar la verificación del onboarding
  bool _forceOnboardingCheck = false;

  // Método para forzar la verificación del onboarding en el próximo checkOnboardingStatus
  void forceOnboardingCheck() {
    _forceOnboardingCheck = true;
    debugPrint('💡 OnboardingFlowService: Forcing onboarding check on next verification');
  }

  Future<void> handleOnboardingFlow(BuildContext context, User user) async {
    debugPrint('🔄 OnboardingFlowService: Verificando estado de onboarding para ${user.email}');
    
    // Forzar reseteo del onboarding si se ha solicitado
    if (_forceOnboardingCheck) {
      debugPrint('💡 OnboardingFlowService: Forced check detected, resetting onboarding');
      await resetOnboarding();
      _forceOnboardingCheck = false;
    }
    
    final hasCompletedOnboarding = await _onboardingService.hasCompletedOnboarding();
    debugPrint('🔄 OnboardingFlowService: hasCompletedOnboarding = $hasCompletedOnboarding');
    
    if (!hasCompletedOnboarding) {
      if (context.mounted) {
        debugPrint('🔄 OnboardingFlowService: Redirigiendo a onboarding');
        await Navigator.of(context).pushNamedAndRemoveUntil(
          AppRouter.onboarding,
          (route) => false,
          arguments: {'user': user},
        );
      }
    } else {
      if (context.mounted) {
        debugPrint('🔄 OnboardingFlowService: Onboarding completado, redirigiendo a home');
        await Navigator.of(context).pushNamedAndRemoveUntil(
          AppRouter.home,
          (route) => false,
        );
      }
    }
  }

  Future<bool> checkOnboardingStatus() async {
    // Si se ha solicitado forzar la verificación, devolvemos false
    if (_forceOnboardingCheck) {
      debugPrint('💡 OnboardingFlowService: Forced check active, returning false for onboarding status');
      _forceOnboardingCheck = false;
      return false;
    }
    
    // Verificar si la clave existe antes de obtener su valor
    final keyExists = await _onboardingService.hasOnboardingKey();
    if (!keyExists) {
      debugPrint('🔍 OnboardingFlowService: Onboarding key does not exist, returning false');
      return false;
    }
    
    final status = await _onboardingService.hasCompletedOnboarding();
    debugPrint('🔍 OnboardingFlowService: checkOnboardingStatus = $status');
    return status;
  }

  Future<void> resetOnboarding() async {
    debugPrint('🔄 OnboardingFlowService: Reseteando onboarding...');
    await _onboardingService.resetOnboarding();
    debugPrint('🔄 OnboardingFlowService: Onboarding reseteado completamente');
    
    // Forzar la verificación en el próximo checkOnboardingStatus
    forceOnboardingCheck();
  }
  
  // Método para marcar el onboarding como completado
  Future<void> completeOnboarding() async {
    debugPrint('✅ OnboardingFlowService: Marcando onboarding como completado');
    await _onboardingService.setOnboardingCompleted();
    debugPrint('✅ OnboardingFlowService: Onboarding marcado como completado');
    _forceOnboardingCheck = false; // Desactivar la verificación forzada
  }
}
