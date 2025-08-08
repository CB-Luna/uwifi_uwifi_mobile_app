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
  
  // Cache to maintain information between reloads
  GatewayInfo? _cachedGatewayInfo;
  DateTime? _lastFetchTime;
  int? _lastCustomerId;
  
  // Tiempo máximo de caché en minutos
  static const int _cacheMaxAgeMinutes = 30;

  ConnectionBloc({
    required this.getCustomerBundle,
    required this.getGatewayInfo,
    required this.updateWifiNetworkName,
    required this.updateWifiPassword,
    required this.rebootGateway,
    required this.secureStorage,
  }) : super(const ConnectionInitial()) {
    on<GetConnectionInfoEvent>(_onGetConnectionInfo);
    on<ForceRefreshConnectionInfoEvent>(_onForceRefreshConnectionInfo);
    on<UpdateWifiNetworkNameEvent>(_onUpdateWifiNetworkName);
    on<UpdateWifiPasswordEvent>(_onUpdateWifiPassword);
    on<RebootGatewayEvent>(_onRebootGateway);
  }

  /// Verifica si debemos usar los datos en caché basado en el tiempo transcurrido
  /// desde la última actualización y si el customerId es el mismo
  bool _shouldUseCachedData(int customerId) {
    // Si no tenemos tiempo de última actualización o customerId, no podemos usar caché
    if (_lastFetchTime == null || _lastCustomerId == null) {
      return false;
    }
    
    // Si el customerId cambió, no podemos usar la caché
    if (_lastCustomerId != customerId) {
      return false;
    }
    
    // Verificar si han pasado menos de _cacheMaxAgeMinutes desde la última actualización
    final now = DateTime.now();
    final difference = now.difference(_lastFetchTime!);
    return difference.inMinutes < _cacheMaxAgeMinutes;
  }

  Future<void> _onForceRefreshConnectionInfo(
    ForceRefreshConnectionInfoEvent event,
    Emitter<ConnectionState> emit,
  ) async {
    try {
      // Siempre mostrar estado de carga pero preservar datos anteriores
      if (_cachedGatewayInfo != null) {
        emit(ConnectionLoading(previousInfo: _cachedGatewayInfo));
      } else {
        emit(const ConnectionLoading());
      }

      AppLogger.navInfo(
        'Forzando actualización de información de conexión para customerId: ${event.customerId}',
      );

      // Step 1: Get customer bundle
      final bundleResult = await getCustomerBundle(event.customerId);

      await bundleResult.fold(
        (failure) async {
          AppLogger.navError(
            'Error getting customer bundle: ${failure.message}',
          );
          
          // Si tenemos información en caché, la usamos a pesar del error
          if (_cachedGatewayInfo != null) {
            emit(ConnectionLoaded(gatewayInfo: _cachedGatewayInfo!));
          } else {
            emit(ConnectionError(message: failure.message));
          }
        },
        (bundles) async {
          if (bundles.isEmpty) {
            AppLogger.navError('No bundles found for customer');
            
            // Si tenemos información en caché, la usamos
            if (_cachedGatewayInfo != null) {
              emit(ConnectionLoaded(gatewayInfo: _cachedGatewayInfo!));
            } else {
              emit(const ConnectionError(message: 'No bundles found'));
            }
            return;
          }

          // Take the first bundle (we assume it's the main one)
          final bundle = bundles.first;
          
          // Check if we have a serial number
          if (bundle.gatewaySerialNumber.isEmpty) {
            AppLogger.navError('Bundle has no serial number');
            
            // Si tenemos información en caché, la usamos
            if (_cachedGatewayInfo != null) {
              emit(ConnectionLoaded(gatewayInfo: _cachedGatewayInfo!));
            } else {
              emit(const ConnectionError(message: 'Device without serial number'));
            }
            return;
          }

          // Step 2: Get gateway information using serial number
          final gatewayInfoResult = await getGatewayInfo(bundle.gatewaySerialNumber);

          await gatewayInfoResult.fold(
            (failure) async {
              AppLogger.navError(
                'Error getting gateway information: ${failure.message}',
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
                  'Gateway information obtained successfully',
                );
                
                // Actualizar la caché y el tiempo de última actualización
                _cachedGatewayInfo = gatewayInfo;
                _lastFetchTime = DateTime.now();
                
                emit(ConnectionLoaded(gatewayInfo: gatewayInfo));
              } catch (e) {
                AppLogger.navError(
                  'Error processing gateway information: $e',
                );
                emit(ConnectionError(message: e.toString()));
              }
            },
          );
        },
      );
    } catch (e) {
      AppLogger.navError('Unexpected error: $e');
      emit(ConnectionError(message: e.toString()));
    }
  }

  Future<void> _onGetConnectionInfo(
    GetConnectionInfoEvent event,
    Emitter<ConnectionState> emit,
  ) async {
    try {
      // Verificar si podemos usar la caché
      final bool useCachedData = _shouldUseCachedData(event.customerId);
      
      // Preserve previous state if it exists
      final currentState = state;
      if (currentState is ConnectionLoaded) {
        _cachedGatewayInfo = currentState.gatewayInfo;
        emit(ConnectionLoading(previousInfo: _cachedGatewayInfo));
      } else if (_cachedGatewayInfo != null) {
        emit(ConnectionLoading(previousInfo: _cachedGatewayInfo));
      } else {
        emit(const ConnectionLoading());
      }

      // Si tenemos datos en caché válidos, los usamos directamente
      if (useCachedData && _cachedGatewayInfo != null) {
        AppLogger.navInfo(
          'Usando información de conexión en caché para customerId: ${event.customerId}',
        );
        emit(ConnectionLoaded(
          gatewayInfo: _cachedGatewayInfo!,
          fromCache: true,
        ));
        return;
      }

      AppLogger.navInfo(
        'Requesting connection information for customerId: ${event.customerId}',
      );

      // Step 1: Get customer bundle
      final bundleResult = await getCustomerBundle(event.customerId);
      
      // Actualizar el último customerId consultado
      _lastCustomerId = event.customerId;

      await bundleResult.fold(
        (failure) async {
          AppLogger.navError(
            'Error getting customer bundle: ${failure.message}',
          );
          emit(ConnectionError(message: failure.message));
        },
        (bundles) async {
          if (bundles.isEmpty) {
            AppLogger.navError('No bundles found for customer');
            emit(const ConnectionError(message: 'No bundles found'));
            return;
          }

          // Take the first bundle (we assume it's the main one)
          final bundle = bundles.first;
          
          // Check if we have a serial number
          if (bundle.gatewaySerialNumber.isEmpty) {
            AppLogger.navError('Bundle has no serial number');
            
            // If we have cached information, we use it
            if (_cachedGatewayInfo != null) {
              emit(ConnectionLoaded(gatewayInfo: _cachedGatewayInfo!));
            } else {
              emit(const ConnectionError(message: 'Device without serial number'));
            }
            return;
          }

          // Step 2: Get gateway information using serial number
          final gatewayInfoResult = await getGatewayInfo(bundle.gatewaySerialNumber);

          await gatewayInfoResult.fold(
            (failure) async {
              AppLogger.navError(
                'Error getting gateway information: ${failure.message}',
              );
              
              // If we have cached information, use it
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
                
                // Actualizar el caché y el tiempo de última actualización
                _cachedGatewayInfo = updatedGatewayInfo;
                _lastFetchTime = DateTime.now();
                
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
      'Updating WiFi network name: ${event.isNetwork24G ? "2.4GHz" : "5GHz"} to ${event.newName}',
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
          'Error updating WiFi network name: ${failure.message}',
        );
        emit(ConnectionError(message: failure.message));
      },
      (success) {
        AppLogger.navInfo('WiFi network name updated successfully');
        
        // Update cached information with the new name
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
      'Updating WiFi password: ${event.isNetwork24G ? "2.4GHz" : "5GHz"}',
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
          'Error updating WiFi password: ${failure.message}',
        );
        emit(ConnectionError(message: failure.message));
      },
      (success) {
        AppLogger.navInfo('WiFi password updated successfully');
        
        // Update cached information with the new password
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
      'Rebooting gateway with serial number: ${event.serialNumber}',
    );
    
    final params = RebootGatewayParams(
      serialNumber: event.serialNumber,
    );
    
    final result = await rebootGateway(params);
    
    result.fold(
      (failure) {
        AppLogger.navError(
          'Error rebooting gateway: ${failure.message}',
        );
        emit(ConnectionError(message: failure.message));
      },
      (success) {
        AppLogger.navInfo('Gateway rebooted successfully');
        
        // We keep the same gateway information since rebooting doesn't change its data
        if (previousInfo != null) {
          emit(ConnectionLoaded(gatewayInfo: previousInfo));
        } else {
          emit(const ConnectionInitial());
        }
      },
    );
  }
}
