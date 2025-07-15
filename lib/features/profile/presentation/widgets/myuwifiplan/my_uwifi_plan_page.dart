import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../core/utils/app_logger.dart';
import '../../../../../injection_container.dart' as di;
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../auth/presentation/bloc/auth_state.dart';
import '../../../../home/presentation/bloc/billing_bloc.dart';
import '../../../../home/presentation/bloc/billing_event.dart';
import '../../../../home/presentation/bloc/billing_state.dart';
import '../../../../home/presentation/bloc/service_bloc.dart';
import '../../../../home/presentation/bloc/service_event.dart';
import '../../../../home/presentation/bloc/service_state.dart';
import 'myuwifiplan_autopay_modal.dart';
import 'plan_checkout_page.dart';

class MyUwifiPlanPage extends StatelessWidget {
  const MyUwifiPlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<BillingBloc>(create: (context) => di.getIt<BillingBloc>()),
        BlocProvider<ServiceBloc>(create: (context) => di.getIt<ServiceBloc>()),
      ],
      child: const _MyUwifiPlanPageContent(),
    );
  }
}

class _MyUwifiPlanPageContent extends StatefulWidget {
  const _MyUwifiPlanPageContent();

  @override
  State<_MyUwifiPlanPageContent> createState() =>
      _MyUwifiPlanPageContentState();
}

class _MyUwifiPlanPageContentState extends State<_MyUwifiPlanPageContent> {
  // Ya no necesitamos el getter autoPayEnabled porque usamos BlocBuilder

  @override
  void initState() {
    super.initState();
    // Delay to ensure the widget is fully built before accessing BLOCs
    Future.microtask(() {
      _loadBillingData();
      _loadServiceData();
    });
  }

  void _loadBillingData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final user = authState.user;

      // Verificar si el usuario tiene customerId
      if (user.customerId != null) {
        AppLogger.navInfo(
          'Cargando período de facturación para customerId: ${user.customerId}',
        );
        context.read<BillingBloc>().add(
          GetBillingPeriodEvent(customerId: user.customerId.toString()),
        );
      } else {
        AppLogger.navError('Error: El usuario no tiene customerId asignado');
      }
    }
  }

  void _loadServiceData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final user = authState.user;

      // Verificar si el usuario tiene customerId
      if (user.customerId != null) {
        AppLogger.navInfo(
          'Cargando servicios activos para customerId: ${user.customerId}',
        );
        context.read<ServiceBloc>().add(
          GetCustomerActiveServicesEvent(
            customerId: user.customerId.toString(),
          ),
        );
      } else {
        AppLogger.navError('Error: El usuario no tiene customerId asignado');
      }
    }
  }

  void _onAutoPayChanged(bool value) async {
    final result = await showDialog<AutoPayAction>(
      context: context,
      barrierDismissible: false,
      builder: (context) => MyUwifiPlanAutoPayModal(activating: value),
    );
    if (!mounted) return;

    if (result == AutoPayAction.activated ||
        result == AutoPayAction.deactivated) {
      final bool isActivating = result == AutoPayAction.activated;

      // Obtenemos el customerId del usuario autenticado
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated && authState.user.customerId != null) {
        final customerId = authState.user.customerId.toString();

        // Enviamos el evento al BillingBloc para actualizar el estado de AutoPay
        context.read<BillingBloc>().add(
          UpdateAutomaticChargeEvent(
            customerId: customerId,
            value: isActivating,
          ),
        );

        // Mostramos el modal de confirmación
        await showDialog(
          context: context,
          builder: (context) =>
              MyUwifiPlanAutoPayConfirmationModal(activated: isActivating),
        );
        if (!mounted) return;
      } else {
        // Si no hay customerId, mostramos un error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo actualizar AutoPay: Usuario no identificado',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
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
          'My U-wifi Plan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card principal del plan
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.grey.shade300, width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/homeimage/launcher.png',
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: BlocBuilder<ServiceBloc, ServiceState>(
                          builder: (context, state) {
                            if (state is ServiceLoaded &&
                                state.services.isNotEmpty) {
                              final service = state
                                  .services
                                  .first; // Tomamos el primer servicio
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    service.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    service.type,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              );
                            } else if (state is ServiceLoading) {
                              return const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Cargando...',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Please wait',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'U-Wifi Internet',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Recurring Charge',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ),
                      BlocBuilder<ServiceBloc, ServiceState>(
                        builder: (context, state) {
                          // El estado del servicio no afecta la apariencia del indicador de estado
                          // Siempre mostramos el estado como activo
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6F9ED),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  color: Colors.green,
                                  size: 12,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Active',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  BlocBuilder<BillingBloc, BillingState>(
                    builder: (context, billingState) {
                      return BlocBuilder<ServiceBloc, ServiceState>(
                        builder: (context, serviceState) {
                          // Obtener el valor del servicio
                          String priceText = '\$0.00';
                          if (serviceState is ServiceLoaded &&
                              serviceState.services.isNotEmpty) {
                            final service = serviceState.services.first;
                            priceText = '\$${service.value.toStringAsFixed(2)}';
                          }

                          // Obtener la fecha de vencimiento
                          String dueDate = 'Next Due';
                          if (billingState is BillingLoaded) {
                            try {
                              final dateFormat = DateFormat('yyyy-MM-dd');
                              final date = dateFormat.parse(
                                billingState.billingPeriod.dueDate,
                              );
                              final formattedDate = DateFormat(
                                'MMM dd',
                              ).format(date);
                              dueDate = billingState.automaticCharge
                                  ? 'Autopay on $formattedDate'
                                  : 'Next Due on $formattedDate';
                            } catch (e) {
                              AppLogger.navError('Error to format date: $e');
                              dueDate = billingState.automaticCharge
                                  ? 'Autopay enabled'
                                  : 'Payment due soon';
                            }
                          }

                          return Row(
                            children: [
                              Text(
                                priceText,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 26,
                                ),
                              ),
                              const SizedBox(width: 18),
                              const Spacer(),
                              Text(
                                dueDate,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text(
                        'AutoPay',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      BlocBuilder<BillingBloc, BillingState>(
                        builder: (context, state) {
                          final bool isAutoPay = state is BillingLoaded
                              ? state.automaticCharge
                              : false;
                          return Switch(
                            value: isAutoPay,
                            onChanged: _onAutoPayChanged,
                            activeColor: Colors.green,
                          );
                        },
                      ),
                      const Spacer(),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const PlanPayNowPage(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.green),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18)),
                          ),
                        ),
                        child: const Text(
                          'Pay Now',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            BlocBuilder<BillingBloc, BillingState>(
              builder: (context, state) {
                if (state is BillingLoaded) {
                  try {
                    final dateFormat = DateFormat('yyyy-MM-dd');
                    final date = dateFormat.parse(
                      state.billingPeriod.currentBillingPeriod.endDate,
                    );
                    final formattedDate = DateFormat('MMMM d').format(date);
                    return Text(
                      'Your billing cycle ends on $formattedDate',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    );
                  } catch (e) {
                    AppLogger.navError('Error al formatear la fecha: $e');
                    return const Text(
                      'Your billing cycle ends soon',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    );
                  }
                } else if (state is BillingLoading) {
                  return const Text(
                    'Loading billing information...',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  );
                } else {
                  return const Text(
                    'Your billing cycle information',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  );
                }
              },
            ),
            const SizedBox(height: 6),
            const Text(
              'Please note that this may not align with the end of the calendar month.',
              style: TextStyle(color: Colors.black54, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
