import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

import '../../../domain/entities/credit_card.dart';
import 'credit_card_widget.dart';

class CreditCardSwiper extends StatefulWidget {
  final List<CreditCard> cards;
  final Function(CreditCard)? onSetDefault;
  final Function(CreditCard)? onDelete;

  const CreditCardSwiper({
    required this.cards,
    this.onSetDefault,
    this.onDelete,
    super.key,
  });

  @override
  State<CreditCardSwiper> createState() => _CreditCardSwiperState();
}

class _CreditCardSwiperState extends State<CreditCardSwiper> {
  final CardSwiperController controller = CardSwiperController();
  
  // Variable para rastrear el índice de la tarjeta frontal actual
  int _currentFrontCardIndex = 0;

  @override
  void initState() {
    super.initState();
    // Inicializar la tarjeta frontal como la primera tarjeta (índice 0)
    _currentFrontCardIndex = 0;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) {
      return const Center(
        child: Text(
          'You have no cards registered',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return SizedBox(
      height: 320,
      child: CardSwiper(
        controller: controller,
        cardsCount: widget.cards.length,
        cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
          // Determinar si es la tarjeta frontal basado en la posición actual
          // La tarjeta está al frente cuando está completamente centrada (percentThreshold cercano a 0)
          final bool isFrontCard = (percentThresholdX.abs() < 0.1) && (_currentFrontCardIndex == index);
          
          return CreditCardWidget(
            card: widget.cards[index],
            onSetDefault: widget.onSetDefault,
            onDelete: widget.onDelete,
            isFrontCard: isFrontCard, // Pasar el parámetro para indicar si es la tarjeta frontal
          );
        },
        // Mostrar hasta 3 tarjetas en el mazo (o menos si no hay suficientes)
        numberOfCardsDisplayed: widget.cards.length > 3
            ? 3
            : widget.cards.length,
        // Desplazamiento para crear efecto escalonado (como en las imágenes de referencia)
        backCardOffset: const Offset(0, -30),
        // Escala para tarjetas traseras (más pequeñas)
        scale: 0.92,
        // Padding para dar espacio al mazo
        padding: const EdgeInsets.all(16.0),
        // Permitir deslizar horizontalmente
        allowedSwipeDirection: const AllowedSwipeDirection.symmetric(
          horizontal: true,
        ),
        // Duración de la animación al deslizar
        duration: const Duration(milliseconds: 300),
        // Sensibilidad del deslizamiento (40%)
        threshold: 40,
        onSwipe: (previousIndex, currentIndex, direction) {
          // Actualizar el índice de la tarjeta frontal cuando el usuario desliza
          setState(() {
            // Asegurarnos de manejar el caso en que currentIndex sea null
            _currentFrontCardIndex = currentIndex ?? 0;
          });
          return true; // Permitir siempre el deslizamiento
        },
      ),
    );
  }
}
