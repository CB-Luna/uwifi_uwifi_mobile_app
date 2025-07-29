import 'package:flutter/material.dart';

import '../../pages/my_flutter_app_icons.dart';

class FloatingNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const FloatingNavigationBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        // ✅ Fondo transparente para Videos, blanco para otras pantallas
        color: currentIndex == 0 ? Colors.transparent : Colors.white,
        boxShadow: currentIndex == 0
            ? [] // ✅ Sin sombra para Videos (transparente)
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: MyFlutterApp.u,
            label: 'Videos',
            index: 0,
            isSelected: currentIndex == 0,
          ),
          _buildNavItem(
            icon: Icons.home_outlined,
            label: 'Home',
            index: 1,
            isSelected: currentIndex == 1,
          ),
          _buildNavItem(
            icon: Icons.person_add_outlined,
            label: 'Invite',
            index: 2,
            isSelected: currentIndex == 2,
          ),
          _buildNavItem(
            icon: Icons.person_outline,
            label: 'Profile',
            index: 3,
            isSelected: currentIndex == 3,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    // ✅ Colores dinámicos según la pantalla actual
    final bool isVideoScreen = currentIndex == 0;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        width: 60,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isVideoScreen
                    ? Colors.green.withAlpha(76) // ✅ Más opaco para Videos
                    : Colors.green.withAlpha(25))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: isVideoScreen && !isSelected
                  ? BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(
                            102,
                          ), // ✅ Sombra para visibilidad
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    )
                  : null,
              child: Icon(
                isSelected ? _getSelectedIcon(icon) : icon,
                color: isVideoScreen
                    ? (isSelected
                          ? Colors.white
                          : Colors.white.withAlpha(
                              230,
                            )) // ✅ Blancos para Videos
                    : (isSelected
                          ? Colors.green
                          : Colors
                                .grey
                                .shade600), // ✅ Colores normales para otras pantallas
                size: isSelected ? 24 : 20,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              decoration: isVideoScreen && !isSelected
                  ? BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(
                            102,
                          ), // ✅ Sombra para texto
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    )
                  : null,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isVideoScreen
                      ? (isSelected
                            ? Colors.white
                            : Colors.white.withAlpha(
                                230,
                              )) // ✅ Blancos para Videos
                      : (isSelected
                            ? Colors.green
                            : Colors
                                  .grey
                                  .shade600), // ✅ Colores normales para otras pantallas
                  fontSize: isSelected ? 10 : 8,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSelectedIcon(IconData icon) {
    switch (icon) {
      case MyFlutterApp.u:
        return MyFlutterApp.u; // Tu ícono personalizado se mantiene igual
      case Icons.home_outlined:
        return Icons.home;
      case Icons.person_add_outlined:
        return Icons.person_add;
      case Icons.person_outline:
        return Icons.person;
      default:
        return icon;
    }
  }
}
