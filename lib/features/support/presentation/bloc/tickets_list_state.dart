import 'package:equatable/equatable.dart';

import '../../domain/entities/support_ticket.dart';

abstract class TicketsListState extends Equatable {
  const TicketsListState();

  @override
  List<Object?> get props => [];
}

class TicketsListInitial extends TicketsListState {
  const TicketsListInitial();
}

class TicketsListLoading extends TicketsListState {
  const TicketsListLoading();
}

class TicketsListLoaded extends TicketsListState {
  final List<SupportTicket> tickets;

  const TicketsListLoaded(this.tickets);

  @override
  List<Object?> get props => [tickets];
}

class TicketsListError extends TicketsListState {
  final String message;

  const TicketsListError(this.message);

  @override
  List<Object?> get props => [message];
}
