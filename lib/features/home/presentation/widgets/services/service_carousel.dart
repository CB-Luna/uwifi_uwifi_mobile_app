import 'package:flutter/material.dart';
import 'free_service_card.dart';
import 'referral_service_card.dart';

class ServiceCarousel extends StatefulWidget {
  const ServiceCarousel({super.key});

  @override
  State<ServiceCarousel> createState() => _ServiceCarouselState();
}

class _ServiceCarouselState extends State<ServiceCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Carrusel de tarjetas
        SizedBox(
          height: 180, // Altura aumentada para evitar overflow
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: const [FreeServiceCard(), ReferralServiceCard()],
          ),
        ),

        const SizedBox(height: 12),

        // Indicadores de página dinámicos
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Indicador para la primera página (Free Service)
            Container(
              width: _currentPage == 0 ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentPage == 0 ? Colors.green : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 6),
            // Indicador para la segunda página (Referral)
            Container(
              width: _currentPage == 1 ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentPage == 1 ? Colors.green : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
