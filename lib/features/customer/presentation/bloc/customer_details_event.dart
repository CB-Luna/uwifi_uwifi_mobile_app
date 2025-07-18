part of 'customer_details_bloc.dart';

abstract class CustomerDetailsEvent extends Equatable {
  const CustomerDetailsEvent();

  @override
  List<Object> get props => [];
}

class FetchCustomerDetails extends CustomerDetailsEvent {
  final int customerId;

  const FetchCustomerDetails(this.customerId);

  @override
  List<Object> get props => [customerId];
}
