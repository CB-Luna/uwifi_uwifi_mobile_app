import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../../core/utils/ad_manager.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../invite/presentation/pages/invite_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
// ignore: unused_import
import '../../../videos/presentation/bloc/videos_bloc.dart'; // Necesario para filtrado por categorías
import '../../../videos/presentation/pages/tiktok_video_feed_page.dart';
import '../widgets/home_content.dart';
import '../widgets/navigation/floating_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 1; // ✅ Start with Home selected instead of Videos
  late PageController _pageController;
  late List<Widget> _pages;

  // Variables para el manejo de anuncios
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  final List<String> _titles = ['Videos', 'Home', 'Invite', 'Profile'];

  @override
  void initState() {
    super.initState();
    AppLogger.navInfo('HomePage initialized');
    _pageController = PageController(
      initialPage: _currentIndex,
    ); // Iniciar en Home (índice 1)

    // Inicializar las páginas después de que el widget esté montado
    _pages = [
      // ✅ Nueva página de videos ultra optimizada y modular
      const TikTokVideoFeedPage(),
      const HomeContent(),
      const InvitePage(),
      const ProfilePage(),
    ];

    // Cargar el anuncio banner
    _loadBannerAd();
  }

  // Método para cargar el anuncio banner adaptativo
  void _loadBannerAd() {
    // Primero cargamos un banner estándar para asegurar que haya un anuncio
    _bannerAd = AdManager.createBannerAd();
    _bannerAd!
        .load()
        .then((value) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        })
        .catchError((error) {
          AppLogger.navInfo('Error al cargar el anuncio: $error');
          _isAdLoaded = false;
        });

    // Luego, una vez que el widget esté completamente montado, intentamos cargar un banner adaptativo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final width = MediaQuery.of(context).size.width.truncate();
      AdManager.createAdaptiveBannerAd(width).then((adaptiveBanner) {
        if (adaptiveBanner != null && mounted) {
          // Disponer del banner anterior si existe
          _bannerAd?.dispose();

          // Asignar y cargar el nuevo banner adaptativo
          _bannerAd = adaptiveBanner;
          _bannerAd!
              .load()
              .then((_) {
                if (mounted) {
                  setState(() {
                    _isAdLoaded = true;
                  });
                }
              })
              .catchError((error) {
                AppLogger.navInfo(
                  'Error al cargar el anuncio adaptativo: $error',
                );
              });
        }
      });
    });
  }

  @override
  void dispose() {
    // Liberar recursos del anuncio
    _bannerAd?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0
          ? AppBar(
              title: Text(_titles[_currentIndex]),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              toolbarHeight: 50, // ✅ AppBar más pequeño
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  color: Colors.white70,
                  iconSize: 22, // ✅ Iconos más pequeños
                  onPressed: () {
                    // Acción para notificaciones
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  color: Colors.red,
                  iconSize: 22, // ✅ Agregar logout también en Videos
                  onPressed: () {
                    _showLogoutDialog(context);
                  },
                ),
              ],
            )
          : _currentIndex == 1
          ? AppBar(
              title: Text(_titles[_currentIndex]),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
              toolbarHeight: 50, // ✅ AppBar para Home también
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  color: Colors.black87,
                  iconSize: 22, // ✅ Iconos más pequeños
                  onPressed: () {
                    // Acción para notificaciones
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  color: Colors.red,
                  iconSize: 22, // ✅ Agregar logout en Home
                  onPressed: () {
                    _showLogoutDialog(context);
                  },
                ),
              ],
            )
          : AppBar(
              title: Text(_titles[_currentIndex]),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
              toolbarHeight: 50, // ✅ AppBar más pequeño
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  color: Colors.black87,
                  iconSize: 22, // ✅ Iconos más pequeños
                  onPressed: () {
                    // Acción para notificaciones
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  color: Colors.red,
                  iconSize: 22, // ✅ Iconos más pequeños
                  onPressed: () {
                    _showLogoutDialog(context);
                  },
                ),
              ],
            ),
      body: Stack(
        children: [
          // Contenido principal
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: _pages,
          ),

          // Barra de navegación flotante
          Positioned(
            // Ajustar posición según la plataforma y si hay anuncios
            bottom: _isAdLoaded
                ? (Platform.isIOS
                      ? 50
                      : 100) // iOS: 5, Android: 110 cuando hay anuncios
                : (Platform.isIOS
                      ? 10
                      : 40), // iOS: 5, Android: 30 cuando no hay anuncios
            left: 0,
            right: 0,
            child: FloatingNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ),

          // Banner de anuncios en la parte inferior
          if (_isAdLoaded && _bannerAd != null)
            Positioned(
              bottom: Platform.isIOS ? 0 : 40, // iOS: 0, Android: 50
              left: 0,
              right: 0,
              child: Container(
                width: MediaQuery.of(
                  context,
                ).size.width, // Ancho explícito de la pantalla
                color: Colors.white,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: _bannerAd!.size.height.toDouble(),
                  alignment: Alignment.center,
                  child: AdWidget(ad: _bannerAd!),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              AppLogger.authInfo('Logout button pressed by user');
              Navigator.pop(context);
              final authBloc = context.read<AuthBloc>();
              AppLogger.authInfo(
                'Using AuthBloc instance - ${authBloc.hashCode}',
              );
              AppLogger.authInfo('Sending LogoutRequested event...');
              authBloc.add(LogoutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
