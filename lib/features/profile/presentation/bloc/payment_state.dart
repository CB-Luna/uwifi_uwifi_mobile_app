import 'package:equatable/equatable.dart';

import '../../domain/entities/credit_card.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentLoaded extends PaymentState {
  final List<CreditCard> creditCards;

  const PaymentLoaded(this.creditCards);

  @override
  List<Object> get props => [creditCards];
}

class PaymentError extends PaymentState {
  final String message;

  const PaymentError(this.message);

  @override
  List<Object> get props => [message];
}
