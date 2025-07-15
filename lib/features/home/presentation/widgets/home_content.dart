import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uwifiapp/injection_container.dart' as di;
import '../bloc/connection_bloc.dart';

import '../../presentation/bloc/billing_bloc.dart';
import '../../presentation/bloc/service_bloc.dart';
import 'connection/connection_card.dart';
import 'services/service_carousel.dart';
import 'subscription/subscription_card.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sección de conexión WiFi
              BlocProvider<ConnectionBloc>(
                create: (_) => di.getIt<ConnectionBloc>(),
                child: const ConnectionCard(),
              ),

              const SizedBox(height: 16),

              // Sección de suscripción
              MultiBlocProvider(
                providers: [
                  BlocProvider<BillingBloc>(
                    create: (_) => di.getIt<BillingBloc>(),
                  ),
                  BlocProvider<ServiceBloc>(
                    create: (_) => di.getIt<ServiceBloc>(),
                  ),
                ],
                child: const SubscriptionCard(),
              ),

              const SizedBox(height: 16),

              // Carrusel de servicios (Free Service y Referral)
              const ServiceCarousel(),

              // Espacio para la barra de navegación
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
