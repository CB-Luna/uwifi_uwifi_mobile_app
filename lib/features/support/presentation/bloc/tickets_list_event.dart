import 'package:equatable/equatable.dart';

abstract class TicketsListEvent extends Equatable {
  const TicketsListEvent();

  @override
  List<Object?> get props => [];
}

class LoadTicketsEvent extends TicketsListEvent {
  final int customerId;

  const LoadTicketsEvent(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

class RefreshTicketsEvent extends TicketsListEvent {
  final int customerId;

  const RefreshTicketsEvent(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

class FilterTicketsEvent extends TicketsListEvent {
  final String status;
  final int customerId;

  const FilterTicketsEvent({
    required this.status,
    required this.customerId,
  });

  @override
  List<Object?> get props => [status, customerId];
}
