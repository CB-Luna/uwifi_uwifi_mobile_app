import 'package:flutter/material.dart';

import '../../../../../core/utils/app_logger.dart';
import '../../../../home/domain/entities/active_service.dart';
import '../../../domain/entities/credit_card.dart';

class CheckoutSummaryPage extends StatefulWidget {
  final List<ActiveService> services;
  final CreditCard? selectedCard;

  const CheckoutSummaryPage({
    required this.services,
    required this.selectedCard,
    super.key,
  });

  @override
  State<CheckoutSummaryPage> createState() => _CheckoutSummaryPageState();
}

class _CheckoutSummaryPageState extends State<CheckoutSummaryPage> {
  bool autoPayment = false;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Verificar los servicios recibidos
    AppLogger.info('CheckoutSummaryPage - Servicios recibidos: ${widget.services.length}');
    
    // Calcular el monto total
    double totalAmount = 0;
    for (var service in widget.services) {
      totalAmount += service.value;
      AppLogger.info('Servicio: ${service.name}, Valor: \$${service.value.toStringAsFixed(2)}');
    }
    AppLogger.info('Monto total calculado: \$${totalAmount.toStringAsFixed(2)}');
  }

  // Método para calcular el monto total de los servicios
  double _calculateTotal() {
    double total = 0;
    for (var service in widget.services) {
      total += service.value;
    }
    return total;
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
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
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
                                  style: const TextStyle(color: Colors.black54, fontSize: 12),
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
                  const Row(
                    children: [
                      Text(
                        '\$0.00',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(' in U-points'),
                    ],
                  ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Enable auto-payment?',
                        style: TextStyle(color: Colors.black87),
                      ),
                      Switch(
                        value: autoPayment,
                        onChanged: (val) => setState(() => autoPayment = val),
                        activeColor: Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: isProcessing
                    ? null
                    : () {
                        setState(() {
                          isProcessing = true;
                        });

                        // Aquí iría la lógica para procesar el pago
                        // Por ahora solo simulamos un proceso
                        Future.delayed(const Duration(seconds: 2), () {
                          // Mostrar un diálogo de éxito
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => AlertDialog(
                              title: const Text('Payment Successful'),
                              content: const Text(
                                'Your payment has been processed successfully.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    // Cerrar el diálogo y volver a la página principal
                                    Navigator.of(context).pop();
                                    // Navegar hacia atrás hasta la página principal
                                    Navigator.of(
                                      context,
                                    ).popUntil((route) => route.isFirst);
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );

                          setState(() {
                            isProcessing = false;
                          });
                        });
                      },
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
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
