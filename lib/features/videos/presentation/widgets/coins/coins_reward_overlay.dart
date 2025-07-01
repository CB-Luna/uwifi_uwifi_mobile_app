import 'package:flutter/material.dart';
import 'animated_coins_reward.dart';

class CoinsRewardOverlay extends StatefulWidget {
  final int earnedCoins;
  final int totalCoins;
  final String? message;
  final VoidCallback? onComplete;

  const CoinsRewardOverlay({
    required this.earnedCoins, required this.totalCoins, super.key,
    this.message,
    this.onComplete,
  });

  @override
  State<CoinsRewardOverlay> createState() => _CoinsRewardOverlayState();
}

class _CoinsRewardOverlayState extends State<CoinsRewardOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _backgroundController;
  late Animation<double> _backgroundOpacity;

  @override
  void initState() {
    super.initState();
    _setupBackgroundAnimation();
    _backgroundController.forward();
  }

  void _setupBackgroundAnimation() {
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _backgroundOpacity = Tween<double>(
      begin: 0.0,
      end: 0.8,
    ).animate(_backgroundController);
  }

  void _closeOverlay() async {
    await _backgroundController.reverse();
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Material(
          color: Colors.black.withValues(alpha: _backgroundOpacity.value),
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Mensaje de felicitación
                if (widget.message != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      widget.message!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                // Animación de monedas
                AnimatedCoinsReward(
                  earnedCoins: widget.earnedCoins,
                  totalCoins: widget.totalCoins,
                  onAnimationComplete: () {
                    Future.delayed(const Duration(milliseconds: 1000), () {
                      _closeOverlay();
                    });
                  },
                ),

                const SizedBox(height: 32),

                // Botón para cerrar
                TextButton(
                  onPressed: _closeOverlay,
                  child: const Text(
                    'Continuar',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }
}
