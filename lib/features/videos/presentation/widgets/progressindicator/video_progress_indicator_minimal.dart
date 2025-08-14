import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../../core/utils/app_logger.dart';

/// Versión Minimalista del indicador de progreso circular con segundos restantes
class VideoProgressIndicatorMinimal extends StatefulWidget {
  final VideoPlayerController? controller;
  final double size;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;
  final Color textColor;
  final VoidCallback? onPlayPausePressed;

  const VideoProgressIndicatorMinimal({
    required this.controller,
    super.key,
    this.size = 20,
    this.strokeWidth = 4,
    this.backgroundColor = Colors.green,
    this.progressColor = Colors.grey,
    this.textColor = Colors.white,
    this.onPlayPausePressed,
  });

  @override
  State<VideoProgressIndicatorMinimal> createState() =>
      _VideoProgressIndicatorMinimalState();
}

class _VideoProgressIndicatorMinimalState
    extends State<VideoProgressIndicatorMinimal>
    with TickerProviderStateMixin {
  AnimationController? _animationController;
  double _progress = 0.0;
  int _remainingSeconds = 0;
  VideoPlayerController? _currentController;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    AppLogger.videoInfo('🔄 VideoProgressIndicator: Inicializando');
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _setupController();
  }

  @override
  void didUpdateWidget(VideoProgressIndicatorMinimal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      AppLogger.videoInfo('🔄 VideoProgressIndicator: Controlador actualizado');
      _setupController();
    }
  }

  @override
  void dispose() {
    AppLogger.videoInfo('🚮 VideoProgressIndicator: Limpiando recursos');
    _isDisposed = true;

    // Eliminar listener de forma segura
    try {
      if (_currentController != null) {
        AppLogger.videoInfo('🔄 Removiendo listener del controlador');
        _currentController!.removeListener(_updateProgress);
        _currentController = null;
      }
    } catch (e) {
      AppLogger.videoError('❌ Error al limpiar controlador: $e');
    }

    // Limpiar controlador de animación
    try {
      if (_animationController != null) {
        _animationController!.dispose();
        _animationController = null;
      }
    } catch (e) {
      AppLogger.videoError('❌ Error al limpiar animación: $e');
    }

    super.dispose();
  }

  void _setupController() {
    // Verificar si el widget todavía está montado
    if (_isDisposed) {
      AppLogger.videoWarning(
        '⚠️ VideoProgressIndicator: Intento de configurar controlador en widget desmontado',
      );
      return;
    }

    // Paso 1: Eliminar listener anterior si existe
    try {
      if (_currentController != null) {
        AppLogger.videoInfo('🔄 Removiendo listener del controlador anterior');
        _currentController!.removeListener(_updateProgress);
        _currentController = null;
      }
    } catch (e) {
      AppLogger.videoError(
        '❌ Error al remover listener del controlador anterior: $e',
      );
    }

    // Verificar si el controlador es válido
    if (widget.controller == null) {
      AppLogger.videoWarning(
        '⚠️ VideoProgressIndicator: Controlador nulo recibido',
      );
      return;
    }

    try {
      // Verificar que el nuevo controlador no esté disposed
      bool isControllerValid = false;
      try {
        // Intentar acceder a una propiedad para verificar si está disposed
        final dataSource = widget.controller?.dataSource ?? 'unknown';
        AppLogger.videoInfo(
          '🔄 VideoProgressIndicator: Configurando controlador para $dataSource',
        );
        isControllerValid = true;
      } catch (e) {
        AppLogger.videoError('❌ El controlador ya está disposed: $e');
        return; // Salir si el controlador ya está disposed
      }

      if (isControllerValid) {
        // Asignar el nuevo controlador
        _currentController = widget.controller;
        _currentController!.addListener(_updateProgress);
        _updateProgress(); // Actualizar inmediatamente
      }
    } catch (e) {
      AppLogger.videoError('❌ Error al configurar controlador: $e');
    }
  }

  void _updateProgress() {
    // Verificar si el widget todavía está montado
    if (_isDisposed) {
      AppLogger.videoWarning(
        '⚠️ VideoProgressIndicator: Intento de actualizar progreso en widget desmontado',
      );
      return;
    }

    try {
      if (_currentController == null ||
          !_currentController!.value.isInitialized) {
        return;
      }

      final position = _currentController!.value.position;
      final duration = _currentController!.value.duration;

      // Calcular progreso
      double calculatedProgress = 0.0;
      if (duration.inMilliseconds > 0) {
        calculatedProgress = position.inMilliseconds / duration.inMilliseconds;
        calculatedProgress = calculatedProgress.clamp(0.0, 1.0);
      }

      // Calcular segundos restantes
      int secondsRemaining = 0;
      if (duration.inMilliseconds > 0) {
        final remaining = duration - position;
        secondsRemaining = remaining.inSeconds;
      }

      // Actualizar estado si ha cambiado
      if (_progress != calculatedProgress ||
          _remainingSeconds != secondsRemaining) {
        if (mounted) {
          setState(() {
            _progress = calculatedProgress;
            _remainingSeconds = secondsRemaining;
          });
        }
      }
    } catch (e) {
      AppLogger.videoError('❌ Error al actualizar progreso: $e');
    }
  }

  void _handlePlayPause() {
    try {
      if (_currentController == null) {
        AppLogger.videoInfo('⚠️ No hay controlador disponible para play/pause');
        return;
      }

      if (_currentController!.value.isPlaying) {
        _currentController!.pause();
      } else {
        _currentController!.play();
      }
      widget.onPlayPausePressed?.call();
    } catch (e) {
      AppLogger.videoError('❌ Error al manejar play/pause: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasController = _currentController != null;
    final isInitialized = _currentController?.value.isInitialized ?? false;

    return GestureDetector(
      onTap: _handlePlayPause,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.5),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Círculo de progreso
            SizedBox(
              width: widget.size,
              height: widget.size,
              child: Transform(
                // Aplicar una transformación para invertir la dirección
                alignment: Alignment.center,
                transform: Matrix4.rotationY(
                  3.14159,
                ), // Rotar en el eje Y (pi radianes)
                child: CircularProgressIndicator(
                  value: _progress,
                  strokeWidth: widget.strokeWidth,
                  backgroundColor: widget.backgroundColor,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.progressColor,
                  ),
                  strokeCap: StrokeCap.round,
                ),
              ),
            ),

            // Número de segundos restantes
            Center(
              child: Text(
                hasController && isInitialized
                    ? _remainingSeconds.toString()
                    : '0',
                style: TextStyle(
                  color: widget.textColor,
                  fontSize: widget.size * 0.5,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
