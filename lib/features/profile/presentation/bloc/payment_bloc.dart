import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_logger.dart';
import '../../domain/usecases/get_credit_cards.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final GetCreditCards getCreditCards;

  PaymentBloc({required this.getCreditCards}) : super(PaymentInitial()) {
    on<GetCreditCardsEvent>(_onGetCreditCards);
  }

  Future<void> _onGetCreditCards(
    GetCreditCardsEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    
    AppLogger.navInfo('Obteniendo tarjetas para customerId: ${event.customerId}');
    
    final result = await getCreditCards(event.customerId);
    
    result.fold(
      (failure) {
        AppLogger.navError('Error al obtener tarjetas: ${failure.message}');
        emit(PaymentError(failure.message));
      },
      (cards) {
        AppLogger.navInfo('Tarjetas obtenidas: ${cards.length}');
        emit(PaymentLoaded(cards));
      },
    );
  }
}
