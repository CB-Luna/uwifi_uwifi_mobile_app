import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../onboarding/presentation/pages/onboarding_page.dart';
import '../../data/services/auth_service.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../pages/login_page.dart';

class AuthWrapperWidget extends StatefulWidget {
  const AuthWrapperWidget({super.key});

  @override
  State<AuthWrapperWidget> createState() => _AuthWrapperWidgetState();
}

class _AuthWrapperWidgetState extends State<AuthWrapperWidget> {
  final AuthService _authService = AuthService();
  String? _lastAuthenticatedUserId;
  int _refreshKey = 0;

  @override
  void initState() {
    super.initState();
    AppLogger.navInfo('AuthWrapper initialized');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthBloc>().add(CheckAuthStatus());
    });
  }

  void _refreshOnboardingStatus() {
    AppLogger.navInfo('Onboarding completed - refreshing status');
    setState(() {
      _refreshKey++;
    });
  }

  Future<void> _handleAuthentication(AuthAuthenticated state) async {
    final currentUserId = state.user.email;
    final isNewUser = _lastAuthenticatedUserId != currentUserId;

    AppLogger.authInfo(
      'Handling authentication - User: $currentUserId, New user: $isNewUser',
    );

    _lastAuthenticatedUserId = currentUserId;

    // Solo verificar el estado del onboarding para usuarios nuevos
    // El método resetOnboardingForNewUser ya verifica si el usuario ha completado el onboarding antes
    if (isNewUser) {
      AppLogger.onboardingInfo(
        'New user detected, checking onboarding status',
      );
      try {
        // Este método solo reseteará si el usuario no ha completado el onboarding antes
        await _authService.resetOnboardingForNewUser();
        // Actualizar el estado para que el FutureBuilder vuelva a verificar
        setState(() {
          _refreshKey++;
        });
      } catch (e) {
        AppLogger.authError('Error checking onboarding for new user: $e');
      }
    } else {
      AppLogger.authInfo('Returning user, maintaining onboarding state');
    }
  }

  void _handleUnauthentication() {
    AppLogger.authInfo('Handling user unauthentication');
    setState(() {
      _lastAuthenticatedUserId = null;
      _refreshKey = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        AppLogger.navInfo('AuthWrapper state changed: ${state.runtimeType}');

        if (state is AuthAuthenticated) {
          _handleAuthentication(state);
        } else if (state is AuthUnauthenticated) {
          _handleUnauthentication();
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          AppLogger.navInfo('Building UI for state: ${state.runtimeType}');

          if (state is AuthLoading) {
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Verificando autenticación...'),
                  ],
                ),
              ),
            );
          }

          if (state is AuthAuthenticated) {
            return _buildAuthenticatedView(state);
          }

          if (state is AuthUnauthenticated) {
            AppLogger.navInfo('Showing login page');
            return const LoginPage();
          }

          if (state is AuthError) {
            return _buildErrorView(state);
          }

          // Estado inicial - mostrar login page por defecto
          if (state is AuthInitial) {
            AppLogger.navInfo('Initial state - showing login page');
            return const LoginPage();
          }

          // Fallback - estado desconocido
          AppLogger.navError('Unknown auth state: ${state.runtimeType}');
          return const LoginPage();
        },
      ),
    );
  }

  Widget _buildAuthenticatedView(AuthAuthenticated state) {
    AppLogger.navInfo(
      'Building authenticated view for user: ${state.user.email}',
    );

    return FutureBuilder<bool>(
      key: ValueKey('onboarding_check_$_refreshKey'),
      future: _authService.hasCompletedOnboarding(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando configuración...'),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          AppLogger.navError(
            'Error checking onboarding status: ${snapshot.error}',
          );
          // En caso de error, mostrar onboarding por seguridad
          return OnboardingPage(
            key: const ValueKey('onboarding_error'),
            user: state.user,
            onCompleted: _refreshOnboardingStatus,
          );
        }

        final hasCompletedOnboarding = snapshot.data ?? false;
        AppLogger.navInfo('Onboarding completed: $hasCompletedOnboarding');

        if (!hasCompletedOnboarding) {
          AppLogger.navInfo('Showing onboarding for user');
          return OnboardingPage(
            key: const ValueKey('onboarding_main'),
            user: state.user,
            onCompleted: _refreshOnboardingStatus,
          );
        }

        AppLogger.navInfo('Showing home page for authenticated user');
        return HomePage(key: ValueKey('home_${state.loginTimestamp ?? 0}'));
      },
    );
  }

  Widget _buildErrorView(AuthError state) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error de autenticación',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<AuthBloc>().add(CheckAuthStatus());
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
