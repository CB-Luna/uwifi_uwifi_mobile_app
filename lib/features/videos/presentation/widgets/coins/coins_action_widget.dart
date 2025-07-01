import 'package:flutter/material.dart';
import '../../../domain/entities/ad.dart';
import 'coins_animation_manager.dart';

/// Widget que maneja la funcionalidad de puntos/monedas con animaciones de gaming
class CoinsActionWidget extends StatefulWidget {
  final Ad video;
  final VoidCallback? onCoinsEarned;
  final int? currentUserPoints;

  const CoinsActionWidget({
    required this.video,
    super.key,
    this.onCoinsEarned,
    this.currentUserPoints,
  });

  @override
  State<CoinsActionWidget> createState() => _CoinsActionWidgetState();
}

class _CoinsActionWidgetState extends State<CoinsActionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: _isProcessing ? null : () => _handleCoins(context),
            onTapDown: (_) => _animationController.forward(),
            onTapUp: (_) => _animationController.reverse(),
            onTapCancel: () => _animationController.reverse(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: _isProcessing
                    ? LinearGradient(
                        colors: [Colors.grey.shade400, Colors.grey.shade600],
                      )
                    : LinearGradient(
                        colors: [Colors.amber.shade400, Colors.orange.shade600],
                      ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (_isProcessing ? Colors.grey : Colors.amber)
                        .withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                _isProcessing ? Icons.hourglass_empty : Icons.monetization_on,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleCoins(BuildContext context) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    // ✅ USAR la lógica centralizada del CoinsAnimationManager
    CoinsAnimationManager.handleManualCoinsClaim(
      context,
      widget
          .video, // Pasamos el video completo para usar sus puntos específicos
      onComplete: () {
        setState(() {
          _isProcessing = false;
        });
        // Callback opcional para notificar que se ganaron monedas
        widget.onCoinsEarned?.call();
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
