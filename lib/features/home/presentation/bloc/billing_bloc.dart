import 'package:bloc/bloc.dart';
import 'package:uwifiapp/core/utils/app_logger.dart';

import '../../domain/usecases/create_manual_billing.dart';
import '../../domain/usecases/get_current_billing_period.dart';
import '../../domain/usecases/get_customer_balance.dart';
import '../../domain/usecases/update_automatic_charge.dart';
import 'billing_event.dart';
import 'billing_state.dart';

class BillingBloc extends Bloc<BillingEvent, BillingState> {
  final GetCurrentBillingPeriod getCurrentBillingPeriod;
  final GetCustomerBalance getCustomerBalance;
  final UpdateAutomaticCharge updateAutomaticCharge;
  final CreateManualBilling createManualBilling;

  BillingBloc({
    required this.getCurrentBillingPeriod,
    required this.getCustomerBalance,
    required this.updateAutomaticCharge,
    required this.createManualBilling,
  }) : super(BillingInitial()) {
    on<GetBillingPeriodEvent>(_onGetBillingPeriod);
    on<GetCustomerBalanceEvent>(_onGetCustomerBalance);
    on<UpdateAutomaticChargeEvent>(_onUpdateAutomaticCharge);
    on<CreateManualBillingEvent>(_onCreateManualBilling);
  }

  Future<void> _onGetBillingPeriod(
    GetBillingPeriodEvent event,
    Emitter<BillingState> emit,
  ) async {
    emit(BillingLoading());

    final result = await getCurrentBillingPeriod(event.customerId);

    result.fold(
      (failure) => emit(BillingError(message: failure.message)),
      (billingPeriod) => emit(BillingLoaded(billingPeriod: billingPeriod)),
    );

    // Después de cargar el período de facturación, también cargamos el balance
    if (state is BillingLoaded) {
      add(GetCustomerBalanceEvent(customerId: event.customerId));
    }
  }

  Future<void> _onGetCustomerBalance(
    GetCustomerBalanceEvent event,
    Emitter<BillingState> emit,
  ) async {
    // Solo actualizamos el balance si ya tenemos un estado cargado
    if (state is BillingLoaded) {
      final currentState = state as BillingLoaded;

      final result = await getCustomerBalance(event.customerId);

      result.fold(
        (failure) {
          // Si hay un error al obtener el balance, mantenemos el estado actual
          // pero podríamos loguear el error
          AppLogger.navError('Error al obtener el balance: ${failure.message}');
        },
        (balance) {
          // Actualizamos el estado con el nuevo balance
          emit(currentState.copyWith(balance: balance));
        },
      );
    }
  }
  
  Future<void> _onUpdateAutomaticCharge(
    UpdateAutomaticChargeEvent event,
    Emitter<BillingState> emit,
  ) async {
    // Solo actualizamos el estado de AutoPay si ya tenemos un estado cargado
    if (state is BillingLoaded) {
      final currentState = state as BillingLoaded;
      
      // Optimistic update - actualizamos inmediatamente la UI
      emit(currentState.copyWith(automaticCharge: event.value));
      
      AppLogger.navInfo(
        'Actualizando AutoPay para customerId: ${event.customerId}, valor: ${event.value}',
      );
      
      final params = UpdateAutomaticChargeParams(
        customerId: event.customerId,
        value: event.value,
      );
      
      final result = await updateAutomaticCharge(params);
      
      result.fold(
        (failure) {
          // Si hay un error, revertimos al estado anterior
          AppLogger.navError('Error al actualizar AutoPay: ${failure.message}');
          emit(currentState.copyWith(automaticCharge: !event.value));
        },
        (success) {
          // La actualización fue exitosa, mantenemos el estado actualizado
          AppLogger.navInfo('AutoPay actualizado exitosamente');
        },
      );
    }
  }

  Future<void> _onCreateManualBilling(
    CreateManualBillingEvent event,
    Emitter<BillingState> emit,
  ) async {
    emit(BillingProcessing());
    
    AppLogger.navInfo(
      'Creando facturación manual para customerId: ${event.customerId}, fecha: ${event.billingDate}, descuento: ${event.discount}, autoPay: ${event.autoPayment}',
    );
    
    final params = CreateManualBillingParams(
      customerId: event.customerId,
      billingDate: event.billingDate,
      discount: event.discount,
      autoPayment: event.autoPayment,
    );
    
    final result = await createManualBilling(params);
    
    result.fold(
      (failure) {
        AppLogger.navError('Error al crear facturación manual: ${failure.message}');
        emit(BillingError(message: failure.message));
      },
      (success) {
        AppLogger.navInfo('Facturación manual creada exitosamente');
        emit(BillingSuccess(message: 'Pago procesado exitosamente'));
        
        // Después de crear la facturación, recargar el periodo de facturación
        // si tenemos un customerId en formato string
        final customerIdStr = event.customerId.toString();
        add(GetBillingPeriodEvent(customerId: customerIdStr));
      },
    );
  }
}
