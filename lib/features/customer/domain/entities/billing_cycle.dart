import 'package:equatable/equatable.dart';

class BillingCycle extends Equatable {
  final int customerId;
  final DateTime createdAt;
  final int day;
  final int billDueDay;
  final int frequency;
  final bool automaticCharge;
  final int graceDays;

  const BillingCycle({
    required this.customerId,
    required this.createdAt,
    required this.day,
    required this.billDueDay,
    required this.frequency,
    required this.automaticCharge,
    required this.graceDays,
  });

  @override
  List<Object?> get props => [
        customerId,
        createdAt,
        day,
        billDueDay,
        frequency,
        automaticCharge,
        graceDays,
      ];
}
