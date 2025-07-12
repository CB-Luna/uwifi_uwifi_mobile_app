import 'package:flutter/material.dart';

import '../../../domain/entities/credit_card.dart';

class CreditCardWidget extends StatelessWidget {
  final CreditCard card;

  const CreditCardWidget({required this.card, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage('assets/images/profile/CreditCardUI.png'),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black.withValues(alpha: 0.0),
              Colors.black.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                card.isDefault
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Default',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
            const Spacer(),
            Text(
              card.cardHolder,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  '•••• •••• •••• ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  card.last4Digits,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'VALID THRU',
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                    Text(
                      '${card.expirationMonth}/${card.expirationYear}',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
