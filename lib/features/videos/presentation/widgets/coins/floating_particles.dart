import 'dart:math' as math;

import 'package:flutter/material.dart';

class FloatingParticles extends StatefulWidget {
  final int particleCount;
  final Duration duration;
  final Color particleColor;
  final double minSize;
  final double maxSize;

  const FloatingParticles({
    super.key,
    this.particleCount = 15,
    this.duration = const Duration(milliseconds: 2000),
    this.particleColor = Colors.amber,
    this.minSize = 8.0, // ✅ Aumentado de 4.0 a 8.0
    this.maxSize = 20.0, // ✅ Aumentado de 12.0 a 20.0
  });

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<FloatingParticles>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _offsetAnimations;
  late List<Animation<double>> _fadeAnimations;
  late List<ParticleData> _particles;

  @override
  void initState() {
    super.initState();
    _initializeParticles();
    _startAnimations();
  }

  void _initializeParticles() {
    final random = math.Random();
    _controllers = [];
    _offsetAnimations = [];
    _fadeAnimations = [];
    _particles = [];

    for (int i = 0; i < widget.particleCount; i++) {
      final controller = AnimationController(
        duration: widget.duration,
        vsync: this,
      );

      final startX = random.nextDouble() * 2 - 1; // -1 a 1
      final endX =
          startX +
          (random.nextDouble() * 0.5 - 0.25); // Movimiento lateral suave
      final startY = 1.0; // Empezar desde abajo
      final endY = -1.0; // Terminar arriba

      final offsetAnimation = Tween<Offset>(
        begin: Offset(startX, startY),
        end: Offset(endX, endY),
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

      final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
        ),
      );

      final particle = ParticleData(
        size:
            widget.minSize +
            random.nextDouble() * (widget.maxSize - widget.minSize),
        delay: Duration(milliseconds: random.nextInt(500)),
      );

      _controllers.add(controller);
      _offsetAnimations.add(offsetAnimation);
      _fadeAnimations.add(fadeAnimation);
      _particles.add(particle);
    }
  }

  void _startAnimations() async {
    for (int i = 0; i < _controllers.length; i++) {
      await Future.delayed(_particles[i].delay);
      if (mounted) {
        _controllers[i].forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(widget.particleCount, (index) {
        return AnimatedBuilder(
          animation: _controllers[index],
          builder: (context, child) {
            return Positioned.fill(
              child: Center(
                child: Transform.translate(
                  offset: Offset(
                    _offsetAnimations[index].value.dx *
                        MediaQuery.of(context).size.width /
                        2,
                    _offsetAnimations[index].value.dy *
                        MediaQuery.of(context).size.height /
                        2,
                  ),
                  child: Opacity(
                    opacity: _fadeAnimations[index].value,
                    child: Container(
                      width: _particles[index].size,
                      height: _particles[index].size,
                      decoration: BoxDecoration(
                        color: widget.particleColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.particleColor.withValues(alpha: 0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
}

class ParticleData {
  final double size;
  final Duration delay;

  ParticleData({required this.size, required this.delay});
}
