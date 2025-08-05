import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/utils/app_logger.dart';
import '../../../auth/presentation/widgets/auth_wrapper_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _isVideoInitialized = false;
  bool _isVideoError = false;
  Timer? _skipButtonTimer;

  @override
  void initState() {
    super.initState();

    // Configurar la orientación y modo inmersivo para el splash
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() {
    _controller = VideoPlayerController.asset('assets/splash/splash.mp4')
      ..initialize()
          .then((_) {
            // Una vez que el video está inicializado, lo reproducimos
            setState(() {
              _isVideoInitialized = true;
            });
            _controller.play();

            // Configuramos un listener para cuando el video termine
            _controller.addListener(() {
              if (_controller.value.position >= _controller.value.duration) {
                _navigateToAuthWrapper();
              }
            });
          })
          .catchError((error) {
            AppLogger.navInfo('Error al inicializar el video: $error');
            setState(() {
              _isVideoError = true;
            });
            // Si hay un error, navegamos después de un breve retraso
            Timer(const Duration(seconds: 2), _navigateToAuthWrapper);
          });
  }

  void _navigateToAuthWrapper() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthWrapperWidget()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _skipButtonTimer?.cancel();

    // Restaurar la configuración del sistema UI al salir
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top],
    );

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Contenido principal (video o pantalla de carga/error)
          _isVideoError
              ? _buildErrorWidget()
              : _isVideoInitialized
              ? _buildVideoWidget()
              : _buildLoadingWidget(),
        ],
      ),
    );
  }

  Widget _buildVideoWidget() {
    // Dimensiones exactas del video: 607x1080
    const double videoWidth = 607.0;
    const double videoHeight = 1080.0;
    const double videoAspectRatio =
        videoWidth / videoHeight; // Aproximadamente 0.56

    // Obtener las dimensiones de la pantalla
    final screenSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap:
          _navigateToAuthWrapper, // Permitir omitir con un toque en cualquier parte
      child: Container(
        color: const Color(0xFFE4ECEC), // Color fondo de video
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Container(
            // Usar FittedBox con BoxFit.contain para asegurar que el video
            // se muestre completo sin distorsión
            constraints: BoxConstraints(
              maxWidth: screenSize.width,
              maxHeight: screenSize.height,
            ),
            child: AspectRatio(
              aspectRatio: videoAspectRatio,
              child: VideoPlayer(_controller),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/login/uwifi_logo.png', height: 120),
          const SizedBox(height: 20),
          const CircularProgressIndicator(color: Colors.white),
        ],
      ),
    );
  }
}
