import 'dart:ui';
import 'package:flutter/material.dart';

class FreeUInfoPage extends StatelessWidget {
  const FreeUInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          // Fondo superior con gradiente
          Container(
            height: 140,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF6B46C1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Contenido principal
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  // Encabezado con flecha a la izquierda y logo centrado
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.black87,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      Image.asset(
                        'assets/images/homeimage/FreeU.png',
                        height: 50,
                      ),
                      const Spacer(flex: 2), // Para mantener el logo centrado
                    ],
                  ),
                  const SizedBox(height: 45),
                  // Texto principal más grande y en negrita
                  const Text(
                    'Turn your time into savings. Start watching, start earning, and pay less every month!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Tarjeta glassmorphism 1
                  const _GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.star, color: Color(0xFF6B46C1)),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Want your monthly plan to be FREE? Yes, it\'s possible!',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'How does it work?',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 5),
                        Divider(),
                        SizedBox(height: 5),
                        _NumberedList([
                          'Go to the "FREE U" section, marked with a U in the menu.',
                          'Watch the ads (you must watch them completely).',
                          'Swipe to the next ad and keep going.',
                          'Earn points with each ad you watch!',
                        ]),
                        SizedBox(height: 5),
                        Text(
                          'Each ad you watch adds points to your account, which you can check anytime in the "My Wallet" section.',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Tarjeta glassmorphism 2
                  const _GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.refresh, color: Color(0xFF10B981)),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'When do the points reset?',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        _NumberedList([
                          'Your points reset at the beginning of your service cycle (not the calendar month).',
                          'If you reach a milestone (2410, 2420, 2430, or the max 2438), that amount will automatically be applied as a discount on your next payment.',
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Botón de acción
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                      shape: const StadiumBorder(),
                      backgroundColor: const Color(0xFF10B981),
                      elevation: 8,
                      shadowColor: const Color(
                        0xFF6B46C1,
                      ).withValues(alpha: 0.3),
                    ),
                    child: const Text(
                      'Go to FREE U',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _NumberedList extends StatelessWidget {
  final List<String> items;
  const _NumberedList(this.items);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < items.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF6B46C1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    items[i],
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
