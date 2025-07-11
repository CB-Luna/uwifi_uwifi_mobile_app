import '../../domain/entities/billing_period.dart';

class BillingPeriodModel extends BillingPeriod {
  const BillingPeriodModel({
    required super.dueDate,
    required CurrentBillingPeriodModel super.currentBillingPeriod,
  });

  factory BillingPeriodModel.fromJson(Map<String, dynamic> json) {
    return BillingPeriodModel(
      dueDate: json['due_date'] ?? '',
      currentBillingPeriod: CurrentBillingPeriodModel.fromJson(
        json['current_billing_period'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'due_date': dueDate,
      'current_billing_period':
          (currentBillingPeriod as CurrentBillingPeriodModel).toJson(),
    };
  }
}

class CurrentBillingPeriodModel extends CurrentBillingPeriod {
  const CurrentBillingPeriodModel({
    required super.startDate,
    required super.endDate,
    super.balance,
  });

  factory CurrentBillingPeriodModel.fromJson(Map<String, dynamic> json) {
    return CurrentBillingPeriodModel(
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      balance: json['balance'] != null ? (json['balance'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start_date': startDate,
      'end_date': endDate,
      'balance': balance,
    };
  }
}
