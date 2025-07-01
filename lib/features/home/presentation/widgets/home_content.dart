import 'package:flutter/material.dart';
import 'connection/connection_card.dart';
import 'subscription/subscription_card.dart';
import 'services/service_carousel.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sección de conexión WiFi
              ConnectionCard(),

              SizedBox(height: 16),

              // Sección de suscripción
              SubscriptionCard(),

              SizedBox(height: 16),

              // Carrusel de servicios (Free Service y Referral)
              ServiceCarousel(),

              // Espacio para la barra de navegación
              SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
