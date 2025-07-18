part of 'customer_details_bloc.dart';

abstract class CustomerDetailsState extends Equatable {
  const CustomerDetailsState();
  
  @override
  List<Object> get props => [];
}

class CustomerDetailsInitial extends CustomerDetailsState {}

class CustomerDetailsLoading extends CustomerDetailsState {}

class CustomerDetailsLoaded extends CustomerDetailsState {
  final CustomerDetails customerDetails;

  const CustomerDetailsLoaded(this.customerDetails);

  @override
  List<Object> get props => [customerDetails];
}

class CustomerDetailsError extends CustomerDetailsState {
  final String message;

  const CustomerDetailsError(this.message);

  @override
  List<Object> get props => [message];
}
