import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/usecases/reset_password.dart';
import 'reset_password_event.dart';
import 'reset_password_state.dart';

class ResetPasswordBloc extends Bloc<ResetPasswordEvent, ResetPasswordState> {
  final ResetPassword resetPassword;

  ResetPasswordBloc({required this.resetPassword}) : super(ResetPasswordInitial()) {
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<ResetPasswordReset>(_onResetPasswordReset);
  }

  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<ResetPasswordState> emit,
  ) async {
    emit(ResetPasswordLoading());
    
    AppLogger.navInfo('Solicitando restablecimiento de contraseña para: ${event.email}');
    
    final result = await resetPassword(event.email);
    
    result.fold(
      (failure) {
        AppLogger.navError('Error al restablecer contraseña: ${failure.message}');
        emit(ResetPasswordError(failure.message));
      },
      (_) {
        AppLogger.navInfo('Solicitud de restablecimiento de contraseña enviada con éxito');
        emit(ResetPasswordSuccess());
      },
    );
  }

  void _onResetPasswordReset(
    ResetPasswordReset event,
    Emitter<ResetPasswordState> emit,
  ) {
    emit(ResetPasswordInitial());
  }
}
