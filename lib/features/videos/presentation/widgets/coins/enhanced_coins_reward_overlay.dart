import 'package:flutter/material.dart';
import 'animated_coins_reward.dart';
import 'floating_particles.dart';

class EnhancedCoinsRewardOverlay extends StatefulWidget {
  final int earnedCoins;
  final int totalCoins;
  final String? message;
  final VoidCallback? onComplete;

  const EnhancedCoinsRewardOverlay({
    required this.earnedCoins, required this.totalCoins, super.key,
    this.message,
    this.onComplete,
  });

  @override
  State<EnhancedCoinsRewardOverlay> createState() =>
      _EnhancedCoinsRewardOverlayState();
}

class _EnhancedCoinsRewardOverlayState extends State<EnhancedCoinsRewardOverlay>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _particlesController;
  late Animation<double> _backgroundOpacity;
  bool _showParticles = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimationSequence();
  }

  void _setupAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _particlesController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _backgroundOpacity = Tween<double>(
      begin: 0.0,
      end: 0.8,
    ).animate(_backgroundController);
  }

  void _startAnimationSequence() async {
    // Iniciar animación de fondo
    _backgroundController.forward();

    // Esperar un poco y luego mostrar partículas
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _showParticles = true;
      });
      _particlesController.forward();
    }
  }

  void _closeOverlay() async {
    setState(() {
      _showParticles = false;
    });
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
          child: Stack(
            children: [
              // Partículas de fondo
              if (_showParticles)
                const Positioned.fill(
                  child: FloatingParticles(
                    particleCount: 20,
                  ),
                ),

              // Contenido principal
              SizedBox(
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
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                offset: const Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ],
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
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: TextButton(
                        onPressed: _closeOverlay,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        child: const Text(
                          'Continuar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _particlesController.dispose();
    super.dispose();
  }
}
