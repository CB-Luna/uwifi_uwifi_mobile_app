import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/usecases/get_customer_tickets.dart';
import 'tickets_list_event.dart';
import 'tickets_list_state.dart';

class TicketsListBloc extends Bloc<TicketsListEvent, TicketsListState> {
  final GetCustomerTickets getCustomerTickets;

  TicketsListBloc({
    required this.getCustomerTickets,
  }) : super(const TicketsListInitial()) {
    on<LoadTicketsEvent>(_onLoadTickets);
    on<RefreshTicketsEvent>(_onRefreshTickets);
    on<FilterTicketsEvent>(_onFilterTickets);
  }

  Future<void> _onLoadTickets(
    LoadTicketsEvent event,
    Emitter<TicketsListState> emit,
  ) async {
    emit(const TicketsListLoading());
    await _fetchTickets(event.customerId, emit);
  }

  Future<void> _onRefreshTickets(
    RefreshTicketsEvent event,
    Emitter<TicketsListState> emit,
  ) async {
    await _fetchTickets(event.customerId, emit, showLoading: false);
  }

  Future<void> _onFilterTickets(
    FilterTicketsEvent event,
    Emitter<TicketsListState> emit,
  ) async {
    emit(const TicketsListLoading());
    
    final result = await getCustomerTickets(
      CustomerTicketsParams(
        customerId: event.customerId,
        status: event.status,
      ),
    );

    result.fold(
      (failure) {
        final message = _mapFailureToMessage(failure);
        AppLogger.navError('Error loading filtered tickets: $message');
        emit(TicketsListError(message));
      },
      (tickets) {
        AppLogger.navInfo('Filtered tickets loaded successfully: ${tickets.length} tickets');
        emit(TicketsListLoaded(tickets));
      },
    );
  }

  Future<void> _fetchTickets(
    int customerId,
    Emitter<TicketsListState> emit, {
    bool showLoading = true,
  }) async {
    if (showLoading) {
      emit(const TicketsListLoading());
    }

    final result = await getCustomerTickets(
      CustomerTicketsParams(customerId: customerId),
    );

    result.fold(
      (failure) {
        final message = _mapFailureToMessage(failure);
        AppLogger.navError('Error loading tickets: $message');
        emit(TicketsListError(message));
      },
      (tickets) {
        AppLogger.navInfo('Tickets loaded successfully: ${tickets.length} tickets');
        emit(TicketsListLoaded(tickets));
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case const (ServerFailure):
        return (failure as ServerFailure).message;
      case const (NetworkFailure):
        return 'Please check your internet connection';
      default:
        return 'Unexpected error';
    }
  }
}
