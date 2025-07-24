import 'package:equatable/equatable.dart';

import '../../domain/entities/ticket_category.dart';

abstract class TicketCategoryState extends Equatable {
  const TicketCategoryState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class TicketCategoryInitial extends TicketCategoryState {
  const TicketCategoryInitial();
}

/// Estado de carga
class TicketCategoryLoading extends TicketCategoryState {
  const TicketCategoryLoading();
}

/// Estado cuando las categorías se han cargado correctamente
class TicketCategoryLoaded extends TicketCategoryState {
  final List<TicketCategory> categories;

  const TicketCategoryLoaded({required this.categories});

  @override
  List<Object?> get props => [categories];
}

/// Estado de error
class TicketCategoryError extends TicketCategoryState {
  final String message;

  const TicketCategoryError({required this.message});

  @override
  List<Object?> get props => [message];
}
