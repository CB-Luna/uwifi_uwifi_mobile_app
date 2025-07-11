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
