import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/app_logger.dart';
import '../../../../../features/profile/presentation/bloc/wallet_bloc.dart';
import '../../../../../features/profile/presentation/bloc/wallet_state.dart';
import '../../../domain/entities/ad.dart';
import '../../pages/video_completion_handler.dart';

/// ✅ Specialized widget to display user points information
/// Modal bottom sheet with minimalist design and progress bar
class PointsInfoBottomSheet extends StatelessWidget {
  final Ad video;
  final int userPoints;

  const PointsInfoBottomSheet({
    required this.video,
    required this.userPoints,
    super.key,
  });

  /// Static method to show the bottom sheet
  static Future<void> show(BuildContext context, Ad video) {
    // Log event in the logger
    AppLogger.videoInfo(
      '📊 Showing PointsInfoBottomSheet for video: ${video.id}',
    );

    // Get current user points from local storage as fallback
    final localPoints = VideoCompletionHandler.currentUserPoints;

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          // Use total points from WalletBloc if available, otherwise use local points
          final totalPoints =
              state is WalletLoaded && state.customerPoints != null
              ? state.customerPoints!.totalPointsEarned
              : localPoints;

          return PointsInfoBottomSheet(video: video, userPoints: totalPoints);
        },
      ),
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
          // Header with title and close button
          Row(
            children: [
              _buildPointsIcon(),
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

          const SizedBox(height: 24),

          // Current points
          _buildCurrentPoints(),

          const SizedBox(height: 16),

          // Progress bar
          _buildProgressBar(context),

          const SizedBox(height: 16),

          // Informative text
          _buildInfoText(),

          const SizedBox(height: 24),

          // Safe area padding at the bottom
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  // Widget to display the points icon
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

  // Widget to display the header content
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
          'Earn points by watching videos',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  // Widget to display current points
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

  // Widget to display the progress bar
  Widget _buildProgressBar(BuildContext context) {
    // Calcular el progreso y estados de los círculos
    double progress = 0.0;
    bool isFirstActive = false;
    bool isSecondActive = false;
    bool isThirdActive = false;

    // Determinar qué círculos están activos basado en los puntos
    isFirstActive = userPoints >= 1000;
    isSecondActive = userPoints >= 2000;
    isThirdActive = userPoints >= 4000;

    // Calcular el progreso para la línea
    if (userPoints >= 4000) {
      progress = 1.0; // 100% de progreso
    } else if (userPoints >= 2000) {
      // Entre $20 y $38 (2000 a 4000 puntos)
      progress = 0.5 + ((userPoints - 2000) / 2000) * 0.5;
    } else if (userPoints >= 1000) {
      // Entre $10 y $20 (1000 a 2000 puntos)
      progress = 0.25 + ((userPoints - 1000) / 1000) * 0.25;
    } else {
      // Entre $0 y $10 (0 a 1000 puntos)
      progress = (userPoints / 1000) * 0.25;
    }

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Línea de conexión (background)
          Positioned(
            left: 30,
            right: 30,
            child: Container(height: 4, color: Colors.grey.shade300),
          ),
          // Línea de progreso (foreground)
          Positioned(
            left: 30,
            width: (MediaQuery.of(context).size.width - 76) * progress,
            child: Container(height: 4, color: Colors.teal),
          ),
          // Círculos de puntos
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPointCircle(
                '\$10',
                isFirstActive,
                isFirstActive ? Colors.teal : Colors.grey,
              ),
              _buildPointCircle(
                '\$20',
                isSecondActive,
                isSecondActive ? Colors.teal : Colors.grey,
              ),
              _buildPointCircle(
                '\$38',
                isThirdActive,
                isThirdActive ? Colors.teal : Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget para construir los círculos de puntos
  Widget _buildPointCircle(String value, bool isActive, Color color) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? color : Colors.grey.shade600,
        border: Border.all(
          color: isActive ? Colors.teal.shade200 : Colors.grey.shade400,
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: isActive
                ? Colors.teal.withValues(alpha: 0.3)
                : Colors.transparent,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // Widget to display informative text
  Widget _buildInfoText() {
    return Text(
      'Watch more videos to earn points and redeem them for rewards',
      style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4),
      textAlign: TextAlign.center,
    );
  }
}
