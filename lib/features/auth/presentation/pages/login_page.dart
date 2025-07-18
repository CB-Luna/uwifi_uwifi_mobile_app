import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/biometric_provider.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/services/biometric_auth_service.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/forgot_password_sheet.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  late final BiometricAuthService _biometricAuthService;

  @override
  void initState() {
    super.initState();
    AppLogger.navInfo('LoginPage initialized');
    _biometricAuthService = di.getIt<BiometricAuthService>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_validateEmail(_emailController.text) == null &&
        _validatePassword(_passwordController.text) == null) {
      AppLogger.authInfo('Login form validated, attempting login');

      context.read<AuthBloc>().add(
        LoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    } else {
      AppLogger.authWarning('Login form validation failed');
    }
  }

  Future<void> _handleBiometricLogin() async {
    AppLogger.authInfo('Biometric login requested');

    try {
      // Disparar el evento de login biométrico
      // No necesitamos verificar si está habilitado porque el botón solo se muestra si lo está
      context.read<AuthBloc>().add(BiometricLoginRequested());

      // No necesitamos esperar aquí ya que el BlocListener en el build
      // manejará los estados de éxito y error
    } catch (e) {
      AppLogger.authError('Error during biometric login: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during biometric login: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showForgotPasswordSheet(BuildContext context) {
    AppLogger.authInfo('Showing forgot password sheet');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      // Eliminamos el controlador de animación personalizado y usamos el predeterminado
      // que es más seguro y evita problemas de vsync
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const ForgotPasswordSheet(),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu email';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Por favor ingresa un email válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu contraseña';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            AppLogger.authError('Login error: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header image
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(20),
                        ),
                        child: Image.asset(
                          'assets/images/login/cover.png',
                          fit: BoxFit.cover,
                          height: 170,
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome to U!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Fill out the information below in order to access your account.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Email field
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.green.shade400,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            enabled: state is! AuthLoading,
                          ),
                          const SizedBox(height: 16),

                          // Password field
                          TextField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.green.shade400,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            enabled: state is! AuthLoading,
                          ),
                          const SizedBox(height: 24),

                          // Login button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: state is AuthLoading
                                  ? null
                                  : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade400,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 0,
                              ),
                              child: state is AuthLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Text('Log In'),
                            ),
                          ),

                          // Biometric login button - usando Consumer para acceder al BiometricProvider
                          Consumer<BiometricProvider>(
                            builder: (context, biometricProvider, child) {
                              // Crear un FutureBuilder para verificar si la biometría está habilitada
                              return FutureBuilder<bool>(
                                future: _biometricAuthService.isBiometricEnabled(),
                                builder: (context, snapshot) {
                                  // Solo mostrar el botón si la biometría está disponible Y habilitada
                                  final bool isEnabled = snapshot.data ?? false;
                                  if (!biometricProvider.isAvailable || !isEnabled) {
                                    return const SizedBox.shrink();
                                  }
                                  
                                  return Column(
                                    children: [
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 50,
                                        child: OutlinedButton(
                                          onPressed: state is AuthLoading
                                              ? null
                                              : _handleBiometricLogin,
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(
                                              color: Colors.green.shade400,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                25,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Log in with ${biometricProvider.biometricType}',
                                                style: TextStyle(
                                                  color: Colors.green.shade400,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              biometricProvider.biometricType
                                                      .contains('Face')
                                                  ? Image.asset(
                                                      'assets/images/login/face-id.png',
                                                      height: 24,
                                                      width: 24,
                                                    )
                                                  : Icon(
                                                      Icons.fingerprint,
                                                      color: Colors.green.shade400,
                                                      size: 24,
                                                    ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),

                          const SizedBox(height: 24),
                          // Forgot password
                          Center(
                            child: TextButton(
                              onPressed: () {
                                _showForgotPasswordSheet(context);
                              },
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(color: Colors.purple.shade700),
                              ),
                            ),
                          ),

                          // Ad banner
                          const SizedBox(height: 24),
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: const Text('AdMob Banner'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
