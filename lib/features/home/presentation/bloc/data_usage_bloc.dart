import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/data_usage.dart';
import '../../domain/usecases/get_data_usage.dart';
import 'data_usage_event.dart';
import 'data_usage_state.dart';

class DataUsageBloc extends Bloc<DataUsageEvent, DataUsageState> {
  final GetDataUsage getDataUsage;
  
  // Cache para mantener la información entre recargas
  DataUsage? _cachedDataUsage;
  String? _lastCustomerId;
  DateTime? _lastFetchTime;

  DataUsageBloc({required this.getDataUsage}) : super(DataUsageInitial()) {
    on<GetDataUsageEvent>(_onGetDataUsage);
    on<ResetDataUsageEvent>(_onResetDataUsage);
    on<ForceRefreshDataUsageEvent>(_onForceRefreshDataUsage);
  }

  Future<void> _onGetDataUsage(
    GetDataUsageEvent event,
    Emitter<DataUsageState> emit,
  ) async {
    // Si tenemos datos en caché para este customerId y no han pasado más de 30 minutos
    final now = DateTime.now();
    final shouldUseCache = _cachedDataUsage != null && 
                         _lastCustomerId == event.customerId &&
                         _lastFetchTime != null &&
                         now.difference(_lastFetchTime!).inMinutes < 30;
    
    if (shouldUseCache) {
      AppLogger.navInfo('Usando datos de uso en caché para el cliente: ${event.customerId}');
      emit(DataUsageLoaded(_cachedDataUsage!, fromCache: true));
      return;
    }
    
    // Si no hay caché o está desactualizada, mostramos el estado de carga
    // pero preservamos los datos anteriores si existen
    if (_cachedDataUsage != null && _lastCustomerId == event.customerId) {
      emit(DataUsageLoading(previousData: _cachedDataUsage));
    } else {
      emit(const DataUsageLoading());
    }
    
    AppLogger.navInfo('Obteniendo datos de uso para el cliente: ${event.customerId}');
    
    final params = CustomerIdParams(customerId: event.customerId);
    final result = await getDataUsage(params);
    
    result.fold(
      (failure) {
        AppLogger.navError('Error al obtener datos de uso: ${failure.message}');
        
        // Si tenemos datos en caché, los usamos a pesar del error
        if (_cachedDataUsage != null && _lastCustomerId == event.customerId) {
          AppLogger.navInfo('Usando datos en caché debido al error');
          emit(DataUsageLoaded(_cachedDataUsage!, fromCache: true));
        } else {
          emit(DataUsageError(failure.message));
        }
      },
      (dataUsage) {
        AppLogger.navInfo('Datos de uso obtenidos con éxito');
        
        // Actualizar la caché
        _cachedDataUsage = dataUsage;
        _lastCustomerId = event.customerId;
        _lastFetchTime = now;
        
        emit(DataUsageLoaded(dataUsage, fromCache: false));
      },
    );
  }

  Future<void> _onResetDataUsage(
    ResetDataUsageEvent event,
    Emitter<DataUsageState> emit,
  ) async {
    _cachedDataUsage = null;
    _lastCustomerId = null;
    _lastFetchTime = null;
    emit(DataUsageInitial());
  }
  
  Future<void> _onForceRefreshDataUsage(
    ForceRefreshDataUsageEvent event,
    Emitter<DataUsageState> emit,
  ) async {
    // Preservar datos anteriores mientras cargamos
    if (_cachedDataUsage != null) {
      emit(DataUsageLoading(previousData: _cachedDataUsage));
    } else {
      emit(const DataUsageLoading());
    }
    
    AppLogger.navInfo('Forzando recarga de datos de uso para el cliente: ${event.customerId}');
    
    final params = CustomerIdParams(customerId: event.customerId);
    final result = await getDataUsage(params);
    
    result.fold(
      (failure) {
        AppLogger.navError('Error al obtener datos de uso: ${failure.message}');
        
        // Si tenemos datos en caché, los usamos a pesar del error
        if (_cachedDataUsage != null && _lastCustomerId == event.customerId) {
          AppLogger.navInfo('Usando datos en caché debido al error en recarga forzada');
          emit(DataUsageLoaded(_cachedDataUsage!, fromCache: true));
        } else {
          emit(DataUsageError(failure.message));
        }
      },
      (dataUsage) {
        AppLogger.navInfo('Datos de uso actualizados con éxito');
        
        // Actualizar la caché
        _cachedDataUsage = dataUsage;
        _lastCustomerId = event.customerId;
        _lastFetchTime = DateTime.now();
        
        emit(DataUsageLoaded(dataUsage, fromCache: false));
      },
    );
  }
}
