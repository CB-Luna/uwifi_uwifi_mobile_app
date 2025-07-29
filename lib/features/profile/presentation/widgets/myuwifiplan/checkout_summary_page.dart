import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uwifiapp/core/utils/app_logger.dart';
import 'package:uwifiapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:uwifiapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:uwifiapp/features/home/domain/entities/active_service.dart';
import 'package:uwifiapp/features/home/presentation/bloc/billing_bloc.dart';
import 'package:uwifiapp/features/home/presentation/bloc/billing_event.dart';
import 'package:uwifiapp/features/home/presentation/bloc/billing_state.dart';
import 'package:uwifiapp/features/profile/domain/entities/credit_card.dart';

class CheckoutSummaryPage extends StatefulWidget {
  final List<ActiveService> services;
  final CreditCard? selectedCard;

  const CheckoutSummaryPage({
    required this.services,
    super.key,
    this.selectedCard,
  });

  @override
  State<CheckoutSummaryPage> createState() => _CheckoutSummaryPageState();
}

class _CheckoutSummaryPageState extends State<CheckoutSummaryPage> {
  late CreditCard selectedCard;
  bool _localAutoPay = false;
  bool isProcessing = false;
  int totalPoints = 0;

  @override
  void initState() {
    super.initState();
    selectedCard = widget.selectedCard!;
    // Verificar los servicios recibidos
    AppLogger.info(
      'CheckoutSummaryPage - Servicios recibidos: ${widget.services.length}',
    );

    // Calcular el monto total
    double totalAmount = 0;
    for (var service in widget.services) {
      totalAmount += service.value;
      AppLogger.info(
        'Servicio: ${service.name}, Valor: \$${service.value.toStringAsFixed(2)}',
      );
    }
    AppLogger.info(
      'Monto total calculado: \$${totalAmount.toStringAsFixed(2)}',
    );

    // Cargar los puntos acumulados del usuario
    _loadWalletData();

    // Cargar el estado de AutoPay
    _loadCustomerDetails();
  }

  // Método para cargar los datos de wallet (puntos acumulados)
  void _loadWalletData() {
    // Simulamos puntos acumulados para esta implementación
    setState(() {
      totalPoints =
          0; // En una implementación real, esto vendría del sistema de puntos
    });
  }

  // Método para cargar los detalles del cliente (estado de AutoPay)
  void _loadCustomerDetails() {
    // En una implementación real, esto cargaría los detalles del cliente
    // Por ahora, simplemente establecemos un valor predeterminado
    setState(() {
      _localAutoPay = false;
    });
  }

  // Método para manejar el cambio de estado del switch de AutoPay
  void _onAutoPayChanged(bool value) {
    // Actualizamos el estado local inmediatamente para que la UI se actualice
    setState(() {
      _localAutoPay = value;
    });

    // En el checkout no enviamos el evento al backend inmediatamente
    // El estado se enviará cuando el usuario confirme el pago
    AppLogger.info(
      'AutoPay cambiado a: $value (se aplicará al confirmar el pago)',
    );
  }

  // Método para calcular el monto total de los servicios
  double _calculateTotal() {
    double total = 0;
    for (var service in widget.services) {
      total += service.value;
    }
    return total;
  }

  // Método para procesar el pago
  void _processPayment() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated || authState.user.customerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo identificar al usuario')),
      );
      return;
    }

    // Obtener el ID del cliente
    final customerId = authState.user.customerId!;
    // Validar que el ID sea válido
    if (customerId <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ID de cliente inválido')));
      return;
    }

    // Mostrar diálogo de confirmación
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmar pago'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Estás seguro que deseas procesar el pago de \$${_calculateTotal().toStringAsFixed(2)}?',
                ),
                const SizedBox(height: 8),
                Text('Método de pago: **** ${selectedCard.last4Digits}'),
                if (_localAutoPay)
                  const Text(
                    'Se activará el pago automático para futuros cargos.',
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Confirmar'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed || !mounted) return;

    setState(() {
      isProcessing = true;
    });

    // Obtener la fecha actual para la facturación
    final now = DateTime.now();
    final billingDate = DateFormat('yyyy-MM-dd').format(now);

    // Calcular el descuento basado en los puntos aplicados
    final discount = totalPoints > 0 ? (totalPoints / 100) : 0.0;

    // Enviar el evento al BillingBloc para crear la facturación manual
    context.read<BillingBloc>().add(
      CreateManualBillingEvent(
        customerId: customerId,
        billingDate: billingDate,
        discount: discount,
        autoPayment: _localAutoPay,
      ),
    );

    // Escuchar el estado del BillingBloc para mostrar el resultado
    final billingState = await _listenForBillingState();

    // Desactivar el indicador de procesamiento
    if (mounted) {
      setState(() {
        isProcessing = false;
      });
    }

    AppLogger.info('Estado de facturación recibido: $billingState');

    // Manejar el resultado según el estado del BillingBloc
    if (billingState is BillingSuccess) {
      // Aplicar los puntos acumulados si están disponibles
      if (totalPoints > 0) {
        AppLogger.info('Aplicando $totalPoints puntos al pago');
        // Aquí enviaríamos el evento para usar los puntos
      }

      // Mostramos un diálogo de éxito
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('¡Pago exitoso!'),
          content: const Text('Tu pago ha sido procesado correctamente.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      // Regresamos a la página principal
      if (!mounted) return;
      Navigator.of(context).pop(true); // Retornamos true para indicar éxito
    } else if (billingState is BillingError) {
      // Mostrar mensaje de error
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${billingState.message}')));
    }
  }

  /// Escucha los cambios de estado del BillingBloc hasta que se complete el proceso
  Future<BillingState> _listenForBillingState() {
    final completer = Completer<BillingState>();
    late final StreamSubscription subscription;

    subscription = context.read<BillingBloc>().stream.listen((state) {
      if (state is BillingSuccess || state is BillingError) {
        completer.complete(state);
        subscription.cancel();
      }
    });

    // Timeout después de 10 segundos
    Future.delayed(const Duration(seconds: 10), () {
      if (!completer.isCompleted) {
        completer.complete(
          const BillingError(message: 'Tiempo de espera agotado'),
        );
        subscription.cancel();
      }
    });

    return completer.future;
  }

  // Método para obtener el icono de la tarjeta según el token
  Widget _getCardIcon(String token) {
    // Determinar el tipo de tarjeta basado en el token
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
              const Icon(Icons.credit_card, color: Colors.black87, size: 25),
        );
      case 'mastercard':
        return Image.asset(
          'assets/images/cards/mastercard.png',
          width: 40,
          height: 25,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.credit_card, color: Colors.black87, size: 25),
        );
      case 'amex':
        return Image.asset(
          'assets/images/cards/amex.png',
          width: 40,
          height: 25,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.credit_card, color: Colors.black87, size: 25),
        );
      case 'discover':
        return Image.asset(
          'assets/images/cards/discover.png',
          width: 40,
          height: 25,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.credit_card, color: Colors.black87, size: 25),
        );
      default:
        return const Icon(Icons.credit_card, color: Colors.black87, size: 25);
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
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Invoice',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Below is the list of items.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  // Lista de servicios
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.services.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final service = widget.services[index];
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
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
                                Text(
                                  service.type,
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '\$${service.value.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  // Información de la tarjeta seleccionada
                  if (widget.selectedCard != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Payment Method',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        _getCardIcon(widget.selectedCard!.token),
                        const SizedBox(width: 8),
                        Text(
                          'Card ending in ${widget.selectedCard!.token.substring(widget.selectedCard!.token.length - 4)}',
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),
                  ],

                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Accumulated U-points',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  // Mostrar puntos acumulados (simulación)
                  Row(
                    children: [
                      Text(
                        totalPoints > 0 ? totalPoints.toString() : '\$0.00',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(' in U-points'),
                    ],
                  ),
                  if (totalPoints > 0)
                    const Text(
                      'These points will be deducted from the total payable.',
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  const SizedBox(height: 16),
                  const Text(
                    'Order Summary',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Subtotal',
                        style: TextStyle(color: Colors.black54),
                      ),
                      Text(
                        '\$${_calculateTotal().toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Discount', style: TextStyle(color: Colors.black54)),
                      Text('\$0.00', style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                  const SizedBox(height: 8),
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
                        '\$${_calculateTotal().toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  // Switch de AutoPay
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Enable auto-payment?',
                        style: TextStyle(color: Colors.black87),
                      ),
                      Switch(
                        value: _localAutoPay,
                        onChanged: _onAutoPayChanged,
                        activeColor: Colors.green,
                      ),
                    ],
                  ),

                  if (totalPoints > 0) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Puntos disponibles',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$totalPoints puntos',
                          style: const TextStyle(color: Colors.black87),
                        ),
                        Text(
                          '-\$${(totalPoints / 100).toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 50),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: isProcessing ? null : _processPayment,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.green),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      child: isProcessing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.green,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Make Payment',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
