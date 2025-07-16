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
