import 'package:equatable/equatable.dart';

abstract class TicketCategoryEvent extends Equatable {
  const TicketCategoryEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar las categorías de tickets de soporte
class LoadTicketCategoriesEvent extends TicketCategoryEvent {
  const LoadTicketCategoriesEvent();
}
