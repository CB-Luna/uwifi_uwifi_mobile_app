import 'package:bloc/bloc.dart';
import '../../domain/usecases/get_current_billing_period.dart';
import '../../domain/usecases/get_customer_balance.dart';
import 'billing_event.dart';
import 'billing_state.dart';

class BillingBloc extends Bloc<BillingEvent, BillingState> {
  final GetCurrentBillingPeriod getCurrentBillingPeriod;
  final GetCustomerBalance getCustomerBalance;

  BillingBloc({
    required this.getCurrentBillingPeriod,
    required this.getCustomerBalance,
  }) : super(BillingInitial()) {
    on<GetBillingPeriodEvent>(_onGetBillingPeriod);
    on<GetCustomerBalanceEvent>(_onGetCustomerBalance);
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
          print('Error al obtener el balance: ${failure.message}');
        },
        (balance) {
          // Actualizamos el estado con el nuevo balance
          emit(currentState.copyWith(balance: balance));
        },
      );
    }
  }
}