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
  static void show(BuildContext context, Ad video) {
    // Log event in the logger
    AppLogger.videoInfo(
      '📊 Showing PointsInfoBottomSheet for video: ${video.id}',
    );

    // Get current user points from local storage as fallback
    final localPoints = VideoCompletionHandler.currentUserPoints;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          // Use total points from WalletBloc if available, otherwise use local points
          final totalPoints = state is WalletLoaded && state.customerPoints != null
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

          const SizedBox(height: 24),

          // Progress bar
          _buildProgressBar(),

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
  Widget _buildProgressBar() {
    // Example values for the progress bar
    const maxValue = 38;
    final progress = userPoints >= maxValue ? 1.0 : userPoints / maxValue;

    return Column(
      children: [
        // Progress bar
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
        // Bar values
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

  // Widget to display informative text
  Widget _buildInfoText() {
    return Text(
      'Watch more videos to earn points and redeem them for rewards',
      style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4),
      textAlign: TextAlign.center,
    );
  }
}
