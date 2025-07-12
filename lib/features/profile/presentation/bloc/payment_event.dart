import 'package:equatable/equatable.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object> get props => [];
}

class GetCreditCardsEvent extends PaymentEvent {
  final String customerId;

  const GetCreditCardsEvent(this.customerId);

  @override
  List<Object> get props => [customerId];
}
