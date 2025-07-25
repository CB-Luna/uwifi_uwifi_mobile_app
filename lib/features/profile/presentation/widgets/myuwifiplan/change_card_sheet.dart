import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/app_logger.dart';
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../auth/presentation/bloc/auth_state.dart';
import '../../../domain/entities/credit_card.dart';
import '../../../presentation/bloc/payment_bloc.dart';
import '../../../presentation/bloc/payment_event.dart';

class ChangeCardSheet extends StatefulWidget {
  final List<CreditCard> creditCards;
  final CreditCard? defaultCard;
  
  const ChangeCardSheet({
    super.key,
    required this.creditCards,
    this.defaultCard,
  });

  @override
  State<ChangeCardSheet> createState() => _ChangeCardSheetState();
}

class _ChangeCardSheetState extends State<ChangeCardSheet> {
  CreditCard? selectedCard;

  @override
  void initState() {
    super.initState();
    // Inicializar la tarjeta seleccionada con la predeterminada o la primera
    if (widget.defaultCard != null) {
      selectedCard = widget.defaultCard;
    } else if (widget.creditCards.isNotEmpty) {
      // Buscar la tarjeta predeterminada
      try {
        selectedCard = widget.creditCards.firstWhere((card) => card.isDefault);
      } catch (e) {
        // Si no hay tarjeta predeterminada, usar la primera
        selectedCard = widget.creditCards.first;
      }
    }
    AppLogger.info('Tarjetas disponibles: ${widget.creditCards.length}');
    if (selectedCard != null) {
      AppLogger.info('Tarjeta seleccionada: ${selectedCard!.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text(
            'Choose your preferred card',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          const SizedBox(height: 18),
          if (widget.creditCards.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  'No payment methods available',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...widget.creditCards.map((card) {
              final isSelected = selectedCard?.id == card.id;
              final last4Digits = card.token.substring(card.token.length - 4);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? Colors.green : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: ListTile(
                  leading: SizedBox(
                    child: _getCardIcon(card.token),
                  ),
                  title: Text('Card ending in $last4Digits'),
                  subtitle: Text(
                    'Expires ${card.expirationMonth}/${card.expirationYear}',
                  ),
                  trailing: Radio<CreditCard>(
                    value: card,
                    groupValue: selectedCard,
                    onChanged: (value) => setState(() => selectedCard = value),
                  ),
                  onTap: () => setState(() => selectedCard = card),
                ),
              );
            }).toList(),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed('/addcard');
            },
            icon: const Icon(Icons.add, color: Colors.green),
            label: const Text(
              'Add Card',
              style: TextStyle(color: Colors.green),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.green),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                if (selectedCard != null && !selectedCard!.isDefault) {
                  // Obtener el customerId del usuario autenticado
                  final authState = context.read<AuthBloc>().state;
                  if (authState is AuthAuthenticated &&
                      authState.user.customerId != null) {
                    final customerId = authState.user.customerId.toString();

                    // Establecer la tarjeta seleccionada como predeterminada
                    context.read<PaymentBloc>().add(
                      SetDefaultCardEvent(
                        customerId: customerId,
                        cardId: selectedCard!.id.toString(),
                      ),
                    );

                    AppLogger.info(
                      'Setting card ${selectedCard!.id} as default',
                    );
                    
                    // Esperar un momento para que se procese el cambio
                    await Future.delayed(const Duration(milliseconds: 300));
                    
                    // Recargar las tarjetas para actualizar la UI
                    if (!context.mounted) return;
                    context.read<PaymentBloc>().add(GetCreditCardsEvent(customerId));
                  }
                }
                
                if (!context.mounted) return;
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.green,
                side: const BorderSide(color: Colors.green),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
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
          width: 48,
          height: 32,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.credit_card, color: Colors.blue, size: 32),
        );
      case 'mastercard':
        return Image.asset(
          'assets/images/cards/mastercard.png',
          width: 48,
          height: 32,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.credit_card, color: Colors.orange, size: 32),
        );
      case 'amex':
        return Image.asset(
          'assets/images/cards/amex.png',
          width: 48,
          height: 32,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.credit_card, color: Colors.indigo, size: 32),
        );
      case 'discover':
        return Image.asset(
          'assets/images/cards/discover.png',
          width: 48,
          height: 32,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.credit_card, color: Colors.red, size: 32),
        );
      default:
        return const Icon(Icons.credit_card, color: Colors.grey, size: 32);
    }
  }
}
