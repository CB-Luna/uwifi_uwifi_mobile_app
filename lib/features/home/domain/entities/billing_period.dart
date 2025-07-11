import 'package:equatable/equatable.dart';

class BillingPeriod extends Equatable {
  final String dueDate;
  final CurrentBillingPeriod currentBillingPeriod;
  final double? balance;

  const BillingPeriod({
    required this.dueDate,
    required this.currentBillingPeriod,
    this.balance,
  });

  @override
  List<Object?> get props => [dueDate, currentBillingPeriod, balance];
}

class CurrentBillingPeriod extends Equatable {
  final String startDate;
  final String endDate;
  final double? balance; // Monto a pagar

  const CurrentBillingPeriod({
    required this.startDate,
    required this.endDate,
    this.balance,
  });

  @override
  List<Object?> get props => [startDate, endDate, balance];
}
