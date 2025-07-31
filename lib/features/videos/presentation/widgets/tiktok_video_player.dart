import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/utils/app_logger.dart';

/// Reproductor de video estilo TikTok con contador circular animado
class TikTokVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool isCurrentVideo;
  final VoidCallback?
  onVideoFinished; // ✅ NUEVO: Callback para cuando termina el video
  final VoidCallback?
  onMoreInfoPressed; // ✅ NUEVO: Callback para botón More Information
  final Function(VideoPlayerController?)?
  onControllerChanged; // ✅ NUEVO: Callback para exponer el controlador

  const TikTokVideoPlayer({
    required this.videoUrl, required this.isCurrentVideo, super.key,
    this.onVideoFinished, // ✅ NUEVO: Callback opcional
    this.onMoreInfoPressed, // ✅ NUEVO: Callback opcional
    this.onControllerChanged, // ✅ NUEVO: Callback para el controlador
  });

  @override
  State<TikTokVideoPlayer> createState() => _TikTokVideoPlayerState();
}

class _TikTokVideoPlayerState extends State<TikTokVideoPlayer>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  late AnimationController _progressController;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _hasFinished = false; // ✅ NUEVO: Evitar múltiples callbacks de fin

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    if (widget.isCurrentVideo) {
      _initializeVideo();
    }
  }

  @override
  void didUpdateWidget(TikTokVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Verificar si cambió la URL del video o si cambió el estado de currentVideo
    final urlChanged = widget.videoUrl != oldWidget.videoUrl;
    final currentStateChanged =
        widget.isCurrentVideo != oldWidget.isCurrentVideo;

    if (urlChanged) {
      AppLogger.videoInfo(
        '🔄 URL de video cambió: ${oldWidget.videoUrl} -> ${widget.videoUrl}',
      );
    }

    if (currentStateChanged) {
      AppLogger.videoInfo(
        '🔄 Estado de video actual cambió: ${oldWidget.isCurrentVideo} -> ${widget.isCurrentVideo}',
      );
    }

    // Si la URL cambió o ahora es el video actual, reinicializar
    if (urlChanged || (currentStateChanged && widget.isCurrentVideo)) {
      // Si el controlador ya existe, liberarlo primero
      _disposeController();

      // Solo inicializar si es el video actual
      if (widget.isCurrentVideo) {
        _initializeVideo();
      }
    } else if (currentStateChanged && !widget.isCurrentVideo) {
      // If it's no longer the current video, pause it
      _pauseVideo();
    }
  }

  // Método para liberar el controlador de forma segura
  Future<void> _disposeController() async {
    final currentController = _controller;
    if (currentController != null) {
      try {
        AppLogger.videoInfo('🚮 Liberando controlador de video anterior: ${widget.videoUrl}');

        // Primero, remover el listener para evitar callbacks después de dispose
        try {
          AppLogger.videoInfo('🎮 Removiendo listener del controlador');
          currentController.removeListener(_onVideoProgress);
        } catch (e) {
          AppLogger.videoError('⚠️ Error al remover listener: $e');
          // Continuar con el proceso de limpieza aunque falle este paso
        }

        // Pausar si está reproduciendo y está inicializado
        try {
          if (currentController.value.isInitialized && 
              currentController.value.isPlaying) {
            AppLogger.videoInfo('⏸️ Pausando video antes de liberar');
            await currentController.pause();
          }
        } catch (e) {
          AppLogger.videoError('⚠️ Error al pausar video: $e');
          // Continuar con el proceso de limpieza aunque falle este paso
        }

        // Dispose del controlador - Paso crítico
        try {
          AppLogger.videoInfo('🗑️ Ejecutando dispose() del controlador');
          await currentController.dispose();
          AppLogger.videoInfo('✅ Controlador liberado correctamente');
        } catch (e) {
          AppLogger.videoError('❌ Error crítico al hacer dispose del controlador: $e');
          // Continuar con la limpieza de referencias aunque falle el dispose
        }
      } catch (e) {
        AppLogger.videoError('❌ Error general al liberar controlador: $e');
      } finally {
        // Limpiar todas las referencias al controlador
        AppLogger.videoInfo('🧹 Limpiando referencias al controlador');
        _controller = null;

        // Notificar que el controlador cambió a null
        try {
          widget.onControllerChanged?.call(null);
        } catch (e) {
          AppLogger.videoError('⚠️ Error al notificar cambio de controlador: $e');
        }

        // Actualizar estado si el widget aún está montado
        if (mounted) {
          setState(() {
            _isInitialized = false;
            _hasError = false;
            _hasFinished = false;
          });
        }
      }
    } else {
      AppLogger.videoInfo('ℹ️ No hay controlador que liberar');
    }
  }

  Future<void> _initializeVideo() async {
    // Verificar si el widget todavía está montado antes de inicializar
    if (!mounted) {
      AppLogger.videoWarning('⚠️ Intento de inicializar video en widget desmontado');
      return;
    }
    
    // Asegurar que cualquier controlador anterior se haya liberado
    await _disposeController();
    
    try {
      AppLogger.videoInfo('🎬 Inicializando video: ${widget.videoUrl}');

      // Validar URL antes de intentar reproducir
      if (widget.videoUrl.isEmpty) {
        throw Exception('Empty video URL');
      }

      // Verificar si la URL tiene un formato válido
      Uri videoUri;
      try {
        videoUri = Uri.parse(widget.videoUrl);
        AppLogger.videoInfo('📋 Parsed URI: ${videoUri.toString()}');
        AppLogger.videoInfo('📋 URI scheme: ${videoUri.scheme}');
        AppLogger.videoInfo('📋 URI host: ${videoUri.host}');
      } catch (e) {
        AppLogger.videoError('❌ Invalid URL format: ${widget.videoUrl}', e);
        throw Exception('Invalid URL format: $e');
      }

      // Verificar que sea una URL válida (http/https)
      if (!videoUri.hasScheme ||
          (!videoUri.scheme.startsWith('http') &&
              !videoUri.scheme.startsWith('https'))) {
        AppLogger.videoError('❌ Unsupported URL scheme: ${videoUri.scheme}');
        throw Exception('Unsupported URL scheme: ${videoUri.scheme}');
      }

      // Asegurarse de que no haya un controlador existente
      await _disposeController();

      AppLogger.videoInfo(
        '🔄 Creating VideoPlayerController for: ${videoUri.toString()}',
      );
      _controller = VideoPlayerController.networkUrl(videoUri);

      AppLogger.videoInfo('⏳ Initializing video controller...');
      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _hasError = false;
          _hasFinished = false; // ✅ NUEVO: Reset flag para nuevo video
        });

        // ✅ MEJORADO: Auto-reproducir solo si es el video actual
        if (widget.isCurrentVideo) {
          _controller!.play();
          _startProgressAnimation();
        }

        // ✅ CORRECCIÓN: NO usar setLooping para evitar reinicio automático
        _controller!.setLooping(false);

        // ✅ CORRECCIÓN: Listener mejorado para el progreso
        _controller!.addListener(_onVideoProgress);

        // ✅ NUEVO: Notificar que el controlador está listo
        widget.onControllerChanged?.call(_controller);

        AppLogger.videoInfo(
          '✅ Video initialized successfully: ${widget.videoUrl}',
        );
      }
    } catch (e) {
      AppLogger.videoError('❌ Error initializing video: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isInitialized = false;
        });
        // ✅ NUEVO: Notificar error del controlador
        widget.onControllerChanged?.call(null);
      }
    }
  }

  void _onVideoProgress() {
    final currentController = _controller;
    if (currentController != null &&
        currentController.value.isInitialized &&
        mounted) {
      try {
        final position = currentController.value.position;
        final duration = currentController.value.duration;

        if (duration.inMilliseconds > 0) {
          final progress = position.inMilliseconds / duration.inMilliseconds;

          // Solo actualizar el progreso si el widget aún está montado
          if (mounted) {
            _progressController.value = progress.clamp(0.0, 1.0);
          }

          // ✅ MEJORADO: Múltiples condiciones para detectar fin de video
          final isNearEnd = progress >= 0.98;
          final hasEnded =
              currentController.value.position >=
              currentController.value.duration;
          final hasReachedEnd = position.inSeconds >= (duration.inSeconds - 1);

          if ((isNearEnd || hasEnded || hasReachedEnd) &&
              !_hasFinished &&
              mounted) {
            _hasFinished = true;
            AppLogger.videoInfo(
              '🏁 Video finished detected - Progress: ${(progress * 100).toStringAsFixed(1)}%',
            );
            _handleVideoFinished();
          }
        }
      } catch (e) {
        AppLogger.videoError('❌ Error in video progress listener: $e');
      }
    }
  }

  // ✅ NUEVO: Manejar cuando el video termina
  void _handleVideoFinished() {
    if (widget.onVideoFinished != null) {
      AppLogger.videoInfo('🏁 Video finished, advancing to next');
      widget.onVideoFinished!();
    }
  }

  void _startProgressAnimation() {
    _progressController.repeat();
  }

  void _pauseVideo() {
    final currentController = _controller;
    if (currentController != null &&
        currentController.value.isInitialized &&
        mounted) {
      try {
        currentController.pause();
        _progressController.stop();
      } catch (e) {
        AppLogger.videoError('❌ Error pausing video: $e');
      }
    }
  }

  void _togglePlayPause() {
    final currentController = _controller;
    if (currentController != null &&
        currentController.value.isInitialized &&
        mounted) {
      try {
        if (currentController.value.isPlaying) {
          currentController.pause();
          _progressController.stop();
        } else {
          currentController.play();
          _startProgressAnimation();
        }
      } catch (e) {
        AppLogger.videoError('❌ Error toggling play/pause: $e');
      }
    }
  }

  // ✅ NUEVO: Método para manejar diferentes formatos de video
  Widget _buildVideoPlayerWithFormat() {
    final currentController = _controller;
    if (currentController == null || !currentController.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    try {
      final videoSize = currentController.value.size;

      // ✅ CORRECCIÓN: Validar que las dimensiones sean válidas antes de calcular aspect ratio
      if (videoSize.width <= 0 || videoSize.height <= 0) {
        // Si las dimensiones no son válidas, usar un fallback simple
        return VideoPlayer(currentController);
      }

      final aspectRatio = videoSize.width / videoSize.height;

      // ✅ CORRECCIÓN: Validar que el aspect ratio sea válido
      if (aspectRatio <= 0 || !aspectRatio.isFinite) {
        // Si el aspect ratio no es válido, usar un fallback simple
        return VideoPlayer(currentController);
      }

      // Determinar si el video es vertical (aspect ratio menor a 1) o horizontal
      final isVerticalVideo = aspectRatio < 1.0;

      if (isVerticalVideo) {
        // Video vertical - estilo TikTok (pantalla completa)
        return FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: videoSize.width,
            height: videoSize.height,
            child: VideoPlayer(currentController),
          ),
        );
      } else {
        // Video horizontal - centrado en la pantalla
        return Center(
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: VideoPlayer(currentController),
          ),
        );
      }
    } catch (e) {
      AppLogger.videoError('❌ Error building video player widget: $e');
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.white, size: 48),
            SizedBox(height: 16),
            Text(
              'Error al mostrar el video',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    // Limpiar completamente todos los recursos
    AppLogger.videoInfo('🚮 Disposing TikTokVideoPlayer: ${widget.videoUrl}');

    // Usar el método seguro de dispose del controlador
    try {
      // Evitar que se ejecuten callbacks durante el proceso de dispose
      AppLogger.videoInfo('🔒 Bloqueando callbacks durante dispose');
      _hasError = true; // Evitar que se ejecuten callbacks de progreso
      
      // Usar el método seguro para liberar el controlador
      _disposeController().then((_) {
        AppLogger.videoInfo('✅ Controlador liberado desde dispose');
      }).catchError((error) {
        AppLogger.videoError('❌ Error al liberar controlador desde dispose: $error');
      });
    } catch (e) {
      AppLogger.videoError('❌ Error general en dispose del controlador: $e');
    }

    // Dispose del animation controller
    try {
      AppLogger.videoInfo('🔄 Liberando controlador de animación');
      _progressController.dispose();
    } catch (e) {
      AppLogger.videoError('❌ Error al liberar controlador de animación: $e');
    }

    // Limpiar todas las referencias
    try {
      AppLogger.videoInfo('🧹 Limpiando referencias finales');
      _controller = null;
      _isInitialized = false;
      _hasError = true; // Marcar como error para evitar operaciones adicionales
      _hasFinished = true;
    } catch (e) {
      AppLogger.videoError('❌ Error al limpiar referencias: $e');
    }

    AppLogger.videoInfo('🔔 Finalizando dispose de TikTokVideoPlayer');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!mounted) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: _togglePlayPause,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo negro siempre
          Container(color: Colors.black),

          // Video player - Solo mostrar cuando esté inicializado y listo
          if (_isInitialized &&
              _controller != null &&
              _controller!.value.isInitialized)
            _buildVideoPlayerWithFormat()
          else if (_hasError)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.white, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'Error al cargar el video',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            )
          else
            // Mostrar loading mientras se carga el video
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          // Indicador de reproducción/pausa en el centro
          if (_isInitialized &&
              _controller != null &&
              _controller!.value.isInitialized &&
              !_controller!.value.isPlaying)
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(16),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Painter para dibujar el progreso circular
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Fondo del círculo
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progreso del círculo
    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * 3.14159 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2, // Empezar desde arriba
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
