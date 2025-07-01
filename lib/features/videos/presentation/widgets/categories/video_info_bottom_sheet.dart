import 'package:flutter/material.dart';
import '../../../domain/entities/ad.dart';
import '../../../../../core/utils/app_logger.dart';

/// ✅ Widget especializado para mostrar información detallada del video
/// Modal bottom sheet con toda la información del anuncio
class VideoInfoBottomSheet extends StatelessWidget {
  final Ad ad;

  const VideoInfoBottomSheet({required this.ad, super.key});

  static void show(BuildContext context, Ad ad) {
    AppLogger.videoInfo('Showing video information for ad: ${ad.id}');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => VideoInfoBottomSheet(ad: ad),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(
          204,
        ), // 80% opacity for better readability
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: Colors.green.withAlpha(77), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Título principal
              Expanded(child: _buildTitle()),

              // Close icon button
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Información adicional - Now at the top as a table
          _buildAdditionalInfo(),

          const SizedBox(height: 16),

          // Partner field - Now more compact
          _buildPartner(),

          const SizedBox(height: 16),

          // Descripción - Now at the bottom
          _buildDescription(),

          // Safe area padding at the bottom
          SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      ad.title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(color: Colors.green, blurRadius: 8),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descripción:',
          style: TextStyle(
            color: Colors.green,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(30),
            borderRadius: BorderRadius.circular(8),
          ),
          width: double.infinity,
          child: Text(
            // Usando el campo overview de Supabase
            ad.overview.isNotEmpty ? ad.overview : 'Sin descripción disponible',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPartner() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detalles del video:',
          style: TextStyle(
            color: Colors.green,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(50),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withAlpha(77)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.movie_outlined,
                    color: Colors.green,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ID del video: ${ad.id}',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.category_outlined,
                    color: Colors.green,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Categoría: ${ad.genreId}',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.link_outlined,
                    color: Colors.green,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'URL: ${ad.videoUrl.length > 30 ? "${ad.videoUrl.substring(0, 30)}..." : ad.videoUrl}',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Table-like row for Video Number, Points, and Duration
        _buildTableRow(),

        const SizedBox(height: 12),

        // Prioridad
        _buildInfoRow('Prioridad:', '${ad.priority}'),
      ],
    );
  }

  // New table-like row for Video Number, Points, and Duration
  Widget _buildTableRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(50),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Video Number
          _buildTableCell('Video', '#${ad.id}'),

          // Vertical divider
          Container(
            height: 40,
            width: 1,
            color: Colors.green.withAlpha(77), // 0.3 * 255 ≈ 77
          ),

          // Points - Usando el valor real de points de Supabase
          _buildTableCell(
            'Puntos',
            '${ad.points > 0 ? ad.points : (ad.duration / 5).ceil()}',
          ),

          // Vertical divider
          Container(
            height: 40,
            width: 1,
            color: Colors.green.withAlpha(77), // 0.3 * 255 ≈ 77
          ),

          // Duration - Formateada en minutos:segundos (usando duration_video de Supabase)
          _buildTableCell(
            'Duración',
            _formatDuration(
              ad.durationVideo > 0 ? ad.durationVideo : ad.duration,
            ),
          ),
        ],
      ),
    );
  }

  // Método para formatear la duración en formato mm:ss
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Helper method for table cells
  Widget _buildTableCell(String label, String value) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.green,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
      ],
    );
  }

  // Method removed as we now use an IconButton for closing
}
