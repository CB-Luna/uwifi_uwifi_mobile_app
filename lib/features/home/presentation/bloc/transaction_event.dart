import 'package:equatable/equatable.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class GetTransactionHistoryEvent extends TransactionEvent {
  final String customerId;

  const GetTransactionHistoryEvent(this.customerId);

  @override
  List<Object?> get props => [customerId];
}
