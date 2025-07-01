import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AnimatedCoinsReward extends StatefulWidget {
  final int earnedCoins;
  final int totalCoins;
  final VoidCallback? onAnimationComplete;
  final Duration animationDuration;

  const AnimatedCoinsReward({
    required this.earnedCoins, required this.totalCoins, super.key,
    this.onAnimationComplete,
    this.animationDuration = const Duration(milliseconds: 2500),
  });

  @override
  State<AnimatedCoinsReward> createState() => _AnimatedCoinsRewardState();
}

class _AnimatedCoinsRewardState extends State<AnimatedCoinsReward>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _coinsController;
  late AnimationController _textController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<int> _coinCountAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimation();
  }

  void _setupAnimations() {
    _mainController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _coinsController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.2, curve: Curves.easeIn),
      ),
    );

    _coinCountAnimation = IntTween(begin: 0, end: widget.earnedCoins).animate(
      CurvedAnimation(parent: _coinsController, curve: Curves.easeOutCubic),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _textController, curve: Curves.elasticOut),
        );
  }

  void _startAnimation() async {
    // Vibración de feedback
    HapticFeedback.mediumImpact();

    // Iniciar animaciones en secuencia
    _mainController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _coinsController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _textController.forward();

    // Completar después de todas las animaciones
    await Future.delayed(widget.animationDuration);
    widget.onAnimationComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade400, Colors.orange.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icono de moneda animado
                  AnimatedBuilder(
                    animation: _coinsController,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Efecto de resplandor
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.yellow.withValues(alpha: 0.6),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          // Icono principal
                          Transform.rotate(
                            angle:
                                _coinsController.value *
                                6.28, // Rotación completa
                            child: Icon(
                              Icons.monetization_on,
                              size: 60,
                              color: Colors.yellow.shade700,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Contador de monedas
                  AnimatedBuilder(
                    animation: _coinCountAnimation,
                    builder: (context, child) {
                      return Text(
                        '+${_coinCountAnimation.value}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              offset: const Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 8),

                  // Texto de total
                  SlideTransition(
                    position: _slideAnimation,
                    child: Text(
                      'Total: ${widget.totalCoins} monedas',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _coinsController.dispose();
    _textController.dispose();
    super.dispose();
  }
}
