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

class SetDefaultCardEvent extends PaymentEvent {
  final String customerId;
  final String cardId;

  const SetDefaultCardEvent({
    required this.customerId,
    required this.cardId,
  });

  @override
  List<Object> get props => [customerId, cardId];
}

class DeleteCreditCardEvent extends PaymentEvent {
  final String customerId;
  final String cardId;

  const DeleteCreditCardEvent({
    required this.customerId,
    required this.cardId,
  });

  @override
  List<Object> get props => [customerId, cardId];
}

class RegisterNewCreditCardEvent extends PaymentEvent {
  final String customerId;
  final String cardNumber;
  final String expMonth;
  final String expYear;
  final String cvv;
  final String cardHolder;

  const RegisterNewCreditCardEvent({
    required this.customerId,
    required this.cardNumber,
    required this.expMonth,
    required this.expYear,
    required this.cvv,
    required this.cardHolder,
  });

  @override
  List<Object> get props => [customerId, cardNumber, expMonth, expYear, cvv, cardHolder];
}
