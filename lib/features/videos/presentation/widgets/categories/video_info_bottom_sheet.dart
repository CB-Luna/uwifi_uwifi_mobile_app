import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/utils/app_logger.dart';
import '../../../domain/entities/ad.dart';

/// ✅ Specialized widget to display detailed video information
/// Modal bottom sheet with minimalist design and button to visit URL
class VideoInfoBottomSheet extends StatelessWidget {
  final Ad ad;

  const VideoInfoBottomSheet({required this.ad, super.key});

  static Future<void> show(BuildContext context, Ad ad) {
    AppLogger.videoInfo('Showing video information for ad: ${ad.id}');

    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => VideoInfoBottomSheet(ad: ad),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with logo/avatar and close button
          Row(
            children: [
              // Logo/Avatar
              _buildAvatar(),
              const SizedBox(width: 12),
              // Title and subtitle
              Expanded(child: _buildHeaderContent()),
              // Close button
              IconButton(
                icon: const Icon(Icons.close, color: Colors.black54),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Description message
          _buildMessage(),

          const SizedBox(height: 24),

          // Visit URL button
          _buildVisitUrlButton(context),

          // Safe area padding at the bottom
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  // Widget to display the avatar/logo
  Widget _buildAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.green,
        shape: BoxShape.circle,
        image: ad.thumbnailUrl != null
            ? DecorationImage(
                image: NetworkImage(ad.thumbnailUrl!),
                fit: BoxFit.cover,
              )
            : const DecorationImage(
                image: AssetImage('assets/images/homeimage/launcher.png'),
                fit: BoxFit.cover,
              ),
      ),
      child: ad.thumbnailUrl == null
          ? const Center(
              child: Icon(Icons.play_arrow, color: Colors.white, size: 24),
            )
          : null,
    );
  }

  // Widget to display title and subtitle
  Widget _buildHeaderContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Nombre de la plataforma
        Row(
          children: [
            Flexible(
              child: Text(
                ad.metadata?.partner ??
                    'U-Wifi', // Valor fijo ya que partner ya no existe
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            // Verification badge icon
            Container(
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '• ${_formatDuration(ad.metadata?.durationSeconds ?? 0)}', // Ya no mostramos la duración porque durationVideo y duration ya no existen
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  // Widget to display the main message
  Widget _buildMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ad.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          ad.description, // Usamos solo description ya que overview ya no existe
          style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.4),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  // Widget for the visit URL button
  Widget _buildVisitUrlButton(BuildContext context) {
    // Usamos el campo videoUrl como alternativa ya que urlAd ya no existe
    final hasUrl = ad.metadata?.urlAd != null;
    return Visibility(
      visible: hasUrl,
      child: SizedBox(
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Shimmer(
            colorOpacity: 0.4,
            duration: const Duration(seconds: 2),
            child: ElevatedButton(
              onPressed: () async {
                // Make sure the URL has the correct format
                String urlString = ad.metadata!.urlAd!;
                if (!urlString.startsWith('http://') &&
                    !urlString.startsWith('https://')) {
                  urlString = 'https://$urlString';
                }

                try {
                  final url = Uri.parse(urlString);
                  // Use launchUrl with specific options to ensure it opens in the external browser
                  await launchUrl(
                    url,
                    mode: LaunchMode.externalApplication,
                  ).then((success) {
                    if (!success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not open URL')),
                      );
                    }
                  });
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error opening URL: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Visit URL',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // El método _formatDuration ha sido eliminado ya que ya no se usa
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')} min';
  }
}
