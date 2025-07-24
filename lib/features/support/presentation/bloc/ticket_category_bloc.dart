import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_ticket_categories.dart';
import 'ticket_category_event.dart';
import 'ticket_category_state.dart';

class TicketCategoryBloc extends Bloc<TicketCategoryEvent, TicketCategoryState> {
  final GetTicketCategories getTicketCategories;

  TicketCategoryBloc({
    required this.getTicketCategories,
  }) : super(const TicketCategoryInitial()) {
    on<LoadTicketCategoriesEvent>(_onLoadTicketCategories);
  }

  Future<void> _onLoadTicketCategories(
    LoadTicketCategoriesEvent event,
    Emitter<TicketCategoryState> emit,
  ) async {
    emit(const TicketCategoryLoading());
    
    final result = await getTicketCategories(NoParams());
    
    result.fold(
      (failure) => emit(TicketCategoryError(message: failure.message)),
      (categories) => emit(TicketCategoryLoaded(categories: categories)),
    );
  }
}
