import 'package:equatable/equatable.dart';

abstract class ServiceEvent extends Equatable {
  const ServiceEvent();

  @override
  List<Object> get props => [];
}

class GetCustomerActiveServicesEvent extends ServiceEvent {
  final String customerId;

  const GetCustomerActiveServicesEvent({required this.customerId});

  @override
  List<Object> get props => [customerId];
}
