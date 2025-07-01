import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:math' as math;

/// Versión Gaming/Tech del indicador de progreso
class VideoProgressIndicatorGaming extends StatefulWidget {
  final VideoPlayerController? controller;
  final double size;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;
  final VoidCallback? onPlayPausePressed;

  const VideoProgressIndicatorGaming({
    required this.controller, super.key,
    this.size = 120,
    this.strokeWidth = 6,
    this.backgroundColor = const Color.fromARGB(100, 255, 255, 255),
    this.progressColor = const Color(0xFF00FF41), // Verde Matrix
    this.onPlayPausePressed,
  });

  @override
  State<VideoProgressIndicatorGaming> createState() =>
      _VideoProgressIndicatorGamingState();
}

class _VideoProgressIndicatorGamingState
    extends State<VideoProgressIndicatorGaming>
    with TickerProviderStateMixin {
  AnimationController? _animationController;
  AnimationController? _pulseController;
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
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _setupController();
  }

  @override
  void didUpdateWidget(VideoProgressIndicatorGaming oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _setupController();
    }
  }

  @override
  void dispose() {
    _currentController?.removeListener(_updateProgress);
    _animationController?.dispose();
    _pulseController?.dispose();
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

    return AnimatedBuilder(
      animation: _pulseController!,
      builder: (context, child) {
        return GestureDetector(
          onTap: _handlePlayPause,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  widget.progressColor.withAlpha(38),
                  Colors.black.withAlpha(230),
                ],
              ),
              border: Border.all(
                color: widget.progressColor.withAlpha(153),
              ),
              boxShadow: [
                // Sombra base
                BoxShadow(
                  color: Colors.black.withAlpha(128),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
                // Glow neón que pulsa
                BoxShadow(
                  color: widget.progressColor.withAlpha(
                    (77 + (_pulseController!.value * 51))
                        .round(), // 0.3 + (0.2)
                  ),
                  blurRadius: 25,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Anillos decorativos
                for (int i = 0; i < 3; i++)
                  Container(
                    width: widget.size - (i * 15),
                    height: widget.size - (i * 15),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.progressColor.withAlpha(
                          (26 - (i * 5)).clamp(5, 26),
                        ), // 0.1 - (i * 0.02)
                        width: 0.5,
                      ),
                    ),
                  ),

                // Progreso principal con efecto cyber
                SizedBox(
                  width: widget.size - 10,
                  height: widget.size - 10,
                  child: CircularProgressIndicator(
                    value: _progress,
                    strokeWidth: widget.strokeWidth,
                    backgroundColor: Colors.cyan.withAlpha(26), // 0.1
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.progressColor,
                    ),
                    strokeCap: StrokeCap.round,
                  ),
                ),

                // Progreso con glow interior
                SizedBox(
                  width: widget.size - 14,
                  height: widget.size - 14,
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

                // Contenido central cyber
                Container(
                  width: widget.size * 0.6,
                  height: widget.size * 0.6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.black.withAlpha(204), // 0.8
                        Colors.black.withAlpha(153), // 0.6
                      ],
                    ),
                    border: Border.all(
                      color: widget.progressColor.withAlpha(77), // 0.3
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Tiempo con efecto Matrix
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.black.withAlpha(179), // 0.7
                          border: Border.all(
                            color: widget.progressColor.withAlpha(128), // 0.5
                            width: 0.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.progressColor.withAlpha(77), // 0.3
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Text(
                          _remainingTime.isNotEmpty
                              ? _remainingTime
                              : (hasController
                                    ? (isInitialized ? '00:00' : '<<<>>>')
                                    : '[ERR]'),
                          style: TextStyle(
                            color: widget.progressColor,
                            fontSize: widget.size * 0.10,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'monospace',
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(
                                color: widget.progressColor.withAlpha(
                                  128,
                                ), // 0.5
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Icono cyber con animación
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.all(isPlaying ? 4 : 6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withAlpha(128), // 0.5
                          border: Border.all(
                            color: widget.progressColor.withAlpha(153), // 0.6
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.progressColor.withAlpha(102), // 0.4
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(
                          hasController
                              ? (isPlaying ? Icons.pause : Icons.play_arrow)
                              : Icons.warning,
                          color: widget.progressColor,
                          size: widget.size * 0.12,
                          shadows: [
                            Shadow(
                              color: widget.progressColor.withAlpha(204), // 0.8
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Efectos de partículas decorativas
                ...List.generate(6, (index) {
                  final angle = (index * 60.0) * (3.14159 / 180);
                  final radius = widget.size * 0.35;
                  final x =
                      radius *
                      math.cos(angle + (_pulseController!.value * 2 * 3.14159));
                  final y =
                      radius *
                      math.sin(angle + (_pulseController!.value * 2 * 3.14159));

                  return Transform.translate(
                    offset: Offset(x, y),
                    child: Container(
                      width: 2,
                      height: 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.progressColor.withAlpha(153), // 0.6
                        boxShadow: [
                          BoxShadow(
                            color: widget.progressColor.withAlpha(77), // 0.3
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
