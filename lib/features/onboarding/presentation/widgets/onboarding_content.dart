import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_font_sizes.dart';

class OnboardingContent extends StatefulWidget {
  final String title;
  final String description;
  final String imagePath;
  final Color? backgroundColor;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final int currentPage;
  final int totalPages;
  final bool
  showImage; // Nuevo parámetro para controlar si se muestra la imagen

  const OnboardingContent({
    required this.title,
    required this.description,
    required this.imagePath,
    super.key,
    this.backgroundColor,
    this.buttonText,
    this.onButtonPressed,
    this.currentPage = 0,
    this.totalPages = 3,
    this.showImage = true, // Por defecto, mostrar la imagen
  });

  @override
  State<OnboardingContent> createState() => _OnboardingContentState();
}

class _OnboardingContentState extends State<OnboardingContent>
    with SingleTickerProviderStateMixin {
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
    _imageAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _titleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );

    _descriptionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
      ),
    );

    _buttonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

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
          // Padding optimizado para diferentes tamaños de pantalla
          padding: EdgeInsets.fromLTRB(
            24.0,
            MediaQuery.of(context).size.height * 0.08,
            24.0,
            16.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Espacio flexible al inicio que se adapta al tamaño de la pantalla
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              // Image section - con animación de fade y scale (solo si showImage es true)
              if (widget.showImage) ...[
                AnimatedBuilder(
                  animation: _imageAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 0.8 + (_imageAnimation.value * 0.2),
                      child: Opacity(
                        opacity: _imageAnimation.value,
                        child: SizedBox(
                          height:
                              MediaQuery.of(context).size.height *
                              0.25, // Reducir altura para dejar más espacio
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
              ],

              SizedBox(height: MediaQuery.of(context).size.height * 0.04),

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
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4CAF50),
                              fontSize: responsiveFontSizes.onboardingTitle(context),
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.03),

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
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                height: 1.5,
                                color: const Color(0xFF14181b),
                                fontSize: responsiveFontSizes.onboardingDescription(context),
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Espacio flexible que se adapta al tamaño de la pantalla
              SizedBox(height: MediaQuery.of(context).size.height * 0.08),

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
                              backgroundColor: const Color(
                                0xFF4CAF50,
                              ), // Color verde
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              widget.buttonText!,
                              style: TextStyle(
                                fontSize: responsiveFontSizes.buttonLarge(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.03),

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

              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ), // Espacio adicional al final
            ],
          ),
        ),
      ),
    );
  }
}
