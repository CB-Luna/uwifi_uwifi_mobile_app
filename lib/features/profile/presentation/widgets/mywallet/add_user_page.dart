import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uwifiapp/core/utils/app_logger.dart';
import 'package:uwifiapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:uwifiapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:uwifiapp/features/profile/presentation/bloc/affiliate_bloc.dart';
import 'package:uwifiapp/features/profile/presentation/bloc/affiliate_event.dart';
import 'package:uwifiapp/features/profile/presentation/bloc/affiliate_state.dart';
import 'package:uwifiapp/injection_container.dart' as di;

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final formKey = GlobalKey<FormState>();
  bool isProcessing = false;

  // Controllers for text fields
  final nameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void dispose() {
    // Release controllers when the widget is destroyed
    nameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  // Validators for each field
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
    // Regular expression to validate email
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
    // Validate that it only contains numbers, spaces, hyphens and parentheses
    // and has at least 10 numeric digits
    final cleanValue = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleanValue.length < 10 || !RegExp(r'^[0-9]+$').hasMatch(cleanValue)) {
      return 'Please enter a valid phone number (min. 10 digits)';
    }
    return null;
  }

  // Method to handle form submission
  void _handleSubmit() {
    if (formKey.currentState!.validate()) {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated ||
          authState.user.customerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo identificar al usuario'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final customerId = authState.user.customerId!;
      if (customerId <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ID de cliente inválido'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        isProcessing = true;
      });

      AppLogger.info(
        'Enviando invitación de afiliado para: ${emailController.text}',
      );

      // Enviar la invitación a través del bloc
      context.read<AffiliateBloc>().add(
        SendAffiliateInvitationEvent(
          firstName: nameController.text,
          lastName: lastNameController.text,
          email: emailController.text,
          phone: phoneController.text,
          customerId: customerId,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.getIt<AffiliateBloc>(),
      child: Builder(
        builder: (context) => Scaffold(
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
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            centerTitle: true,
          ),
          backgroundColor: Colors.white,
          body: BlocConsumer<AffiliateBloc, AffiliateState>(
            listener: (context, state) {
              if (state is AffiliateLoading) {
                setState(() {
                  isProcessing = true;
                });
              } else if (state is AffiliateSuccess) {
                setState(() {
                  isProcessing = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
                Future.delayed(const Duration(seconds: 2), () {
                  if (!mounted) return;
                  Navigator.of(context).pop();
                });
              } else if (state is AffiliateError) {
                setState(() {
                  isProcessing = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              return Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 60),
                            const Text(
                              'Add a new affiliate',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Fill in the information to send an invitation',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Form(
                              key: formKey,
                              child: Column(
                                children: [
                                  _ModernInputField(
                                    icon: Icons.person,
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
                                      onPressed: isProcessing
                                          ? null
                                          : _handleSubmit,
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                        ),
                                        elevation: 2,
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: isProcessing
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            )
                                          : const Text(
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
              );
            },
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
