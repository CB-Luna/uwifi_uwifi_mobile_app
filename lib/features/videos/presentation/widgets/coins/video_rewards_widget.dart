import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'animated_points_button.dart';
import 'coins_animation_manager.dart';
import '../../bloc/videos_bloc.dart';
import '../../bloc/videos_state.dart';
import '../../../domain/entities/ad.dart';

class VideoRewardsWidget extends StatefulWidget {
  final Ad video;
  final Function(int points)? onPointsAwarded;

  const VideoRewardsWidget({
    required this.video,
    super.key,
    this.onPointsAwarded,
  });

  @override
  State<VideoRewardsWidget> createState() => _VideoRewardsWidgetState();
}

class _VideoRewardsWidgetState extends State<VideoRewardsWidget> {
  bool _isAnimating = false;
  int _currentPoints = 0;
  bool _hasWatchedVideo = false;

  @override
  void initState() {
    super.initState();
    // Obtener puntos actuales del estado
    final videosState = context.read<VideosBloc>().state;
    if (videosState is VideosLoadedState) {
      _currentPoints = videosState.userPoints ?? 0;
    }
  }

  void _handleVideoCompleted() {
    if (_isAnimating || _hasWatchedVideo) return;

    setState(() {
      _isAnimating = true;
      _hasWatchedVideo = true;
    });

    // Calcular puntos basado en el video
    final videoPoints = _calculatePoints();

    // Simular delay del final del video
    Future.delayed(const Duration(milliseconds: 500), () {
      // Check if the widget is still mounted before using context
      if (!mounted) return;

      final newTotal = _currentPoints + videoPoints;

      CoinsAnimationManager.showVideoCompletedAnimation(
        context,
        earnedCoins: videoPoints,
        totalCoins: newTotal,
        onComplete: () {
          if (!mounted) return;
          setState(() {
            _currentPoints = newTotal;
            _isAnimating = false;
          });
          widget.onPointsAwarded?.call(videoPoints);
        },
      );
    });
  }

  /// Calcula los puntos basado en un valor fijo
  int _calculatePoints() {
    // Ahora usamos un valor fijo de puntos ya que los campos views y duration ya no existen
    const basePoints = 10;
    
    // Ya no calculamos bonificaciones basadas en vistas o duración
    return basePoints;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VideosBloc, VideosState>(
      listener: (context, state) {
        if (state is VideosLoadedState) {
          setState(() {
            _currentPoints = state.userPoints ?? 0;
          });
        }
      },
      child: Column(
        children: [
          // Botón de puntos animado
          AnimatedPointsButton(
            currentPoints: _currentPoints,
            isAnimating: _isAnimating,
            onTap: () {
              // Mostrar información de puntos o navegar a perfil
              _showPointsInfo();
            },
          ),
          const SizedBox(height: 16),

          // Botón para simular completar video (solo para testing)
          if (!_hasWatchedVideo)
            ElevatedButton.icon(
              onPressed: _handleVideoCompleted,
              icon: const Icon(Icons.play_circle_fill),
              label: Text('Ganar ${_calculatePoints()} pts'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

          // Indicador de video completado
          if (_hasWatchedVideo)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Video completado',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showPointsInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.stars, color: Colors.amber),
            SizedBox(width: 8),
            Text('Mis Puntos'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Puntos actuales: $_currentPoints',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              '• Completa videos para ganar puntos\n'
              '• Los puntos se basan en vistas y duración\n'
              '• Usa tus puntos para desbloquear contenido',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
