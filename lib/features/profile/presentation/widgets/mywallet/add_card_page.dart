import 'package:flutter/material.dart';

class AddCardPage extends StatelessWidget {
  const AddCardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Add the new Credit Card',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  // Imagen de la tarjeta
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/profile/CreditCardUI.png',
                      width: MediaQuery.of(context).size.width - 40,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 22,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.07),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Please fill the form below',
                          style: TextStyle(color: Colors.black54, fontSize: 15),
                        ),
                        const SizedBox(height: 22),
                        Form(
                          key: formKey,
                          child: Column(
                            children: [
                              const _ModernInputField(
                                icon: Icons.person_outline,
                                hintText: 'Name on Card',
                              ),
                              const SizedBox(height: 14),
                              const _ModernInputField(
                                icon: Icons.credit_card,
                                hintText: 'Card Number',
                                maxLength: 16,
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 14),
                              const SizedBox(height: 14),
                              const _ModernInputField(
                                icon: Icons.date_range,
                                hintText: 'Expedition Month',
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 14),
                              const _ModernInputField(
                                icon: Icons.calendar_today,
                                hintText: 'Expedition Year',
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 14),
                              const _ModernInputField(
                                icon: Icons.lock_outline,
                                hintText: 'CVV',
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 28),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    elevation: 2,
                                    backgroundColor: const Color(0xFF43E97B),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text(
                                    'Save Card',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModernInputField extends StatelessWidget {
  final IconData icon;
  final String hintText;
  final TextInputType? keyboardType;
  final int? maxLength;
  const _ModernInputField({
    required this.icon,
    required this.hintText,
    this.keyboardType,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: keyboardType,
      maxLength: maxLength,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.green),
        hintText: hintText,
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
