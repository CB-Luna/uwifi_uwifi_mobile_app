import 'package:flutter/material.dart';

class AccountSecurityFaqPage extends StatelessWidget {
  const AccountSecurityFaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        'question': 'How do I change my password?',
        'answer':
            "It's simple. On the login screen, tap on the text that says 'Forgot your password?' A popup will appear asking for your email. Once you enter your email and tap continue, you'll receive an email with instructions to reset your password.",
      },
      {
        'question': 'How can I update my personal information?',
        'answer':
            "At the moment, it's not possible to update your personal information through the app, except for adding or removing cards from your Wallet. If you need help changing any personal data, please contact the U-wifi team — we're always ready to assist you as quickly and helpfully as possible.",
      },
      {
        'question': 'How do I run a speed test?',
        'answer':
            "On the Home screen, tap 'Connection Details' in the gateway card. At the top, you'll find the 'Speed Test' button.",
      },
      {
        'question': 'Is my personal data safe in the app?',
        'answer':
            "Absolutely. Your personal data is securely stored on our servers. And don't worry about your payment data — we don't store credit card information. All payment data is handled by iPPay, who encrypts all information related to your payment methods.",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Help Center',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lock_outline, size: 36, color: Colors.black87),
                SizedBox(width: 12),
                Text(
                  'Account & Security',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView.separated(
                itemCount: faqs.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final faq = faqs[index];
                  return _FaqAccordion(
                    question: faq['question']!,
                    answer: faq['answer']!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqAccordion extends StatefulWidget {
  final String question;
  final String answer;
  const _FaqAccordion({required this.question, required this.answer});

  @override
  State<_FaqAccordion> createState() => _FaqAccordionState();
}

class _FaqAccordionState extends State<_FaqAccordion> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => setState(() => expanded = !expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.question,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Icon(
                      expanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.black54,
                    ),
                  ],
                ),
                if (expanded && widget.answer.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.answer,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
