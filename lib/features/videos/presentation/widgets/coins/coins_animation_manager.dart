import 'package:flutter/material.dart';
import 'package:uwifiapp/core/utils/app_logger.dart';
import '../../../domain/entities/ad.dart';
import 'enhanced_coins_reward_overlay.dart';
import '../../pages/video_completion_handler.dart';

/// Manager centralizado para toda la lógica de puntos y animaciones de monedas
class CoinsAnimationManager {
  // ✅ REMOVIDO: Ya no necesitamos un sistema separado de puntos
  // Ahora usamos VideoCompletionHandler como fuente única de verdad

  /// Obtener los puntos totales actuales (delegado a VideoCompletionHandler)
  static int getTotalUserPoints() {
    return VideoCompletionHandler.currentUserPoints;
  }

  /// Cargar puntos desde almacenamiento persistente (delegado a VideoCompletionHandler)
  static Future<void> loadUserPointsFromStorage() async {
    // Delegamos la carga al VideoCompletionHandler
    await VideoCompletionHandler.loadUserPointsFromStorage();
    AppLogger.videoInfo(
      '📥 CoinsAnimationManager - Using VideoCompletionHandler points: ${VideoCompletionHandler.currentUserPoints}',
    );
  }

  /// Manejar finalización de video con puntos específicos (DELEGADO a VideoCompletionHandler)
  static void handleVideoCompletion(
    BuildContext context,
    Ad completedVideo, {
    VoidCallback? onComplete,
  }) {
    // ✅ DELEGAMOS al VideoCompletionHandler que maneja correctamente los puntos
    VideoCompletionHandler.handleVideoCompletion(
      context,
      completedVideo,
      onAnimationComplete: onComplete,
    );
  }

  /// Manejar click manual del botón de monedas (SOLO ANIMACIÓN, sin acumular)
  static void handleManualCoinsClaim(
    BuildContext context,
    Ad video, {
    VoidCallback? onComplete,
    int? customPoints,
  }) {
    final earnedPoints = customPoints ?? 10; // Valor predeterminado de 10 puntos

    // ARREGLADO: NO acumular puntos, solo mostrar animación
    AppLogger.videoInfo(
      ' Manual coins animation for video: "${video.title}" - Showing: +$earnedPoints points (NO accumulation)',
    );

    // Obtener el total actual de puntos SIN modificarlo
    final currentTotal = VideoCompletionHandler.currentUserPoints;

    // Mostrar la animación bonita con monedas PERO sin cambiar el total
    _showCoinsOverlay(
      context,
      earnedPoints,
      currentTotal, // ✅ Usar el total actual, NO incrementar
      '¡Recompensa del video!\n¡${video.title}!',
      onComplete,
    );
  }

  /// Método privado para mostrar la animación de monedas
  static void _showCoinsOverlay(
    BuildContext context,
    int earnedCoins,
    int totalCoins,
    String message,
    VoidCallback? onComplete,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (BuildContext dialogContext) {
        return EnhancedCoinsRewardOverlay(
          earnedCoins: earnedCoins,
          totalCoins: totalCoins,
          message: message,
          onComplete: () {
            Navigator.of(dialogContext).pop();
            if (onComplete != null) onComplete();
          },
        );
      },
    );
  }

  /// Mostrar animación de recompensa general
  static void showRewardAnimation(
    BuildContext context, {
    required int earnedCoins,
    required int totalCoins,
    String? customMessage,
    VoidCallback? onComplete,
  }) {
    final message = customMessage ?? '¡Felicidades!\n¡Has ganado monedas!';
    _showCoinsOverlay(context, earnedCoins, totalCoins, message, onComplete);
  }

  /// Mostrar animación específica para video completado
  static void showVideoCompletedAnimation(
    BuildContext context, {
    required int earnedCoins,
    required int totalCoins,
    VoidCallback? onComplete,
  }) {
    _showCoinsOverlay(
      context,
      earnedCoins,
      totalCoins,
      '¡Video completado!\n¡Has ganado monedas!',
      onComplete,
    );
  }

  /// Resetear puntos (delegado a VideoCompletionHandler)
  static Future<void> resetPoints() async {
    await VideoCompletionHandler.resetUserPoints();
    AppLogger.videoInfo(
      '🔄 CoinsAnimationManager - User points reset via VideoCompletionHandler',
    );
  }
}
