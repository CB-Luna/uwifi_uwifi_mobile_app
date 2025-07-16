import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:uwifiapp/features/auth/presentation/bloc/auth_state.dart';

import '../../../../../core/utils/app_logger.dart';
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../presentation/bloc/payment_bloc.dart';
import '../../../presentation/bloc/payment_event.dart';
import '../../../presentation/bloc/payment_state.dart';

class AddCardPage extends StatefulWidget {
  const AddCardPage({super.key});

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  String _expiryMonth = '';
  String _expiryYear = '';
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String? _customerId;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // Obtener el customerId del AuthBloc después de que el widget esté completamente construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        setState(() {
          _customerId = authState.user.id;
          AppLogger.navInfo('CustomerId obtenido: $_customerId');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Please fill the form below',
                  style: TextStyle(color: Colors.black54, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              // Tarjeta de crédito con vista previa
              CreditCardWidget(
                cardNumber: cardNumber,
                expiryDate: expiryDate,
                cardHolderName: cardHolderName,
                cvvCode: cvvCode,
                showBackView: isCvvFocused,
                isHolderNameVisible: true,
                cardBgColor: Colors.blueGrey,
                backgroundImage: 'assets/images/profile/CreditCardUI.png',
                onCreditCardWidgetChange: (CreditCardBrand creditCardBrand) {},
                customCardTypeIcons: [
                  CustomCardTypeIcon(
                    cardType: CardType.mastercard,
                    cardImage: const Icon(
                      Icons.credit_card,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                  CustomCardTypeIcon(
                    cardType: CardType.visa,
                    cardImage: const Icon(
                      Icons.credit_card,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          // Campo para nombre en la tarjeta
                          _buildCustomTextField(
                            hintText: 'Card Holder',
                            onChanged: (value) {
                              setState(() {
                                cardHolderName = value;
                                isCvvFocused = false;
                              });
                            },
                            onTap: () {
                              setState(() {
                                isCvvFocused = false;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter card holder name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Campo para número de tarjeta
                          _buildCustomTextField(
                            hintText: 'Card Number',
                            keyboardType: TextInputType.number,
                            maxLength: 16,
                            onChanged: (value) {
                              setState(() {
                                cardNumber = value;
                                isCvvFocused = false;
                              });
                            },
                            onTap: () {
                              setState(() {
                                isCvvFocused = false;
                              });
                            },
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value.length < 16) {
                                return 'Please enter a valid card number';
                              }
                              return null;
                            },
                            counterText: cardNumber.isNotEmpty
                                ? '${cardNumber.length}/16'
                                : null,
                          ),
                          const SizedBox(height: 16),

                          // Fila para fecha de expiración y CVV
                          Row(
                            children: [
                              // Campo para mes de expiración
                              Expanded(
                                child: _buildCustomTextField(
                                  hintText: 'Exp Month',
                                  keyboardType: TextInputType.number,
                                  maxLength: 2,
                                  onChanged: (value) {
                                    setState(() {
                                      isCvvFocused = false;
                                    });
                                    _updateExpiryDate(month: value);
                                  },
                                  onTap: () {
                                    setState(() {
                                      isCvvFocused = false;
                                    });
                                  },
                                  counterText: '',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    final month = int.tryParse(value);
                                    if (month == null ||
                                        month < 1 ||
                                        month > 12) {
                                      return 'Invalid';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Campo para año de expiración
                              Expanded(
                                child: _buildCustomTextField(
                                  hintText: 'Exp Year',
                                  keyboardType: TextInputType.number,
                                  maxLength: 2,
                                  onChanged: (value) {
                                    setState(() {
                                      isCvvFocused = false;
                                    });
                                    _updateExpiryDate(year: value);
                                  },
                                  onTap: () {
                                    setState(() {
                                      isCvvFocused = false;
                                    });
                                  },
                                  counterText: '',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Campo para CVV
                              Expanded(
                                child: _buildCustomTextField(
                                  hintText: 'CVV',
                                  keyboardType: TextInputType.number,
                                  maxLength: 3,
                                  onChanged: (value) {
                                    setState(() {
                                      cvvCode = value;
                                      isCvvFocused = true;
                                    });
                                  },
                                  onTap: () {
                                    setState(() {
                                      isCvvFocused = true;
                                    });
                                  },
                                  counterText: '',
                                  validator: (value) {
                                    if (value == null ||
                                        value.isEmpty ||
                                        value.length < 3) {
                                      return 'Invalid CVV';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Botón para guardar la tarjeta
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.green, width: 2),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.green,
                                elevation: 0,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                ),
                              ),
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  _registerCreditCard(context);
                                }
                              },
                              child: const Text(
                                'Save Card',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Método para construir campos de texto personalizados
  Widget _buildCustomTextField({
    required String hintText,
    required Function(String) onChanged,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    int? maxLength,
    String? counterText,
    Function()? onTap,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: hintText,
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[100],
        counterText: counterText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      keyboardType: keyboardType,
      maxLength: maxLength,
      onChanged: onChanged,
      validator: validator,
      onTap: onTap,
    );
  }

  // Método para actualizar la fecha de expiración
  void _updateExpiryDate({String? month, String? year}) {
    if (month != null) {
      _expiryMonth = month;
    }
    if (year != null) {
      _expiryYear = year;
    }

    if (_expiryMonth.isNotEmpty && _expiryYear.isNotEmpty) {
      setState(() {
        expiryDate = '$_expiryMonth/$_expiryYear';
      });
    }
  }

  // Método para manejar el cambio de foco en el CVV
  void onCvvFocus() {
    setState(() {
      isCvvFocused = true;
    });
  }

  // Método para manejar cuando el CVV pierde el foco
  void onCvvBlur() {
    setState(() {
      isCvvFocused = false;
    });
  }

  void _registerCreditCard(BuildContext context) {
    if (_customerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No se pudo obtener el ID del cliente'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    // Eliminar espacios y guiones del número de tarjeta
    final cleanCardNumber = cardNumber.replaceAll(RegExp(r'\s|-'), '');

    AppLogger.navInfo(
      'Registrando tarjeta: $_customerId, $cleanCardNumber, $_expiryMonth, $_expiryYear, $cvvCode, $cardHolderName',
    );

    // Enviar evento al PaymentBloc
    context.read<PaymentBloc>().add(
      RegisterNewCreditCardEvent(
        customerId: _customerId!,
        cardNumber: cleanCardNumber,
        expMonth: _expiryMonth,
        expYear: _expiryYear,
        cvv: cvvCode,
        cardHolder: cardHolderName,
      ),
    );

    // Mostrar diálogo de carga y escuchar cambios en el estado
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BlocListener<PaymentBloc, PaymentState>(
          listener: (context, state) {
            if (state is PaymentLoaded) {
              Navigator.of(context).pop(); // Cerrar diálogo de carga
              _showSuccessDialog(context);
            } else if (state is PaymentError) {
              Navigator.of(context).pop(); // Cerrar diálogo de carga
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.message}')),
              );
            }
          },
          child: const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Registrando tarjeta...'),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Success'),
          content: const Text('Card added successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Return to previous screen
              },
              child: const Text('OK', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }
}
