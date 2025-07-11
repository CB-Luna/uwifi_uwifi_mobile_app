import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../presentation/bloc/billing_bloc.dart';
import '../../../presentation/bloc/billing_event.dart';
import '../../../presentation/bloc/billing_state.dart';
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../auth/presentation/bloc/auth_state.dart';
import 'plan_details_page.dart';
import 'package:intl/intl.dart';

class SubscriptionCard extends StatefulWidget {
  const SubscriptionCard({super.key});

  @override
  State<SubscriptionCard> createState() => _SubscriptionCardState();
}

class _SubscriptionCardState extends State<SubscriptionCard> {
  @override
  void initState() {
    super.initState();
    _loadBillingPeriod();
  }

  void _loadBillingPeriod() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final user = authState.user;
      
      // Verificar si el usuario tiene customerId
      if (user.customerId != null) {
        print('Cargando período de facturación para customerId: ${user.customerId}');
        context.read<BillingBloc>().add(
              GetBillingPeriodEvent(customerId: user.customerId.toString()),
            );
      } else {
        print('Error: El usuario no tiene customerId asignado');
        // Podríamos mostrar un mensaje de error o intentar otra estrategia
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFCACECF), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(13),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Encabezado con icono y texto
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/homeimage/launcher.png',
                    fit: BoxFit.cover,
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'U-wifi Internet',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'Recurring Charge',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Active',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Fecha de vencimiento y monto
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Fecha de vencimiento
              Row(
                children: [
                  Icon(
                    Icons.calendar_month,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  BlocBuilder<BillingBloc, BillingState>(
                    builder: (context, state) {
                      if (state is BillingLoaded) {
                        // Formatear la fecha para mostrarla en formato MMM dd
                        final dueDate = state.billingPeriod.dueDate;
                        final formattedDate = _formatDate(dueDate);
                        return Text(
                          'Due Date: $formattedDate',
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                        );
                      }
                      return Text(
                        'Due Date: Loading...',
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                      );
                    },
                  ),
                ],
              ),

              // Monto a pagar
              BlocBuilder<BillingBloc, BillingState>(
                builder: (context, state) {
                  String amountText = 'Amount Due: --';
                  
                  if (state is BillingLoaded && state.balance != null) {
                    // Formatear el balance como moneda
                    final formatter = NumberFormat.currency(symbol: '\$');
                    amountText = 'Amount Due: ${formatter.format(state.balance)}';
                  }
                  
                  return Row(
                    children: [
                      Icon(
                        Icons.monetization_on_outlined,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        amountText,
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Botones de acción
          Row(
            children: [
              // Botón de detalles del plan
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PlanDetailsPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Plan Details'),
                ),
              ),

              const SizedBox(width: 12),

              // Botón de pago
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Colors.green),
                    ),
                  ),
                  child: const Text('Pay Now'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Método para formatear la fecha en formato MMM dd
  String _formatDate(String dateString) {
    try {
      // Intentar parsear la fecha en formato ISO
      final date = DateTime.parse(dateString);
      final formatter = DateFormat('MMM dd');
      return formatter.format(date);
    } catch (e) {
      // Si hay un error al parsear, devolver la fecha original
      return dateString;
    }
  }
}
