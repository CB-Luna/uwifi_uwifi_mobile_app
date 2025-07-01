import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Widget simple y eficiente que muestra el progreso del video en un círculo
class CustomVideoProgressIndicator extends StatefulWidget {
  final VideoPlayerController? controller;
  final double size;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;
  final VoidCallback? onPlayPausePressed;

  const CustomVideoProgressIndicator({
    required this.controller, super.key,
    this.size = 120,
    this.strokeWidth = 6,
    this.backgroundColor = const Color.fromARGB(100, 255, 255, 255),
    this.progressColor = Colors.green,
    this.onPlayPausePressed,
  });

  @override
  State<CustomVideoProgressIndicator> createState() =>
      _CustomVideoProgressIndicatorState();
}

class _CustomVideoProgressIndicatorState
    extends State<CustomVideoProgressIndicator>
    with TickerProviderStateMixin {
  AnimationController? _animationController;
  double _progress = 0.0;
  String _remainingTime = '';
  VideoPlayerController? _currentController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _setupController();
  }

  @override
  void didUpdateWidget(CustomVideoProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _setupController();
    }
  }

  @override
  void dispose() {
    _currentController?.removeListener(_updateProgress);
    _animationController?.dispose();
    super.dispose();
  }

  void _setupController() {
    // Remover listener anterior
    _currentController?.removeListener(_updateProgress);

    // Configurar nuevo controller
    _currentController = widget.controller;

    if (_currentController != null) {
      // Verificar que el controlador no esté desechado antes de usarlo
      try {
        // Verificar si el controlador está desechado usando debugAssertNotDisposed
        // Si está desechado, esto lanzará una excepción
        _currentController!.addListener(() {});
        _currentController!.removeListener(() {});
        
        // Si llegamos aquí, el controlador es válido
        _currentController!.addListener(_updateProgress);
        
        // Actualizar inmediatamente si está inicializado
        if (_currentController!.value.isInitialized) {
          _updateProgress();
        }
      } catch (e) {
        // El controlador está desechado, no usarlo
        _currentController = null;
      }
    } else {
      // Reset si no hay controller
      if (mounted) {
        setState(() {
          _progress = 0.0;
          _remainingTime = '';
        });
      }
    }
  }

  void _updateProgress() {
    if (!mounted ||
        _currentController == null ||
        !_currentController!.value.isInitialized) {
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

      // ✅ Actualización directa - Eliminamos la complejidad de la bandera
      if (mounted) {
        // Solo actualizar si hay cambios significativos para evitar spam
        if ((_progress - newProgress).abs() > 0.005 ||
            _remainingTime != timeString) {
          setState(() {
            _progress = newProgress;
            _remainingTime = timeString;
          });
        }
      }
    }
  }

  void _handlePlayPause() {
    if (_currentController != null && _currentController!.value.isInitialized) {
      if (_currentController!.value.isPlaying) {
        _currentController!.pause();
      } else {
        _currentController!.play();
      }
      widget.onPlayPausePressed?.call();
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
          gradient: RadialGradient(
            colors: [
              Colors.white.withAlpha(38), // 0.15
              Colors.white.withAlpha(13), // 0.05
            ],
          ),
          border: Border.all(
            color: Colors.white.withAlpha(51),
            width: 1.5,
          ), // 0.2
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(77), // 0.3
              blurRadius: 15,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: widget.progressColor.withAlpha(51), // 0.2
              blurRadius: 20,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Fondo del progreso
            SizedBox(
              width: widget.size - 8,
              height: widget.size - 8,
              child: CircularProgressIndicator(
                value: 1.0,
                strokeWidth: widget.strokeWidth,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white.withAlpha(26), // 0.1
                ),
                strokeCap: StrokeCap.round,
              ),
            ),

            // Progreso principal con efecto neón
            SizedBox(
              width: widget.size - 8,
              height: widget.size - 8,
              child: CircularProgressIndicator(
                value: _progress,
                strokeWidth: widget.strokeWidth,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(widget.progressColor),
                strokeCap: StrokeCap.round,
              ),
            ),

            // Progreso con glow interior
            SizedBox(
              width: widget.size - 12,
              height: widget.size - 12,
              child: CircularProgressIndicator(
                value: _progress,
                strokeWidth: 2,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white.withAlpha(204), // 0.8
                ),
                strokeCap: StrokeCap.round,
              ),
            ),

            // Contenido central con glassmorphism
            Container(
              width: widget.size * 0.65,
              height: widget.size * 0.65,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withAlpha(26), // 0.1
                    Colors.white.withAlpha(13), // 0.05
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withAlpha(38), // 0.15
                ),
              ),
              // Usar ClipRect para asegurarnos de que no haya overflow
              child: ClipRect(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tiempo con efecto brillante
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 0.5,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.black.withAlpha(77), // 0.3
                        border: Border.all(
                          color: Colors.white.withAlpha(26), // 0.1
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        _remainingTime.isNotEmpty
                            ? _remainingTime
                            : (hasController
                                  ? (isInitialized ? '00:00' : 'Loading...')
                                  : 'No Video'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize:
                              widget.size * 0.10, // Reducido de 0.11 a 0.10
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          shadows: [
                            Shadow(
                              color: widget.progressColor.withAlpha(128), // 0.5
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Icono con animación suave
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: EdgeInsets.all(isPlaying ? 3 : 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            widget.progressColor.withAlpha(77), // 0.3
                            widget.progressColor.withAlpha(26), // 0.1
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white.withAlpha(51), // 0.2
                          width: 0.5,
                        ),
                      ),
                      child: Icon(
                        hasController
                            ? (isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded)
                            : Icons.error_outline_rounded,
                        color: Colors.white,
                        size: widget.size * 0.14,
                        shadows: [
                          Shadow(
                            color: Colors.black.withAlpha(77), // 0.3
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
