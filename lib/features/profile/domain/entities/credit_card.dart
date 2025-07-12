import 'package:equatable/equatable.dart';

class CreditCard extends Equatable {
  final int id;
  final String cardHolder;
  final DateTime createdAt;
  final String expirationMonth;
  final String expirationYear;
  final String token;
  final int customerFk;
  final bool isActive;
  final bool isDefault;

  const CreditCard({
    required this.id,
    required this.cardHolder,
    required this.createdAt,
    required this.expirationMonth,
    required this.expirationYear,
    required this.token,
    required this.customerFk,
    required this.isActive,
    required this.isDefault,
  });

  @override
  List<Object?> get props => [
    id,
    cardHolder,
    createdAt,
    expirationMonth,
    expirationYear,
    token,
    customerFk,
    isActive,
    isDefault,
  ];

  // Método para obtener los últimos 4 dígitos de la tarjeta
  String get last4Digits {
    if (token.length >= 4) {
      return token.substring(token.length - 4);
    }
    return '';
  }
}
