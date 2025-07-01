import 'package:flutter/material.dart';

class OnboardingContent extends StatefulWidget {
  final String title;
  final String description;
  final String imagePath;
  final Color? backgroundColor;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final int currentPage;
  final int totalPages;

  const OnboardingContent({
    required this.title, required this.description, required this.imagePath, super.key,
    this.backgroundColor,
    this.buttonText,
    this.onButtonPressed,
    this.currentPage = 0,
    this.totalPages = 3,
  });

  @override
  State<OnboardingContent> createState() => _OnboardingContentState();
}

class _OnboardingContentState extends State<OnboardingContent> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _imageAnimation;
  late Animation<double> _titleAnimation;
  late Animation<double> _descriptionAnimation;
  late Animation<double> _buttonAnimation;

  int? _previousPage;

  @override
  void initState() {
    super.initState();
    _previousPage = widget.currentPage;
    
    // Configurar el controlador de animación
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    // Animaciones para cada elemento con diferentes intervalos
    _imageAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));
    
    _titleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
    ));
    
    _descriptionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
    ));
    
    _buttonAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    ));
    
    // Iniciar la animación
    _animationController.forward();
  }

  @override
  void didUpdateWidget(OnboardingContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Reiniciar animaciones cuando cambia la página
    if (widget.currentPage != _previousPage) {
      _previousPage = widget.currentPage;
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/onboarding/onboardingWhite.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // Image section - con animación de fade y scale
              AnimatedBuilder(
                animation: _imageAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 0.8 + (_imageAnimation.value * 0.2),
                    child: Opacity(
                      opacity: _imageAnimation.value,
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.35,
                        child: Center(
                          child: Image.asset(
                            widget.imagePath,
                            fit: BoxFit.contain,
                            width: 250,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Title section - con animación de slide y fade
              AnimatedBuilder(
                animation: _titleAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - _titleAnimation.value)),
                    child: Opacity(
                      opacity: _titleAnimation.value,
                      child: Text(
                        widget.title,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4CAF50),
                          fontSize: 28,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Description section - con animación de fade
              AnimatedBuilder(
                animation: _descriptionAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _descriptionAnimation.value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - _descriptionAnimation.value)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          widget.description,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            height: 1.5,
                            color: const Color(0xFF14181b),
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Spacer para empujar el botón hacia abajo
              const Spacer(flex: 2),

              // Button section - con animación de scale y fade
              if (widget.buttonText != null)
                AnimatedBuilder(
                  animation: _buttonAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 0.9 + (0.1 * _buttonAnimation.value),
                      child: Opacity(
                        opacity: _buttonAnimation.value,
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 40),
                          child: ElevatedButton(
                            onPressed: widget.onButtonPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50), // Color verde
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              widget.buttonText!,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 20),

              // Pagination dots - dinámicos según la página actual
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.totalPages,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: widget.currentPage == index ? 30 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: widget.currentPage == index
                          ? const Color(0xFF4CAF50) // Verde para página actual
                          : Colors.grey.shade400, // Gris para las demás
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20), // Espacio adicional al final
            ],
          ),
        ),
      ),
    );
  }
}
