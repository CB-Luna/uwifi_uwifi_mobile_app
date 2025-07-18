import '../../domain/entities/billing_cycle.dart';

class BillingCycleModel extends BillingCycle {
  const BillingCycleModel({
    required super.customerId,
    required super.createdAt,
    required super.day,
    required super.billDueDay,
    required super.frequency,
    required super.automaticCharge,
    required super.graceDays,
  });

  factory BillingCycleModel.fromJson(Map<String, dynamic> json) {
    return BillingCycleModel(
      customerId: json['customer_id'],
      createdAt: DateTime.parse(json['created_at']),
      day: json['day'],
      billDueDay: json['bill_due_day'],
      frequency: json['frequency'],
      automaticCharge: json['automatic_charge'],
      graceDays: json['grace_days'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customer_id': customerId,
      'created_at': createdAt.toIso8601String(),
      'day': day,
      'bill_due_day': billDueDay,
      'frequency': frequency,
      'automatic_charge': automaticCharge,
      'grace_days': graceDays,
    };
  }
  
  Map<String, dynamic> toJson() => toMap();
}
