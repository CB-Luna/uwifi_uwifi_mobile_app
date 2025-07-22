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
  
  // Variable to track the current front card index
  int _currentFrontCardIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize the front card as the first card (index 0)
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
          // Determine if it's the front card based on the current position
          // The card is at the front when it's completely centered (percentThreshold close to 0)
          final bool isFrontCard = (percentThresholdX.abs() < 0.1) && (_currentFrontCardIndex == index);
          
          return CreditCardWidget(
            card: widget.cards[index],
            onSetDefault: widget.onSetDefault,
            onDelete: widget.onDelete,
            isFrontCard: isFrontCard, // Pass the parameter to indicate if it's the front card
          );
        },
        // Show up to 3 cards in the deck (or fewer if there aren't enough)
        numberOfCardsDisplayed: widget.cards.length > 3
            ? 3
            : widget.cards.length,
        // Offset to create staggered effect (as in the reference images)
        backCardOffset: const Offset(0, -30),
        // Scale for back cards (smaller)
        scale: 0.92,
        // Padding to give space to the deck
        padding: const EdgeInsets.all(16.0),
        // Allow horizontal swiping
        allowedSwipeDirection: const AllowedSwipeDirection.symmetric(
          horizontal: true,
        ),
        // Duration of the swipe animation
        duration: const Duration(milliseconds: 300),
        // Swipe sensitivity (40%)
        threshold: 40,
        onSwipe: (previousIndex, currentIndex, direction) {
          // Update the front card index when the user swipes
          setState(() {
            // Make sure to handle the case where currentIndex is null
            _currentFrontCardIndex = currentIndex ?? 0;
          });
          return true; // Always allow swiping
        },
      ),
    );
  }
}
