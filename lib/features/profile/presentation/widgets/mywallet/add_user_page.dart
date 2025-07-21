import 'package:flutter/material.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final formKey = GlobalKey<FormState>();

  // Controladores para los campos de texto
  final nameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void dispose() {
    // Liberar los controladores cuando se destruye el widget
    nameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  // Validadores para cada campo
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a name';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a last name';
    }
    if (value.length < 2) {
      return 'Last name must be at least 2 characters';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    }
    // Expresión regular para validar email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a phone number';
    }
    // Validar que solo contenga números, espacios, guiones y paréntesis
    // y tenga al menos 10 dígitos numéricos
    final cleanValue = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleanValue.length < 10 || !RegExp(r'^[0-9]+$').hasMatch(cleanValue)) {
      return 'Please enter a valid phone number (min. 10 digits)';
    }
    return null;
  }

  // Método para manejar el envío del formulario
  void _handleSubmit() {
    if (formKey.currentState!.validate()) {
      // Si el formulario es válido, mostrar un snackbar de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invitation sent successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Aquí iría la lógica para enviar la invitación
      // Por ahora solo cerramos la página después de un breve delay
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'New affiliated user',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Avatar/Ilustración
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 38,
                    backgroundColor: Color(0xFF4CAF50),
                    child: Icon(Icons.group_add, color: Colors.white, size: 38),
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
                        "Invite a new user to your group",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "They'll be able to download the U-app, watch ads, and earn points for your main account!",
                        style: TextStyle(color: Colors.black54, fontSize: 15),
                      ),
                      const SizedBox(height: 22),
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            _ModernInputField(
                              icon: Icons.person_outline,
                              hintText: 'Name',
                              controller: nameController,
                              validator: validateName,
                            ),
                            const SizedBox(height: 14),
                            _ModernInputField(
                              icon: Icons.person,
                              hintText: 'Last Name',
                              controller: lastNameController,
                              validator: validateLastName,
                            ),
                            const SizedBox(height: 14),
                            _ModernInputField(
                              icon: Icons.email_outlined,
                              hintText: 'Email',
                              keyboardType: TextInputType.emailAddress,
                              controller: emailController,
                              validator: validateEmail,
                            ),
                            const SizedBox(height: 14),
                            _ModernInputField(
                              icon: Icons.phone,
                              hintText: 'Phone number',
                              keyboardType: TextInputType.phone,
                              controller: phoneController,
                              validator: validatePhone,
                            ),
                            const SizedBox(height: 28),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _handleSubmit,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  elevation: 2,
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text(
                                  'Send Invitation',
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
    );
  }
}

class _ModernInputField extends StatelessWidget {
  final IconData icon;
  final String hintText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final TextEditingController? controller;

  const _ModernInputField({
    required this.icon,
    required this.hintText,
    this.keyboardType,
    this.validator,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.green),
        hintText: hintText,
        labelText: hintText,
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
