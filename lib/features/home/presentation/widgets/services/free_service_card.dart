import 'package:flutter/material.dart';
import 'free_u_info_page.dart';

class FreeServiceCard extends StatelessWidget {
  const FreeServiceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.only(top: 16, left: 16, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Contenido del lado izquierdo
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título con imagen FREE U
                Row(
                  children: [
                    const Text(
                      'Free Service with ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Image.asset(
                      'assets/images/homeimage/FreeU.png',
                      height: 35,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Texto descriptivo
                const Text(
                  'Earn While You Watch. Seriously. Free.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 16),

                // Botón de más información (justificado a la izquierda)
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const FreeUInfoPage(),
                        ),
                      );
                    },
                    icon: const Icon(
                      IconData(0xe800, fontFamily: 'MyFlutterApp'),
                      color: Colors.green,
                      size: 16,
                    ),
                    label: const Text('See More'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Contenedor del lado derecho con GIF justificado a la derecha
          Container(
            width: 100,
            height: 120,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              child: Image.asset(
                'assets/images/homeimage/mainCoinGif.gif',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
