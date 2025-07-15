import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/affiliated_user.dart';
import '../../domain/entities/customer_points.dart';
import '../../domain/usecases/get_affiliated_users.dart';
import '../../domain/usecases/get_customer_points.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final GetAffiliatedUsers getAffiliatedUsers;
  final GetCustomerPoints getCustomerPoints;
  
  // Cache de datos para evitar pérdida de información
  List<AffiliatedUser>? _cachedAffiliatedUsers;
  CustomerPoints? _cachedCustomerPoints;

  WalletBloc({
    required this.getAffiliatedUsers,
    required this.getCustomerPoints,
  }) : super(WalletInitial()) {
    on<GetAffiliatedUsersEvent>(_onGetAffiliatedUsers);
    on<GetCustomerPointsEvent>(_onGetCustomerPoints);
  }

  Future<void> _onGetAffiliatedUsers(
    GetAffiliatedUsersEvent event,
    Emitter<WalletState> emit,
  ) async {
    // Preservamos el estado actual si ya está cargado
    final currentState = state;
    
    // Si tenemos usuarios en caché, los usamos durante la carga
    if (currentState is! WalletLoaded) {
      if (_cachedAffiliatedUsers != null && _cachedAffiliatedUsers!.isNotEmpty) {
        // Usar el caché durante la carga
        emit(WalletLoading(affiliatedUsers: _cachedAffiliatedUsers));
      } else {
        emit(const WalletLoading());
      }
    } else {
      // Si ya tenemos datos, emitimos un estado de carga pero preservando los datos anteriores
      emit(WalletLoading.fromLoaded(currentState));
      // Actualizar el caché con los datos actuales
      _cachedAffiliatedUsers = currentState.affiliatedUsers;
    }

    AppLogger.navInfo(
      'Solicitando usuarios afiliados para customerId: ${event.customerId}',
    );

    final result = await getAffiliatedUsers(event.customerId);

    result.fold(
      (failure) {
        AppLogger.navError(
          'Error al obtener usuarios afiliados: ${failure.message}',
        );
        // Si teníamos un estado cargado previamente, lo restauramos en lugar de mostrar error
        if (currentState is WalletLoaded) {
          emit(currentState);
        } else if (_cachedAffiliatedUsers != null && _cachedAffiliatedUsers!.isNotEmpty) {
          // Usar el caché si hay un error y no hay estado previo
          emit(WalletLoaded(affiliatedUsers: _cachedAffiliatedUsers!));
        } else {
          emit(WalletError(message: failure.message));
        }
      },
      (affiliatedUsers) {
        AppLogger.navInfo(
          'Usuarios afiliados obtenidos: ${affiliatedUsers.length}',
        );
        // Actualizar el caché con los nuevos datos
        _cachedAffiliatedUsers = affiliatedUsers;
        
        if (currentState is WalletLoaded) {
          emit(currentState.copyWith(affiliatedUsers: affiliatedUsers));
        } else {
          emit(WalletLoaded(affiliatedUsers: affiliatedUsers));
        }
      },
    );
  }

  Future<void> _onGetCustomerPoints(
    GetCustomerPointsEvent event,
    Emitter<WalletState> emit,
  ) async {
    // Preservamos el estado actual si ya está cargado
    final currentState = state;
    
    // Si tenemos datos en caché, los usamos durante la carga
    if (currentState is! WalletLoaded) {
      // Determinar qué datos tenemos en caché
      final hasAffiliatedUsers = _cachedAffiliatedUsers != null && _cachedAffiliatedUsers!.isNotEmpty;
      final hasPoints = _cachedCustomerPoints != null;
      
      if (hasAffiliatedUsers || hasPoints) {
        // Usar el caché durante la carga
        emit(WalletLoading(
          affiliatedUsers: _cachedAffiliatedUsers,
          customerPoints: _cachedCustomerPoints,
        ));
      } else {
        emit(const WalletLoading());
      }
    } else {
      // Si ya tenemos datos, emitimos un estado de carga pero preservando los datos anteriores
      emit(WalletLoading.fromLoaded(currentState));
      // Actualizar el caché con los datos actuales
      _cachedAffiliatedUsers = currentState.affiliatedUsers;
      _cachedCustomerPoints = currentState.customerPoints;
    }

    AppLogger.navInfo(
      'Solicitando puntos del cliente para customerId: ${event.customerId}',
    );

    final result = await getCustomerPoints(event.customerId);

    result.fold(
      (failure) {
        AppLogger.navError(
          'Error al obtener puntos del cliente: ${failure.message}',
        );
        // Si teníamos un estado cargado previamente, lo restauramos en lugar de mostrar error
        if (currentState is WalletLoaded) {
          emit(currentState);
        } else if (_cachedCustomerPoints != null || (_cachedAffiliatedUsers != null && _cachedAffiliatedUsers!.isNotEmpty)) {
          // Usar el caché si hay un error y no hay estado previo
          emit(WalletLoaded(
            affiliatedUsers: _cachedAffiliatedUsers ?? const [],
            customerPoints: _cachedCustomerPoints,
          ));
        } else {
          emit(WalletError(message: failure.message));
        }
      },
      (customerPoints) {
        AppLogger.navInfo(
          'Puntos del cliente obtenidos: ${customerPoints.totalPointsEarned}',
        );
        // Actualizar el caché con los nuevos datos
        _cachedCustomerPoints = customerPoints;
        
        if (currentState is WalletLoaded) {
          emit(currentState.copyWith(customerPoints: customerPoints));
        } else {
          emit(
            WalletLoaded(
              affiliatedUsers: _cachedAffiliatedUsers ?? const [],
              customerPoints: customerPoints,
            ),
          );
        }
      },
    );
  }
}
