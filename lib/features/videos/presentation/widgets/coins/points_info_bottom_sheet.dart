import 'package:flutter/material.dart';

import '../../../../../core/utils/app_logger.dart';
import '../../../domain/entities/ad.dart';
import '../../pages/video_completion_handler.dart';

/// ✅ Widget especializado para mostrar información de puntos del usuario
/// Modal bottom sheet con diseño minimalista y barra de progreso
class PointsInfoBottomSheet extends StatelessWidget {
  final Ad video;
  final int userPoints;

  const PointsInfoBottomSheet({
    required this.video,
    required this.userPoints,
    super.key,
  });

  /// Método estático para mostrar el bottom sheet
  static void show(BuildContext context, Ad video) {
    // Registrar evento en el logger
    AppLogger.videoInfo(
      '📊 Mostrando PointsInfoBottomSheet para video: ${video.id}',
    );

    // Obtener los puntos actuales del usuario
    final currentPoints = VideoCompletionHandler.currentUserPoints;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          PointsInfoBottomSheet(video: video, userPoints: currentPoints),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header con título y botón de cerrar
          Row(
            children: [
              _buildPointsIcon(),
              const SizedBox(width: 12),
              // Título y subtítulo
              Expanded(child: _buildHeaderContent()),
              // Botón de cerrar
              IconButton(
                icon: const Icon(Icons.close, color: Colors.black54),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Puntos actuales
          _buildCurrentPoints(),

          const SizedBox(height: 24),

          // Barra de progreso
          _buildProgressBar(),

          const SizedBox(height: 16),

          // Texto informativo
          _buildInfoText(),

          const SizedBox(height: 24),

          // Safe area padding at the bottom
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  // Widget para mostrar el icono de puntos
  Widget _buildPointsIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade400, Colors.orange.shade600],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.monetization_on, color: Colors.white, size: 24),
      ),
    );
  }

  // Widget para mostrar el contenido del encabezado
  Widget _buildHeaderContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'U-Wifi Points',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Gana puntos viendo videos',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  // Widget para mostrar los puntos actuales
  Widget _buildCurrentPoints() {
    return Column(
      children: [
        const Text(
          'Your current Points',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          '$userPoints',
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Widget para mostrar la barra de progreso
  Widget _buildProgressBar() {
    // Valores de ejemplo para la barra de progreso
    const maxValue = 38;
    final progress = userPoints >= maxValue ? 1.0 : userPoints / maxValue;

    return Column(
      children: [
        // Barra de progreso
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 12,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        ),
        const SizedBox(height: 8),
        // Valores de la barra
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\$0',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            Text(
              '\$10',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            Text(
              '\$20',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            Text(
              '\$$maxValue',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  // Widget para mostrar texto informativo
  Widget _buildInfoText() {
    return Text(
      'Ve más videos para ganar puntos y canjearlos por recompensas',
      style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4),
      textAlign: TextAlign.center,
    );
  }
}
