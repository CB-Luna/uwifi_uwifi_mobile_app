import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/services/biometric_preferences_service.dart';
import '../../../../injection_container.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/services/biometric_auth_service.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/logout_user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser loginUser;
  final LogoutUser logoutUser;
  final GetCurrentUser getCurrentUser;
  final BiometricAuthService biometricAuthService;
  final AuthRepository authRepository;

  AuthBloc({
    required this.loginUser,
    required this.logoutUser,
    required this.getCurrentUser,
    required this.biometricAuthService,
    required this.authRepository,
  }) : super(AuthInitial()) {
    AppLogger.authInfo('Creating new AuthBloc instance - $hashCode');
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<AuthStatusChanged>(_onAuthStatusChanged);
    on<BiometricLoginRequested>(_onBiometricLoginRequested);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.authInfo('Checking authentication status...');
    emit(AuthLoading());

    try {
      final result = await getCurrentUser(NoParams());

      result.fold(
        (failure) {
          AppLogger.authError(
            'Failed to get current user: ${failure.toString()}',
          );
          emit(AuthUnauthenticated());
        },
        (user) {
          if (user != null) {
            AppLogger.authInfo('User found: ${user.email}');
            emit(
              AuthAuthenticated(
                user: user,
                loginTimestamp: DateTime.now().millisecondsSinceEpoch,
              ),
            );
          } else {
            AppLogger.authInfo('No user found, user is unauthenticated');
            emit(AuthUnauthenticated());
          }
        },
      );
    } catch (e) {
      AppLogger.authError('Exception during auth check: $e');
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.authInfo('Login requested for email: ${event.email}');
    emit(AuthLoading());

    try {
      final result = await loginUser(
        LoginParams(email: event.email, password: event.password),
      );

      result.fold(
        (failure) {
          AppLogger.authError('Login failed: ${failure.toString()}');
          emit(AuthError(message: failure.toString()));
        },
        (user) {
          AppLogger.authInfo('Login successful for user: ${user.email}');
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          emit(AuthAuthenticated(user: user, loginTimestamp: timestamp));
        },
      );
    } catch (e) {
      AppLogger.authError('Exception during login: $e');
      emit(const AuthError(message: 'Error inesperado durante el login'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.authInfo('Logout requested');
    emit(AuthLoading());

    try {
      final result = await logoutUser(NoParams());

      result.fold(
        (failure) {
          AppLogger.authError('Logout failed: ${failure.toString()}');
          // Incluso si falla el logout en el servidor, limpiamos el estado local
          emit(AuthUnauthenticated());
        },
        (_) {
          AppLogger.authInfo('Logout successful');
          emit(AuthUnauthenticated());
        },
      );
    } catch (e) {
      AppLogger.authError('Exception during logout: $e');
      // En caso de excepción, aún así limpiamos el estado local
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthStatusChanged(
    AuthStatusChanged event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.authInfo('Auth status changed: ${event.isAuthenticated}');
    if (!event.isAuthenticated) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onBiometricLoginRequested(
    BiometricLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.authInfo('Biometric login requested');
    emit(AuthLoading());

    try {
      final isAvailable = await biometricAuthService.isBiometricAvailable();
      if (!isAvailable) {
        AppLogger.authWarning('Biometric authentication not available');
        emit(
          const AuthError(message: 'Autenticación biométrica no disponible'),
        );
        return;
      }

      final authenticated = await biometricAuthService.authenticate();
      if (authenticated) {
        AppLogger.authInfo('Biometric authentication successful via provider');
        
        // Obtener el email guardado en las preferencias biométricas
        final biometricPreferencesService = getIt<BiometricPreferencesService>();
        final savedEmail = await biometricPreferencesService.getBiometricUserEmail();
        
        if (savedEmail != null && savedEmail.isNotEmpty) {
          AppLogger.authInfo('Found saved email for biometric login: $savedEmail');
          
          // Intentar iniciar sesión con el email guardado
          // Aquí no necesitamos contraseña porque la autenticación biométrica ya fue exitosa
          // Simplemente recuperamos el usuario asociado con este email
          final result = await authRepository.getUserByEmail(savedEmail);
          
          result.fold(
            (failure) {
              AppLogger.authError(
                'Failed to get user with saved email: ${failure.toString()}',
              );
              emit(
                const AuthError(
                  message: 'Error al recuperar usuario con email guardado',
                ),
              );
            },
            (user) {
              if (user != null) {
                AppLogger.authInfo(
                  'Biometric login successful for user: ${user.email}',
                );
                final timestamp = DateTime.now().millisecondsSinceEpoch;
                emit(AuthAuthenticated(user: user, loginTimestamp: timestamp));
              } else {
                AppLogger.authWarning(
                  'No user found with saved email after biometric authentication',
                );
                emit(
                  const AuthError(
                    message: 'No se encontró usuario para autenticación biométrica',
                  ),
                );
              }
            },
          );
        } else {
          // Si no hay email guardado, intentar obtener el usuario actual
          AppLogger.authWarning('No saved email found for biometric login');
          final result = await getCurrentUser(NoParams());

          result.fold(
            (failure) {
              AppLogger.authError(
                'Failed to get current user after biometric auth: ${failure.toString()}',
              );
              emit(
                const AuthError(
                  message:
                      'Error al obtener usuario después de autenticación biométrica',
                ),
              );
            },
            (user) {
              if (user != null) {
                AppLogger.authInfo(
                  'Biometric login successful for current user: ${user.email}',
                );
                final timestamp = DateTime.now().millisecondsSinceEpoch;
                emit(AuthAuthenticated(user: user, loginTimestamp: timestamp));
              } else {
                AppLogger.authWarning(
                  'No user found after biometric authentication',
                );
                emit(
                  const AuthError(
                    message: 'No se encontró usuario para autenticación biométrica',
                  ),
                );
              }
            },
          );
        }
      } else {
        AppLogger.authWarning('Biometric authentication failed');
        emit(const AuthError(message: 'Autenticación biométrica fallida'));
      }
    } catch (e) {
      AppLogger.authError('Exception during biometric login: $e');
      emit(
        const AuthError(
          message: 'Error inesperado durante la autenticación biométrica',
        ),
      );
    }
  }
}
