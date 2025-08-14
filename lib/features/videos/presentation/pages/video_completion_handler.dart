import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

import '../../../../core/utils/app_logger.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/ad.dart';
import '../../domain/usecases/register_media_visualization.dart';
import '../widgets/coins/coins_action_widget.dart';

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
    AppLogger.videoInfo(
      '🚨 DIAGNÓSTICO: Iniciando handleVideoCompletion para video "${video.title}" (ID: ${video.id})',
    );

    // Registrar la visualización del video en la base de datos
    AppLogger.videoInfo(
      '🚨 DIAGNÓSTICO: Registrando visualización del video en la base de datos',
    );
    await _registerMediaVisualization(context, video, customPoints ?? 10);

    try {
      // Usar puntos personalizados o valor predeterminado de 10 puntos
      final pointsToAdd = customPoints ?? 10;
      AppLogger.videoInfo('🚨 DIAGNÓSTICO: Puntos a otorgar: $pointsToAdd');

      // ✅ ONLY accumulate points ONCE when the video actually ends
      AppLogger.videoInfo('🚨 DIAGNÓSTICO: Otorgando puntos al usuario');
      await _awardPoints(pointsToAdd, video.title);

      AppLogger.videoInfo(
        '🎉 Video completed: "${video.title}" - Points awarded: $pointsToAdd - Total: $_currentUserPoints',
      );

      // Pequeña pausa para asegurar que el contexto esté listo
      // Esto es crucial para el primer video
      await Future.delayed(const Duration(milliseconds: 300));

      // Verificar si el contexto sigue siendo válido
      if (!context.mounted) {
        AppLogger.videoError(
          '❌ DIAGNÓSTICO: Contexto no válido antes de mostrar animación',
        );
        onAnimationComplete?.call();
        return;
      }

      // Mostrar animación de puntos ganados
      AppLogger.videoInfo(
        '🚨 DIAGNÓSTICO: Mostrando animación de puntos ganados',
      );

      // Usar un timeout para evitar bloqueos
      bool animationStarted = false;

      try {
        // Intentar mostrar la animación
        await _showPointsEarnedAnimation(context, pointsToAdd).timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            AppLogger.videoWarning(
              '⚠️ DIAGNÓSTICO: Timeout al mostrar animación',
            );
            if (!animationStarted) {
              onAnimationComplete?.call();
            }
            return null;
          },
        );

        animationStarted = true;
        AppLogger.videoInfo('🚨 DIAGNÓSTICO: Animación completada con éxito');
      } catch (animError) {
        AppLogger.videoError(
          '❌ DIAGNÓSTICO: Error al mostrar animación: $animError',
        );
        if (!animationStarted) {
          onAnimationComplete?.call();
        }
      }

      // Solo llamar al callback si la animación no se ha iniciado correctamente
      if (!animationStarted) {
        AppLogger.videoInfo(
          '🚨 DIAGNÓSTICO: Llamando al callback porque la animación no se inició',
        );
        onAnimationComplete?.call();
      }

      AppLogger.videoInfo(
        '🚨 DIAGNÓSTICO: Proceso de handleVideoCompletion finalizado',
      );
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
    AppLogger.videoInfo(
      '🎞️ DIAGNÓSTICO ANIMACIÓN: Iniciando _showPointsEarnedAnimation',
    );
    AppLogger.videoInfo('🎞️ - Puntos ganados: $pointsEarned');

    // Usar un completer para controlar el flujo asíncrono
    final completer = Completer<void>();

    // Verificar si el contexto es válido
    if (!context.mounted) {
      AppLogger.videoError(
        '❌ DIAGNÓSTICO ANIMACIÓN: Context no está montado, cancelando animación',
      );
      completer.complete();
      return completer.future;
    }

    // Usar WidgetsBinding para asegurar que el overlay se inserte en el momento correcto
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) {
        AppLogger.videoError(
          '❌ DIAGNÓSTICO ANIMACIÓN: Contexto no montado después de postFrameCallback',
        );
        if (!completer.isCompleted) completer.complete();
        return;
      }

      try {
        // Obtener el contexto seguro
        BuildContext safeContext = context;

        // Obtener el overlay usando el contexto seguro
        final overlay = Overlay.of(safeContext);
        AppLogger.videoInfo(
          '🎞️ DIAGNÓSTICO ANIMACIÓN: Overlay obtenido correctamente',
        );

        // Crear la entrada del overlay con máxima prioridad
        late final OverlayEntry overlayEntry;

        overlayEntry = OverlayEntry(
          maintainState:
              true, // Mantener el estado para evitar reconstrucciones
          builder: (context) {
            AppLogger.videoInfo(
              '🎞️ DIAGNÓSTICO ANIMACIÓN: Construyendo widget de animación',
            );
            return _PointsEarnedWidget(
              points: pointsEarned,
              onAnimationComplete: () {
                AppLogger.videoInfo(
                  '🎞️ DIAGNÓSTICO ANIMACIÓN: Animación completada, removiendo overlay',
                );
                // Asegurar que la entrada del overlay se elimine correctamente
                if (overlayEntry.mounted) {
                  overlayEntry.remove();
                }
                if (!completer.isCompleted) completer.complete();
              },
            );
          },
        );

        // Insertar el overlay con máxima prioridad
        overlay.insert(overlayEntry);
        AppLogger.videoInfo(
          '🎞️ DIAGNÓSTICO ANIMACIÓN: Overlay insertado correctamente',
        );

        // Animar el botón de monedas para indicar que se han ganado puntos
        AppLogger.videoInfo('💰 Animando botón de monedas');
        try {
          final coinsWidgetState = CoinsActionWidget.globalKey.currentState;
          if (coinsWidgetState != null) {
            // Iniciar la animación del botón de monedas
            coinsWidgetState.animateCoinsEarned();
            AppLogger.videoInfo('💰 Botón de monedas animado correctamente');
          } else {
            AppLogger.videoWarning(
              '⚠️ No se pudo acceder al estado del botón de monedas',
            );
          }
        } catch (e) {
          AppLogger.videoError('❌ Error al animar botón de monedas: $e');
          // Ignorar errores de animación del botón
        }

        // Timeout aumentado para asegurar que la animación tenga tiempo suficiente
        Future.delayed(const Duration(seconds: 7), () {
          if (!completer.isCompleted) {
            AppLogger.videoWarning(
              '⚠️ DIAGNÓSTICO ANIMACIÓN: Timeout en animación Lottie',
            );
            // Intentar eliminar el overlay si aún está montado
            if (overlayEntry.mounted) {
              overlayEntry.remove();
            }
            completer.complete();
          }
        });
      } catch (e) {
        AppLogger.videoError(
          '❌ DIAGNÓSTICO ANIMACIÓN: Error al mostrar animación: $e',
        );
        if (!completer.isCompleted) completer.complete();
      }
    });

    return completer.future;
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
    AppLogger.videoInfo(
      '🌟 DIAGNÓSTICO WIDGET: initState de _PointsEarnedWidget',
    );

    try {
      // Controlador para la animación Lottie
      AppLogger.videoInfo('🌟 DIAGNÓSTICO WIDGET: Creando controlador Lottie');
      _lottieController = AnimationController(
        duration: const Duration(milliseconds: 2500),
        vsync: this,
      );

      // Controlador para el desvanecimiento
      AppLogger.videoInfo('🌟 DIAGNÓSTICO WIDGET: Creando controlador Fade');
      _fadeController = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      );

      // Asegurar que la UI esté lista antes de iniciar animaciones
      // Esto es crucial para el primer video
      Future.microtask(() {
        if (mounted) {
          AppLogger.videoInfo(
            '🌟 DIAGNÓSTICO WIDGET: Iniciando animaciones en microtask',
          );
          _startAnimations();
        }
      });
    } catch (e) {
      AppLogger.videoError('❌ DIAGNÓSTICO WIDGET: Error en initState: $e');
    }
  }

  void _startAnimations() async {
    AppLogger.videoInfo('🌟 DIAGNÓSTICO ANIMACIÓN: Iniciando _startAnimations');

    try {
      // Pequeña pausa para asegurar que el widget esté completamente montado
      await Future.delayed(const Duration(milliseconds: 50));

      if (!mounted) {
        AppLogger.videoError(
          '❌ DIAGNÓSTICO ANIMACIÓN: Widget desmontado antes de iniciar animaciones',
        );
        return;
      }

      // Mostrar la animación
      AppLogger.videoInfo(
        '🌟 DIAGNÓSTICO ANIMACIÓN: Configurando visibilidad inicial',
      );
      _fadeController.value = 1.0; // Comenzar visible

      // Verificar si el dispositivo soporta vibración
      AppLogger.videoInfo(
        '🌟 DIAGNÓSTICO ANIMACIÓN: Verificando soporte de vibración',
      );
      bool? hasVibrator = await Vibration.hasVibrator();
      AppLogger.videoInfo(
        '🌟 DIAGNÓSTICO ANIMACIÓN: Soporte de vibración: ${hasVibrator == true ? "Sí" : "No"}',
      );

      if (!mounted) {
        AppLogger.videoError(
          '❌ DIAGNÓSTICO ANIMACIÓN: Widget desmontado después de verificar vibración',
        );
        return;
      }

      // Vibración inicial al mostrar la animación (patrón de monedas)
      if (hasVibrator == true) {
        try {
          AppLogger.videoInfo(
            '🌟 DIAGNÓSTICO ANIMACIÓN: Ejecutando vibración inicial',
          );
          // Patrón de vibración tipo "monedas cayendo"
          Vibration.vibrate(pattern: [0, 100, 50, 100, 50, 150]);
        } catch (e) {
          AppLogger.videoError(
            '❌ DIAGNÓSTICO ANIMACIÓN: Error en vibración inicial: $e',
          );
          // Ignorar errores de vibración
        }
      }

      // Reproducir animación Lottie
      AppLogger.videoInfo(
        '🌟 DIAGNÓSTICO ANIMACIÓN: Iniciando animación Lottie',
      );
      try {
        // Asegurar que el controlador esté en estado inicial
        _lottieController.reset();

        // Usar un timeout para evitar bloqueos
        bool animationCompleted = false;

        // Iniciar la animación
        _lottieController
            .forward()
            .then((_) {
              animationCompleted = true;
              AppLogger.videoInfo(
                '🌟 DIAGNÓSTICO ANIMACIÓN: Animación Lottie completada normalmente',
              );
            })
            .catchError((e) {
              AppLogger.videoError(
                '❌ DIAGNÓSTICO ANIMACIÓN: Error en forward de Lottie: $e',
              );
            });

        // Esperar a que la animación termine o timeout
        await Future.delayed(const Duration(milliseconds: 2500));

        if (!animationCompleted) {
          AppLogger.videoWarning(
            '⚠️ DIAGNÓSTICO ANIMACIÓN: Timeout en animación Lottie',
          );
        }

        AppLogger.videoInfo(
          '🌟 DIAGNÓSTICO ANIMACIÓN: Animación Lottie completada',
        );
      } catch (e) {
        AppLogger.videoError(
          '❌ DIAGNÓSTICO ANIMACIÓN: Error en animación Lottie: $e',
        );
      }

      if (!mounted) {
        AppLogger.videoError(
          '❌ DIAGNÓSTICO ANIMACIÓN: Widget desmontado después de animación Lottie',
        );
        return;
      }

      // Vibración final al completar la animación
      if (hasVibrator == true) {
        try {
          AppLogger.videoInfo(
            '🌟 DIAGNÓSTICO ANIMACIÓN: Ejecutando vibración final',
          );
          // Vibración final más fuerte
          Vibration.vibrate(duration: 150, amplitude: 128);
        } catch (e) {
          AppLogger.videoError(
            '❌ DIAGNÓSTICO ANIMACIÓN: Error en vibración final: $e',
          );
          // Ignorar errores de vibración
        }
      }

      if (!mounted) {
        AppLogger.videoError(
          '❌ DIAGNÓSTICO ANIMACIÓN: Widget desmontado antes del desvanecimiento',
        );
        return;
      }

      // Desvanecer al final
      AppLogger.videoInfo(
        '🌟 DIAGNÓSTICO ANIMACIÓN: Iniciando desvanecimiento',
      );
      await _fadeController.animateTo(0.0);
      AppLogger.videoInfo(
        '🌟 DIAGNÓSTICO ANIMACIÓN: Desvanecimiento completado',
      );

      if (!mounted) {
        AppLogger.videoError(
          '❌ DIAGNÓSTICO ANIMACIÓN: Widget desmontado antes de notificar finalización',
        );
        return;
      }

      // Notificar que la animación ha terminado
      AppLogger.videoInfo(
        '🌟 DIAGNÓSTICO ANIMACIÓN: Notificando finalización de animación',
      );
      widget.onAnimationComplete();
      AppLogger.videoInfo(
        '🌟 DIAGNÓSTICO ANIMACIÓN: _startAnimations completado',
      );
    } catch (e) {
      AppLogger.videoError(
        '❌ DIAGNÓSTICO ANIMACIÓN: Error general en _startAnimations: $e',
      );
      // En caso de error, notificar que la animación ha terminado para evitar bloqueos
      if (mounted) {
        widget.onAnimationComplete();
      }
    }
  }

  @override
  void dispose() {
    _lottieController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.videoInfo(
      '🌟 DIAGNÓSTICO WIDGET: Construyendo _PointsEarnedWidget',
    );

    try {
      AppLogger.videoInfo(
        '🌟 DIAGNÓSTICO WIDGET: Verificando estado de controladores',
      );
      AppLogger.videoInfo(
        '🌟 - Lottie controller status: ${_lottieController.status}',
      );
      AppLogger.videoInfo(
        '🌟 - Fade controller status: ${_fadeController.status}',
      );

      // Verificar si el asset existe
      AppLogger.videoInfo(
        '🌟 DIAGNÓSTICO WIDGET: Intentando cargar asset Lottie: assets/animations/lotties/Ucoins.json',
      );

      // Usar un widget con máxima prioridad visual para el primer video
      return Stack(
        children: [
          // Capa de fondo oscuro para mayor contraste
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(
                alpha: 0.85,
              ), // Fondo muy oscuro para mayor contraste
            ),
          ),
          // Contenido principal con animación
          Positioned.fill(
            child: Material(
              type: MaterialType
                  .transparency, // Usar transparencia para evitar conflictos
              child: Center(
                child: FadeTransition(
                  opacity: _fadeController,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animación Lottie con mayor tamaño para asegurar visibilidad
                      SizedBox(
                        width:
                            MediaQuery.of(context).size.width *
                            0.8, // Aumentado para máxima visibilidad
                        height:
                            MediaQuery.of(context).size.height *
                            0.8, // Altura controlada
                        child: Lottie.asset(
                          'assets/animations/lotties/Ucoins.json',
                          controller: _lottieController,
                          repeat:
                              true, // Forzar repetición para el primer video
                          frameRate: FrameRate.max, // Máximo framerate
                          onLoaded: (composition) {
                            AppLogger.videoInfo(
                              '🌟 DIAGNÓSTICO WIDGET: Lottie cargado correctamente',
                            );
                            // Asegurar que el controlador esté configurado correctamente
                            _lottieController.duration = composition.duration;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } catch (e) {
      AppLogger.videoError('❌ DIAGNÓSTICO WIDGET: Error en build: $e');
      // En caso de error, mostrar un widget vacío para evitar errores visuales
      return const SizedBox.shrink();
    }
  }
}
