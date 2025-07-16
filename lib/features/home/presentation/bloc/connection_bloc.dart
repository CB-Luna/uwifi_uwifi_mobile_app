import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/gateway_info.dart';
import '../../domain/usecases/get_customer_bundle.dart';
import '../../domain/usecases/get_gateway_info.dart';
import '../../domain/usecases/update_wifi_network_name.dart';
import '../../domain/usecases/update_wifi_password.dart';
import 'connection_event.dart';
import 'connection_state.dart';

class ConnectionBloc extends Bloc<ConnectionEvent, ConnectionState> {
  final GetCustomerBundle getCustomerBundle;
  final GetGatewayInfo getGatewayInfo;
  final UpdateWifiNetworkName updateWifiNetworkName;
  final UpdateWifiPassword updateWifiPassword;
  
  // Cache para mantener la información entre recargas
  GatewayInfo? _cachedGatewayInfo;

  ConnectionBloc({
    required this.getCustomerBundle,
    required this.getGatewayInfo,
    required this.updateWifiNetworkName,
    required this.updateWifiPassword,
  }) : super(const ConnectionInitial()) {
    on<GetConnectionInfoEvent>(_onGetConnectionInfo);
    on<UpdateWifiNetworkNameEvent>(_onUpdateWifiNetworkName);
    on<UpdateWifiPasswordEvent>(_onUpdateWifiPassword);
  }

  Future<void> _onGetConnectionInfo(
    GetConnectionInfoEvent event,
    Emitter<ConnectionState> emit,
  ) async {
    // Preservar estado anterior si existe
    final currentState = state;
    if (currentState is ConnectionLoaded) {
      _cachedGatewayInfo = currentState.gatewayInfo;
      emit(ConnectionLoading(previousInfo: _cachedGatewayInfo));
    } else if (_cachedGatewayInfo != null) {
      emit(ConnectionLoading(previousInfo: _cachedGatewayInfo));
    } else {
      emit(const ConnectionLoading());
    }

    AppLogger.navInfo(
      'Solicitando información de conexión para customerId: ${event.customerId}',
    );

    // Paso 1: Obtener el bundle del cliente
    final bundleResult = await getCustomerBundle(event.customerId);

    await bundleResult.fold(
      (failure) async {
        AppLogger.navError(
          'Error al obtener bundle del cliente: ${failure.message}',
        );
        
        // Si tenemos información en caché, la usamos
        if (_cachedGatewayInfo != null) {
          emit(ConnectionLoaded(gatewayInfo: _cachedGatewayInfo!));
        } else {
          emit(ConnectionError(message: failure.message));
        }
      },
      (bundles) async {
        // Verificar si hay bundles disponibles
        if (bundles.isEmpty) {
          AppLogger.navError('No se encontraron bundles para el cliente');
          
          // Si tenemos información en caché, la usamos
          if (_cachedGatewayInfo != null) {
            emit(ConnectionLoaded(gatewayInfo: _cachedGatewayInfo!));
          } else {
            emit(const ConnectionError(message: 'No se encontraron dispositivos'));
          }
          return;
        }

        // Tomar el primer bundle (asumimos que es el principal)
        final bundle = bundles.first;
        
        // Verificar si tenemos un número de serie
        if (bundle.gatewaySerialNumber.isEmpty) {
          AppLogger.navError('El bundle no tiene número de serie');
          
          // Si tenemos información en caché, la usamos
          if (_cachedGatewayInfo != null) {
            emit(ConnectionLoaded(gatewayInfo: _cachedGatewayInfo!));
          } else {
            emit(const ConnectionError(message: 'Dispositivo sin número de serie'));
          }
          return;
        }

        // Paso 2: Obtener la información del gateway usando el número de serie
        final gatewayInfoResult = await getGatewayInfo(bundle.gatewaySerialNumber);

        gatewayInfoResult.fold(
          (failure) {
            AppLogger.navError(
              'Error al obtener información del gateway: ${failure.message}',
            );
            
            // Si tenemos información en caché, la usamos
            if (_cachedGatewayInfo != null) {
              emit(ConnectionLoaded(gatewayInfo: _cachedGatewayInfo!));
            } else {
              emit(ConnectionError(message: failure.message));
            }
          },
          (gatewayInfo) {
            AppLogger.navInfo(
              'Información del gateway obtenida: ${gatewayInfo.wifiName} - ${gatewayInfo.connectionStatus}',
            );
            
            // Actualizar el caché
            _cachedGatewayInfo = gatewayInfo;
            
            emit(ConnectionLoaded(gatewayInfo: gatewayInfo));
          },
        );
      },
    );
  }
  
  Future<void> _onUpdateWifiNetworkName(
    UpdateWifiNetworkNameEvent event,
    Emitter<ConnectionState> emit,
  ) async {
    // Preservar estado anterior
    final currentState = state;
    GatewayInfo? previousInfo;
    
    if (currentState is ConnectionLoaded) {
      previousInfo = currentState.gatewayInfo;
      emit(ConnectionLoading(previousInfo: previousInfo));
    } else {
      emit(const ConnectionLoading());
      return; // No podemos actualizar sin información previa
    }
    
    AppLogger.navInfo(
      'Actualizando nombre de red WiFi: ${event.isNetwork24G ? "2.4GHz" : "5GHz"} a ${event.newName}',
    );
    
    final params = UpdateWifiNetworkNameParams(
      serialNumber: event.serialNumber,
      newName: event.newName,
      isNetwork24G: event.isNetwork24G,
    );
    
    final result = await updateWifiNetworkName(params);
    
    result.fold(
      (failure) {
        AppLogger.navError(
          'Error al actualizar nombre de red WiFi: ${failure.message}',
        );
        emit(ConnectionError(message: failure.message));
      },
      (success) {
        AppLogger.navInfo('Nombre de red WiFi actualizado con éxito');
        
        // Actualizar la información en caché con el nuevo nombre
        GatewayInfo updatedInfo;
        if (event.isNetwork24G) {
          updatedInfo = previousInfo!.copyWith(wifi24GName: event.newName);
        } else {
          updatedInfo = previousInfo!.copyWith(wifi5GName: event.newName);
        }
        
        _cachedGatewayInfo = updatedInfo;
        emit(ConnectionLoaded(gatewayInfo: updatedInfo));
      },
    );
  }
  
  Future<void> _onUpdateWifiPassword(
    UpdateWifiPasswordEvent event,
    Emitter<ConnectionState> emit,
  ) async {
    // Preservar estado anterior
    final currentState = state;
    GatewayInfo? previousInfo;
    
    if (currentState is ConnectionLoaded) {
      previousInfo = currentState.gatewayInfo;
      emit(ConnectionLoading(previousInfo: previousInfo));
    } else {
      emit(const ConnectionLoading());
      return; // No podemos actualizar sin información previa
    }
    
    AppLogger.navInfo(
      'Actualizando contraseña WiFi: ${event.isNetwork24G ? "2.4GHz" : "5GHz"}',
    );
    
    final params = UpdateWifiPasswordParams(
      serialNumber: event.serialNumber,
      newPassword: event.newPassword,
      isNetwork24G: event.isNetwork24G,
    );
    
    final result = await updateWifiPassword(params);
    
    result.fold(
      (failure) {
        AppLogger.navError(
          'Error al actualizar contraseña WiFi: ${failure.message}',
        );
        emit(ConnectionError(message: failure.message));
      },
      (success) {
        AppLogger.navInfo('Contraseña WiFi actualizada con éxito');
        
        // Actualizar la información en caché con la nueva contraseña
        GatewayInfo updatedInfo;
        if (event.isNetwork24G) {
          updatedInfo = previousInfo!.copyWith(wifi24GPassword: event.newPassword);
        } else {
          updatedInfo = previousInfo!.copyWith(wifi5GPassword: event.newPassword);
        }
        
        _cachedGatewayInfo = updatedInfo;
        emit(ConnectionLoaded(gatewayInfo: updatedInfo));
      },
    );
  }
}
