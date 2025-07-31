import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

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
  void didUpdateWidget(VideoProgressIndicatorMinimal oldWidget) {
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
