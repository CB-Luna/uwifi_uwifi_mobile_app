import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
// ignore: unused_import
import '../../../videos/presentation/bloc/videos_bloc.dart'; // Necesario para filtrado por categorías
import '../../../videos/presentation/pages/tiktok_video_feed_page.dart';
import '../../../invite/presentation/pages/invite_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
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

  final List<String> _titles = ['Ver Videos', 'Home', 'Invite', 'Profile'];

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
  }

  @override
  void dispose() {
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
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: _pages,
          ),
          FloatingNavigationBar(
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
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
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
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}
