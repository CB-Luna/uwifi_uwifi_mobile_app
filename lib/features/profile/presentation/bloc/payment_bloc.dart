import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_logger.dart';
import '../../domain/usecases/delete_credit_card.dart';
import '../../domain/usecases/get_credit_cards.dart';
import '../../domain/usecases/set_default_card.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final GetCreditCards getCreditCards;
  final SetDefaultCard setDefaultCard;
  final DeleteCreditCard deleteCreditCard;

  PaymentBloc({
    required this.getCreditCards,
    required this.setDefaultCard,
    required this.deleteCreditCard,
  }) : super(PaymentInitial()) {
    on<GetCreditCardsEvent>(_onGetCreditCards);
    on<SetDefaultCardEvent>(_onSetDefaultCard);
    on<DeleteCreditCardEvent>(_onDeleteCreditCard);
  }

  Future<void> _onGetCreditCards(
    GetCreditCardsEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());

    AppLogger.navInfo(
      'Obteniendo tarjetas para customerId: ${event.customerId}',
    );

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

  Future<void> _onSetDefaultCard(
    SetDefaultCardEvent event,
    Emitter<PaymentState> emit,
  ) async {
    // Guardar el estado actual para mantener las tarjetas mientras se actualiza
    final currentState = state;

    // Emitir estado de carga pero preservando las tarjetas actuales
    if (currentState is PaymentLoaded) {
      emit(PaymentLoading(previousCards: currentState.creditCards));
    } else {
      emit(const PaymentLoading());
    }

    AppLogger.navInfo(
      'Estableciendo tarjeta ${event.cardId} como predeterminada',
    );

    final result = await setDefaultCard(
      SetDefaultCardParams(customerId: event.customerId, cardId: event.cardId),
    );

    result.fold(
      (failure) {
        AppLogger.navError(
          'Error al establecer tarjeta como predeterminada: ${failure.message}',
        );
        emit(PaymentError(failure.message));
      },
      (_) {
        // Recargar las tarjetas para mostrar los cambios
        _reloadCards(event.customerId, emit);
      },
    );
  }

  Future<void> _onDeleteCreditCard(
    DeleteCreditCardEvent event,
    Emitter<PaymentState> emit,
  ) async {
    // Guardar el estado actual para mantener las tarjetas mientras se actualiza
    final currentState = state;

    // Emitir estado de carga pero preservando las tarjetas actuales
    if (currentState is PaymentLoaded) {
      emit(PaymentLoading(previousCards: currentState.creditCards));
    } else {
      emit(const PaymentLoading());
    }

    AppLogger.navInfo('Eliminando tarjeta ${event.cardId}');

    final result = await deleteCreditCard(
      DeleteCreditCardParams(
        customerId: event.customerId,
        cardId: event.cardId,
      ),
    );

    result.fold(
      (failure) {
        AppLogger.navError('Error al eliminar tarjeta: ${failure.message}');
        emit(PaymentError(failure.message));
      },
      (_) {
        // Recargar las tarjetas para mostrar los cambios
        _reloadCards(event.customerId, emit);
      },
    );
  }

  // Método auxiliar para recargar las tarjetas después de una operación
  void _reloadCards(
    String customerId,
    Emitter<PaymentState> emit,
  ) {
    // En lugar de esperar aquí, emitimos un estado de carga y dejamos que
    // el evento GetCreditCardsEvent maneje la carga de tarjetas
    emit(const PaymentLoading());
    add(GetCreditCardsEvent(customerId));
    
    AppLogger.navInfo('Solicitando recarga de tarjetas para customerId: $customerId');
  }
}
