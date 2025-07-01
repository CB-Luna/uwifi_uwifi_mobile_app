import 'package:flutter/material.dart';

/// Widget del encabezado de invitación con gradiente y icono
class InviteHeaderWidget extends StatelessWidget {
  const InviteHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6B46C1), // Purple
              Color(0xFF10B981), // Green
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Imagen de usuario sin recuadro
            Image.asset(
              'assets/images/homeimage/UserMetalic.png',
              width: 80,
              height: 80,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 20),

            // Título principal centrado
            const Text(
              'Bring a friend and',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),

            // Título destacado centrado
            const Text(
              'GET DISCOUNTS!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 16),

            // Descripción centrada
            Text(
              'Your friend will receive exclusive benefits when they sign up using your referral link.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
    );
  }
}
