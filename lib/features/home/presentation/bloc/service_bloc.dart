import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uwifiapp/core/errors/failures.dart';
import 'package:uwifiapp/core/utils/app_logger.dart';

import '../../domain/usecases/get_customer_active_services.dart';
import 'service_event.dart';
import 'service_state.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final GetCustomerActiveServices getCustomerActiveServices;

  ServiceBloc({required this.getCustomerActiveServices})
    : super(ServiceInitial()) {
    on<GetCustomerActiveServicesEvent>(_onGetCustomerActiveServices);
  }

  Future<void> _onGetCustomerActiveServices(
    GetCustomerActiveServicesEvent event,
    Emitter<ServiceState> emit,
  ) async {
    AppLogger.navInfo(
      'Iniciando petición de servicios activos para customerId: ${event.customerId}',
    );

    emit(ServiceLoading());

    final result = await getCustomerActiveServices(event.customerId);

    result.fold(
      (failure) {
        AppLogger.navError(
          'Error al obtener servicios activos: ${_mapFailureToMessage(failure)}',
        );
        emit(ServiceError(message: _mapFailureToMessage(failure)));
      },
      (services) {
        AppLogger.navInfo(
          'Servicios activos obtenidos con éxito: ${services.length} servicios',
        );
        if (services.isEmpty) {
          AppLogger.navInfo('La lista de servicios activos está vacía');
        } else {
          for (final service in services) {
            AppLogger.navInfo(
              'Servicio: ${service.name}, Tipo: ${service.type}, Valor: ${service.value}',
            );
          }
        }
        emit(ServiceLoaded(services: services));
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case const (ServerFailure):
        return failure.toString();
      case const (NetworkFailure):
        return 'Not connected to the internet';
      default:
        return 'Unexpected error';
    }
  }
}
