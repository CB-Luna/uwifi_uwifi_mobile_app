import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/customer_details.dart';
import '../../domain/usecases/get_customer_details.dart';

part 'customer_details_event.dart';
part 'customer_details_state.dart';

class CustomerDetailsBloc
    extends Bloc<CustomerDetailsEvent, CustomerDetailsState> {
  final GetCustomerDetails getCustomerDetails;

  CustomerDetailsBloc({required this.getCustomerDetails})
    : super(CustomerDetailsInitial()) {
    on<FetchCustomerDetails>(_onFetchCustomerDetails);
  }

  Future<void> _onFetchCustomerDetails(
    FetchCustomerDetails event,
    Emitter<CustomerDetailsState> emit,
  ) async {
    AppLogger.navInfo('Solicitando detalles del cliente: ${event.customerId}');
    emit(CustomerDetailsLoading());

    final result = await getCustomerDetails(
      Params(customerId: event.customerId),
    );

    result.fold(
      (failure) {
        AppLogger.navError('Error al obtener detalles del cliente: $failure');
        emit(CustomerDetailsError(_mapFailureToMessage(failure)));
      },
      (customerDetails) {
        AppLogger.navInfo('Detalles del cliente obtenidos con éxito');
        emit(CustomerDetailsLoaded(customerDetails));
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case const (ServerFailure):
        // La propiedad message nunca es null según la definición de Failure
        return failure.message;
      case const (CacheFailure):
        return failure.message;
      case const (NetworkFailure):
        return failure.message;
      default:
        return 'Error inesperado';
    }
  }
}
