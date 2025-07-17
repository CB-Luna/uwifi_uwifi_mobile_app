import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/gateway_info.dart';
import '../../domain/usecases/get_customer_bundle.dart';
import '../../domain/usecases/get_gateway_info.dart';
import '../../domain/usecases/reboot_gateway.dart';
import '../../domain/usecases/update_wifi_network_name.dart';
import '../../domain/usecases/update_wifi_password.dart';
import 'connection_event.dart';
import 'connection_state.dart';

class ConnectionBloc extends Bloc<ConnectionEvent, ConnectionState> {
  final GetCustomerBundle getCustomerBundle;
  final GetGatewayInfo getGatewayInfo;
  final UpdateWifiNetworkName updateWifiNetworkName;
  final UpdateWifiPassword updateWifiPassword;
  final RebootGateway rebootGateway;
  final SecureStorageService secureStorage;
  
  // Cache para mantener la información entre recargas
  GatewayInfo? _cachedGatewayInfo;

  ConnectionBloc({
    required this.getCustomerBundle,
    required this.getGatewayInfo,
    required this.updateWifiNetworkName,
    required this.updateWifiPassword,
    required this.rebootGateway,
    required this.secureStorage,
  }) : super(const ConnectionInitial()) {
    on<GetConnectionInfoEvent>(_onGetConnectionInfo);
    on<UpdateWifiNetworkNameEvent>(_onUpdateWifiNetworkName);
    on<UpdateWifiPasswordEvent>(_onUpdateWifiPassword);
    on<RebootGatewayEvent>(_onRebootGateway);
  }

  Future<void> _onGetConnectionInfo(
    GetConnectionInfoEvent event,
    Emitter<ConnectionState> emit,
  ) async {
    try {
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
            'Error al obtener el bundle del cliente: ${failure.message}',
          );
          emit(ConnectionError(message: failure.message));
        },
        (bundles) async {
          if (bundles.isEmpty) {
            AppLogger.navError('No se encontraron bundles para el cliente');
            emit(const ConnectionError(message: 'No se encontraron bundles'));
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

          await gatewayInfoResult.fold(
            (failure) async {
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
            (gatewayInfo) async {
              try {
                AppLogger.navInfo(
                  'Información del gateway obtenida: ${gatewayInfo.wifiName} - ${gatewayInfo.connectionStatus}',
                );
                
                // Intentar recuperar las contraseñas guardadas
                final wifi24GPassword = await secureStorage.getWifi24GPassword();
                final wifi5GPassword = await secureStorage.getWifi5GPassword();
                
                // Guardar el número de serie para futuras operaciones
                await secureStorage.saveGatewaySerialNumber(bundle.gatewaySerialNumber);
                
                // Crear una copia de gatewayInfo con las contraseñas guardadas
                final updatedGatewayInfo = gatewayInfo.copyWith(
                  serialNumber: bundle.gatewaySerialNumber,
                  wifi24GPassword: wifi24GPassword ?? gatewayInfo.wifi24GPassword,
                  wifi5GPassword: wifi5GPassword ?? gatewayInfo.wifi5GPassword,
                );
                
                // Actualizar el caché
                _cachedGatewayInfo = updatedGatewayInfo;
                
                // Emitir el estado final después de todas las operaciones asíncronas
                emit(ConnectionLoaded(gatewayInfo: updatedGatewayInfo));
              } catch (e) {
                AppLogger.navError('Error al procesar información del gateway: $e');
                // Si hay un error al procesar, al menos emitimos la información básica del gateway
                emit(ConnectionLoaded(gatewayInfo: gatewayInfo.copyWith(
                  serialNumber: bundle.gatewaySerialNumber
                )));
              }
            },
          );
        },
      );
    } catch (e) {
      AppLogger.navError('Error general en _onGetConnectionInfo: $e');
      emit(ConnectionError(message: e.toString()));
    }
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
  
  Future<void> _onRebootGateway(
    RebootGatewayEvent event,
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
      'Reiniciando gateway con número de serie: ${event.serialNumber}',
    );
    
    final params = RebootGatewayParams(
      serialNumber: event.serialNumber,
    );
    
    final result = await rebootGateway(params);
    
    result.fold(
      (failure) {
        AppLogger.navError(
          'Error al reiniciar el gateway: ${failure.message}',
        );
        emit(ConnectionError(message: failure.message));
      },
      (success) {
        AppLogger.navInfo('Gateway reiniciado con éxito');
        
        // Mantenemos la misma información del gateway ya que el reinicio no cambia sus datos
        if (previousInfo != null) {
          emit(ConnectionLoaded(gatewayInfo: previousInfo));
        } else {
          emit(const ConnectionInitial());
        }
      },
    );
  }
}
