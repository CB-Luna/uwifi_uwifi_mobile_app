import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../../core/utils/app_logger.dart';

/// Versión Minimalista del indicador de progreso
class VideoProgressIndicatorMinimal extends StatefulWidget {
  final VideoPlayerController? controller;
  final double size;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor1;
  final Color progressColor2;
  final VoidCallback? onPlayPausePressed;

  const VideoProgressIndicatorMinimal({
    required this.controller,
    super.key,
    this.size = 120,
    this.strokeWidth = 6,
    this.backgroundColor = const Color.fromARGB(100, 255, 255, 255),
    this.progressColor1 = Colors.green,
    this.progressColor2 = Colors.deepPurple,
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
  String _remainingTime = '';
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
      AppLogger.videoWarning('⚠️ VideoProgressIndicator: Intento de configurar controlador en widget desmontado');
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
      AppLogger.videoError('❌ Error al remover listener del controlador anterior: $e');
    }

    // Verificar si el controlador es válido
    if (widget.controller == null) {
      AppLogger.videoWarning('⚠️ VideoProgressIndicator: Controlador nulo recibido');
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
        
        // Agregar listener para actualizar progreso
        _currentController!.addListener(_updateProgress);
        
        // Actualizar estado inicial
        if (_currentController!.value.isInitialized) {
          _updateProgress();
        } else {
          AppLogger.videoInfo('⏳ Controlador no inicializado todavía');
        }
      }
    } catch (e) {
      AppLogger.videoError('❌ Error al configurar nuevo controlador: $e');
    }
  }

  void _updateProgress() {
    try {
      if (_isDisposed || _currentController == null) {
        return;
      }
      
      // Verificar si el controlador sigue siendo válido
      if (!_currentController!.value.isInitialized) {
        AppLogger.videoInfo('⚠️ Controlador no inicializado en _updateProgress');
        return;
      }

      final position = _currentController!.value.position;
      final duration = _currentController!.value.duration;

      if (duration.inMilliseconds > 0) {
        final progress = position.inMilliseconds / duration.inMilliseconds;
        final remainingTime = duration - position;
        final remainingSeconds = remainingTime.inSeconds;

        final minutes = remainingSeconds ~/ 60;
        final seconds = remainingSeconds % 60;
        final timeString =
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

        final newProgress = progress.clamp(0.0, 1.0);

        if (!_isDisposed &&
            ((_progress - newProgress).abs() > 0.005 ||
                _remainingTime != timeString)) {
          setState(() {
            _progress = newProgress;
            _remainingTime = timeString;
          });
        }
      }
    } catch (e) {
      AppLogger.videoError('❌ Error en _updateProgress: $e');
      // Si hay un error, probablemente el controlador ya no es válido
      // Intentamos limpiar la referencia para evitar más errores
      if (!_isDisposed) {
        setState(() {
          _progress = 0.0;
          _remainingTime = '';
        });
      }
    }
  }

  void _handlePlayPause() {
    try {
      if (_currentController != null && _currentController!.value.isInitialized) {
        if (_currentController!.value.isPlaying) {
          AppLogger.videoInfo('⏸️ Pausando video');
          _currentController!.pause();
        } else {
          AppLogger.videoInfo('▶️ Reproduciendo video');
          _currentController!.play();
        }
        widget.onPlayPausePressed?.call();
      }
    } catch (e) {
      AppLogger.videoError('❌ Error al manejar play/pause: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasController = _currentController != null;
    final isInitialized = _currentController?.value.isInitialized ?? false;
    final isPlaying = _currentController?.value.isPlaying ?? false;

    return GestureDetector(
      onTap: _handlePlayPause,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withAlpha(102), // 0.4
          border: Border.all(
            color: Colors.white.withAlpha(26),
            width: 0.5,
          ), // 0.1
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Círculo de progreso ultra fino
            SizedBox(
              width: widget.size - 4,
              height: widget.size - 4,
              child: CircularProgressIndicator(
                value: _progress,
                strokeWidth: 1.5, // Ultra delgado
                backgroundColor: Colors.white.withAlpha(20), // 0.08
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.progressColor2,
                ),
                strokeCap: StrokeCap.round,
              ),
            ),

            // Línea de progreso adicional (más gruesa)
            SizedBox(
              width: widget.size - 8,
              height: widget.size - 8,
              child: CircularProgressIndicator(
                value: _progress,
                strokeWidth: 3,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.progressColor1, // 0.6
                ),
                strokeCap: StrokeCap.round,
              ),
            ),

            // Contenido central minimalista
            Container(
              width: widget.size * 0.7,
              height: widget.size * 0.7,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Tiempo sin decoraciones
                  Text(
                    _remainingTime.isNotEmpty
                        ? _remainingTime
                        : (hasController
                              ? (isInitialized ? '00:00' : '•••')
                              : '---'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: widget.size * 0.13,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1.5,
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 6),

                  // Icono minimalista
                  Container(
                    padding: const EdgeInsets.all(1),
                    child: Icon(
                      hasController
                          ? (isPlaying
                                ? Icons.pause_outlined
                                : Icons.play_arrow_outlined)
                          : Icons.error_outline,
                      color: Colors.white.withAlpha(230), // 0.9
                      size: widget.size * 0.16,
                    ),
                  ),
                ],
              ),
            ),

            // Punto central decorativo
            Container(
              width: 3,
              height: 3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.progressColor1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
