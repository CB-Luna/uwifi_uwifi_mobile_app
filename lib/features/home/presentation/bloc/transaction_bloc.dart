import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_logger.dart';
import '../../domain/usecases/get_transaction_history.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactionHistory getTransactionHistory;

  TransactionBloc({required this.getTransactionHistory})
      : super(TransactionInitial()) {
    on<GetTransactionHistoryEvent>(_onGetTransactionHistory);
  }

  Future<void> _onGetTransactionHistory(
    GetTransactionHistoryEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());

    AppLogger.navInfo(
      'Obteniendo historial de transacciones para customerId: ${event.customerId}',
    );

    final result = await getTransactionHistory(event.customerId);

    result.fold(
      (failure) {
        AppLogger.navError(
          'Error al obtener historial de transacciones: ${failure.message}',
        );
        emit(TransactionError(failure.message));
      },
      (transactions) {
        AppLogger.navInfo(
          'Historial de transacciones obtenido: ${transactions.length} transacciones',
        );
        emit(TransactionLoaded(transactions));
      },
    );
  }
}
