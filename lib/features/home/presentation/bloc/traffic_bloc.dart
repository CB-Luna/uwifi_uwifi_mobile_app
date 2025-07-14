import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uwifiapp/core/utils/app_logger.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/usecases/get_traffic_information.dart';
import 'traffic_event.dart';
import 'traffic_state.dart';

class TrafficBloc extends Bloc<TrafficEvent, TrafficState> {
  final GetTrafficInformation getTrafficInformation;

  TrafficBloc({required this.getTrafficInformation}) : super(TrafficInitial()) {
    on<GetTrafficInformationEvent>(_onGetTrafficInformation);
  }

  Future<void> _onGetTrafficInformation(
    GetTrafficInformationEvent event,
    Emitter<TrafficState> emit,
  ) async {
    AppLogger.navInfo(
      '[DEBUG] 📡 TrafficBloc: Iniciando petición de datos de tráfico',
    );
    AppLogger.navInfo(
      '[DEBUG] 📡 TrafficBloc: customerId=${event.customerId}, startDate=${event.startDate}, endDate=${event.endDate}',
    );

    emit(TrafficLoading());

    final result = await getTrafficInformation(
      TrafficParams(
        customerId: event.customerId,
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );

    result.fold(
      (failure) {
        AppLogger.navError(
          '[DEBUG] ❌ TrafficBloc: Error al obtener datos de tráfico: ${_mapFailureToMessage(failure)}',
        );
        emit(TrafficError(message: _mapFailureToMessage(failure)));
      },
      (trafficData) {
        AppLogger.navInfo(
          '[DEBUG] ✅ TrafficBloc: Datos de tráfico obtenidos con éxito: ${trafficData.length} registros',
        );
        if (trafficData.isEmpty) {
          AppLogger.navInfo(
            '[DEBUG] ⚠️ TrafficBloc: La lista de datos de tráfico está vacía',
          );
        } else {
          for (final data in trafficData) {
            AppLogger.navInfo(
              '[DEBUG] 💾 TrafficBloc: Mes: ${data.month}, Download: ${data.downloadGB} GB, Upload: ${data.uploadGB} GB',
            );
          }
        }
        emit(TrafficLoaded(trafficData: trafficData));
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure():
        return failure.toString();
      case NetworkFailure():
        return 'No hay conexión a internet';
      default:
        return 'Error inesperado';
    }
  }
}
