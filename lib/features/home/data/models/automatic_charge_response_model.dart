import 'package:equatable/equatable.dart';

class AutomaticChargeResponseModel extends Equatable {
  final bool success;
  final String message;
  final AutomaticChargeDataModel data;

  const AutomaticChargeResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AutomaticChargeResponseModel.fromJson(Map<String, dynamic> json) {
    return AutomaticChargeResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: AutomaticChargeDataModel.fromJson(json['data'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [success, message, data];
}

class AutomaticChargeDataModel extends Equatable {
  final int customerId;
  final String createdAt;
  final int day;
  final int billDueDay;
  final int frequency;
  final bool automaticCharge;
  final int graceDays;

  const AutomaticChargeDataModel({
    required this.customerId,
    required this.createdAt,
    required this.day,
    required this.billDueDay,
    required this.frequency,
    required this.automaticCharge,
    required this.graceDays,
  });

  factory AutomaticChargeDataModel.fromJson(Map<String, dynamic> json) {
    return AutomaticChargeDataModel(
      customerId: json['customer_id'] ?? 0,
      createdAt: json['created_at'] ?? '',
      day: json['day'] ?? 0,
      billDueDay: json['bill_due_day'] ?? 0,
      frequency: json['frequency'] ?? 0,
      automaticCharge: json['automatic_charge'] ?? false,
      graceDays: json['grace_days'] ?? 0,
    );
  }

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
