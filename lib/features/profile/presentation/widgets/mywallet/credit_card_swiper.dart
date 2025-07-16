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

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: CardSwiper(
            controller: controller,
            cardsCount: widget.cards.length,
            cardBuilder:
                (context, index, percentThresholdX, percentThresholdY) =>
                    CreditCardWidget(
                      card: widget.cards[index],
                      onSetDefault: widget.onSetDefault,
                      onDelete: widget.onDelete,
                    ),
            numberOfCardsDisplayed: 1,
            backCardOffset: const Offset(0, 0),
            padding: const EdgeInsets.all(24.0),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.cards.length > 1) ...[
              IconButton(
                onPressed: () => controller.swipe(CardSwiperDirection.left),
                icon: const Icon(Icons.arrow_back_ios),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () => controller.swipe(CardSwiperDirection.right),
                icon: const Icon(Icons.arrow_forward_ios),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
