import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uwifiapp/core/utils/app_logger.dart';
import '../../domain/entities/ad.dart';

/// Handler for video completion and points system
class VideoCompletionHandler {
  static const String _userPointsKey = 'user_points';
  static int _currentUserPoints = 0;

  /// Load user points from local storage
  static Future<void> loadUserPointsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentUserPoints = prefs.getInt(_userPointsKey) ?? 0;
      AppLogger.videoInfo(
        '💰 User points loaded: $_currentUserPoints',
      );
    } catch (e) {
      AppLogger.videoError('❌ Error loading user points: $e');
      _currentUserPoints = 0;
    }
  }

  /// Get current user points
  static int get currentUserPoints => _currentUserPoints;

  /// Save user points to local storage
  static Future<void> _saveUserPoints() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_userPointsKey, _currentUserPoints);
      AppLogger.videoInfo('💾 Points saved: $_currentUserPoints');
    } catch (e) {
      AppLogger.videoError('❌ Error saving points: $e');
    }
  }

  /// Handle video completion and award points (ONLY ONCE)
  static Future<void> handleVideoCompletion(
    BuildContext context,
    Ad video, {
    VoidCallback? onAnimationComplete,
    int? customPoints,
  }) async {
    try {
      // Usar puntos personalizados o valor predeterminado de 10 puntos
      final pointsToAdd = customPoints ?? 10;

      // ✅ ONLY accumulate points ONCE when the video actually ends
      await _awardPoints(pointsToAdd, video.title);

      AppLogger.videoInfo(
        '🎉 Video completed: "${video.title}" - Points awarded: $pointsToAdd - Total: $_currentUserPoints',
      );

      // Show earned points animation
      if (context.mounted) {
        await _showPointsEarnedAnimation(context, pointsToAdd);
      }

      // Ejecutar callback cuando termine la animación
      onAnimationComplete?.call();
    } catch (e) {
      AppLogger.videoError('❌ Error en handleVideoCompletion: $e');
      // In case of error, execute the callback anyway
      onAnimationComplete?.call();
    }
  }

  /// Show ONLY the points animation (without accumulating)
  static Future<void> showPointsAnimation(
    BuildContext context,
    int points, {
    VoidCallback? onAnimationComplete,
  }) async {
    try {
      AppLogger.videoInfo(
        '🎬 Showing animation of $points points (without accumulating)',
      );

      // Only show animation, without accumulating points
      if (context.mounted) {
        await _showPointsEarnedAnimation(context, points);
      }

      // Ejecutar callback cuando termine la animación
      onAnimationComplete?.call();
    } catch (e) {
      AppLogger.videoError('❌ Error en showPointsAnimation: $e');
      onAnimationComplete?.call();
    }
  }

  /// Private method to accumulate points (only called once per video)
  static Future<void> _awardPoints(int points, String videoTitle) async {
    // Add points to user's total
    _currentUserPoints += points;

    // Save updated points
    await _saveUserPoints();
  }

  /// Show earned points animation
  static Future<void> _showPointsEarnedAnimation(
    BuildContext context,
    int pointsEarned,
  ) async {
    if (!context.mounted) return;

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _PointsEarnedWidget(
        points: pointsEarned,
        onAnimationComplete: () {
          overlayEntry.remove();
        },
      ),
    );

    overlay.insert(overlayEntry);

    // Wait for animation to finish
    await Future.delayed(const Duration(milliseconds: 2000));
  }

  /// Reset user points (for testing or admin functionality)
  static Future<void> resetUserPoints() async {
    _currentUserPoints = 0;
    await _saveUserPoints();
    AppLogger.videoInfo('🔄 Puntos del usuario reseteados');
  }

  /// Add points manually (for other functionalities)
  static Future<void> addPoints(int points) async {
    _currentUserPoints += points;
    await _saveUserPoints();
    AppLogger.videoInfo(
      '💰 Puntos agregados manualmente: +$points (Total: $_currentUserPoints)',
    );
  }
}

/// Animation widget to show earned points
class _PointsEarnedWidget extends StatefulWidget {
  final int points;
  final VoidCallback onAnimationComplete;

  const _PointsEarnedWidget({
    required this.points,
    required this.onAnimationComplete,
  });

  @override
  State<_PointsEarnedWidget> createState() => _PointsEarnedWidgetState();
}

class _PointsEarnedWidgetState extends State<_PointsEarnedWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Controladores de animación
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Animations
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.2).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -0.5),
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    await _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();
    _slideController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    widget.onAnimationComplete();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _scaleController,
              _fadeController,
              _slideController,
            ]),
            builder: (context, child) {
              return SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.amber, Colors.orange],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.stars,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '+${widget.points}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'points',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
