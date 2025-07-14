import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/usecases/get_data_usage.dart';
import 'data_usage_event.dart';
import 'data_usage_state.dart';

class DataUsageBloc extends Bloc<DataUsageEvent, DataUsageState> {
  final GetDataUsage getDataUsage;

  DataUsageBloc({required this.getDataUsage}) : super(DataUsageInitial()) {
    on<GetDataUsageEvent>(_onGetDataUsage);
    on<ResetDataUsageEvent>(_onResetDataUsage);
  }

  Future<void> _onGetDataUsage(
    GetDataUsageEvent event,
    Emitter<DataUsageState> emit,
  ) async {
    emit(DataUsageLoading());
    
    AppLogger.navInfo('Obteniendo datos de uso para el cliente: ${event.customerId}');
    
    final params = CustomerIdParams(customerId: event.customerId);
    final result = await getDataUsage(params);
    
    result.fold(
      (failure) {
        AppLogger.navError('Error al obtener datos de uso: ${failure.message}');
        emit(DataUsageError(failure.message));
      },
      (dataUsage) {
        AppLogger.navInfo('Datos de uso obtenidos con éxito');
        emit(DataUsageLoaded(dataUsage));
      },
    );
  }

  Future<void> _onResetDataUsage(
    ResetDataUsageEvent event,
    Emitter<DataUsageState> emit,
  ) async {
    emit(DataUsageInitial());
  }
}
