import 'package:flutter/material.dart';
import 'package:uwifiapp/core/utils/responsive_font_sizes_screen.dart';

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
      child: Stack(
        children: [
          // Contenedor del lado derecho con GIF justificado a la derecha
          Positioned(
            right: 0,
            child: Container(
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
          ),
          // Contenido del lado izquierdo
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título con imagen FREE U
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
                    Text(
                      'Free Service with ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: responsiveFontSizesScreen.bodyLarge(context),
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
                Text(
                  'Earn While You Watch. Seriously. Free.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: responsiveFontSizesScreen.bodyMedium(context),
                    height: 1.0,
                  ),
                  maxLines: 3,
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
                    label: Text(
                      'See More',
                      style: TextStyle(
                        fontSize: responsiveFontSizesScreen.bodySmall(context),
                      ),
                    ),
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
        ],
      ),
    );
  }
}
