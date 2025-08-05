import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:uwifiapp/core/utils/ad_manager.dart';

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
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isPasswordVisible = false;
  late final BiometricAuthService _biometricAuthService;
  // Variables para el manejo de anuncios
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    AppLogger.navInfo('LoginPage initialized');
    _biometricAuthService = di.getIt<BiometricAuthService>();
    _loadBannerAd();
    
    // Configurar listeners para los campos de texto
    _emailController.addListener(_scrollToBottomOnFocus);
    _passwordController.addListener(_scrollToBottomOnFocus);
  }

  void _scrollToBottomOnFocus() {
    // Pequeño retraso para asegurar que el teclado ya esté visible
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    // Validar el formulario usando el formKey
    if (_formKey.currentState?.validate() ?? false) {
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
    
    // Usamos showModalBottomSheet con isScrollControlled: true para permitir que
    // el sheet se expanda cuando el teclado está abierto
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      // Eliminamos las restricciones de altura para permitir que se ajuste automáticamente
      builder: (context) => DraggableScrollableSheet(
        // Hacemos que inicialmente ocupe menos espacio para que el teclado no cubra el botón
        initialChildSize: 0.6,
        minChildSize: 0.4, // Mínimo tamaño al deslizar hacia abajo
        maxChildSize: 0.95, // Máximo tamaño al expandir
        expand: false,
        builder: (context, scrollController) => Padding(
          // Ajustamos el padding para que el contenido se desplace hacia arriba cuando el teclado aparece
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          // Usamos SingleChildScrollView para asegurar que todo el contenido sea desplazable
          child: SingleChildScrollView(
            controller: scrollController,
            child: const ForgotPasswordSheet(),
          ),
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }

  // Método para cargar el anuncio banner
  void _loadBannerAd() {
    _bannerAd = AdManager.createBannerAd();
    _bannerAd!
        .load()
        .then((value) {
          setState(() {
            _isAdLoaded = true;
          });
        })
        .catchError((error) {
          AppLogger.navInfo('Error al cargar el anuncio: $error');
          _isAdLoaded = false;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Configurar para que el contenido se ajuste cuando aparece el teclado
      resizeToAvoidBottomInset: true,
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
                controller: _scrollController,
                // Añadir padding inferior para evitar que el teclado cubra el botón
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 80,
                ),
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
                      child: Form(
                        key: _formKey,
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
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              onTap: _scrollToBottomOnFocus,
                              onChanged: (value) {
                                // Convertir automáticamente a minúsculas
                                if (value != value.toLowerCase()) {
                                  _emailController.value = TextEditingValue(
                                    text: value.toLowerCase(),
                                    selection: TextSelection.collapsed(offset: value.toLowerCase().length),
                                  );
                                }
                              },
                              validator: _validateEmail,
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
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.red.shade400,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.red.shade400,
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
                            TextFormField(
                              controller: _passwordController,
                              onTap: _scrollToBottomOnFocus,
                              obscureText: !_isPasswordVisible,
                              validator: _validatePassword,
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
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.red.shade400,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.red.shade400,
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
                                  future: _biometricAuthService
                                      .isBiometricEnabled(),
                                  builder: (context, snapshot) {
                                    // Solo mostrar el botón si la biometría está disponible Y habilitada
                                    final bool isEnabled =
                                        snapshot.data ?? false;
                                    if (!biometricProvider.isAvailable ||
                                        !isEnabled) {
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
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Log in with ${biometricProvider.biometricType}',
                                                  style: TextStyle(
                                                    color:
                                                        Colors.green.shade400,
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
                                                        color: Colors
                                                            .green
                                                            .shade400,
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
                                  style: TextStyle(
                                    color: Colors.purple.shade700,
                                  ),
                                ),
                              ),
                            ),

                            // Ad banner
                            const SizedBox(height: 24),
                            // Banner de anuncios en la parte inferior
                            if (_isAdLoaded && _bannerAd != null)
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.only(
                                    bottom: 8,
                                    top: 8,
                                  ), // Padding inferior para evitar solapamiento
                                  alignment: Alignment.center,
                                  width: _bannerAd!.size.width.toDouble(),
                                  height:
                                      _bannerAd!.size.height.toDouble() +
                                      8, // Añadimos espacio extra para el padding
                                  child: AdWidget(ad: _bannerAd!),
                                ),
                              ),
                          ],
                        ),
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
