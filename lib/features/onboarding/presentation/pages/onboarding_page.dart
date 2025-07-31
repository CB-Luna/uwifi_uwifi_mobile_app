import 'package:flutter/material.dart';

import '../../../../core/utils/app_logger.dart';
import '../../../auth/domain/entities/user.dart';
import '../../data/datasources/onboarding_service.dart';
import '../widgets/onboarding_content.dart';

class OnboardingPage extends StatefulWidget {
  final User? user;
  final VoidCallback? onCompleted; // Callback para notificar cuando se complete

  const OnboardingPage({super.key, this.user, this.onCompleted});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late PageController _pageController;
  int _currentPage = 0;
  final OnboardingService _onboardingService = OnboardingService();
  bool _hasUserInteracted = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Añadir listener al controlador para monitorear cambios
    _pageController.addListener(() {
      AppLogger.onboardingInfo(
        'PageController position: ${_pageController.page}',
      );
    });

    AppLogger.onboardingInfo(
      'OnboardingPage initialized for user: ${widget.user?.email}',
    );
    AppLogger.onboardingInfo('Initial page set to 0');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    AppLogger.onboardingInfo('Next page called, current page: $_currentPage');
    AppLogger.onboardingInfo('User has interacted: $_hasUserInteracted');

    // Mark that user has interacted
    _hasUserInteracted = true;

    if (_currentPage < 2) {
      AppLogger.onboardingInfo('Moving to next page...');
      try {
        _pageController
            .nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            )
            .then((_) {
              AppLogger.onboardingInfo('NextPage animation completed');
            })
            .catchError((error) {
              AppLogger.onboardingError('Error in nextPage: $error');
              _tryAnimateToNextPage();
            });
      } catch (e) {
        AppLogger.onboardingError('Exception in nextPage: $e');
        _tryAnimateToNextPage();
      }
    } else {
      AppLogger.onboardingInfo('Finishing onboarding...');
      _finishOnboarding();
    }
  }

  void _tryAnimateToNextPage() {
    try {
      final nextPage = (_currentPage + 1).toDouble();
      AppLogger.onboardingInfo('Trying animateTo page $nextPage');
      _pageController
          .animateToPage(
            _currentPage + 1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          )
          .then((_) {
            AppLogger.onboardingInfo('AnimateToPage completed');
          })
          .catchError((error) {
            AppLogger.onboardingError('Error in animateToPage: $error');
            _manuallyUpdatePage();
          });
    } catch (e) {
      AppLogger.onboardingError('Exception in animateToPage: $e');
      _manuallyUpdatePage();
    }
  }

  void _manuallyUpdatePage() {
    // Método de último recurso: actualización manual
    setState(() {
      _currentPage += 1;
      AppLogger.onboardingInfo('Manually set page to $_currentPage');
    });
  }

  Future<void> _finishOnboarding() async {
    AppLogger.onboardingInfo(
      'Finishing onboarding for user: ${widget.user?.email}',
    );
    try {
      // Marcar el onboarding como completado
      await _onboardingService.setOnboardingCompleted();
      AppLogger.onboardingInfo('Onboarding marked as completed');

      // Notificar al AuthWrapper que el onboarding se completó
      if (widget.onCompleted != null) {
        AppLogger.onboardingInfo('Calling onCompleted callback');
        widget.onCompleted!();
      }
    } catch (e) {
      AppLogger.onboardingError('Error completing onboarding: $e');
    }
  }

  Future<void> _skipOnboarding() async {
    AppLogger.onboardingInfo(
      'Skipping onboarding for user: ${widget.user?.email}',
    );
    try {
      // Marcar el onboarding como completado
      await _onboardingService.setOnboardingCompleted();
      AppLogger.onboardingInfo('Onboarding marked as skipped/completed');

      // Notificar al AuthWrapper que el onboarding se completó
      if (widget.onCompleted != null) {
        AppLogger.onboardingInfo('Calling onCompleted callback after skip');
        widget.onCompleted!();
      }
    } catch (e) {
      AppLogger.onboardingError('Error skipping onboarding: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView content que cubre toda la pantalla
          PageView.builder(
            controller: _pageController,
            physics: const ClampingScrollPhysics(),
            itemCount: 3, // Número total de páginas
            onPageChanged: (index) {
              AppLogger.onboardingInfo('Page changed to index: $index');
              if (index != _currentPage) {
                setState(() {
                  _currentPage = index;
                });
                AppLogger.onboardingInfo(
                  'Current page updated to: $_currentPage',
                );
              }
            },
            itemBuilder: (context, index) {
              // Contenido dinámico basado en el índice
              switch (index) {
                case 0:
                  return OnboardingContent(
                    title: "It's all about U!",
                    description:
                        "Hi${widget.user?.name != null ? ' ${widget.user!.name}' : ''}! Welcome to U-wifi. Get ready to enjoy a super fast and stable connection wherever you go. Let's get started!",
                    imagePath: "assets/images/onboarding/logouwifi.png",
                    buttonText: "Continue",
                    backgroundColor: const Color(0xFF4CAF50),
                    onButtonPressed: _nextPage,
                    currentPage: _currentPage,
                  );
                case 1:
                  return OnboardingContent(
                    title: "Total control in your hand!",
                    description:
                        "Take full control of your network. Monitor your connection status, switch between networks, update passwords, and manage your devices. Everything you need to manage your network in one place.",
                    imagePath: "assets/images/onboarding/onbor2.png",
                    backgroundColor: const Color(0xFF4CAF50),
                    buttonText: "Continue",
                    onButtonPressed: _nextPage,
                    currentPage: _currentPage,
                  );
                case 2:
                  return OnboardingContent(
                    title: "Want your service for free?",
                    description:
                        "With FREE U, it's possible! Watch videos, earn points, and redeem them for free service or whatever you like best! Customize your experience and enjoy your connection to the fullest.",
                    imagePath: "assets/images/onboarding/onbor3.png",
                    backgroundColor: const Color(0xFF4CAF50),
                    buttonText: "Get Started",
                    onButtonPressed: _nextPage,
                    currentPage: _currentPage,
                  );
                default:
                  return const SizedBox.shrink();
              }
            },
          ),

          // Skip button posicionado sobre el contenido
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _skipOnboarding,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withAlpha(
                      229,
                    ), // 0.9 * 255 = 229
                    foregroundColor: Colors.grey.shade700,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Skip',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ),

          // Se eliminó el segundo conjunto de controles de navegación
        ],
      ),
    );
  }
}
