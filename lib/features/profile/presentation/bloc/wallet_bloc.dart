import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/usecases/get_affiliated_users.dart';
import '../../domain/usecases/get_customer_points.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final GetAffiliatedUsers getAffiliatedUsers;
  final GetCustomerPoints getCustomerPoints;

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
    emit(WalletLoading());
    
    AppLogger.navInfo(
      'Solicitando usuarios afiliados para customerId: ${event.customerId}',
    );
    
    final result = await getAffiliatedUsers(event.customerId);
    
    result.fold(
      (failure) {
        AppLogger.navError('Error al obtener usuarios afiliados: ${failure.message}');
        emit(WalletError(message: failure.message));
      },
      (affiliatedUsers) {
        AppLogger.navInfo('Usuarios afiliados obtenidos: ${affiliatedUsers.length}');
        final currentState = state;
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
    // No emitimos WalletLoading aquí para evitar reemplazar el estado actual
    // si ya tenemos datos de usuarios afiliados
    final currentState = state;
    if (currentState is! WalletLoaded) {
      emit(WalletLoading());
    }
    
    AppLogger.navInfo(
      'Solicitando puntos del cliente para customerId: ${event.customerId}',
    );
    
    final result = await getCustomerPoints(event.customerId);
    
    result.fold(
      (failure) {
        AppLogger.navError('Error al obtener puntos del cliente: ${failure.message}');
        // Solo emitimos error si no tenemos datos previos
        if (currentState is! WalletLoaded) {
          emit(WalletError(message: failure.message));
        }
      },
      (customerPoints) {
        AppLogger.navInfo('Puntos del cliente obtenidos: ${customerPoints.totalPointsEarned}');
        if (currentState is WalletLoaded) {
          emit(currentState.copyWith(customerPoints: customerPoints));
        } else {
          emit(WalletLoaded(
            affiliatedUsers: const [],
            customerPoints: customerPoints,
          ));
        }
      },
    );
  }
}
