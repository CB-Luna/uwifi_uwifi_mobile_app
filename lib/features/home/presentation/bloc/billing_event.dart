import 'package:equatable/equatable.dart';

abstract class BillingEvent extends Equatable {
  const BillingEvent();

  @override
  List<Object> get props => [];
}

class GetBillingPeriodEvent extends BillingEvent {
  final String customerId;

  const GetBillingPeriodEvent({required this.customerId});

  @override
  List<Object> get props => [customerId];
}

class GetCustomerBalanceEvent extends BillingEvent {
  final String customerId;

  const GetCustomerBalanceEvent({required this.customerId});

  @override
  List<Object> get props => [customerId];
}

class UpdateAutomaticChargeEvent extends BillingEvent {
  final String customerId;
  final bool value;

  const UpdateAutomaticChargeEvent({
    required this.customerId,
    required this.value,
  });

  @override
  List<Object> get props => [customerId, value];
}

class CreateManualBillingEvent extends BillingEvent {
  final int customerId;
  final String billingDate;
  final double discount;
  final bool autoPayment;

  const CreateManualBillingEvent({
    required this.customerId,
    required this.billingDate,
    required this.discount,
    required this.autoPayment,
  });

  @override
  List<Object> get props => [customerId, billingDate, discount, autoPayment];
}
