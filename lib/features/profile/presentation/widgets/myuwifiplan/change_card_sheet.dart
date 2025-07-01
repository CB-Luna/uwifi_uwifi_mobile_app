import 'package:flutter/material.dart';

class ChangeCardSheet extends StatefulWidget {
  const ChangeCardSheet({super.key});

  @override
  State<ChangeCardSheet> createState() => _ChangeCardSheetState();
}

class _ChangeCardSheetState extends State<ChangeCardSheet> {
  int? selectedCard = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          ...List.generate(2, (index) {
            final cardInfo = index == 0
                ? {'last': '1000', 'exp': '04/24'}
                : {'last': '4000', 'exp': '12/32'};
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selectedCard == index
                      ? Colors.green
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/profile/CreditCardUI.png',
                    width: 48,
                    height: 32,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text('Card ending in [${cardInfo['last']}]'),
                subtitle: Text('Expires in ${cardInfo['exp']}'),
                trailing: Radio<int>(
                  value: index,
                  groupValue: selectedCard,
                  onChanged: (val) => setState(() => selectedCard = val),
                  activeColor: Colors.green,
                ),
                onTap: () => setState(() => selectedCard = index),
              ),
            );
          }),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, color: Colors.black54),
            label: const Text(
              'Add Card',
              style: TextStyle(color: Colors.black87),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.green),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
