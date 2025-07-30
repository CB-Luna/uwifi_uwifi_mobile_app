import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/utils/app_logger.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/ad.dart';
import '../../domain/usecases/register_media_visualization.dart';

/// Handler for video completion and points system
class VideoCompletionHandler {
  static const String _userPointsKey = 'user_points';
  static int _currentUserPoints = 0;

  /// Load user points from local storage
  static Future<void> loadUserPointsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentUserPoints = prefs.getInt(_userPointsKey) ?? 0;
      AppLogger.videoInfo('💰 User points loaded: $_currentUserPoints');
    } catch (e) {
      AppLogger.videoError('❌ Error loading user points: $e');
      _currentUserPoints = 0;
    }
  }

  /// Get current user points
  static int get currentUserPoints => _currentUserPoints;

  /// Save user points to local storage
  static Future<void> _saveUserPoints() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_userPointsKey, _currentUserPoints);
      AppLogger.videoInfo('💾 Points saved: $_currentUserPoints');
    } catch (e) {
      AppLogger.videoError('❌ Error saving points: $e');
    }
  }

  /// Handle video completion and award points (ONLY ONCE)
  static Future<void> handleVideoCompletion(
    BuildContext context,
    Ad video, {
    VoidCallback? onAnimationComplete,
    int? customPoints,
  }) async {
    // Registrar la visualización del video en la base de datos
    await _registerMediaVisualization(context, video, customPoints ?? 10);
    try {
      // Usar puntos personalizados o valor predeterminado de 10 puntos
      final pointsToAdd = customPoints ?? 10;

      // ✅ ONLY accumulate points ONCE when the video actually ends
      await _awardPoints(pointsToAdd, video.title);

      AppLogger.videoInfo(
        '🎉 Video completed: "${video.title}" - Points awarded: $pointsToAdd - Total: $_currentUserPoints',
      );

      // Show earned points animation
      if (context.mounted) {
        await _showPointsEarnedAnimation(context, pointsToAdd);
      }

      // Ejecutar callback cuando termine la animación
      onAnimationComplete?.call();
    } catch (e) {
      AppLogger.videoError('❌ Error en handleVideoCompletion: $e');
      // In case of error, execute the callback anyway
      onAnimationComplete?.call();
    }
  }

  /// Show ONLY the points animation (without accumulating)
  static Future<void> showPointsAnimation(
    BuildContext context,
    int points, {
    VoidCallback? onAnimationComplete,
  }) async {
    try {
      AppLogger.videoInfo(
        '🎬 Showing animation of $points points (without accumulating)',
      );

      // Only show animation, without accumulating points
      if (context.mounted) {
        await _showPointsEarnedAnimation(context, points);
      }

      // Ejecutar callback cuando termine la animación
      onAnimationComplete?.call();
    } catch (e) {
      AppLogger.videoError('❌ Error en showPointsAnimation: $e');
      onAnimationComplete?.call();
    }
  }

  /// Private method to accumulate points (only called once per video)
  static Future<void> _awardPoints(int points, String videoTitle) async {
    // Add points to user's total
    _currentUserPoints += points;

    // Save updated points
    await _saveUserPoints();
  }

  /// Registra la visualización del video en la base de datos
  static Future<void> _registerMediaVisualization(
    BuildContext context,
    Ad video,
    int pointsEarned,
  ) async {
    try {
      // Obtener el estado de autenticación actual
      final authState = context.read<AuthBloc>().state;

      // Verificar si el usuario está autenticado
      if (authState is AuthAuthenticated) {
        final user = authState.user;
        final customerId = user.customerId;

        // Verificar que los valores no sean nulos
        if (customerId == null) {
          AppLogger.videoError('❌ Error: customerId is null');
          return;
        }

        // Si customerAfiliateId es nulo, usar customerId
        final customerAfiliateId = user.customerAfiliateId ?? customerId;
        final mediaFileId = video.id;

        // Registrar la visualización usando el caso de uso
        final registerMediaVisualization =
            GetIt.instance<RegisterMediaVisualization>();
        final result = await registerMediaVisualization(
          RegisterMediaVisualizationParams(
            mediaFileId: mediaFileId,
            customerId: customerId,
            pointsEarned: pointsEarned,
            customerAfiliateId: customerAfiliateId,
          ),
        );

        result.fold(
          (failure) => AppLogger.videoError(
            '❌ Error registering media visualization: ${failure.message}',
          ),
          (success) => AppLogger.videoInfo(
            '✅ Media visualization registered successfully',
          ),
        );
      } else {
        AppLogger.videoWarning(
          '⚠️ User not authenticated, skipping media visualization registration',
        );
      }
    } catch (e) {
      AppLogger.videoError('❌ Error registering media visualization: $e');
    }
  }

  /// Show earned points animation using Lottie animation
  static Future<void> _showPointsEarnedAnimation(
    BuildContext context,
    int pointsEarned,
  ) async {
    if (!context.mounted) return;

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _PointsEarnedWidget(
        points: pointsEarned,
        onAnimationComplete: () {
          overlayEntry.remove();
        },
      ),
    );

    overlay.insert(overlayEntry);

    // Wait for animation to finish - increased duration for Lottie animation
    await Future.delayed(const Duration(milliseconds: 3000));
  }

  /// Reset user points (for testing or admin functionality)
  static Future<void> resetUserPoints() async {
    _currentUserPoints = 0;
    await _saveUserPoints();
    AppLogger.videoInfo('🔄 Puntos del usuario reseteados');
  }

  /// Add points manually (for other functionalities)
  static Future<void> addPoints(int points) async {
    _currentUserPoints += points;
    await _saveUserPoints();
    AppLogger.videoInfo(
      '💰 Puntos agregados manualmente: +$points (Total: $_currentUserPoints)',
    );
  }
}

/// Animation widget to show earned points
class _PointsEarnedWidget extends StatefulWidget {
  final int points;
  final VoidCallback onAnimationComplete;

  const _PointsEarnedWidget({
    required this.points,
    required this.onAnimationComplete,
  });

  @override
  State<_PointsEarnedWidget> createState() => _PointsEarnedWidgetState();
}

class _PointsEarnedWidgetState extends State<_PointsEarnedWidget>
    with TickerProviderStateMixin {
  late AnimationController _lottieController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();

    // Controlador para la animación Lottie
    _lottieController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Controlador para el desvanecimiento
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Iniciar animaciones
    _startAnimations();
  }

  void _startAnimations() async {
    // Mostrar la animación
    _fadeController.value = 1.0; // Comenzar visible
    await _lottieController.forward(); // Reproducir animación Lottie

    // Desvanecer al final
    await _fadeController.animateTo(0.0);

    // Notificar que la animación ha terminado
    widget.onAnimationComplete();
  }

  @override
  void dispose() {
    _lottieController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: FadeTransition(
            opacity: _fadeController,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animación Lottie
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: Lottie.asset(
                    'assets/animations/lotties/Ucoins.json',
                    controller: _lottieController,
                    fit: BoxFit.contain,
                    animate: true,
                    repeat: false,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
