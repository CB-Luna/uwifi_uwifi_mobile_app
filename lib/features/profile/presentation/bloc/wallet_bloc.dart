import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/usecases/get_affiliated_users.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final GetAffiliatedUsers getAffiliatedUsers;

  WalletBloc({required this.getAffiliatedUsers}) : super(WalletInitial()) {
    on<GetAffiliatedUsersEvent>(_onGetAffiliatedUsers);
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
        emit(WalletLoaded(affiliatedUsers: affiliatedUsers));
      },
    );
  }
}
