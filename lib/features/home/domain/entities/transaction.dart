import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final int transactionId;
  final int customerId;
  final DateTime createdAt;
  final int transactionTypeFk;
  final double amount;
  final int? serviceFk;

  const Transaction({
    required this.transactionId,
    required this.customerId,
    required this.createdAt,
    required this.transactionTypeFk,
    required this.amount,
    this.serviceFk,
  });

  @override
  List<Object?> get props => [
    transactionId,
    customerId,
    createdAt,
    transactionTypeFk,
    amount,
    serviceFk,
  ];

  // Método para obtener el tipo de transacción como texto
  String get transactionType {
    switch (transactionTypeFk) {
      case 1:
        return 'Payment';
      case 4:
        return 'Recurring Charge';
      case 8:
        return 'Tax';
      default:
        return 'Other';
    }
  }

  // Método para formatear la fecha
  String get formattedDate {
    return '${createdAt.month.toString().padLeft(2, '0')}/${createdAt.day.toString().padLeft(2, '0')}/${createdAt.year}';
  }
}
