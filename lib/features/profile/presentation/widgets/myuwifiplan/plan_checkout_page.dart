import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uwifiapp/features/home/domain/entities/active_service.dart';

import '../../../../../core/utils/app_logger.dart';
import '../../../../../injection_container.dart' as di;
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../auth/presentation/bloc/auth_state.dart';
import '../../../../home/presentation/bloc/billing_bloc.dart';
import '../../../../home/presentation/bloc/billing_event.dart';
import '../../../../home/presentation/bloc/service_bloc.dart';
import '../../../../home/presentation/bloc/service_event.dart';
import '../../../../home/presentation/bloc/service_state.dart';
import '../../../domain/entities/credit_card.dart';
import '../../../presentation/bloc/payment_bloc.dart';
import '../../../presentation/bloc/payment_event.dart';
import '../../../presentation/bloc/payment_state.dart';
import 'change_card_sheet.dart';
import 'checkout_summary_page.dart';

class PlanPayNowPage extends StatelessWidget {
  final List<ActiveService> services;
  const PlanPayNowPage({required this.services, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<BillingBloc>(create: (context) => di.getIt<BillingBloc>()),
        BlocProvider<ServiceBloc>(create: (context) => di.getIt<ServiceBloc>()),
        // Usar el PaymentBloc existente en lugar de crear uno nuevo
        BlocProvider.value(value: BlocProvider.of<PaymentBloc>(context)),
      ],
      child: _PlanPayNowPageContent(services: services),
    );
  }
}

class _PlanPayNowPageContent extends StatefulWidget {
  final List<ActiveService> services;
  const _PlanPayNowPageContent({required this.services});

  @override
  State<_PlanPayNowPageContent> createState() => _PlanPayNowPageContentState();
}

class _PlanPayNowPageContentState extends State<_PlanPayNowPageContent> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Método para obtener el logo de la tarjeta según el token
  Widget _getCardLogo(String token) {
    // Determinar el tipo de tarjeta basado en el token
    // Esto es una simplificación, en una implementación real
    // se debería usar un método más robusto para identificar el tipo de tarjeta
    String cardType = 'visa'; // Por defecto

    if (token.startsWith('4')) {
      cardType = 'visa';
    } else if (token.startsWith('5')) {
      cardType = 'mastercard';
    } else if (token.startsWith('3')) {
      cardType = 'amex';
    } else if (token.startsWith('6')) {
      cardType = 'discover';
    }

    // Retornar el logo correspondiente
    switch (cardType) {
      case 'visa':
        return Image.asset(
          'assets/images/cards/visa.png',
          width: 40,
          height: 25,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.credit_card, color: Colors.white, size: 25),
        );
      case 'mastercard':
        return Image.asset(
          'assets/images/cards/mastercard.png',
          width: 40,
          height: 25,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.credit_card, color: Colors.white, size: 25),
        );
      case 'amex':
        return Image.asset(
          'assets/images/cards/amex.png',
          width: 40,
          height: 25,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.credit_card, color: Colors.white, size: 25),
        );
      case 'discover':
        return Image.asset(
          'assets/images/cards/discover.png',
          width: 40,
          height: 25,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.credit_card, color: Colors.white, size: 25),
        );
      default:
        return const Icon(Icons.credit_card, color: Colors.white, size: 25);
    }
  }

  void _loadData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated && authState.user.customerId != null) {
      final customerId = authState.user.customerId.toString();
      AppLogger.info('Cargando datos para customerId: $customerId');

      // Cargar servicios activos
      context.read<ServiceBloc>().add(
        GetCustomerActiveServicesEvent(customerId: customerId),
      );

      // Cargar período de facturación
      context.read<BillingBloc>().add(
        GetBillingPeriodEvent(customerId: customerId),
      );

      // Cargar métodos de pago
      final paymentBloc = context.read<PaymentBloc>();
      AppLogger.info(
        'Estado actual de PaymentBloc: ${paymentBloc.state.runtimeType}',
      );
      paymentBloc.add(GetCreditCardsEvent(customerId));
      AppLogger.info(
        'Solicitando tarjetas de crédito para customerId: $customerId',
      );
    } else {
      AppLogger.navError('Error: Usuario no autenticado o sin customerId');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Plan Checkout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado de servicios
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Services',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Price',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Lista de servicios
            BlocBuilder<ServiceBloc, ServiceState>(
              builder: (context, state) {
                if (state is ServiceLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  );
                } else if (state is ServiceLoaded &&
                    state.services.isNotEmpty) {
                  // Calcular el total
                  double totalAmount = 0;
                  for (var service in state.services) {
                    totalAmount += service.value;
                  }

                  return Column(
                    children: [
                      // Lista de servicios
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.services.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 16),
                        itemBuilder: (context, index) {
                          final service = state.services[index];
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Nombre del servicio
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      service.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (service.description.isNotEmpty)
                                      Text(
                                        service.description,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    Chip(
                                      label: Text(
                                        service.type,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      backgroundColor: const Color(0xFFF3F5F8),
                                      labelPadding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Precio del servicio
                              Expanded(
                                child: Text(
                                  '\$${service.value.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),

                      // Total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            '\$${totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  return const Center(child: Text('No services available'));
                }
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'Payment options',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 18),
            BlocBuilder<PaymentBloc, PaymentState>(
              buildWhen: (previous, current) {
                // Reconstruir siempre que cambie el estado
                AppLogger.info(
                  'PaymentBloc estado anterior: ${previous.runtimeType}, nuevo: ${current.runtimeType}',
                );
                return true;
              },
              builder: (context, state) {
                AppLogger.info(
                  'Construyendo UI con estado PaymentBloc: ${state.runtimeType}',
                );
                if (state is PaymentLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  );
                } else if (state is PaymentLoaded &&
                    state.creditCards.isNotEmpty) {
                  // Encontrar la tarjeta predeterminada
                  CreditCard defaultCard;
                  try {
                    defaultCard = state.creditCards.firstWhere(
                      (card) => card.isDefault,
                    );
                    AppLogger.info(
                      'Tarjeta predeterminada encontrada: ${defaultCard.id}',
                    );
                  } catch (e) {
                    // Si no hay tarjeta predeterminada, usar la primera
                    defaultCard = state.creditCards.first;
                    AppLogger.info(
                      'No hay tarjeta predeterminada, usando la primera: ${defaultCard.id}',
                    );
                  }

                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 140,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  children: [
                                    // Fondo de la tarjeta
                                    Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        image: const DecorationImage(
                                          image: AssetImage(
                                            'assets/images/profile/CreditCardUI.png',
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    // Contenido de la tarjeta
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'CREDIT CARD',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              // Logo de la tarjeta
                                              _getCardLogo(defaultCard.token),
                                            ],
                                          ),
                                          const SizedBox(height: 20),
                                          Text(
                                            '**** **** **** ${defaultCard.token.substring(defaultCard.token.length - 4)}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 2.0,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                defaultCard.cardHolder
                                                    .toUpperCase(),
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Text(
                                                '${defaultCard.expirationMonth}/${defaultCard.expirationYear}',
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 18),
                          Image.asset(
                            'assets/images/profile/PaypalBanner.png',
                            width: 100,
                            height: 60,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: 180,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            // Obtener el customerId y las tarjetas disponibles
                            final authState = context.read<AuthBloc>().state;
                            String? customerId;
                            if (authState is AuthAuthenticated &&
                                authState.user.customerId != null) {
                              customerId = authState.user.customerId.toString();
                            }

                            // Obtener las tarjetas del estado actual del PaymentBloc
                            final paymentState = context
                                .read<PaymentBloc>()
                                .state;
                            List<CreditCard> creditCards = [];
                            CreditCard? defaultCard;

                            if (paymentState is PaymentLoaded) {
                              creditCards = paymentState.creditCards;

                              // Buscar la tarjeta predeterminada
                              try {
                                defaultCard = creditCards.firstWhere(
                                  (card) => card.isDefault,
                                );
                              } catch (e) {
                                // Si no hay tarjeta predeterminada y hay tarjetas, usar la primera
                                if (creditCards.isNotEmpty) {
                                  defaultCard = creditCards.first;
                                }
                              }
                            } else {
                              // Si no hay tarjetas cargadas, intentar cargarlas
                              if (customerId != null) {
                                context.read<PaymentBloc>().add(
                                  GetCreditCardsEvent(customerId),
                                );
                                // Esperar un momento para que se carguen las tarjetas
                                await Future.delayed(
                                  const Duration(milliseconds: 300),
                                );

                                // Intentar obtener las tarjetas nuevamente
                                final updatedState = context
                                    .read<PaymentBloc>()
                                    .state;
                                if (updatedState is PaymentLoaded) {
                                  creditCards = updatedState.creditCards;
                                  try {
                                    defaultCard = creditCards.firstWhere(
                                      (card) => card.isDefault,
                                    );
                                  } catch (e) {
                                    if (creditCards.isNotEmpty) {
                                      defaultCard = creditCards.first;
                                    }
                                  }
                                }
                              }
                            }

                            // Mostrar el modal de selección de tarjeta
                            await showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.white,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(25),
                                ),
                              ),
                              builder: (context) => MultiBlocProvider(
                                providers: [
                                  BlocProvider.value(
                                    value: BlocProvider.of<PaymentBloc>(
                                      context,
                                    ),
                                  ),
                                  BlocProvider.value(
                                    value: BlocProvider.of<AuthBloc>(context),
                                  ),
                                ],
                                child: ChangeCardSheet(
                                  creditCards: creditCards,
                                  defaultCard: defaultCard,
                                ),
                              ),
                            );

                            // Forzar actualización de la UI después de cerrar el modal
                            if (customerId != null) {
                              // Recargar las tarjetas para obtener los cambios
                              context.read<PaymentBloc>().add(
                                GetCreditCardsEvent(customerId),
                              );

                              // Esperar un momento para que se actualice el estado
                              await Future.delayed(
                                const Duration(milliseconds: 300),
                              );

                              // Forzar reconstrucción del widget
                              if (mounted) {
                                setState(() {});
                                AppLogger.info(
                                  'Forzando reconstrucción del widget después de cambiar tarjeta',
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.sync_alt, color: Colors.green),
                          label: const Text(
                            'Change Card',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.green),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(18),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  // No hay tarjetas o error al cargar
                  return Column(
                    children: [
                      Container(
                        height: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.credit_card_outlined,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'No payment methods available',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: 180,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/addcard');
                          },
                          icon: const Icon(Icons.add, color: Colors.green),
                          label: const Text(
                            'Add Card',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.green),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(18),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 150),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Obtener los servicios del ServiceBloc
                  final serviceState = context.read<ServiceBloc>().state;

                  // Registrar información sobre los servicios para depuración
                  if (serviceState is ServiceLoaded &&
                      serviceState.services.isNotEmpty) {
                    AppLogger.info(
                      'Número de servicios a procesar: ${serviceState.services.length}',
                    );

                    // Calcular el monto total para el log (solo para depuración)
                    double totalAmount = 0;
                    for (var service in serviceState.services) {
                      totalAmount += service.value;
                      AppLogger.info(
                        'Servicio: ${service.name}, Valor: \$${service.value.toStringAsFixed(2)}',
                      );
                    }

                    AppLogger.info(
                      'Monto total calculado: \$${totalAmount.toStringAsFixed(2)}',
                    );
                  } else {
                    AppLogger.info(
                      'No hay servicios disponibles o estado no cargado',
                    );
                  }

                  // Obtener la tarjeta predeterminada del PaymentBloc
                  final paymentState = context.read<PaymentBloc>().state;
                  CreditCard? defaultCard;

                  if (paymentState is PaymentLoaded &&
                      paymentState.creditCards.isNotEmpty) {
                    try {
                      defaultCard = paymentState.creditCards.firstWhere(
                        (card) => card.isDefault,
                      );
                    } catch (e) {
                      // Si no hay tarjeta predeterminada, usar la primera
                      defaultCard = paymentState.creditCards.first;
                    }
                  }

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CheckoutSummaryPage(
                        services:
                            serviceState is ServiceLoaded &&
                                serviceState.services.isNotEmpty
                            ? serviceState.services
                            : [],
                        selectedCard: defaultCard,
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.green, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: const Text(
                  'Continue to Checkout',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}
