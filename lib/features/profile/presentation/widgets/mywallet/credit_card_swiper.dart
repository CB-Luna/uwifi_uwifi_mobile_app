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
          // Aplicar transformaciones basadas en el índice para crear efecto de mazo
          return CreditCardWidget(
            card: widget.cards[index],
            onSetDefault: widget.onSetDefault,
            onDelete: widget.onDelete,
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
          // Opcional: Añadir lógica adicional al deslizar
          return true; // Permitir siempre el deslizamiento
        },
      ),
    );
  }
}
