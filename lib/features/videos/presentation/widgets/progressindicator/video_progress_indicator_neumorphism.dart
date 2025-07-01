import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Versión Neumorphism del indicador de progreso
class VideoProgressIndicatorNeumorphism extends StatefulWidget {
  final VideoPlayerController? controller;
  final double size;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;
  final VoidCallback? onPlayPausePressed;

  const VideoProgressIndicatorNeumorphism({
    required this.controller, super.key,
    this.size = 120,
    this.strokeWidth = 6,
    this.backgroundColor = const Color.fromARGB(100, 255, 255, 255),
    this.progressColor = Colors.green,
    this.onPlayPausePressed,
  });

  @override
  State<VideoProgressIndicatorNeumorphism> createState() =>
      _VideoProgressIndicatorNeumorphismState();
}

class _VideoProgressIndicatorNeumorphismState
    extends State<VideoProgressIndicatorNeumorphism>
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
  void didUpdateWidget(VideoProgressIndicatorNeumorphism oldWidget) {
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
    _currentController?.removeListener(_updateProgress);
    _currentController = widget.controller;

    if (_currentController != null) {
      _currentController!.addListener(_updateProgress);
      if (_currentController!.value.isInitialized) {
        _updateProgress();
      }
    } else {
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

      if (mounted &&
          ((_progress - newProgress).abs() > 0.005 ||
              _remainingTime != timeString)) {
        setState(() {
          _progress = newProgress;
          _remainingTime = timeString;
        });
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
          color: const Color(0xFF2A2A2A),
          boxShadow: [
            // Sombra externa (oscura) - Efecto hundido
            BoxShadow(
              color: Colors.black.withAlpha(102), // 0.4
              offset: const Offset(8, 8),
              blurRadius: 20,
              spreadRadius: 1,
            ),
            // Luz interna (clara) - Efecto elevado
            BoxShadow(
              color: Colors.white.withAlpha(26), // 0.1
              offset: const Offset(-8, -8),
              blurRadius: 20,
              spreadRadius: 1,
            ),
            // Sombra interna para profundidad
            BoxShadow(
              color: Colors.black.withAlpha(51), // 0.2
              offset: const Offset(4, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Progreso de fondo
            SizedBox(
              width: widget.size - 16,
              height: widget.size - 16,
              child: CircularProgressIndicator(
                value: 1.0,
                strokeWidth: widget.strokeWidth * 0.7,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white.withAlpha(13), // 0.05
                ),
                strokeCap: StrokeCap.round,
              ),
            ),

            // Progreso principal
            SizedBox(
              width: widget.size - 16,
              height: widget.size - 16,
              child: CircularProgressIndicator(
                value: _progress,
                strokeWidth: widget.strokeWidth * 0.7,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(widget.progressColor),
                strokeCap: StrokeCap.round,
              ),
            ),

            // Contenido central neumórfico
            Container(
              width: widget.size * 0.6,
              height: widget.size * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2A2A2A),
                boxShadow: [
                  // Sombra interna para efecto hundido
                  BoxShadow(
                    color: Colors.black.withAlpha(77), // 0.3
                    offset: const Offset(4, 4),
                    blurRadius: 8,
                  ),
                  BoxShadow(
                    color: Colors.white.withAlpha(13), // 0.05
                    offset: const Offset(-4, -4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize:
                    MainAxisSize.min, // Añadir esto para evitar el overflow
                children: [
                  // Tiempo con efecto neumórfico
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical:
                          2, // Reducir más el padding vertical para evitar overflow
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: const Color(0xFF2A2A2A),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(51), // 0.2
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                        ),
                        BoxShadow(
                          color: Colors.white.withAlpha(13), // 0.05
                          offset: const Offset(-2, -2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      _remainingTime.isNotEmpty
                          ? _remainingTime
                          : (hasController
                                ? (isInitialized ? '00:00' : 'Loading...')
                                : 'No Video'),
                      style: TextStyle(
                        color: Colors.white.withAlpha(230), // 0.9
                        fontSize: widget.size * 0.11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Icono con efecto neumórfico
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.all(isPlaying ? 6 : 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF2A2A2A),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(77), // 0.3
                          offset: const Offset(3, 3),
                          blurRadius: 6,
                        ),
                        BoxShadow(
                          color: Colors.white.withAlpha(13), // 0.05
                          offset: const Offset(-3, -3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Icon(
                      hasController
                          ? (isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded)
                          : Icons.error_outline_rounded,
                      color: widget.progressColor,
                      size: widget.size * 0.12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
